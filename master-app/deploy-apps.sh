#!/bin/bash

# Global variables
workers=( $(cat workers) )
app_dir=worker-app/*

# Push app to all workers
for worker in ${workers[@]}
do
    scp -r ${app_dir} ${worker}:~
done