#!/bin/bash

# Port forwarding script for Assignment7 services
# This script sets up port forwarding for all services

echo "Setting up port forwarding for Assignment7 services..."

# Function to check if kubectl is available
check_kubectl() {
    if ! command -v kubectl &> /dev/null; then
        echo "Error: kubectl is not installed or not in PATH"
        exit 1
    fi
}

# Function to check if services are running
check_services() {
    echo "Checking if services are running..."
    kubectl get pods -l app=frontend --no-headers | grep -q "Running" || echo "Warning: Frontend may not be running"
    kubectl get pods -l app=backend --no-headers | grep -q "Running" || echo "Warning: Backend may not be running"
    kubectl get pods -l app=mongo --no-headers | grep -q "Running" || echo "Warning: MongoDB may not be running"
    kubectl get pods -l app=mongo-express --no-headers | grep -q "Running" || echo "Warning: Mongo Express may not be running"
}

# Function to setup port forwarding
setup_port_forward() {
    echo "Starting port forwarding in background..."
    
    # Frontend (3000:3000)
    echo "Forwarding frontend port 3000 -> localhost:3000"
    kubectl port-forward service/frontend 3000:3000 &
    FRONTEND_PID=$!
    
    # Backend (8000:8000)
    echo "Forwarding backend port 8000 -> localhost:8000"
    kubectl port-forward service/backend 8000:8000 &
    BACKEND_PID=$!
    
    # MongoDB (27017:27017)
    echo "Forwarding MongoDB port 27017 -> localhost:27017"
    kubectl port-forward service/mongo 27017:27017 &
    MONGO_PID=$!
    
    # Mongo Express (8081:8081)
    echo "Forwarding Mongo Express port 8081 -> localhost:8081"
    kubectl port-forward service/mongo-express 8081:8081 &
    MONGO_EXPRESS_PID=$!
    
    # Save PIDs to file for cleanup
    echo $FRONTEND_PID > /tmp/frontend_pf.pid
    echo $BACKEND_PID > /tmp/backend_pf.pid
    echo $MONGO_PID > /tmp/mongo_pf.pid
    echo $MONGO_EXPRESS_PID > /tmp/mongo_express_pf.pid
    
    echo "Port forwarding started successfully!"
    echo "PIDs saved to /tmp/ for cleanup"
}

# Function to stop port forwarding
stop_port_forward() {
    echo "Stopping port forwarding..."
    
    if [ -f /tmp/frontend_pf.pid ]; then
        kill $(cat /tmp/frontend_pf.pid) 2>/dev/null && rm /tmp/frontend_pf.pid
    fi
    if [ -f /tmp/backend_pf.pid ]; then
        kill $(cat /tmp/backend_pf.pid) 2>/dev/null && rm /tmp/backend_pf.pid
    fi
    if [ -f /tmp/mongo_pf.pid ]; then
        kill $(cat /tmp/mongo_pf.pid) 2>/dev/null && rm /tmp/mongo_pf.pid
    fi
    if [ -f /tmp/mongo_express_pf.pid ]; then
        kill $(cat /tmp/mongo_express_pf.pid) 2>/dev/null && rm /tmp/mongo_express_pf.pid
    fi
    
    echo "Port forwarding stopped"
}

# Function to show status
show_status() {
    echo "Port forwarding status:"
    echo "======================"
    echo "Frontend:     http://localhost:3000"
    echo "Backend:      http://localhost:8000"
    echo "MongoDB:      localhost:27017"
    echo "Mongo Express:http://localhost:8081"
    echo ""
    echo "Active processes:"
    ps aux | grep "kubectl port-forward" | grep -v grep || echo "No active port forwarding processes found"
}

# Main script logic
case "$1" in
    "start")
        check_kubectl
        check_services
        setup_port_forward
        show_status
        ;;
    "stop")
        stop_port_forward
        ;;
    "status")
        show_status
        ;;
    "restart")
        stop_port_forward
        sleep 2
        check_kubectl
        check_services
        setup_port_forward
        show_status
        ;;
    *)
        echo "Usage: $0 {start|stop|status|restart}"
        echo ""
        echo "Commands:"
        echo "  start   - Start port forwarding for all services"
        echo "  stop    - Stop all port forwarding"
        echo "  status  - Show current port forwarding status"
        echo "  restart - Restart port forwarding"
        exit 1
        ;;
esac
