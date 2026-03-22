package models

type User struct {
	Email    string `json:"email" firestore:"email"`
	Password string `json:"password" firestore:"password"`
	Name     string `json:"name" firestore:"name"`
	Username string `json:"username" firestore:"username"`
}

type LoginRequest struct {
	Identifier string `json:"identifier"`
	Password   string `json:"password"`
}
