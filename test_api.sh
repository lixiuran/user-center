#!/bin/bash

# 配置
API_URL="http://localhost:8080/api"
TOKEN=""

# 颜色配置
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 打印带颜色的信息
print_info() {
    echo -e "${YELLOW}[INFO] $1${NC}"
}

print_success() {
    echo -e "${GREEN}[SUCCESS] $1${NC}"
}

print_error() {
    echo -e "${RED}[ERROR] $1${NC}"
}

# 测试注册
test_register() {
    print_info "Testing registration..."
    
    response=$(curl -s -w "\n%{http_code}" -X POST "${API_URL}/users/register" \
        -H "Content-Type: application/json" \
        -d '{
            "username": "testuser123",
            "password": "password123",
            "email": "testuser123@example.com",
            "phone": "13800138000"
        }')

    body=$(echo "$response" | head -n 1)
    status_code=$(echo "$response" | tail -n 1)

    echo "Status code: $status_code"
    echo "Response: $body"

    if [ "$status_code" -eq 200 ]; then
        print_success "Registration successful"
        return 0
    else
        print_error "Registration failed"
        return 1
    fi
}

# 测试登录
test_login() {
    print_info "Testing login..."
    
    response=$(curl -s -w "\n%{http_code}" -X POST "${API_URL}/users/login" \
        -H "Content-Type: application/json" \
        -d '{
            "username": "testuser123",
            "password": "password123"
        }')

    body=$(echo "$response" | head -n 1)
    status_code=$(echo "$response" | tail -n 1)

    echo "Status code: $status_code"
    echo "Response: $body"

    if [ "$status_code" -eq 200 ]; then
        # 提取 token
        TOKEN=$(echo "$body" | grep -o '"token":"[^"]*' | cut -d'"' -f4)
        if [ -n "$TOKEN" ]; then
            print_success "Login successful. Token obtained."
            return 0
        else
            print_error "Login successful but no token found"
            return 1
        fi
    else
        print_error "Login failed"
        return 1
    fi
}

# 测试获取用户信息
test_get_user() {
    print_info "Testing get user info..."
    
    if [ -z "$TOKEN" ]; then
        print_error "No token available. Please login first."
        return 1
    fi

    response=$(curl -s -w "\n%{http_code}" -X GET "${API_URL}/users/1" \
        -H "Authorization: Bearer ${TOKEN}")

    body=$(echo "$response" | head -n 1)
    status_code=$(echo "$response" | tail -n 1)

    echo "Status code: $status_code"
    echo "Response: $body"

    if [ "$status_code" -eq 200 ]; then
        print_success "Get user info successful"
        return 0
    else
        print_error "Get user info failed"
        return 1
    fi
}

# 测试更新用户信息
test_update_user() {
    print_info "Testing update user info..."
    
    if [ -z "$TOKEN" ]; then
        print_error "No token available. Please login first."
        return 1
    fi

    response=$(curl -s -w "\n%{http_code}" -X PUT "${API_URL}/users/1" \
        -H "Authorization: Bearer ${TOKEN}" \
        -H "Content-Type: application/json" \
        -d '{
            "phone": "13900139000"
        }')

    body=$(echo "$response" | head -n 1)
    status_code=$(echo "$response" | tail -n 1)

    echo "Status code: $status_code"
    echo "Response: $body"

    if [ "$status_code" -eq 200 ]; then
        print_success "Update user info successful"
        return 0
    else
        print_error "Update user info failed"
        return 1
    fi
}

# 测试删除用户
test_delete_user() {
    print_info "Testing delete user..."
    
    if [ -z "$TOKEN" ]; then
        print_error "No token available. Please login first."
        return 1
    fi

    response=$(curl -s -w "\n%{http_code}" -X DELETE "${API_URL}/users/1" \
        -H "Authorization: Bearer ${TOKEN}")

    body=$(echo "$response" | head -n 1)
    status_code=$(echo "$response" | tail -n 1)

    echo "Status code: $status_code"
    echo "Response: $body"

    if [ "$status_code" -eq 200 ]; then
        print_success "Delete user successful"
        return 0
    else
        print_error "Delete user failed"
        return 1
    fi
}

# 运行所有测试
run_all_tests() {
    print_info "Starting API tests..."
    echo "=============================="
    
    local failed=0
    
    # 运行测试并检查返回值
    test_register || failed=$((failed + 1))
    echo "------------------------------"
    sleep 1
    
    test_login || failed=$((failed + 1))
    echo "------------------------------"
    sleep 1
    
    test_get_user || failed=$((failed + 1))
    echo "------------------------------"
    sleep 1
    
    test_update_user || failed=$((failed + 1))
    echo "------------------------------"
    sleep 1
    
    test_delete_user || failed=$((failed + 1))
    
    echo "=============================="
    if [ $failed -eq 0 ]; then
        print_success "All tests passed!"
    else
        print_error "$failed test(s) failed!"
    fi
    
    return $failed
}

# 检查服务是否运行
check_server() {
    curl -s "${API_URL}/users/health" > /dev/null
    if [ $? -ne 0 ]; then
        print_error "API server is not running at ${API_URL}"
        print_info "Please start the server first"
        exit 1
    fi
}

# 主函数
main() {
    # 检查 curl 是否安装
    if ! command -v curl &> /dev/null; then
        print_error "curl is required but not installed. Please install curl first."
        exit 1
    fi
    
    # 检查服务器状态
    check_server
    
    # 运行测试
    run_all_tests
    exit $?
}

# 执行主函数
main 