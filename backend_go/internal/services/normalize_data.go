package services

import (
	"cloud.google.com/go/firestore"
	"fmt"
	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/status"
	"time"

	"github.com/agungknwn/ngirit_backend/internal/config"
	"github.com/agungknwn/ngirit_backend/internal/models"
	"github.com/agungknwn/ngirit_backend/internal/utils"
)

func NormalizeExpensesByExchangeRate(userId, monthYear string, exchangeRate float64) error {
	docs, err := config.Client.Collection("users").Doc(userId).
		Collection("expenses").Where("monthYear", "==", monthYear).
		Documents(config.Ctx).GetAll()
	if err != nil {
		return fmt.Errorf("failed to fetch expenses: %w", err)
	}

	bulkWriter := config.Client.BulkWriter(config.Ctx)

	for _, doc := range docs {
		var expense models.Expense
		if err := doc.DataTo(&expense); err != nil {
			return fmt.Errorf("failed to parse expense %s: %w", doc.Ref.ID, err)
		}

		// Decrypt current amount
		decryptedAmount, err := utils.DecryptFloat64(expense.EncryptedAmount)
		if err != nil {
			return fmt.Errorf("failed to decrypt expense %s: %w", doc.Ref.ID, err)
		}

		// Multiply by exchange rate
		normalizedAmount := decryptedAmount * exchangeRate

		// Re-encrypt normalized amount
		reEncryptedAmount, err := utils.EncryptFloat64(normalizedAmount)
		if err != nil {
			return fmt.Errorf("failed to encrypt expense %s: %w", doc.Ref.ID, err)
		}

		_, err = bulkWriter.Update(doc.Ref, []firestore.Update{
			{Path: "amount", Value: reEncryptedAmount},
			{Path: "updatedAt", Value: time.Now()},
		})
		if err != nil {
			return fmt.Errorf("failed to queue update for expense %s: %w", doc.Ref.ID, err)
		}
	}

	bulkWriter.Flush()
	return nil
}

func NormalizeMonthlySummary(userId, monthYear string, exchangeRate float64) error {
	summaryId := "monthly_" + monthYear
	ref := config.Client.Collection("users").Doc(userId).
		Collection("summaries").Doc(summaryId)

	doc, err := ref.Get(config.Ctx)
	if err != nil {
		// No summary yet for this month — nothing to normalize
		if status.Code(err) == codes.NotFound {
			return nil
		}
		return fmt.Errorf("failed to fetch summary: %w", err)
	}

	raw := doc.Data()

	// --- Decrypt and normalize totalExpenses ---
	var normalizedTotal float64
	switch v := raw["totalExpenses"].(type) {
	case string:
		decrypted, err := utils.DecryptFloat64(v)
		if err != nil {
			return fmt.Errorf("failed to decrypt totalExpenses: %w", err)
		}
		normalizedTotal = decrypted * exchangeRate
	case float64:
		normalizedTotal = v * exchangeRate
	case int64:
		normalizedTotal = float64(v) * exchangeRate
	}

	encryptedTotal, err := utils.EncryptFloat64(normalizedTotal)
	if err != nil {
		return fmt.Errorf("failed to encrypt totalExpenses: %w", err)
	}

	// --- Decrypt and normalize categoryBreakdown ---
	normalizedBreakdown := make(map[string]string)
	if rawBreakdown, ok := raw["categoryBreakdown"].(map[string]interface{}); ok {
		for category, val := range rawBreakdown {
			var amount float64
			switch v := val.(type) {
			case string:
				decrypted, err := utils.DecryptFloat64(v)
				if err != nil {
					return fmt.Errorf("failed to decrypt category %s: %w", category, err)
				}
				amount = decrypted
			case float64:
				amount = v
			case int64:
				amount = float64(v)
			}

			encryptedCategory, err := utils.EncryptFloat64(amount * exchangeRate)
			if err != nil {
				return fmt.Errorf("failed to encrypt category %s: %w", category, err)
			}
			normalizedBreakdown[category] = encryptedCategory
		}
	}

	// --- Normalize plain float fields ---
	var summary models.MonthlySummary
	if err := doc.DataTo(&summary); err != nil {
		return fmt.Errorf("failed to parse summary: %w", err)
	}

	_, err = ref.Set(config.Ctx, map[string]interface{}{
		"totalExpenses":     encryptedTotal,
		"categoryBreakdown": normalizedBreakdown,
		"remainingBudget":   summary.RemainingBudget * exchangeRate,
		"savingsAmount":     summary.SavingsAmount * exchangeRate,
		"dailyAverage":      summary.DailyAverage * exchangeRate,
		"updatedAt":         time.Now(),
	}, firestore.MergeAll)
	if err != nil {
		return fmt.Errorf("failed to update summary: %w", err)
	}

	return nil
}
