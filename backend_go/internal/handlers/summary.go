package handlers

import (
	"github.com/agungknwn/ngirit_backend/internal/config"
	"github.com/agungknwn/ngirit_backend/internal/models"
	"github.com/agungknwn/ngirit_backend/internal/utils"
	"github.com/gin-gonic/gin"
	"net/http"
	"strings"
)

// ==================== SUMMARY HANDLERS ====================

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
	doc.DataTo(&summary)
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

	summary := models.MonthlySummary{
		CategoryBreakdown: make(map[string]float64),
	}
	doc.DataTo(&summary)

	// Decrypt total expenses
	if summary.EncryptedTotalExpense != "" {
		summary.TotalExpenses, _ = utils.DecryptFloat64(summary.EncryptedTotalExpense)
	}

	// Parse categoryBreakdown
	rawData := doc.Data()
	const prefix = "categoryBreakdown."
	for k, v := range rawData {
		if strings.HasPrefix(k, prefix) {
			category := strings.TrimPrefix(k, prefix)
			switch val := v.(type) {
			case float64:
				summary.CategoryBreakdown[category] = val
			case int64:
				summary.CategoryBreakdown[category] = float64(val)
			}
		}
	}

	c.JSON(http.StatusOK, summary)
}
