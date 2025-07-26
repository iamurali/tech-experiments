package main

import (
	"fmt"
)

func main() {
	fmt.Println("Kafka Experiment - Producer Only")
	fmt.Println("To run consumer separately: go run consumer/consumer.go")
	fmt.Println("To run producer separately: go run producer/producer.go")

	// Example of how to use the producer programmatically
	// Uncomment the lines below if you want to run producer here
	/*
		err := producer.Produce(context.Background(), "user-events", "user-123", "Hello, World!")
		if err != nil {
			log.Fatalf("Failed to produce message: %v", err)
		}
	*/
}
