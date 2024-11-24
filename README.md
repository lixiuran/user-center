```SQL

CREATE DATABASE user_center CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
use user_center;
CREATE TABLE users (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    username VARCHAR(50) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    phone VARCHAR(20),
    created_at TIMESTAMP NOT NULL,
    updated_at TIMESTAMP NOT NULL,
    status TINYINT DEFAULT 1 COMMENT '1:正常 0:禁用',
    last_login_at TIMESTAMP NULL DEFAULT NULL
);