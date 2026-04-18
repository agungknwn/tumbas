package handlers

import (
	// "log"
	"net/http"
	"time"

	"cloud.google.com/go/firestore"
	"github.com/agungknwn/ngirit_backend/internal/config"
	"github.com/agungknwn/ngirit_backend/internal/models"
	"github.com/agungknwn/ngirit_backend/internal/services"
	"github.com/agungknwn/ngirit_backend/internal/utils"
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

	if err := doc.DataTo(&budget); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to parse budget amount"})
		return
	}

	if budget.EncryptedMonthlyBudget != "" {
		decryptedAmount, err := utils.DecryptFloat64(budget.EncryptedMonthlyBudget)
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Decryption failed"})
			return
		}

		budget.MonthlyBudget = decryptedAmount
	}
	// doc.DataTo(&budget)
	c.JSON(http.StatusOK, budget)
}

func CreateBudget(c *gin.Context) {
	userId := c.Param("userId")

	var budget models.Budget
	if err := c.ShouldBindJSON(&budget); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	encryptedBudget, err := utils.EncryptFloat64(budget.MonthlyBudget)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Encryption Failed"})
	}

	budget.EncryptedMonthlyBudget = encryptedBudget
	budget.CreatedAt = time.Now()
	budget.UpdatedAt = time.Now()

	budgetId := "budget_" + budget.MonthYear
	_, err = config.Client.Collection("users").Doc(userId).
		Collection("budgets").Doc(budgetId).Set(config.Ctx, budget)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusCreated, gin.H{"budgetId": budgetId, "data": budget})
}

//	func UpdateBudget(c *gin.Context) {
//		userId := c.Param("userId")
//		budgetId := c.Param("budgetId")
//
//		var budget models.Budget
//		if err := c.ShouldBindJSON(&budget); err != nil {
//			c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
//			return
//		}
//
//		encryptedVal, err := utils.EncryptFloat64(budget.MonthlyBudget)
//		if err != nil {
//			c.JSON(http.StatusInternalServerError, gin.H{"error": "Encryption Failed"})
//			return
//		}
//
//		//budget.UpdatedAt = time.Now()
//		updateData := map[string]interface{}{
//			"amount":    encryptedVal,
//			"currency":  budget.Currency,
//			"monthYear": budget.MonthYear,
//			"updatedAt": time.Now(),
//		}
//
//		_, err = config.Client.Collection("users").Doc(userId).
//			Collection("budgets").Doc(budgetId).Set(config.Ctx, updateData, firestore.MergeAll)
//		if err != nil {
//			c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
//			return
//		}
//
//		c.JSON(http.StatusOK, gin.H{"message": "Budget Updated", "data": budget})
//	}
func UpdateBudget(c *gin.Context) {
	// log.Println("Update Budget Called")
	userId := c.Param("userId")
	budgetId := c.Param("budgetId")
	// log.Println("userId:", userId, "budgetId:", budgetId)

	var req models.UpdateBudgetRequest
	if err := c.ShouldBindJSON(&req); err != nil {

		// log.Println("bind error:", err)
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}
	// log.Printf("Request: %+v\n", req)

	// use exchangeRate ONLY for logic (not stored)
	// convertedAmount := req.MonthlyBudget * req.ExchangeRate

	encryptedVal, err := utils.EncryptFloat64(req.MonthlyBudget)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Encryption Failed"})
		return
	}

	updateData := map[string]interface{}{
		"amount":    encryptedVal,
		"currency":  req.Currency,
		"monthYear": req.MonthYear,
		"updatedAt": time.Now(),
	}

	_, err = config.Client.Collection("users").Doc(userId).
		Collection("budgets").Doc(budgetId).
		Set(config.Ctx, updateData, firestore.MergeAll)

	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	converter, err := services.NewConverter("USD")
	if err != nil {

		// log.Println("converter error:", err)
		c.JSON(http.StatusInternalServerError, gin.H{"error": "failed to fetch rates"})
		return
	}

	rate, err := converter.CrossRate(req.FromCurrency, req.ToCurrency)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "invalid currency"})
		return
	}
	// Normalize expenses only if ExchangeRate is provided and not 1
	if req.ExchangeRate != 0 && req.ExchangeRate != 1 {
		if err := services.NormalizeExpensesByExchangeRate(userId, req.MonthYear, rate); err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Budget updated but failed to normalize expenses: " + err.Error()})
			return
		}
		if err := services.NormalizeMonthlySummary(userId, req.MonthYear, rate); err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Budget updated but failed to normalize summary: " + err.Error()})
			return
		}
	}

	c.JSON(http.StatusOK, gin.H{
		"message": "Budget Updated",
	})
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
