package services

import (
	"context"
	"fmt"
	"time"

	"cloud.google.com/go/firestore"
	"github.com/agungknwn/ngirit_backend/internal/config"
	"github.com/agungknwn/ngirit_backend/internal/models"
	"github.com/agungknwn/ngirit_backend/internal/utils"
)

//// ==================== HELPER FUNCTIONS FOR SUMMARIES ====================

//	func UpdateDailySummaryAfterAdd(userId string, expense models.Expense) {
//		summaryId := "daily_" + expense.Date
//		summaryRef := config.Client.Collection("users").Doc(userId).
//			Collection("summaries").Doc(summaryId)
//
//		// Use transaction for atomic updates
//		config.Client.RunTransaction(config.Ctx, func(ctx context.Context, tx *firestore.Transaction) error {
//			categoryPath := "categoryBreakdown." + expense.Category
//
//			tx.Set(summaryRef, map[string]interface{}{
//				"type":          "daily",
//				"date":          expense.Date,
//				"totalExpenses": firestore.Increment(expense.Amount),
//				"expenseCount":  firestore.Increment(1),
//				categoryPath:    firestore.Increment(expense.Amount),
//				"updatedAt":     time.Now(),
//			}, firestore.MergeAll)
//
//			return nil
//		})
//	}
func UpdateDailySummaryAfterAdd(userId string, expense models.Expense) {
	summaryId := "daily_" + expense.Date
	summaryRef := config.Client.Collection("users").Doc(userId).
		Collection("summaries").Doc(summaryId)

	config.Client.RunTransaction(config.Ctx, func(ctx context.Context, tx *firestore.Transaction) error {
		var currentTotal float64
		categoryBreakdown := make(map[string]float64) // decrypted map

		// Read existing summary
		doc, err := tx.Get(summaryRef)
		if err == nil {
			var summary models.DailySummary
			if err := doc.DataTo(&summary); err == nil {
				// Decrypt total
				if summary.EncryptedTotalExpense != "" {
					currentTotal, _ = utils.DecryptFloat64(summary.EncryptedTotalExpense)
				}
				// Decrypt each category
				for category, encryptedVal := range summary.EncryptedCategoryBreakdown {
					decrypted, err := utils.DecryptFloat64(encryptedVal)
					if err == nil {
						categoryBreakdown[category] = decrypted
					}
				}
			}
		}

		// Update values
		newTotal := currentTotal + expense.Amount
		categoryBreakdown[expense.Category] += expense.Amount

		// Encrypt total
		encryptedTotal, err := utils.EncryptFloat64(newTotal)
		if err != nil {
			return fmt.Errorf("failed to encrypt total: %w", err)
		}

		// Encrypt each category
		encryptedCategoryBreakdown := make(map[string]interface{})
		for category, amount := range categoryBreakdown {
			encryptedVal, err := utils.EncryptFloat64(amount)
			if err != nil {
				return fmt.Errorf("failed to encrypt category %s: %w", category, err)
			}
			encryptedCategoryBreakdown[category] = encryptedVal
		}

		tx.Set(summaryRef, map[string]interface{}{
			"type":              "daily",
			"date":              expense.Date,
			"totalExpenses":     encryptedTotal,
			"expenseCount":      firestore.Increment(1),
			"categoryBreakdown": encryptedCategoryBreakdown, // full encrypted map
			"updatedAt":         time.Now(),
		}, firestore.MergeAll)

		return nil
	})
}

