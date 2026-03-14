package handlers

import (
	"net/http"

	"cloud.google.com/go/firestore"
	"github.com/agungknwn/ngirit_backend/internal/config"
	"github.com/agungknwn/ngirit_backend/internal/models"
	"github.com/agungknwn/ngirit_backend/internal/services"
	"github.com/gin-gonic/gin"
)

// ==================== QUERY HANDLERS ====================
func GetExpensesByDate(c *gin.Context) {
	userId := c.Param("userId")
	date := c.Param("date")

	docs, err := config.Client.Collection("users").Doc(userId).
		Collection("expenses").Where("date", "==", date).
		OrderBy("timestamp", firestore.Asc).Documents(config.Ctx).GetAll()
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	expenses := []models.Expense{}
	for _, doc := range docs {
		var expense models.Expense
		doc.DataTo(&expense)

		if err := services.DecryptExpenseFields(&expense); err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "decryption failed"})
			return
		}
		expense.ExpenseID = doc.Ref.ID
		expenses = append(expenses, expense)
	}

	c.JSON(http.StatusOK, expenses)
}

func GetExpensesByMonth(c *gin.Context) {
	userId := c.Param("userId")
	monthYear := c.Param("monthYear")

	docs, err := config.Client.Collection("users").Doc(userId).
		Collection("expenses").Where("monthYear", "==", monthYear).
		OrderBy("timestamp", firestore.Desc).Documents(config.Ctx).GetAll()
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	expenses := []models.Expense{}
	for _, doc := range docs {
		var expense models.Expense
		doc.DataTo(&expense)
		expense.ExpenseID = doc.Ref.ID
		expenses = append(expenses, expense)
	}

	c.JSON(http.StatusOK, expenses)
}

func GetExpensesByCategory(c *gin.Context) {
	userId := c.Param("userId")
	category := c.Param("category")

	docs, err := config.Client.Collection("users").Doc(userId).
		Collection("expenses").Where("category", "==", category).
		OrderBy("timestamp", firestore.Desc).Documents(config.Ctx).GetAll()
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	expenses := []models.Expense{}
	for _, doc := range docs {
		var expense models.Expense
		doc.DataTo(&expense)
		expense.ExpenseID = doc.Ref.ID
		expenses = append(expenses, expense)
	}

	c.JSON(http.StatusOK, expenses)
}
