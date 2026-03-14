package main

import (
	"log"

	"github.com/agungknwn/ngirit_backend/internal/config"
	"github.com/agungknwn/ngirit_backend/internal/routes"
	"github.com/agungknwn/ngirit_backend/internal/services"
	"github.com/gin-contrib/cors"
	"github.com/gin-gonic/gin"
	"github.com/joho/godotenv"
	// "os"
)

// func init() {
// 	// try root-relative path explicitly
// 	if err := godotenv.Load("../../.env"); err != nil {
// 		if err := godotenv.Load(".env"); err != nil {
// 			log.Println("No .env file found, using system env vars")
// 		}
// 	}
// }

func main() {
	// if err := godotenv.Load(); err != nil {
	// 	log.Println("No .env file found, using system env vars")
	// }
	// 1. Load .env first
	if err := godotenv.Load("../../.env"); err != nil {
		godotenv.Load(".env")
	}

	// 2. NOW init encryption
	if err := services.InitEncryption(); err != nil {
		log.Fatalf("Encryption init failed: %v", err)
	}

	// 3. Rest of setup
	if err := config.InitFirebase(); err != nil {
		log.Fatalf("Failed to init firebase: %v", err)
	}
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
