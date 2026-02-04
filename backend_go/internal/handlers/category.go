package handlers

import (
	"net/http"
	"time"

	"cloud.google.com/go/firestore"
	"github.com/agungknwn/ngirit_backend/internal/config"
	"github.com/agungknwn/ngirit_backend/internal/models"
	"github.com/gin-gonic/gin"
)

// ==================== CATEGORY HANDLERS ====================

func ListCategories(c *gin.Context) {
	userId := c.Param("userId")

	docs, err := config.Client.Collection("users").Doc(userId).
		Collection("categories").OrderBy("order", firestore.Asc).Documents(config.Ctx).GetAll()
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	categories := []models.Category{}
	for _, doc := range docs {
		var category models.Category
		doc.DataTo(&category)
		category.CategoryID = doc.Ref.ID
		categories = append(categories, category)
	}

	c.JSON(http.StatusOK, categories)
}

func CreateCategory(c *gin.Context) {
	userId := c.Param("userId")

	var category models.Category
	if err := c.ShouldBindJSON(&category); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	category.CreatedAt = time.Now()
	category.IsActive = true

	categoryId := "cat_" + time.Now().Format("20060102150405")
	_, err := config.Client.Collection("users").Doc(userId).
		Collection("categories").Doc(categoryId).Set(config.Ctx, category)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusCreated, gin.H{"categoryId": categoryId, "data": category})
}

func UpdateCategory(c *gin.Context) {
	userId := c.Param("userId")
	categoryId := c.Param("categoryId")

	var category models.Category
	if err := c.ShouldBindJSON(&category); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	_, err := config.Client.Collection("users").Doc(userId).
		Collection("categories").Doc(categoryId).Set(config.Ctx, category, firestore.MergeAll)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "Category updated", "data": category})
}

func DeleteCategory(c *gin.Context) {
	userId := c.Param("userId")
	categoryId := c.Param("categoryId")

	_, err := config.Client.Collection("users").Doc(userId).
		Collection("categories").Doc(categoryId).Delete(config.Ctx)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "Category deleted"})
}
