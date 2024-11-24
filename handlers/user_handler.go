package handlers

import (
    "net/http"
    "user-center/models"
    "user-center/repository"
    "user-center/utils"
    "user-center/config"
    "time"
    "fmt"

    "github.com/gin-gonic/gin"
)

type UserHandler struct {
    userRepo repository.UserRepository
    jwtConfig config.JWTConfig
}

func NewUserHandler(userRepo repository.UserRepository, jwtConfig config.JWTConfig) *UserHandler {
    return &UserHandler{
        userRepo: userRepo,
        jwtConfig: jwtConfig,
    }
}

// Register 用户注册
func (h *UserHandler) Register(c *gin.Context) {
    var req models.RegisterRequest
    if err := c.ShouldBindJSON(&req); err != nil {
        c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
        return
    }

    hashedPassword, err := utils.HashPassword(req.Password)
    if err != nil {
        c.JSON(http.StatusInternalServerError, gin.H{"error": "密码加密失败"})
        return
    }

    user := &models.User{
        Username: req.Username,
        Password: hashedPassword,
        Email:    req.Email,
        Phone:    req.Phone,
        Status:   1,
    }

    if err := h.userRepo.Create(user); err != nil {
        c.JSON(http.StatusInternalServerError, gin.H{"error": "注册失败: " + err.Error()})
        return
    }

    c.JSON(http.StatusOK, gin.H{"message": "注册成功"})
}

// Login 用户登录
func (h *UserHandler) Login(c *gin.Context) {
    var req models.LoginRequest
    if err := c.ShouldBindJSON(&req); err != nil {
        c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
        return
    }

    user, err := h.userRepo.GetByUsername(req.Username)
    if err != nil {
        c.JSON(http.StatusUnauthorized, gin.H{"error": "用户名或密码错误"})
        return
    }

    if !utils.CheckPassword(req.Password, user.Password) {
        c.JSON(http.StatusUnauthorized, gin.H{"error": "用户名或密码错误"})
        return
    }

    // 更新最后登录时间
    now := time.Now()
    user.LastLoginAt = &now
    if err := h.userRepo.Update(fmt.Sprint(user.ID), user); err != nil {
        // 记录错误但不影响登录
        utils.Log.WithError(err).Error("Failed to update last login time")
    }

    // 使用 JWT 配置生成 token
    token, err := utils.GenerateToken(user.ID, user.Username, h.jwtConfig)
    if err != nil {
        c.JSON(http.StatusInternalServerError, gin.H{"error": "生成token失败"})
        return
    }

    c.JSON(http.StatusOK, gin.H{
        "token": token,
        "user":  user,
    })
}

// GetUser 获取用户信息
func (h *UserHandler) GetUser(c *gin.Context) {
    id := c.Param("id")
    user, err := h.userRepo.GetByID(id)
    if err != nil {
        c.JSON(http.StatusNotFound, gin.H{"error": "用户不存在"})
        return
    }
    c.JSON(http.StatusOK, user)
}

// UpdateUser 更新用户信息
func (h *UserHandler) UpdateUser(c *gin.Context) {
    id := c.Param("id")
    var user models.User
    if err := c.ShouldBindJSON(&user); err != nil {
        c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
        return
    }

    if err := h.userRepo.Update(id, &user); err != nil {
        c.JSON(http.StatusInternalServerError, gin.H{"error": "更新失败"})
        return
    }

    c.JSON(http.StatusOK, gin.H{"message": "更新成功"})
}

// DeleteUser 删除用户
func (h *UserHandler) DeleteUser(c *gin.Context) {
    id := c.Param("id")
    if err := h.userRepo.Delete(id); err != nil {
        c.JSON(http.StatusInternalServerError, gin.H{"error": "删除失败"})
        return
    }
    c.JSON(http.StatusOK, gin.H{"message": "删除成功"})
} 