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
	if len(os.Args) > 1 {
		topic = os.Args[1]
	}

	Consume(context.Background(), topic)
}

func Consume(ctx context.Context, topic string) {
	fmt.Println("Consuming messages from topic", topic)

	config := &kafka.ConfigMap{
		// Single consumer setup
		"bootstrap.servers": "127.0.0.1:9092",
		"group.id":          "user-events-consumer",
		"auto.offset.reset": "earliest",
	}

	consumer, err := kafka.NewConsumer(config)

	if err != nil {
		log.Fatalf("Failed to create consumer: %v", err)
	}

	consumer.Subscribe(topic, nil)

	for {
		msg, err := consumer.ReadMessage(-1)
		if err != nil {
			fmt.Printf("Consumer error: %v (%v)\n", err, msg)
		} else {
			fmt.Printf("Received message: %s\n", string(msg.Value))
		}
	}
}
