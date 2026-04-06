package models

import (
	"time"
)

type Expense struct {
	ExpenseID     string    `json:"expenseId,omitempty" firestore:"-"`
	Date          string    `json:"date" firestore:"date"`
	Timestamp     time.Time `json:"timestamp" firestore:"timestamp"`
	MonthYear     string    `json:"monthYear" firestore:"monthYear"`
	Category      string    `json:"category" firestore:"category"`
	Name          string    `json:"name" firestore:"-"`
	Amount        float64   `json:"amount" firestore:"-"`
	PaymentMethod string    `json:"paymentMethod" firestore:"paymentMethod"`
	Notes         string    `json:"notes" firestore:"notes"`
	CreatedAt     time.Time `json:"createdAt" firestore:"createdAt"`
	UpdatedAt     time.Time `json:"updatedAt" firestore:"updatedAt"`
	// Encrypted fields stored in Firestore
	EncryptedName   string `json:"-" firestore:"name"`
	EncryptedAmount string `json:"-" firestore:"amount"`
}

type Category struct {
	CategoryID string    `json:"categoryId,omitempty" firestore:"-"`
	Name       string    `json:"name" firestore:"name"`
	Icon       string    `json:"icon" firestore:"icon"`
	Color      string    `json:"color" firestore:"color"`
	Order      int       `json:"order" firestore:"order"`
	IsActive   bool      `json:"isActive" firestore:"isActive"`
	CreatedAt  time.Time `json:"createdAt" firestore:"createdAt"`
}
