#!/bin/bash

workers=( $(kubectl get pods -o custom-columns=name:metadata.name --no-headers) )

echo "This test is run on following workers."
echo "--------------------------------------"
for i in {0..3}
do
    echo "Name: ${workers[i]} -- Id: ${i}"
done

echo -e "\nRun tasks on all workers..."
for worker in ${workers[@]}
do
    (kubectl exec ${worker} -- python main.py --restart True) &
done

echo -e "\nWait for 35 seconds..."
sleep 35

pkill kubectl

echo -e "\nStop tasks..."
kubectl get pods -o custom-columns=name:metadata.name --no-headers | xargs -I{} kubectl exec {} -- pkill python

echo -e "\nGet logs on all workers..."
for worker in ${workers[@]}
do
    echo "${worker} did:"
    kubectl exec ${worker} -- cat data/output-tasks.txt
done

# echo -e "\nRemove the first worker..."
# workers=( ${workers[@]/${workers[0]}} )

# echo -e "\nRun tasks on following workers..."
# for worker in ${workers[@]}
# do
# (kubectl exec ${worker} -- python main.py )