package models

import (
	"time"
)

type DailySummary struct {
	Type              string             `json:"type" firestore:"type"`
	Date              string             `json:"date" firestore:"date"`
	MonthYear         string             `json:"monthYear" firestore:"monthYear"`
	TotalExpenses     float64            `json:"totalExpenses" firestore:"-"`
	ExpenseCount      int                `json:"expenseCount" firestore:"expenseCount"`
	CategoryBreakdown map[string]float64 `json:"categoryBreakdown" firestore:"-"`
	UpdatedAt         time.Time          `json:"updatedAt" firestore:"updatedAt"`
	// Encrypted fields stored in firestore
	EncryptedTotalExpense      string            `json:"-" firestore:"totalExpenses"`
	EncryptedCategoryBreakdown map[string]string `json:"-" firestore:"categoryBreakdown"`
}

type MonthlySummary struct {
	Type              string             `json:"type" firestore:"type"`
	MonthYear         string             `json:"monthYear" firestore:"monthYear"`
	TotalExpenses     float64            `json:"totalExpenses" firestore:"-"`
	ExpenseCount      int                `json:"expenseCount" firestore:"expenseCount"`
	RemainingBudget   float64            `json:"remainingBudget" firestore:"remainingBudget"`
	SavingsAmount     float64            `json:"savingsAmount" firestore:"savingsAmount"`
	CategoryBreakdown map[string]float64 `json:"categoryBreakdown" firestore:"-"`
	DailyAverage      float64            `json:"dailyAverage" firestore:"dailyAverage"`
	UpdatedAt         time.Time          `json:"updatedAt" firestore:"updatedAt"`
	// Encrypted fields stored in firestore
	EncryptedTotalExpense      string            `json:"-" firestore:"totalExpenses"`
	EncryptedCategoryBreakdown map[string]string `json:"-" firestore:"categoryBreakdown"`
}
