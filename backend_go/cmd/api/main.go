package main

import (
	"log"

	"github.com/agungknwn/ngirit_backend/internal/config"
	"github.com/agungknwn/ngirit_backend/internal/routes"
	"github.com/gin-contrib/cors"
	"github.com/gin-gonic/gin"
)

func main() {

	// Initialize Firebase
	if err := config.InitFirebase(); err != nil {
		log.Fatalf("Failed to init firebase: %v", err)
	}
	defer config.CloseFirebase()

	// Setup Gin router
	r := gin.Default()
	r.Use(cors.Default()) // Quick fix - allows all origins

	routes.RegisterRoutes(r)
	r.Run("0.0.0.0:8080")
}
