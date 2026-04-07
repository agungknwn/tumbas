package handlers

import (
	"github.com/agungknwn/ngirit_backend/internal/config"
	"github.com/agungknwn/ngirit_backend/internal/models"
	"github.com/agungknwn/ngirit_backend/internal/utils"
	"github.com/gin-gonic/gin"
	"net/http"
)

// ==================== SUMMARY HANDLERS ====================

//	func GetDailySummary(c *gin.Context) {
//		userId := c.Param("userId")
//		date := c.Param("date")
//
//		summaryId := "daily_" + date
//		doc, err := config.Client.Collection("users").Doc(userId).
//			Collection("summaries").Doc(summaryId).Get(config.Ctx)
//		if err != nil {
//			c.JSON(http.StatusNotFound, gin.H{"error": "Summary not found"})
//			return
//		}
//
//		var summary models.DailySummary
//		doc.DataTo(&summary)
//		c.JSON(http.StatusOK, summary)
//	}
func GetDailySummary(c *gin.Context) {
	userId := c.Param("userId")
	date := c.Param("date")
	summaryId := "daily_" + date

	doc, err := config.Client.Collection("users").Doc(userId).
		Collection("summaries").Doc(summaryId).Get(config.Ctx)
	if err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Summary not found"})
		return
	}

	var summary models.DailySummary
	if err := doc.DataTo(&summary); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to parse summary"})
		return
	}

	// Decrypt total expenses
	if summary.EncryptedTotalExpense != "" {
		decryptedTotal, err := utils.DecryptFloat64(summary.EncryptedTotalExpense)
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to decrypt total expenses"})
			return
		}
		summary.TotalExpenses = decryptedTotal
	}

	// Decrypt category breakdown
	if len(summary.EncryptedCategoryBreakdown) > 0 {
		decryptedBreakdown := make(map[string]float64)
		for category, encryptedVal := range summary.EncryptedCategoryBreakdown {
			decryptedVal, err := utils.DecryptFloat64(encryptedVal)
			if err != nil {
				c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to decrypt category: " + category})
				return
			}
			decryptedBreakdown[category] = decryptedVal
		}
		summary.CategoryBreakdown = decryptedBreakdown
	}

	c.JSON(http.StatusOK, summary)
}

//	func GetMonthlySummary(c *gin.Context) {
//		userId := c.Param("userId")
//		monthYear := c.Param("monthYear")
//		summaryId := "monthly_" + monthYear
//
//		doc, err := config.Client.Collection("users").Doc(userId).
//			Collection("summaries").Doc(summaryId).Get(config.Ctx)
//		if err != nil {
//			c.JSON(http.StatusNotFound, gin.H{"error": "Summary not found"})
//			return
//		}
//
//		summary := models.MonthlySummary{
//			CategoryBreakdown: make(map[string]float64),
//		}
//		doc.DataTo(&summary)
//
//		// Parse flat dot-notation keys into the map
//		rawData := doc.Data()
//		const prefix = "categoryBreakdown."
//		for k, v := range rawData {
//			if strings.HasPrefix(k, prefix) {
//				category := strings.TrimPrefix(k, prefix)
//				switch val := v.(type) {
//				case float64:
//					summary.CategoryBreakdown[category] = val
//				case int64:
//					summary.CategoryBreakdown[category] = float64(val)
//				}
//			}
//		}
//
//		c.JSON(http.StatusOK, summary)
//	}

func GetMonthlySummary(c *gin.Context) {
	userId := c.Param("userId")
	monthYear := c.Param("monthYear")
	summaryId := "monthly_" + monthYear

	doc, err := config.Client.Collection("users").Doc(userId).
		Collection("summaries").Doc(summaryId).Get(config.Ctx)
	if err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Summary not found"})
		return
	}

	raw := doc.Data()

	// --- Decode totalExpenses (handle both plain float and encrypted string) ---
	var totalExpenses float64
	switch v := raw["totalExpenses"].(type) {
	case string:
		decrypted, err := utils.DecryptFloat64(v)
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to decrypt totalExpenses"})
			return
		}
		totalExpenses = decrypted
	case float64:
		totalExpenses = v // not yet migrated, return as-is
	case int64:
		totalExpenses = float64(v)
	}

	// --- Decode categoryBreakdown (handle both plain float and encrypted string) ---
	categoryBreakdown := make(map[string]float64)
	if rawBreakdown, ok := raw["categoryBreakdown"].(map[string]interface{}); ok {
		for category, val := range rawBreakdown {
			switch v := val.(type) {
			case string:
				decrypted, err := utils.DecryptFloat64(v)
				if err != nil {
					c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to decrypt category: " + category})
					return
				}
				categoryBreakdown[category] = decrypted
			case float64:
				categoryBreakdown[category] = v // not yet migrated
			case int64:
				categoryBreakdown[category] = float64(v)
			}
		}
	}

	// --- Build response using struct for other fields ---
	var summary models.MonthlySummary
	if err := doc.DataTo(&summary); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to parse summary"})
		return
	}

	// Override with correctly decoded values
	summary.TotalExpenses = totalExpenses
	summary.CategoryBreakdown = categoryBreakdown

	c.JSON(http.StatusOK, summary)
}
