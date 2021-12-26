#!/bin/bash

# Remove existing outputs folder
rm -r outputs 2>/dev/null

# Global variables
workers=( $(cat workers) )

# Create outputs folder
mkdir outputs

# Pull output files from all workers
for i in $(seq 1 ${#workers[@]})
do
    worker_dir=outputs/worker-${i}
    j=$((i-1))

    mkdir ${worker_dir}
    scp -r ${workers[j]}:data/EXP_* ${worker_dir}
done