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

func HealthCheck(c *gin.Context) {
	c.JSON(http.StatusOK, gin.H{"status": "ok"})
}

func Register(c *gin.Context) {
	var cred models.User

	if err := c.ShouldBindJSON(&cred); err != nil {
		c.JSON(400, gin.H{"error": "invalid request"})
		return
	}

	// Check if username already exists
	userRef := config.Client.Collection("users").Doc(cred.Username)
	docSnap, err := userRef.Get(config.Ctx)

	hashedPassword, err := services.HashPassword(cred.Password)
	if err != nil {
		c.JSON(500, gin.H{"error": "could not hash password"})
		return
	}

	if err == nil && docSnap.Exists() {
		c.JSON(409, gin.H{"error": "username already registered"})
		return
	}

	// Check email uniqueness
	existEmail := config.Client.Collection("users").
		Where("email", "==", cred.Email).
		Limit(1).
		Documents(config.Ctx)

	if _, err := existEmail.Next(); err == nil {
		c.JSON(409, gin.H{"error": "email already registered"})
		return
	}

	existUsername := config.Client.Collection("users").Where("email", "==", cred.Email).
		Limit(1).Documents(config.Ctx)

	if _, err := existUsername.Next(); err == nil {
		c.JSON(409, gin.H{"error": "username already registered"})
		return
	}

	// Create user
	_, err = userRef.Set(config.Ctx, map[string]interface{ any }{
		"email":     cred.Email,
		"password":  hashedPassword, // ⚠️ hash in production
		"name":      cred.Name,
		"username":  cred.Username,
		"createdAt": time.Now(),
	})

	if err != nil {
		c.JSON(500, gin.H{"error": err.Error()})
		return
	}

	c.JSON(200, gin.H{"userId": cred.Username})
}

func Login(c *gin.Context) {
	var cred models.LoginRequest

	if err := c.ShouldBindJSON(&cred); err != nil {
		c.JSON(400, gin.H{"error": "invalid request"})
		return
	}

	filter := firestore.OrFilter{
		Filters: []firestore.EntityFilter{
			firestore.PropertyFilter{Path: "email", Operator: "==", Value: cred.Identifier},
			firestore.PropertyFilter{Path: "username", Operator: "==", Value: cred.Identifier},
		},
	}

	iter := config.Client.Collection("users").
		WhereEntity(filter).
		// Where("password", "==", cred.Password).
		Limit(1).
		Documents(config.Ctx)

	doc, err := iter.Next()
	if err != nil {
		c.JSON(401, gin.H{"error": "invalid credentials"})
		return
	}

	// Extract hash password
	storedHash := doc.Data()["password"].(string)

	if !services.CheckPasswordHash(cred.Password, storedHash) {
		c.JSON(401, gin.H{"error": "invalid password"})
		return
	}

	c.JSON(200, gin.H{"userId": doc.Ref.ID})
}
