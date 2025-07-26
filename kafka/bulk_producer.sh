echo "Launching bulk producer"
for i in {1..3}; do
  go run producer/bulk_producer.go &
  PRODUCER_PIDS[$i]=$!
done

for pid in "${PRODUCER_PIDS[@]}"; do
  wait $pid
done

echo "Bulk Producer Finished"