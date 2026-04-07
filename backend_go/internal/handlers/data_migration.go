package handlers

import (
	"github.com/agungknwn/ngirit_backend/internal/services"
	"github.com/gin-gonic/gin"
	"net/http"
)

func RunMigration(c *gin.Context) {
	userId := c.Param("userId")
	if err := services.MigrateSummariesToEncryptedV2(userId); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}
	c.JSON(http.StatusOK, gin.H{"message": "Migration completed"})
}
