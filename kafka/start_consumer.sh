go run consumer/consumer_group_a.go &
CONSUMER_A_PID=$!
go run consumer/consumer_group_b.go &
CONSUMER_B_PID=$!
go run consumer/consumer_group_combination.go &
CONSUMER_COMBINATION_PID=$!

sleep 2


# Start the consumer 
while true; do
    USERID="user-$((RANDOM % 100))"
    TRANSACTIONID="transaction-$((RANDOM % 1000))"
    AMOUNT=$((RANDOM % 1000))
    echo "Producing user-events: $USERID, payment-events: $TRANSACTIONID, amount: $AMOUNT"
    go run producer/producer.go "user-events" "$USERID" "User $USERID purchased $AMOUNT"
    go run producer/producer.go "payment-events" "$TRANSACTIONID" "User $USERID paid $AMOUNT"
    echo "Produced user-events: $USERID, payment-events: $TRANSACTIONID, amount: $AMOUNT"
    sleep 1
done

# to stop kill $CONSUMER_A_PID $CONSUMER_B_PID $CONSUMER_COMBINATION_PID