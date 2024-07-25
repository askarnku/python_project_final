#!/bin/bash

# Assume $memory_usage holds the floating-point value, for example
memory_usage="78.2"  # Example memory usage in percent
memory_threshold="80.0"  # Threshold memory usage in percent

# Compare using bc
memory_comparison=$(echo "$memory_usage < $memory_threshold" | bc)
if [ "$memory_comparison" -ne 1 ]; then
    echo "Memory usage is below threshold."
else
    echo "Memory usage is above threshold."
fi
