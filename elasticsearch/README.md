# 🚀 Elasticsearch Multi-Node Cluster POC

> **A comprehensive Proof of Concept for Elasticsearch with Docker, featuring multi-node clusters, load balancing, high availability testing, and e-commerce data management.**

[![Elasticsearch](https://img.shields.io/badge/Elasticsearch-9.1.0-005571?style=for-the-badge&logo=elasticsearch)](https://www.elastic.co/)
[![Docker](https://img.shields.io/badge/Docker-Compose-2496ED?style=for-the-badge&logo=docker)](https://www.docker.com/)
[![Kibana](https://img.shields.io/badge/Kibana-9.1.0-005571?style=for-the-badge&logo=kibana)](https://www.elastic.co/kibana)
[![HA Testing](https://img.shields.io/badge/HA--Testing-Available-brightgreen?style=for-the-badge)](https://www.elastic.co/)

---

## 📋 Table of Contents

- [🏗️ Architecture Overview](#️-architecture-overview)
- [📁 Project Structure](#-project-structure)
- [⚡ Quick Start](#-quick-start)
- [🔧 Setup Options](#-setup-options)
- [📊 Data Management](#-data-management)
- [🔍 Search & Analytics](#-search--analytics)
- [🛠️ Management Commands](#️-management-commands)
- [🐳 Docker Operations](#-docker-operations)
- [🔄 High Availability Testing](#-high-availability-testing)
- [📈 Replica Management](#-replica-management)
- [🔒 Security & Best Practices](#-security--best-practices)
- [📚 Resources & References](#-resources--references)

---

## 🏗️ Architecture Overview

This POC demonstrates a production-ready Elasticsearch setup with the following components:

### 🎯 Core Components
- **Elasticsearch 9.1.0** - Distributed search and analytics engine
- **Kibana 9.1.0** - Data visualization and management interface
- **HAProxy** - Load balancer for multi-node clusters
- **Docker Compose** - Container orchestration

### 🏢 Cluster Architecture
```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Master Node   │    │   Master Node   │    │   Master Node   │
│   (es-master-01)│    │   (es-master-02)│    │   (es-master-03)│
│   Port: 9200    │    │   Port: 9201    │    │   Port: 9202    │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                       │                       │
         └───────────────────────┼───────────────────────┘
                                 │
                    ┌─────────────────┐
                    │   HAProxy LB    │
                    │   (Port 9999)   │
                    └─────────────────┘
                                 │
                    ┌─────────────────┐
                    │   Data Node     │
                    │   (es-data-01)  │
                    │   Port: 9203    │
                    └─────────────────┘
                                 │
                    ┌─────────────────┐
                    │  Coordinator    │
                    │   (es-coord-01) │
                    │   Port: 9204    │
                    └─────────────────┘
```

### 🎯 High Availability Features
- **3 Master Nodes**: Ensures quorum and prevents split-brain
- **1 Data Node**: Handles data storage and processing
- **2 Coordinator Nodes**: Manages client requests and load distribution
- **HAProxy Load Balancer**: Distributes traffic and provides failover
- **Replica Configuration**: Data replication across nodes for fault tolerance

---

## 📁 Project Structure

```
elasticsearch/
├── 📄 README.md                    # This comprehensive guide
├── 📊 index_mapping.json          # E-commerce product schema
├── 🐍 dummy_data_generator.py     # Data generation script
├── 🔑 kaggle.json                 # Kaggle API credentials
├── 📊 All Appliances.csv          # Sample dataset
│
├── 🏢 multi_node_setup/           # Multi-node cluster setup
│   ├── 📄 docker-compose.yml      # Multi-node configuration
│   ├── ⚙️ elasticsearch.yml       # ES configuration
│   ├── 🔄 haproxy.cfg             # Load balancer config
│   └── 🧪 testing.sh              # HA testing script
│
└── 🏠 single_node_setup/          # Single node setup
    ├── 📄 docker-compose.yml      # Single node configuration
    └── 📄 postman_collection.json # API testing collection
```

---

## ⚡ Quick Start

### 🎯 Prerequisites

- [Docker](https://docs.docker.com/get-docker/) & [Docker Compose](https://docs.docker.com/compose/install/)
- [curl](https://curl.se/) or [Postman](https://www.postman.com/) for API testing
- [Python 3.8+](https://www.python.org/downloads/) (for data generation)

### 🚀 Single Node Setup (Development)

```bash
# 1. Navigate to single node setup
cd elasticsearch/single_node_setup

# 2. Start Elasticsearch and Kibana
docker compose up -d

# 3. Verify services
curl http://localhost:9200/_cluster/health
curl http://localhost:5601/api/status

# 4. Access services
# Elasticsearch: http://localhost:9200
# Kibana: http://localhost:5601
```

### 🏢 Multi-Node Setup (Production-like)

```bash
# 1. Navigate to multi-node setup
cd elasticsearch/multi_node_setup

# 2. Start the cluster
docker compose up -d

# 3. Verify cluster health
curl http://localhost:9200/_cluster/health?pretty

# 4. Access services
# Elasticsearch: http://localhost:9200 (via HAProxy)
# Kibana: http://localhost:5601
# HAProxy Stats: http://localhost:8404/stats
```

---

## 🔧 Setup Options

### 🏠 Single Node Setup
**Best for:** Development, testing, learning
- **Elasticsearch:** Port 9200
- **Kibana:** Port 5601
- **Memory:** ~2GB
- **Use case:** Local development, small datasets

### 🏢 Multi-Node Setup
**Best for:** Production, high availability, large datasets
- **3 Master Nodes:** Ports 9200, 9201, 9202
- **1 Data Node:** Port 9203
- **2 Coordinator Nodes:** Ports 9204, 9205
- **HAProxy Load Balancer:** Port 9999
- **Kibana:** Port 5601
- **Memory:** ~8GB total
- **Use case:** Production workloads, high availability

---

## 📊 Data Management

### 🗂️ Index Creation

```bash
# Create ecommerce_products index with mapping
curl -X PUT "localhost:9200/ecommerce_products" \
  -H "Content-Type: application/json" \
  -d @index_mapping.json
```

### 📈 Data Generation

```bash
# Generate 100,000 sample products
cd elasticsearch
python dummy_data_generator.py
```

### 🔄 Replica Configuration

```bash
# For multi-node clusters, set replicas
curl -X PUT "localhost:9200/ecommerce_products/_settings" \
  -H "Content-Type: application/json" \
  -d '{
    "index": {
      "number_of_replicas": 2
    }
  }'
```

### 📊 Index Schema

| Field | Type | Description | Example |
|-------|------|-------------|---------|
| `product_id` | `keyword` | Unique identifier | `"prod_123"` |
| `title` | `text` | Product name | `"Wireless Headphones"` |
| `category` | `text + keyword` | Product category | `"Electronics"` |
| `brand` | `keyword` | Brand name | `"TechCorp"` |
| `price` | `float` | Current price | `99.99` |
| `rating` | `float` | User rating | `4.5` |
| `availability` | `keyword` | Stock status | `"in_stock"` |
| `location` | `geo_point` | Warehouse location | `{"lat": 40.7128, "lon": -74.0060}` |

---

## 🔍 Search & Analytics

### 🔎 Basic Search

```bash
# Search products by title
curl -X GET "localhost:9200/ecommerce_products/_search" \
  -H "Content-Type: application/json" \
  -d '{
    "query": {
      "match": {
        "title": "headphones"
      }
    }
  }'
```

### 🎯 Filtered Search

```bash
# Search with filters
curl -X GET "localhost:9200/ecommerce_products/_search" \
  -H "Content-Type: application/json" \
  -d '{
    "query": {
      "bool": {
        "must": [
          {"match": {"category": "Electronics"}},
          {"range": {"price": {"gte": 50, "lte": 200}}}
        ]
      }
    }
  }'
```

### 📊 Aggregations

```bash
# Category distribution
curl -X GET "localhost:9200/ecommerce_products/_search" \
  -H "Content-Type: application/json" \
  -d '{
    "size": 0,
    "aggs": {
      "categories": {
        "terms": {
          "field": "category.keyword",
          "size": 10
        }
      }
    }
  }'
```

### 📍 Geo Search

```bash
# Find products near location
curl -X GET "localhost:9200/ecommerce_products/_search" \
  -H "Content-Type: application/json" \
  -d '{
    "query": {
      "geo_distance": {
        "distance": "100km",
        "location": {"lat": 40.7128, "lon": -74.0060}
      }
    }
  }'
```

---

## 🛠️ Management Commands

### 📋 Index Management

```bash
# List all indices
curl -X GET "localhost:9200/_cat/indices?v"

# Check index mapping
curl -X GET "localhost:9200/ecommerce_products/_mapping"

# Check index settings
curl -X GET "localhost:9200/ecommerce_products/_settings"

# Delete index (⚠️ destructive)
curl -X DELETE "localhost:9200/ecommerce_products"

# Update replica settings
curl -X PUT "localhost:9200/ecommerce_products/_settings" \
  -H "Content-Type: application/json" \
  -d '{"index": {"number_of_replicas": 2}}'
```

### 🏢 Cluster Management

```bash
# Cluster health
curl -X GET "localhost:9200/_cluster/health?pretty"

# Node information
curl -X GET "localhost:9200/_nodes?pretty"

# Cluster settings
curl -X GET "localhost:9200/_cluster/settings?pretty"

# Shard allocation
curl -X GET "localhost:9200/_cat/shards?v"
```

### 🔄 Data Operations

```bash
# Reindex data
curl -X POST "localhost:9200/_reindex" \
  -H "Content-Type: application/json" \
  -d '{
    "source": {"index": "source_index"},
    "dest": {"index": "ecommerce_products"}
  }'

# Bulk indexing
curl -X POST "localhost:9200/_bulk" \
  -H "Content-Type: application/json" \
  --data-binary @bulk_data.json
```

---

## 🐳 Docker Operations

### 🚀 Service Management

```bash
# Start services
docker compose up -d

# Stop services
docker compose down

# Restart services
docker compose restart

# View logs
docker compose logs -f elasticsearch
docker compose logs -f kibana

# Remove everything (clean slate)
docker compose down -v
```

### 🔍 Container Monitoring

```bash
# Check container status
docker ps

# Monitor resource usage
docker stats

# Execute commands in container
docker exec -it es-master-01 bash

# View container logs
docker logs es-master-01
```

### 🧹 Cleanup

```bash
# Remove all containers and volumes
docker compose down -v

# Remove all images
docker rmi $(docker images -q)

# Clean up unused resources
docker system prune -a
```

---

## 🔄 High Availability Testing

### 🎯 Overview

The POC includes comprehensive HA testing capabilities to validate cluster resilience and data availability during node failures.

### 🧪 Testing Script

The `testing.sh` script provides automated testing for various failure scenarios:

```bash
# Navigate to multi-node setup
cd elasticsearch/multi_node_setup

# Test node failure scenarios
./testing.sh test-failure                    # Test with default node (es-master-02)
./testing.sh test-failure es-master-01       # Test with specific master node
./testing.sh test-failure es-data-01         # Test with data node
./testing.sh test-failure es-coordinator-01  # Test with coordinator node

# Cluster management
./testing.sh stop                            # Stop the cluster
./testing.sh cleanup                         # Complete cleanup
```

### 🔍 Available Test Nodes

| Node Type | Service Name | Port | Role | Testing Purpose |
|-----------|--------------|------|------|-----------------|
| Master | `es-master-01` | 9200 | Master, Data, Ingest | Quorum testing |
| Master | `es-master-02` | 9201 | Master, Data, Ingest | Master failure |
| Master | `es-master-03` | 9202 | Master, Data, Ingest | Master failure |
| Data | `es-data-01` | 9203 | Data, Ingest | Data availability |
| Coordinator | `es-coordinator-01` | 9204 | All roles | Request routing |
| Coordinator | `es-coordinator-02` | 9205 | All roles | Request routing |

### 🧪 Test Scenarios

#### **1. Master Node Failure Test**
```bash
./testing.sh test-failure es-master-02
```
**What it tests:**
- Cluster quorum maintenance
- Master election process
- Data availability during master failure
- Automatic recovery

#### **2. Data Node Failure Test**
```bash
./testing.sh test-failure es-data-01
```
**What it tests:**
- Replica shard promotion
- Data accessibility
- Shard rebalancing
- Recovery time

#### **3. Coordinator Node Failure Test**
```bash
./testing.sh test-failure es-coordinator-01
```
**What it tests:**
- Load balancer failover
- Request routing
- Client connectivity
- Performance impact

### 📊 Test Results Interpretation

#### **Cluster Health Status**
- **Green**: All primary and replica shards allocated
- **Yellow**: All primary shards allocated, some replicas not allocated
- **Red**: Some primary shards not allocated

#### **Expected Behaviors**
1. **During Node Failure:**
   - Cluster status may turn yellow/red temporarily
   - Data should remain accessible via replicas
   - HAProxy should route traffic to healthy nodes

2. **After Node Recovery:**
   - Cluster should return to green status
   - Shards should rebalance across nodes
   - All data should be accessible

### 🔧 Manual Testing Commands

```bash
# Check cluster health before test
curl -s "http://localhost:9200/_cluster/health?pretty"

# Check node information
curl -s "http://localhost:9200/_nodes/_all/name,roles,master?pretty"

# Test data accessibility
curl -s "http://localhost:9200/ecommerce_products/_search?size=1"

# Check shard allocation
curl -s "http://localhost:9200/_cat/shards?v"

# Monitor cluster during failure
watch -n 2 'curl -s "http://localhost:9200/_cluster/health?pretty"'
```

---

## 📈 Replica Management

### 🎯 Replica Strategy

The POC implements a comprehensive replica strategy for high availability:

#### **Replica Configuration**
```bash
# Set replicas for high availability
curl -X PUT "localhost:9200/ecommerce_products/_settings" \
  -H "Content-Type: application/json" \
  -d '{
    "index": {
      "number_of_replicas": 2,
      "number_of_shards": 3
    }
  }'
```

#### **Replica Distribution**
- **Primary Shards**: 3 shards for data distribution
- **Replica Shards**: 2 replicas per primary for fault tolerance
- **Total Shards**: 9 shards (3 primary + 6 replicas)

### 🔄 Replica Operations

#### **Check Replica Status**
```bash
# View shard allocation
curl -X GET "localhost:9200/_cat/shards?v"

# Check replica health
curl -X GET "localhost:9200/_cat/indices?v"

# Monitor replica recovery
curl -X GET "localhost:9200/_cat/recovery?v"
```

#### **Replica Management Commands**
```bash
# Increase replicas for better availability
curl -X PUT "localhost:9200/ecommerce_products/_settings" \
  -H "Content-Type: application/json" \
  -d '{"index": {"number_of_replicas": 3}}'

# Decrease replicas to save resources
curl -X PUT "localhost:9200/ecommerce_products/_settings" \
  -H "Content-Type: application/json" \
  -d '{"index": {"number_of_replicas": 1}}'

# Disable replicas (not recommended for production)
curl -X PUT "localhost:9200/ecommerce_products/_settings" \
  -H "Content-Type: application/json" \
  -d '{"index": {"number_of_replicas": 0}}'
```

### 📊 Replica Performance Impact

#### **Benefits**
- **High Availability**: Data accessible even if nodes fail
- **Fault Tolerance**: Automatic failover to replica shards
- **Read Performance**: Replicas can handle read requests
- **Load Distribution**: Better resource utilization

#### **Considerations**
- **Storage**: Each replica requires full storage space
- **Network**: Replica synchronization uses network bandwidth
- **Write Performance**: More replicas = slower writes
- **Resource Usage**: Additional CPU and memory usage

### 🔧 Replica Monitoring

#### **Health Checks**
```bash
# Monitor replica allocation
curl -X GET "localhost:9200/_cluster/health?pretty"

# Check unassigned shards
curl -X GET "localhost:9200/_cat/shards?v" | grep UNASSIGNED

# Monitor replica recovery
curl -X GET "localhost:9200/_cat/recovery?v"
```

#### **Performance Metrics**
```bash
# Check replica lag
curl -X GET "localhost:9200/_cat/indices?v"

# Monitor replica operations
curl -X GET "localhost:9200/_nodes/stats/indices?pretty"
```

---

## 🔒 Security & Best Practices

### 🛡️ Security Configuration

> ⚠️ **Note:** This POC has security disabled for development. Enable for production.

```yaml
# Enable security in elasticsearch.yml
xpack.security.enabled: true
xpack.security.transport.ssl.enabled: true
```

### 📊 Performance Optimization

```bash
# Optimize index settings
curl -X PUT "localhost:9200/ecommerce_products/_settings" \
  -H "Content-Type: application/json" \
  -d '{
    "index": {
      "number_of_replicas": 2,
      "refresh_interval": "30s",
      "number_of_shards": 3
    }
  }'
```

### 🔧 Monitoring

```bash
# Enable monitoring
curl -X PUT "localhost:9200/_cluster/settings" \
  -H "Content-Type: application/json" \
  -d '{
    "persistent": {
      "xpack.monitoring.collection.enabled": true
    }
  }'
```

### 🎯 HA Best Practices

1. **Node Configuration**
   - Use dedicated master nodes for large clusters
   - Configure appropriate memory limits
   - Enable monitoring and alerting

2. **Replica Strategy**
   - Set replicas based on node count: `(nodes - 1) / 2`
   - Monitor replica allocation and health
   - Test failure scenarios regularly

3. **Load Balancing**
   - Use HAProxy for request distribution
   - Configure health checks and failover
   - Monitor load balancer performance

4. **Monitoring**
   - Set up cluster health monitoring
   - Monitor shard allocation and recovery
   - Track performance metrics

---

## 📚 Resources & References

### 📖 Official Documentation
- [Elasticsearch Guide](https://www.elastic.co/guide/index.html)
- [Kibana User Guide](https://www.elastic.co/guide/en/kibana/current/index.html)
- [Elasticsearch Query DSL](https://www.elastic.co/guide/en/elasticsearch/reference/current/query-dsl.html)

### 🛠️ Tools & Utilities
- [Elasticsearch Head](https://github.com/mobz/elasticsearch-head) - Web interface
- [Kibana Dev Tools](http://localhost:5601/app/dev_tools#/console) - Query console
- [Elasticsearch Curator](https://github.com/elastic/curator) - Index management

### 🎓 Learning Resources
- [Elasticsearch: The Definitive Guide](https://www.elastic.co/guide/en/elasticsearch/guide/current/index.html)
- [Elasticsearch in Action](https://www.manning.com/books/elasticsearch-in-action)
- [Elasticsearch: The Complete Guide](https://www.udemy.com/course/elasticsearch-complete-guide/)

### 🔄 HA Testing Resources
- [Elasticsearch High Availability](https://www.elastic.co/guide/en/elasticsearch/reference/current/high-availability.html)
- [Cluster Health API](https://www.elastic.co/guide/en/elasticsearch/reference/current/cluster-health.html)
- [Shard Allocation](https://www.elastic.co/guide/en/elasticsearch/reference/current/shards-allocation.html)

---

## 🤝 Contributing

1. 🧪 Test your changes locally using Docker Compose
2. 📝 Update this README for any new features
3. 🔍 Ensure all commands work as documented
4. 📊 Add examples for new functionality
5. 🧪 Test HA scenarios with the testing script

---

## 📄 License

This POC is for **educational and development purposes**. 

---

<div align="center">

**Made with ❤️ for Elasticsearch enthusiasts**

[![GitHub](https://img.shields.io/badge/GitHub-100000?style=for-the-badge&logo=github&logoColor=white)](https://github.com/)
[![Docker](https://img.shields.io/badge/Docker-2496ED?style=for-the-badge&logo=docker&logoColor=white)](https://www.docker.com/)
[![Elasticsearch](https://img.shields.io/badge/Elasticsearch-005571?style=for-the-badge&logo=elasticsearch&logoColor=white)](https://www.elastic.co/)

</div>
