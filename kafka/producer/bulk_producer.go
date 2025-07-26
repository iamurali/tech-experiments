package main

import (
	"fmt"
	"math/rand"
	"time"

	"github.com/confluentinc/confluent-kafka-go/v2/kafka"
)

func main() {
	producer, _ := kafka.NewProducer(&kafka.ConfigMap{
		"bootstrap.servers": "127.0.0.1:9092,127.0.0.1:9093,127.0.0.1:9094",
	})
	start := time.Now()
	topic := "user-events"
	deliveryChan := make(chan kafka.Event)

	go func() {
		for e := range deliveryChan {
			switch ev := e.(type) {
			case *kafka.Message:
				if ev.TopicPartition.Error != nil {
					fmt.Printf("Delivery failed: %v\n", ev.TopicPartition)
				}
			}

		}
	}()

	const totalMessages = 1000000
	for i := 0; i < totalMessages; i++ {
		key := fmt.Sprintf("user-%d", rand.Intn(100000))
		value := fmt.Sprintf("message %d", i)

		producer.Produce(&kafka.Message{
			TopicPartition: kafka.TopicPartition{Topic: &topic, Partition: kafka.PartitionAny},
			Key:            []byte(key),
			Value:          []byte(value),
		}, deliveryChan)
		// Limit rate slightly
		if i%100000 == 0 {
			fmt.Println("Sent", i, "messages")
			//time.Sleep(10 * time.Second)
		}
	}

	producer.Flush(5000)
	producer.Close()
	fmt.Println("Done in", time.Since(start))
}
