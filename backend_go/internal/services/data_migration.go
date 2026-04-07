package services

import (
	"cloud.google.com/go/firestore"
	"fmt"
	"github.com/agungknwn/ngirit_backend/internal/config"
	"github.com/agungknwn/ngirit_backend/internal/utils"
	"log"
	// "strings"
	"time"
)

func MigrateSummariesToEncrypted(userId string) error {
	summariesRef := config.Client.Collection("users").Doc(userId).Collection("summaries")

	docs, err := summariesRef.Documents(config.Ctx).GetAll()
	if err != nil {
		return fmt.Errorf("failed to fetch summaries: %w", err)
	}

	for _, doc := range docs {
		rawData := doc.Data()

		// Skip if already encrypted (string type = already migrated)
		existingTotal := rawData["totalExpenses"]
		if _, isString := existingTotal.(string); isString {
			log.Printf("Skipping %s — already encrypted", doc.Ref.ID)
			continue
		}

		// Get plain float value
		var plainTotal float64
		switch v := existingTotal.(type) {
		case float64:
			plainTotal = v
		case int64:
			plainTotal = float64(v)
		default:
			log.Printf("Skipping %s — unexpected type %T", doc.Ref.ID, existingTotal)
			continue
		}

		// Encrypt
		encryptedTotal, err := utils.EncryptFloat64(plainTotal)
		if err != nil {
			return fmt.Errorf("failed to encrypt %s: %w", doc.Ref.ID, err)
		}

		// Update only the totalExpenses field
		_, err = doc.Ref.Update(config.Ctx, []firestore.Update{
			{Path: "totalExpenses", Value: encryptedTotal},
		})
		if err != nil {
			return fmt.Errorf("failed to update %s: %w", doc.Ref.ID, err)
		}

		log.Printf("Migrated %s: %.2f → encrypted", doc.Ref.ID, plainTotal)
	}

	return nil
}

func MigrateSummariesToEncryptedV2(userId string) error {
	summariesRef := config.Client.Collection("users").Doc(userId).Collection("summaries")
	docs, err := summariesRef.Documents(config.Ctx).GetAll()
	if err != nil {
		return fmt.Errorf("failed to fetch summaries: %w", err)
	}

	for _, doc := range docs {
		raw := doc.Data()

		// --- Migrate totalExpenses ---
		var totalExpenses float64
		switch v := raw["totalExpenses"].(type) {
		case string:
			// Already encrypted, decrypt to get value
			decrypted, err := utils.DecryptFloat64(v)
			if err != nil {
				log.Printf("Failed to decrypt totalExpenses in %s: %v", doc.Ref.ID, err)
				continue
			}
			totalExpenses = decrypted
		case float64:
			totalExpenses = v
		case int64:
			totalExpenses = float64(v)
		default:
			log.Printf("Unexpected totalExpenses type in %s: %T", doc.Ref.ID, v)
		}

		encryptedTotal, err := utils.EncryptFloat64(totalExpenses)
		if err != nil {
			log.Printf("Failed to encrypt totalExpenses in %s: %v", doc.Ref.ID, err)
			continue
		}

		// --- Migrate categoryBreakdown ---
		// doc.Data() merges flat fields into nested map automatically,
		// so raw["categoryBreakdown"] already contains ALL categories
		encryptedBreakdown := make(map[string]interface{})

		if rawBreakdown, ok := raw["categoryBreakdown"].(map[string]interface{}); ok {
			for category, val := range rawBreakdown {
				switch v := val.(type) {
				case string:
					// Already encrypted
					decrypted, err := utils.DecryptFloat64(v)
					if err != nil {
						log.Printf("Failed to decrypt category %s in %s: %v", category, doc.Ref.ID, err)
						continue
					}
					encryptedVal, err := utils.EncryptFloat64(decrypted)
					if err != nil {
						log.Printf("Failed to re-encrypt category %s in %s: %v", category, doc.Ref.ID, err)
						continue
					}
					encryptedBreakdown[category] = encryptedVal
				case float64:
					encryptedVal, err := utils.EncryptFloat64(v)
					if err != nil {
						log.Printf("Failed to encrypt category %s in %s: %v", category, doc.Ref.ID, err)
						continue
					}
					encryptedBreakdown[category] = encryptedVal
				case int64:
					encryptedVal, err := utils.EncryptFloat64(float64(v))
					if err != nil {
						log.Printf("Failed to encrypt category %s in %s: %v", category, doc.Ref.ID, err)
						continue
					}
					encryptedBreakdown[category] = encryptedVal
				}
			}
		}

		// Build clean document — use Set (full overwrite) to wipe ALL old flat fields
		cleanDoc := map[string]interface{}{
			"type":              raw["type"],
			"expenseCount":      raw["expenseCount"],
			"totalExpenses":     encryptedTotal,
			"categoryBreakdown": encryptedBreakdown,
			"updatedAt":         time.Now(),
		}

		// Add date or monthYear depending on summary type
		if raw["type"] == "daily" {
			cleanDoc["date"] = raw["date"]
		} else if raw["type"] == "monthly" {
			cleanDoc["monthYear"] = raw["monthYear"]
		}

		// Full overwrite — this wipes categoryBreakdown.Food, categoryBreakdown.Bills etc.
		if _, err := doc.Ref.Set(config.Ctx, cleanDoc); err != nil {
			log.Printf("Failed to overwrite %s: %v", doc.Ref.ID, err)
			continue
		}

		log.Printf("Migrated %s (%v)", doc.Ref.ID, raw["type"])
	}

	return nil
}
