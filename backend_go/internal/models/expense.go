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
	Name          string    `json:"name" firestore:"name"`
	Amount        float64   `json:"amount" firestore:"amount"`
	PaymentMethod string    `json:"paymentMethod" firestore:"paymentMethod"`
	Notes         string    `json:"notes" firestore:"notes"`
	CreatedAt     time.Time `json:"createdAt" firestore:"createdAt"`
	UpdatedAt     time.Time `json:"updatedAt" firestore:"updatedAt"`
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

type DailySummary struct {
	Type              string             `json:"type" firestore:"type"`
	Date              string             `json:"date" firestore:"date"`
	TotalExpenses     float64            `json:"totalExpenses" firestore:"totalExpenses"`
	ExpenseCount      int                `json:"expenseCount" firestore:"expenseCount"`
	CategoryBreakdown map[string]float64 `json:"categoryBreakdown" firestore:"categoryBreakdown"`
	UpdatedAt         time.Time          `json:"updatedAt" firestore:"updatedAt"`
}

type MonthlySummary struct {
	Type              string             `json:"type" firestore:"type"`
	MonthYear         string             `json:"monthYear" firestore:"monthYear"`
	TotalExpenses     float64            `json:"totalExpenses" firestore:"totalExpenses"`
	ExpenseCount      int                `json:"expenseCount" firestore:"expenseCount"`
	RemainingBudget   float64            `json:"remainingBudget" firestore:"remainingBudget"`
	SavingsAmount     float64            `json:"savingsAmount" firestore:"savingsAmount"`
	CategoryBreakdown map[string]float64 `json:"categoryBreakdown" firestore:"categoryBreakdown"`
	DailyAverage      float64            `json:"dailyAverage" firestore:"dailyAverage"`
	UpdatedAt         time.Time          `json:"updatedAt" firestore:"updatedAt"`
}

