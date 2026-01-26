# Port Forwarding Guide for Assignment7

This guide explains how to access your frontend, backend, MongoDB, and Mongo Express services.

## Services Overview

- **Frontend**: Port 3000
- **Backend**: Port 8000  
- **MongoDB**: Port 27017
- **Mongo Express**: Port 8081

## Method 1: Port Forwarding (Recommended for Development)

### Quick Start
```bash
# Navigate to k8s directory
cd /home/palmu/Assignment7/k8s

# Start port forwarding for all services
./port-forward.sh start

# Check status
./port-forward.sh status

# Stop port forwarding
./port-forward.sh stop
```

### Access URLs
- Frontend: http://localhost:3000
- Backend API: http://localhost:8000
- MongoDB: localhost:27017 (connect with MongoDB client)
- Mongo Express: http://localhost:8081
  - Username: amu
  - Password: 123

### Manual Port Forwarding
If you prefer to set up port forwarding manually:

```bash
# Terminal 1 - Frontend
kubectl port-forward service/frontend 3000:3000

# Terminal 2 - Backend  
kubectl port-forward service/backend 8000:8000

# Terminal 3 - MongoDB
kubectl port-forward service/mongo 27017:27017

# Terminal 4 - Mongo Express
kubectl port-forward service/mongo-express 8081:8081
```

## Method 2: NodePort Services (For External Access)

### Setup NodePort Services
```bash
# Apply NodePort services
kubectl apply -f services-nodeport.yaml

# Get node IP (for minikube)
minikube ip

# For other clusters, get external IP
kubectl get nodes -o wide
```

### Access URLs (replace NODE_IP with your cluster node IP)
- Frontend: http://NODE_IP:30001
- Backend: http://NODE_IP:30002
- MongoDB: NODE_IP:30003
- Mongo Express: http://NODE_IP:30004

## Method 3: LoadBalancer Services (Cloud Providers Only)

For cloud providers (AWS, GCP, Azure), you can modify services to use LoadBalancer type:

```yaml
# Example for frontend service
apiVersion: v1
kind: Service
metadata:
  name: frontend-lb
spec:
  selector:
    app: frontend
  ports:
  - port: 3000
    targetPort: 3000
  type: LoadBalancer
```

## Troubleshooting

### Common Issues

1. **Port already in use**
   ```bash
   # Check what's using the port
   lsof -i :3000
   # Stop the service using the port or use different ports
   ```

2. **Services not running**
   ```bash
   # Check pod status
   kubectl get pods
   # Check service status
   kubectl get services
   ```

3. **Connection refused**
   ```bash
   # Check if services are properly exposed
   kubectl describe service <service-name>
   # Check pod logs
   kubectl logs <pod-name>
   ```

4. **MongoDB connection issues**
   - Ensure MongoDB pod is running
   - Check if backend can connect to MongoDB
   - Verify environment variables in backend deployment

### Cleanup

```bash
# Stop port forwarding
./port-forward.sh stop

# Remove NodePort services
kubectl delete -f services-nodeport.yaml

# Kill any remaining kubectl port-forward processes
pkill -f "kubectl port-forward"
```

## Development Workflow

1. Deploy your services:
   ```bash
   kubectl apply -f frontend.yaml
   kubectl apply -f backend.yaml
   kubectl apply -f mongo.yaml
   kubectl apply -f mongo-express.yaml
   ```

2. Start port forwarding:
   ```bash
   ./port-forward.sh start
   ```

3. Access your applications via localhost URLs

4. When done, stop port forwarding:
   ```bash
   ./port-forward.sh stop
   ```
