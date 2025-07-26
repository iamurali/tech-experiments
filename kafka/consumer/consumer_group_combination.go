package main

import (
	"fmt"
	"os"

	"github.com/confluentinc/confluent-kafka-go/v2/kafka"
)

func main() {
	bootstrapServers := os.Getenv("KAFKA_BOOTSTRAP_SERVERS")
	if bootstrapServers == "" {
		bootstrapServers = "127.0.0.1:9092,127.0.0.1:9093,127.0.0.1:9094"
	}

	consumer, _ := kafka.NewConsumer(&kafka.ConfigMap{
		"bootstrap.servers": bootstrapServers,
		"group.id":          "group-analytics",
		"auto.offset.reset": "earliest",
	})

	consumer.SubscribeTopics([]string{"payment-events", "user-events"}, nil)
	fmt.Println("group-analytics listening on 'user-events' + 'payment-events'")

	for {
		msg, err := consumer.ReadMessage(-1)
		if err != nil {
			fmt.Printf("Consumer error: %v (%v)\n", err, msg)
		} else {
			fmt.Printf("Received message from the consumer group group-analytics : %s and key is %s\n", string(msg.Value), string(msg.Key))
		}
	}
}
