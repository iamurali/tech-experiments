
# Function to cleanup processes on exit
cleanup() {
    echo "Cleaning up processes..."
    if [ ! -z "$CONSUMER_A_PID" ]; then
        kill $CONSUMER_A_PID 2>/dev/null
    fi
    if [ ! -z "$CONSUMER_B_PID" ]; then
        kill $CONSUMER_B_PID 2>/dev/null
    fi
    if [ ! -z "$CONSUMER_COMBINATION_PID" ]; then
        kill $CONSUMER_COMBINATION_PID 2>/dev/null
    fi
    if [ ! -z "$PRODUCER_PIDS" ]; then
        for pid in "${PRODUCER_PIDS[@]}"; do
            kill $pid 2>/dev/null
        done
    fi
    # Kill any remaining consumer processes
    pkill -f "consumer_group" 2>/dev/null
    pkill -f "go run consumer" 2>/dev/null
    echo "Cleanup complete"
    exit 0
}

# Set up signal handlers
trap cleanup SIGINT SIGTERM

KAFKA_BOOTSTRAP_SERVERS="127.0.0.1:9092,127.0.0.1:9093,127.0.0.1:9094" go run consumer/consumer_group_a.go &
CONSUMER_A_PID=$!
KAFKA_BOOTSTRAP_SERVERS="127.0.0.1:9092,127.0.0.1:9093,127.0.0.1:9094" go run consumer/consumer_group_b.go &
CONSUMER_B_PID=$!
KAFKA_BOOTSTRAP_SERVERS="127.0.0.1:9092,127.0.0.1:9093,127.0.0.1:9094" go run consumer/consumer_group_combination.go &
CONSUMER_COMBINATION_PID=$!

wait $CONSUMER_A_PID
wait $CONSUMER_B_PID
wait $CONSUMER_COMBINATION_PID

echo "Consumption of all messages done"

# to stop kill $CONSUMER_A_PID $CONSUMER_B_PID $CONSUMER_COMBINATION_PID