package repository

import (
    "user-center/models"
    "gorm.io/gorm"
    "time"
)

type UserRepository interface {
    Create(user *models.User) error
    GetByID(id string) (*models.User, error)
    GetByUsername(username string) (*models.User, error)
    Update(id string, user *models.User) error
    Delete(id string) error
}

type userRepository struct {
    db *gorm.DB
}

func NewUserRepository(db *gorm.DB) UserRepository {
    return &userRepository{db: db}
}

func (r *userRepository) Create(user *models.User) error {
    now := time.Now()
    user.CreatedAt = now
    user.UpdatedAt = now
    
    return r.db.Create(user).Error
}

func (r *userRepository) GetByID(id string) (*models.User, error) {
    var user models.User
    err := r.db.First(&user, id).Error
    return &user, err
}

func (r *userRepository) GetByUsername(username string) (*models.User, error) {
    var user models.User
    err := r.db.Where("username = ?", username).First(&user).Error
    return &user, err
}

func (r *userRepository) Update(id string, user *models.User) error {
    return r.db.Model(&models.User{}).Where("id = ?", id).Updates(user).Error
}

func (r *userRepository) Delete(id string) error {
    return r.db.Delete(&models.User{}, id).Error
} 