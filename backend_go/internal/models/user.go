package models

type User struct {
	Email string `json:"email" firestore:"email"`
	Password string `json:"password" firestore:"password"`
	Name string `json:"name" firestore:"name"`
	Username string `json:"username" firestore:"username"`
}


