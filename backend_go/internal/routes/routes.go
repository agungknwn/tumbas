package routes

import (
	"github.com/agungknwn/ngirit_backend/internal/handlers"
	"github.com/gin-gonic/gin"
)

func RegisterRoutes(r *gin.Engine) {
	// Health check
	r.GET("/health", handlers.HealthCheck)

	// Auth
	auth := r.Group("/auth")
	{
		auth.POST("/register", handlers.Register)
		auth.POST("/login", handlers.Login)
	}

	// User routes
	users := r.Group("/users/:userId")
	{
		// Budgets
		budgets := users.Group("/budgets")
		{
			budgets.GET("", handlers.ListBudgets)
			budgets.POST("", handlers.CreateBudget)
			budgets.GET("/:budgetId", handlers.GetBudget)
			budgets.PUT("/:budgetId", handlers.UpdateBudget)
		}

		// Expenses
		expenses := users.Group("/expenses")
		{
			expenses.GET("", handlers.ListExpenses)
			expenses.POST("", handlers.CreateExpense)
			expenses.GET("/:expenseId", handlers.GetExpense)
			expenses.PUT("/:expenseId", handlers.UpdateExpense)
			expenses.PATCH("/:expenseId", handlers.PatchExpense)
			expenses.DELETE("/:expenseId", handlers.DeleteExpense)

			// Query endpoints
			expenses.GET("/by-date/:date", handlers.GetExpensesByDate)
			expenses.GET("/by-month/:monthYear", handlers.GetExpensesByMonth)
			expenses.GET("/by-category/:category", handlers.GetExpensesByCategory)
		}

		// Categories
		categories := users.Group("/categories")
		{
			categories.GET("", handlers.ListCategories)
			categories.POST("", handlers.CreateCategory)
			categories.PUT("/:categoryId", handlers.UpdateCategory)
			categories.DELETE("/:categoryId", handlers.DeleteCategory)
		}

		// Summaries
		summaries := users.Group("/summaries")
		{
			summaries.GET("/daily/:date", handlers.GetDailySummary)
			summaries.GET("/monthly/:monthYear", handlers.GetMonthlySummary)
		}
	}
}
