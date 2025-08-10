#!/bin/bash

# testing.sh - Node failure testing and cluster cleanup for Elasticsearch

set -e

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Change to the script directory to ensure docker-compose.yml is found
cd "$SCRIPT_DIR"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to check if docker-compose.yml exists
check_docker_compose() {
    if [ ! -f "docker-compose.yml" ]; then
        print_error "docker-compose.yml not found in current directory: $(pwd)"
        exit 1
    fi
    print_status "Found docker-compose.yml in: $(pwd)"
}

# Function to check if cluster is running
check_cluster_running() {
    if ! curl -s "http://localhost:9200/_cluster/health" >/dev/null 2>&1; then
        print_error "Elasticsearch cluster is not running. Please start it first."
        exit 1
    fi
    print_status "Cluster is running and accessible."
}

# Function to test node failure scenario
test_node_failure() {
    print_status "Starting node failure test..."
    
    check_docker_compose
    check_cluster_running

    echo "=== Initial Cluster Status ==="
    curl -s "http://localhost:9200/_cluster/health?pretty"

    echo -e "\n=== Node Information ==="
    curl -s "http://localhost:9200/_nodes/_all/name,roles,master?pretty"

    # Available nodes for testing
    print_status "Available nodes for testing:"
    echo "  - es-master-01 (Master node)"
    echo "  - es-master-02 (Master node)"
    echo "  - es-master-03 (Master node)"
    echo "  - es-data-01 (Data node)"
    echo "  - es-coordinator-01 (Coordinator node)"
    echo "  - es-coordinator-02 (Coordinator node)"

    # Default to es-master-02 for testing
    NODE_TO_TEST=${2:-"es-master-02"}
    
    print_warning "Stopping $NODE_TO_TEST to simulate node failure..."
    docker-compose stop $NODE_TO_TEST

    sleep 15

    echo -e "\n=== Cluster Status After Node Failure ==="
    curl -s "http://localhost:9200/_cluster/health?pretty"

    echo -e "\n=== Testing Data Accessibility ==="
    # Test if we can still search (assuming ecommerce_products index exists)
    if curl -s "http://localhost:9200/ecommerce_products/_search?size=1" >/dev/null 2>&1; then
        print_status "SUCCESS: Data is still accessible after node failure!"
    else
        print_warning "Data accessibility test inconclusive (index may not exist)"
    fi

    print_status "Restarting the failed node..."
    docker-compose start $NODE_TO_TEST

    sleep 20

    echo -e "\n=== Final Cluster Status After Recovery ==="
    curl -s "http://localhost:9200/_cluster/health?pretty"

    print_status "Node failure test completed!"
}

# Function to stop the cluster
stop_cluster() {
    print_status "Stopping Elasticsearch cluster..."
    check_docker_compose
    docker-compose down
    print_status "Cluster stopped successfully."
}

# Function to clean up everything
cleanup() {
    print_status "Cleaning up cluster and all data..."
    check_docker_compose
    docker-compose down -v
    docker system prune -f
    print_status "Cleanup completed. All containers, volumes, and unused resources removed."
}

# Main script logic
case "$1" in
    "test-failure")
        test_node_failure
        ;;
    "stop")
        stop_cluster
        ;;
    "cleanup")
        cleanup
        ;;
    *)
        echo "Usage: $0 {test-failure [node-name]|stop|cleanup}"
        echo ""
        echo "Commands:"
        echo "  test-failure [node-name] - Simulate node failure and test recovery"
        echo "                            Default: es-master-02"
        echo "                            Options: es-master-01, es-master-02, es-master-03,"
        echo "                                    es-data-01, es-coordinator-01, es-coordinator-02"
        echo "  stop                     - Stop the cluster"
        echo "  cleanup                  - Stop cluster and remove all data"
        echo ""
        echo "Examples:"
        echo "  $0 test-failure                    # Test with default node (es-master-02)"
        echo "  $0 test-failure es-master-01       # Test with specific master node"
        echo "  $0 test-failure es-data-01         # Test with data node"
        echo "  $0 test-failure es-coordinator-01  # Test with coordinator node"
        exit 1
        ;;
esac