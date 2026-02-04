package handlers

import (
	"net/http"
	"time"

	"cloud.google.com/go/firestore"
	"github.com/agungknwn/ngirit_backend/internal/config"
	"github.com/agungknwn/ngirit_backend/internal/models"
	"github.com/gin-gonic/gin"
)

func GetBudget(c *gin.Context) {
	userId := c.Param("userId")
	budgetId := c.Param("budgetId")

	doc, err := config.Client.Collection("users").Doc(userId).
		Collection("budgets").Doc(budgetId).Get(config.Ctx)
	if err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Budget not found"})
		return
	}

	var budget models.Budget
	doc.DataTo(&budget)
	c.JSON(http.StatusOK, budget)
}

func CreateBudget(c *gin.Context) {
	userId := c.Param("userId")

	var budget models.Budget
	if err := c.ShouldBindJSON(&budget); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	budget.CreatedAt = time.Now()
	budget.UpdatedAt = time.Now()

	budgetId := "budget_" + budget.MonthYear
	_, err := config.Client.Collection("users").Doc(userId).
		Collection("budgets").Doc(budgetId).Set(config.Ctx, budget)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusCreated, gin.H{"budgetId": budgetId, "data": budget})
}

func UpdateBudget(c *gin.Context) {
	userId := c.Param("userId")
	budgetId := c.Param("budgetId")

	var budget models.Budget
	if err := c.ShouldBindJSON(&budget); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	budget.UpdatedAt = time.Now()

	_, err := config.Client.Collection("users").Doc(userId).
		Collection("budgets").Doc(budgetId).Set(config.Ctx, budget, firestore.MergeAll)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "Budget updated", "data": budget})
}

func ListBudgets(c *gin.Context) {
	userId := c.Param("userId")

	docs, err := config.Client.Collection("users").Doc(userId).
		Collection("budgets").Documents(config.Ctx).GetAll()
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	budgets := []models.Budget{}
	for _, doc := range docs {
		var budget models.Budget
		doc.DataTo(&budget)
		budgets = append(budgets, budget)
	}

	c.JSON(http.StatusOK, budgets)
}
