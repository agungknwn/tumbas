package models

import (
	"time"
)

// Structs for request/response
type Budget struct {
	MonthYear     string  `json:"monthYear" firestore:"monthYear"`
	MonthlyBudget float64 `json:"amount" firestore:"-"`
	// MonthlyBudget  float64   `json:"monthlyBudget" firestore:"monthlyBudget"`
	// DailyBudget    float64   `json:"dailyBudget" firestore:"dailyBudget"`
	// SavingsGoal    float64   `json:"savingsGoal" firestore:"savingsGoal"`
	Currency               string    `json:"currency" firestore:"currency"`
	CreatedAt              time.Time `json:"createdAt" firestore:"createdAt"`
	UpdatedAt              time.Time `json:"updatedAt" firestore:"updatedAt"`
	EncryptedMonthlyBudget string    `json:"-" firestore:"amount"`
}
