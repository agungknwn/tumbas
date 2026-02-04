package handlers

import (
	"net/http"
	"time"

	"cloud.google.com/go/firestore"
	"github.com/agungknwn/ngirit_backend/internal/config"
	"github.com/agungknwn/ngirit_backend/internal/models"
	"github.com/agungknwn/ngirit_backend/internal/services"
	"github.com/gin-gonic/gin"
)

// ==================== EXPENSE HANDLERS ====================

func GetExpense(c *gin.Context) {
	userId := c.Param("userId")
	expenseId := c.Param("expenseId")

	doc, err := config.Client.Collection("users").Doc(userId).
		Collection("expenses").Doc(expenseId).Get(config.Ctx)
	if err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Expense not found"})
		return
	}

	var expense models.Expense
	doc.DataTo(&expense)
	expense.ExpenseID = doc.Ref.ID
	c.JSON(http.StatusOK, expense)
}

func ListExpenses(c *gin.Context) {
	userId := c.Param("userId")
	limit := 50 // Default limit

	query := config.Client.Collection("users").Doc(userId).
		Collection("expenses").OrderBy("timestamp", firestore.Desc).Limit(limit)

	docs, err := query.Documents(config.Ctx).GetAll()
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

func CreateExpense(c *gin.Context) {
	userId := c.Param("userId")

	var expense models.Expense
	if err := c.ShouldBindJSON(&expense); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	expense.Timestamp = time.Now()
	expense.CreatedAt = time.Now()
	expense.UpdatedAt = time.Now()

	// Add expense to Firestore
	docRef, _, err := config.Client.Collection("users").Doc(userId).
		Collection("expenses").Add(config.Ctx, expense)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	expense.ExpenseID = docRef.ID

	// Update daily summary
	go services.UpdateDailySummaryAfterAdd(userId, expense)

	// Update monthly summary
	go services.UpdateMonthlySummaryAfterAdd(userId, expense)

	c.JSON(http.StatusCreated, gin.H{"expenseId": docRef.ID, "data": expense})
}

func UpdateExpense(c *gin.Context) {
	userId := c.Param("userId")
	expenseId := c.Param("expenseId")

	// Get old expense first for summary updates
	oldDoc, err := config.Client.Collection("users").Doc(userId).
		Collection("expenses").Doc(expenseId).Get(config.Ctx)
	if err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Expense not found"})
		return
	}

	var oldExpense models.Expense
	oldDoc.DataTo(&oldExpense)

	var newExpense models.Expense
	if err := c.ShouldBindJSON(&newExpense); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	newExpense.UpdatedAt = time.Now()
	newExpense.CreatedAt = oldExpense.CreatedAt // Keep original creation time

	_, err = config.Client.Collection("users").Doc(userId).
		Collection("expenses").Doc(expenseId).Set(config.Ctx, newExpense)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	// Update summaries (subtract old, add new)
	go services.UpdateSummariesAfterUpdate(userId, oldExpense, newExpense)

	c.JSON(http.StatusOK, gin.H{"message": "Expense updated", "data": newExpense})
}

func PatchExpense(c *gin.Context) {
	userId := c.Param("userId")
	expenseId := c.Param("expenseId")

	var updates map[string]interface{}
	if err := c.ShouldBindJSON(&updates); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	updates["updatedAt"] = time.Now()

	// Convert map to firestore updates
	var firestoreUpdates []firestore.Update
	for key, value := range updates {
		firestoreUpdates = append(firestoreUpdates, firestore.Update{
			Path:  key,
			Value: value,
		})
	}

	_, err := config.Client.Collection("users").Doc(userId).
		Collection("expenses").Doc(expenseId).Update(config.Ctx, firestoreUpdates)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "Expense patched"})
}

func DeleteExpense(c *gin.Context) {
	userId := c.Param("userId")
	expenseId := c.Param("expenseId")

	// Get expense data before deleting for summary updates
	doc, err := config.Client.Collection("users").Doc(userId).
		Collection("expenses").Doc(expenseId).Get(config.Ctx)
	if err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Expense not found"})
		return
	}

	var expense models.Expense
	doc.DataTo(&expense)

	// Delete expense
	_, err = config.Client.Collection("users").Doc(userId).
		Collection("expenses").Doc(expenseId).Delete(config.Ctx)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	// Update summaries (subtract deleted expense)
	go services.UpdateSummariesAfterDelete(userId, expense)

	c.JSON(http.StatusOK, gin.H{"message": "Expense deleted"})
}
