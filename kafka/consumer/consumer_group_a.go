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

	c, _ := kafka.NewConsumer(&kafka.ConfigMap{
		"bootstrap.servers": bootstrapServers,
		"group.id":          "user-events-consumer-group",
		"auto.offset.reset": "earliest",
	})

	c.Subscribe("user-events", nil)
	fmt.Println("user-events-consumer-group listening on 'user-events'")

	for {
		msg, err := c.ReadMessage(-1)
		if err != nil {
			fmt.Printf("Consumer error: %v (%v)\n", err, msg)
		} else {
			fmt.Printf("Received message from  the consumer group user-events-consumer-group : %s and key is %s\n", string(msg.Value), string(msg.Key))
		}
	}
}
