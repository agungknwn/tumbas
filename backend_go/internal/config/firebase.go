package config

import (
	"context"
	"log"

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
