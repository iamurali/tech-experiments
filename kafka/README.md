# Kafka Docker Setup

**This repo contains Kafka experiments including:**
- Bulk producer and consumer scripts
- Multiple consumer groups and multi-topic consumers
- Shell scripts for running and managing experiments
- Example Go code for Kafka producers and consumers

This directory contains a Docker Compose setup for running Apache Kafka with Zookeeper and AKHQ (Kafka UI).

## Prerequisites

- Docker installed on your system
- Docker Compose installed on your system

## Services

The setup includes the following services:

1. **Zookeeper** - Required for Kafka cluster coordination
2. **Kafka** - Apache Kafka broker
3. **AKHQ** - Web-based Kafka UI for managing topics, messages, and clusters

## Quick Start

1. **Start the services:**
   ```bash
   docker-compose up -d
   ```

2. **Check if services are running:**
   ```bash
   docker-compose ps
   ```

3. **View logs:**
   ```bash
   docker-compose logs -f
   ```

## Access Points

- **Kafka Broker**: `localhost:9092`
- **Zookeeper**: `localhost:2181`
- **AKHQ (Kafka UI)**: http://localhost:8080

## Usage

### Using AKHQ Web Interface

1. Open your browser and navigate to http://localhost:8080
2. You'll see the Kafka cluster dashboard
3. Use the interface to:
   - Create and manage topics
   - View and produce messages
   - Monitor consumer groups
   - Browse cluster configuration

### Using Kafka CLI Tools

You can also use Kafka CLI tools from within the Kafka container:

```bash
# Enter the Kafka container
docker exec -it kafka bash

# List topics
kafka-topics --bootstrap-server localhost:9092 --list

# Create a topic
kafka-topics --bootstrap-server localhost:9092 --create --topic test-topic --partitions 1 --replication-factor 1

# Produce messages
kafka-console-producer --bootstrap-server localhost:9092 --topic test-topic

# Consume messages
kafka-console-consumer --bootstrap-server localhost:9092 --topic test-topic --from-beginning
```

## Stopping the Services

```bash
# Stop and remove containers
docker-compose down

# Stop and remove containers, networks, and volumes
docker-compose down -v
```

## Configuration

The setup uses the following configuration:

- **Kafka Version**: 7.6.0
- **Zookeeper Version**: 7.6.0
- **AKHQ Version**: 0.24.0
- **Replication Factor**: 1 (single broker setup)
- **Security**: PLAINTEXT (no authentication/encryption)

## Troubleshooting

### Port Conflicts
If you get port conflicts, check if the following ports are already in use:
- 2181 (Zookeeper)
- 9092 (Kafka)
- 8080 (AKHQ)

### Container Issues
```bash
# Check container status
docker-compose ps

# View specific service logs
docker-compose logs kafka
docker-compose logs zookeeper
docker-compose logs akhq

# Restart a specific service
docker-compose restart kafka
```

### Data Persistence
By default, this setup doesn't persist data. If you need data persistence, you can add volumes to the `docker-compose.yml` file.

## Development Notes

This is a development setup suitable for local development and testing. For production use, consider:

- Adding authentication and encryption
- Using multiple Kafka brokers for high availability
- Configuring proper data retention policies
- Setting up monitoring and alerting 