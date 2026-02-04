package handlers

import (
	"net/http"

	"github.com/agungknwn/ngirit_backend/internal/config"
	"github.com/agungknwn/ngirit_backend/internal/models"
	"github.com/gin-gonic/gin"
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

	var summary models.MonthlySummary
	doc.DataTo(&summary)
	c.JSON(http.StatusOK, summary)
}