//	func UpdateMonthlySummaryAfterAdd(userId string, expense models.Expense) {
//		summaryId := "monthly_" + expense.MonthYear
//		summaryRef := config.Client.Collection("users").Doc(userId).
//			Collection("summaries").Doc(summaryId)
//
//		config.Client.RunTransaction(config.Ctx, func(ctx context.Context, tx *firestore.Transaction) error {
//			categoryPath := "categoryBreakdown." + expense.Category
//
//			tx.Set(summaryRef, map[string]interface{}{
//				"type":          "monthly",
//				"monthYear":     expense.MonthYear,
//				"totalExpenses": firestore.Increment(expense.Amount),
//				"expenseCount":  firestore.Increment(1),
//				categoryPath:    firestore.Increment(expense.Amount),
//				"updatedAt":     time.Now(),
//			}, firestore.MergeAll)
//
//			return nil
//		})
//	}
func UpdateMonthlySummaryAfterAdd(userId string, expense models.Expense) {
	summaryId := "monthly_" + expense.MonthYear
	summaryRef := config.Client.Collection("users").Doc(userId).
		Collection("summaries").Doc(summaryId)

	config.Client.RunTransaction(config.Ctx, func(ctx context.Context, tx *firestore.Transaction) error {
		var currentTotal float64
		categoryBreakdown := make(map[string]float64)

		// Read existing summary
		doc, err := tx.Get(summaryRef)
		if err == nil {
			var summary models.MonthlySummary
			if err := doc.DataTo(&summary); err == nil {
				//dcrypt total monthly
				if summary.EncryptedTotalExpense != "" {
					currentTotal, _ = utils.DecryptFloat64(summary.EncryptedTotalExpense)
				}
				//decrypt category monthly
				for category, encryptedVal := range summary.EncryptedCategoryBreakdown {
					decrypted, err := utils.DecryptFloat64(encryptedVal)
					if err == nil {
						categoryBreakdown[category] = decrypted
					}
				}
			}
		}

		// Add new amount & encrypt
		encryptedTotal, err := utils.EncryptFloat64(currentTotal + expense.Amount)
		if err != nil {
			return fmt.Errorf("failed to encrypt total: %w", err)
		}

		// update values
		categoryBreakdown[expense.Category] += expense.Amount
		encryptedCategoryBreakdown := make(map[string]interface{})
		for category, amount := range categoryBreakdown {
			encryptedVal, err := utils.EncryptFloat64(amount)
			if err != nil {
				return fmt.Errorf("failed to encrypt category %s: %w", category, err)
			}
			encryptedCategoryBreakdown[category] = encryptedVal
		}

		tx.Set(summaryRef, map[string]interface{}{
			"type":              "monthly",
			"monthYear":         expense.MonthYear,
			"totalExpenses":     encryptedTotal,
			"expenseCount":      firestore.Increment(1),
			"categoryBreakdown": encryptedCategoryBreakdown,
			"updatedAt":         time.Now(),
		}, firestore.MergeAll)
		return nil
	})
}

func UpdateSummariesAfterUpdate(userId string, oldExpense, newExpense models.Expense) {
	// Subtract old values
	UpdateDailySummaryAfterDelete(userId, oldExpense)
	UpdateMonthlySummaryAfterDelete(userId, oldExpense)

	// Add new values
	UpdateDailySummaryAfterAdd(userId, newExpense)
	UpdateMonthlySummaryAfterAdd(userId, newExpense)
}

func UpdateSummariesAfterDelete(userId string, expense models.Expense) {
	UpdateDailySummaryAfterDelete(userId, expense)
	UpdateMonthlySummaryAfterDelete(userId, expense)
}

