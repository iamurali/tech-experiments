package main

import (
	"context"
	"fmt"
	"log"
	"os"

	"github.com/confluentinc/confluent-kafka-go/v2/kafka"
)

func main() {
	topic := "user-events"
	key := "user-123"
	message := "Hello, World!"

	if len(os.Args) > 1 {
		topic = os.Args[1]
	}
	if len(os.Args) > 2 {
		key = os.Args[2]
	}
	if len(os.Args) > 3 {
		message = os.Args[3]
	}

	err := Produce(context.Background(), topic, key, message)
	if err != nil {
		log.Fatalf("Failed to produce message: %v", err)
	}
}

func Produce(ctx context.Context, topic string, key string, message string) error {
	fmt.Println("Producing message to topic", topic, "with key", key, "and message", message)

	config := &kafka.ConfigMap{
		"bootstrap.servers": "127.0.0.1:9092,127.0.0.1:9093,127.0.0.1:9094",
		"client.id":         "USER-SERVICE-PRODUCER",
		"acks":              "all",
		"retries":           3,
		"retry.backoff.ms":  100,
		"batch.size":        100,
		"linger.ms":         100,
		"compression.type":  "snappy",
		"security.protocol": "PLAINTEXT",
	}

	producer, err := kafka.NewProducer(config)
	if err != nil {
		log.Fatalf("Failed to create producer: %v", err)
		return err
	}

	defer producer.Close()

	producer.Produce(&kafka.Message{
		TopicPartition: kafka.TopicPartition{
			Topic: &topic,
		},
		Key:   []byte(key),
		Value: []byte(message),
	}, nil)

	// Wait for all messages to be delivered
	producer.Flush(10000) // 10 second timeout
	return nil
}
