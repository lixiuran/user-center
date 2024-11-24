package models

import "time"

type User struct {
    ID          int64      `json:"id" gorm:"primaryKey"`
    Username    string     `json:"username" gorm:"unique;not null"`
    Password    string     `json:"-" gorm:"not null"`
    Email       string     `json:"email" gorm:"unique;not null"`
    Phone       string     `json:"phone"`
    CreatedAt   time.Time  `json:"created_at"`
    UpdatedAt   time.Time  `json:"updated_at"`
    Status      int8       `json:"status" gorm:"default:1"`
    LastLoginAt *time.Time `json:"last_login_at"`
}

type RegisterRequest struct {
    Username string `json:"username" binding:"required,min=3,max=50"`
    Password string `json:"password" binding:"required,min=6"`
    Email    string `json:"email" binding:"required,email"`
    Phone    string `json:"phone"`
}

type LoginRequest struct {
    Username string `json:"username" binding:"required"`
    Password string `json:"password" binding:"required"`
} 