//	func UpdateDailySummaryAfterDelete(userId string, expense models.Expense) {
//		summaryId := "daily_" + expense.Date
//		summaryRef := config.Client.Collection("users").Doc(userId).
//			Collection("summaries").Doc(summaryId)
//
//		config.Client.RunTransaction(config.Ctx, func(ctx context.Context, tx *firestore.Transaction) error {
//			categoryPath := "categoryBreakdown." + expense.Category
//
//			tx.Set(summaryRef, map[string]interface{}{
//				"totalExpenses": firestore.Increment(-expense.Amount),
//				"expenseCount":  firestore.Increment(-1),
//				categoryPath:    firestore.Increment(-expense.Amount),
//				"updatedAt":     time.Now(),
//			}, firestore.MergeAll)
//
//			return nil
//		})
//	}
//
//	func UpdateMonthlySummaryAfterDelete(userId string, expense models.Expense) {
//		summaryId := "monthly_" + expense.MonthYear
//		summaryRef := config.Client.Collection("users").Doc(userId).
//			Collection("summaries").Doc(summaryId)
//
//		config.Client.RunTransaction(config.Ctx, func(ctx context.Context, tx *firestore.Transaction) error {
//			categoryPath := "categoryBreakdown." + expense.Category
//
//			tx.Set(summaryRef, map[string]interface{}{
//				"totalExpenses": firestore.Increment(-expense.Amount),
//				"expenseCount":  firestore.Increment(-1),
//				categoryPath:    firestore.Increment(-expense.Amount),
//				"updatedAt":     time.Now(),
//			}, firestore.MergeAll)
//
//			return nil
//		})
//	}
func UpdateDailySummaryAfterDelete(userId string, expense models.Expense) {
	summaryId := "daily_" + expense.Date
	summaryRef := config.Client.Collection("users").Doc(userId).
		Collection("summaries").Doc(summaryId)

	config.Client.RunTransaction(config.Ctx, func(ctx context.Context, tx *firestore.Transaction) error {
		var currentTotal float64
		categoryBreakdown := make(map[string]float64) // decrypted map

		doc, err := tx.Get(summaryRef)
		if err == nil {
			var summary models.DailySummary
			if err := doc.DataTo(&summary); err == nil {

				// decrypt total
				if summary.EncryptedTotalExpense != "" {
					currentTotal, _ = utils.DecryptFloat64(summary.EncryptedTotalExpense)
				}
				// Decrypt each category
				for category, encryptedVal := range summary.EncryptedCategoryBreakdown {
					decrypted, err := utils.DecryptFloat64(encryptedVal)
					if err == nil {
						categoryBreakdown[category] = decrypted
					}
				}
			}
		}

		// Subtract
		encryptedTotal, err := utils.EncryptFloat64(currentTotal - expense.Amount)
		if err != nil {
			return fmt.Errorf("failed to encrypt total: %w", err)
		}

		// update values (Subtract)
		categoryBreakdown[expense.Category] -= expense.Amount

		// Encrypt each category
		encryptedCategoryBreakdown := make(map[string]interface{ any })
		for category, amount := range categoryBreakdown {
			encryptedVal, err := utils.EncryptFloat64(amount)
			if err != nil {
				return fmt.Errorf("failed to encrypt category %s: %w", category, err)
			}
			encryptedCategoryBreakdown[category] = encryptedVal
		}

		tx.Set(summaryRef, map[string]interface{ any }{
			"totalExpenses":     encryptedTotal,
			"expenseCount":      firestore.Increment(-1),
			"categoryBreakdown": encryptedCategoryBreakdown,
			"updatedAt":         time.Now(),
		}, firestore.MergeAll)
		return nil
	})
}

func UpdateMonthlySummaryAfterDelete(userId string, expense models.Expense) {
	summaryId := "monthly_" + expense.MonthYear
	summaryRef := config.Client.Collection("users").Doc(userId).
		Collection("summaries").Doc(summaryId)

	config.Client.RunTransaction(config.Ctx, func(ctx context.Context, tx *firestore.Transaction) error {
		var currentTotal float64
		categoryBreakdown := make(map[string]float64)

		doc, err := tx.Get(summaryRef)
		if err == nil {
			var summary models.MonthlySummary
			if err := doc.DataTo(&summary); err == nil {

				//dcrypt total monthly
				if summary.EncryptedTotalExpense != "" {
					currentTotal, _ = utils.DecryptFloat64(summary.EncryptedTotalExpense)
				}
				//decrypt category monthly
				for category, encryptedVal := range summary.EncryptedCategoryBreakdown {
					decrypted, err := utils.DecryptFloat64(encryptedVal)
					if err == nil {
						categoryBreakdown[category] = decrypted
					}
				}
			}
		}

		// Subtract
		encryptedTotal, err := utils.EncryptFloat64(currentTotal - expense.Amount)
		if err != nil {
			return fmt.Errorf("failed to encrypt total: %w", err)
		}

		// update values
		categoryBreakdown[expense.Category] -= expense.Amount
		encryptedCategoryBreakdown := make(map[string]interface{})
		for category, amount := range categoryBreakdown {
			encryptedVal, err := utils.EncryptFloat64(amount)
			if err != nil {
				return fmt.Errorf("failed to encrypt category %s: %w", category, err)
			}
			encryptedCategoryBreakdown[category] = encryptedVal
		}
		tx.Set(summaryRef, map[string]interface{}{
			"totalExpenses":     encryptedTotal,
			"expenseCount":      firestore.Increment(-1),
			"categoryBreakdown": encryptedCategoryBreakdown,
			"updatedAt":         time.Now(),
		}, firestore.MergeAll)
		return nil
	})
}
