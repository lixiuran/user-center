package middleware

import (
    "net/http"
    "strings"
    "user-center/config"
    "user-center/utils"

    "github.com/gin-gonic/gin"
)

func AuthMiddleware(config config.JWTConfig) gin.HandlerFunc {
    return func(c *gin.Context) {
        authHeader := c.GetHeader("Authorization")
        if authHeader == "" {
            c.JSON(http.StatusUnauthorized, gin.H{"error": "未提供认证信息"})
            c.Abort()
            return
        }

        parts := strings.SplitN(authHeader, " ", 2)
        if !(len(parts) == 2 && parts[0] == "Bearer") {
            c.JSON(http.StatusUnauthorized, gin.H{"error": "认证格式错误"})
            c.Abort()
            return
        }

        claims, err := utils.ParseToken(parts[1], config)
        if err != nil {
            c.JSON(http.StatusUnauthorized, gin.H{"error": "无效的token"})
            c.Abort()
            return
        }

        // 将用户信息存储到上下文中
        c.Set("userID", claims.UserID)
        c.Set("username", claims.Username)
        c.Next()
    }
} 