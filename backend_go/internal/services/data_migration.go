package services

import (
	"cloud.google.com/go/firestore"
	"fmt"
	"github.com/agungknwn/ngirit_backend/internal/config"
	"github.com/agungknwn/ngirit_backend/internal/utils"
	"log"
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
