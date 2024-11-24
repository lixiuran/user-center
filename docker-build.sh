#!/bin/bash

# 颜色配置
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 配置
IMAGE_NAME="user-center"
CONTAINER_NAME="user-center-app"
VERSION="1.0.0"
PORT=8080

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

# 检查 Docker 是否安装
check_docker() {
    if ! command -v docker &> /dev/null; then
        print_error "Docker is not installed"
        exit 1
    fi
}

# 构建应用
build_app() {
    print_info "Building application..."
    
    # 清理 Docker 凭证
    if [ -f ~/.docker/config.json ]; then
        print_info "Cleaning Docker credentials..."
        rm -f ~/.docker/config.json
    fi
    
    # 构建 Docker 镜像
    docker build --no-cache \
        --network=host \
        -t ${IMAGE_NAME}:${VERSION} .
    
    if [ $? -eq 0 ]; then
        print_success "Application built successfully"
    else
        print_error "Failed to build application"
        exit 1
    fi
}

# 运行应用
run_app() {
    print_info "Starting application container..."
    
    # 停止并删除旧容器（如果存在）
    if docker ps -a | grep -q ${CONTAINER_NAME}; then
        print_info "Stopping and removing old container..."
        docker stop ${CONTAINER_NAME}
        docker rm ${CONTAINER_NAME}
    fi
    
    # 运行新容器
    docker run -d \
        --name ${CONTAINER_NAME} \
        -p ${PORT}:${PORT} \
        ${IMAGE_NAME}:${VERSION}
    
    if [ $? -eq 0 ]; then
        print_success "Application is running on port ${PORT}"
        print_info "Container logs:"
        docker logs ${CONTAINER_NAME}
    else
        print_error "Failed to start application"
        exit 1
    fi
}

# 检查容器状态
check_status() {
    print_info "Checking container status..."
    
    if docker ps | grep -q ${CONTAINER_NAME}; then
        print_success "Application is running"
        docker ps | grep ${CONTAINER_NAME}
    else
        print_error "Application is not running"
    fi
    
    print_info "Recent logs:"
    docker logs ${CONTAINER_NAME} --tail 10
}

# 显示帮助信息
show_help() {
    echo "Usage: $0 [command]"
    echo "Commands:"
    echo "  build    - Build the application"
    echo "  start    - Start the application"
    echo "  stop     - Stop the application"
    echo "  restart  - Restart the application"
    echo "  status   - Check application status"
    echo "  logs     - Show container logs"
    echo "  help     - Show this help message"
}

# 显示日志
show_logs() {
    print_info "Showing container logs..."
    docker logs -f ${CONTAINER_NAME}
}

# 主函数
main() {
    check_docker
    
    case "$1" in
        "build")
            build_app
            ;;
        "start")
            run_app
            ;;
        "stop")
            print_info "Stopping application..."
            docker stop ${CONTAINER_NAME}
            print_success "Application stopped"
            ;;
        "restart")
            print_info "Restarting application..."
            docker restart ${CONTAINER_NAME}
            check_status
            ;;
        "status")
            check_status
            ;;
        "logs")
            show_logs
            ;;
        "help")
            show_help
            ;;
        *)
            print_error "Invalid command"
            show_help
            exit 1
            ;;
    esac
}

# 执行主函数
main "$@" 

echo 22;