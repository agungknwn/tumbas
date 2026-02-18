package config

import (
	"context"
	// "encoding/base64"
	"log"
	// "os"

	"cloud.google.com/go/firestore"
	"firebase.google.com/go/v4"
	"google.golang.org/api/option"
)

var (
	Client *firestore.Client
	Ctx    context.Context
)

func InitFirebase() error {
	Ctx = context.Background()

	//render config
	// credBase64 := os.Getenv("FIREBASE_CREDENTIALS_BASE64")
	// credJSON, _ := base64.StdEncoding.DecodeString(credBase64)
	//
	// sa := option.WithCredentialsJSON(credJSON)
	sa := option.WithCredentialsFile("serviceAccount.json")
	app, err := firebase.NewApp(Ctx, nil, sa)
	if err != nil {
		return err
	}

	Client, err = app.Firestore(Ctx)
	if err != nil {
		return err
	}

	log.Println("Firebase initialized successfully")
	return nil
}

func CloseFirebase() {
	if Client != nil {
		Client.Close()
	}
}
