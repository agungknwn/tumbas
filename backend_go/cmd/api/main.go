package main

import (
	"log"

	"github.com/agungknwn/ngirit_backend/internal/config"
	"github.com/agungknwn/ngirit_backend/internal/routes"
	"github.com/gin-contrib/cors"
	"github.com/gin-gonic/gin"
	// "os"
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
	port := ""
	// port := os.Getenv("PORT")
	if port == "" {
		port = "8081"
	}
	r.Run("0.0.0.0:" + port)
}
