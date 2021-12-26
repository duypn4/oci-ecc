#!/bin/bash

# GLOBAL ARGUMENTS
shifted_cyclic=0
data_folder="data/"
total_machine=7
code_parameter=3
step_save=10
time_sleep=0
run_times=4
load_delay=10

# UTILITY FUNCTIONS
setup_experiment () {
    local experiment="EXP_SC${shifted_cyclic}_RT${run_time}_MD${machine_dead}."

    local data_file="${data_folder}input-matrix.txt"
    local task_file="${data_folder}${experiment}output-tasks.txt"
    status_file="${data_folder}${experiment}output-status.txt"
    local time_file0="${data_folder}${experiment}output-time.txt"
    local log_file="${data_folder}${experiment}output-log.txt"

    arguments="--total_machine ${total_machine} --code_parameter ${code_parameter} --shifted_cyclic ${shifted_cyclic} --step_save ${step_save} --time_sleep ${time_sleep} --data_file ${data_file} --task_file ${task_file} --status_file ${status_file} --time_file ${time_file0} --log_file ${log_file}"

    echo "EXPERIMENT: ${experiment} ................."
}

get_workers () {
    workers=( $(kubectl get pods -o custom-columns=name:metadata.name --no-headers) )

    echo "This test is run on following workers."
    echo "--------------------------------------"
    for i in $(seq 1 ${total_machine})
    do
        j=$((i-1))
        echo "Name: ${workers[j]} -- ID: ${i}"
    done

    pkill kubectl
}

get_worker_logs () {
    while true
    do
        echo "Getting logs..."

        local count_machine=0

        for worker in ${workers[@]}
        do
            status=$(kubectl exec ${worker} -- cat "${status_file}" 2>/dev/null)
            if [ "${status}" != "" ]
            then
                if [ "${status%,*}" -gt "0" ]
                then
                    echo "${worker} did: ${status}"
                    count_machine=$((count_machine+1))
                fi
            fi
        done

        if [ "${count_machine}" -eq "$1" ]
        then
            break
        fi
    done

    pkill kubectl
}

run_all_tasks () {
    echo "Run tasks on all workers..."

    i=0
    for worker in ${workers[@]}
    do
        i=$((i+1))
        if [ "$1" = "" ]
        then
            (kubectl exec ${worker} -- python main.py ${arguments} --machine_id ${i}) &
        else
            (kubectl exec ${worker} -- python main.py ${arguments} --machine_id ${i} --machine_dead ${machine_dead}) &
        fi
    done

    sleep ${load_delay}
    pkill kubectl
}

stop_all_tasks () {
    echo "Stop tasks on all workers..."
    kubectl get pods -o custom-columns=name:metadata.name --no-headers | xargs -I{} kubectl exec {} -- pkill python 2>/dev/null
    pkill kubectl
}

compute_time0() {
    exe_time=0

    for worker in ${workers[@]}
    do
        local experiment="EXP_SC${shifted_cyclic}_RT0_MD0."
        local time_file0="${data_folder}${experiment}output-time.txt"

        local exe_time_worker=$(kubectl exec ${worker} -- cat "${time_file0}")

        if [ "1" -eq "$(echo "${exe_time_worker%,*} > ${exe_time}" | bc)" ]
        then
            exe_time="${exe_time_worker%,*}"
        fi
    done

    echo "Run time without killing: ${exe_time}s."

    pkill kubectl
}

# CLEAR CONSOLE
clear

# START EXPERIMENTS
for shifted_cyclic in {0..1}
do
    machine_dead=0
    for run_time in $(seq 0 ${run_times})
    do
        if [ "${run_time}" -eq "0" ]
        then
            echo -e "\nCASE RT0: No machine is killed. Just to record the maximum run time."

            setup_experiment
            get_workers
            run_all_tasks
            get_worker_logs ${#workers[@]}
            compute_time0
        else
            echo -e "\nCASE RT${run_time}: Start to kill the machine at l${run_time}."
            
            for machine_dead in $(seq 1 ${total_machine})
            do
                setup_experiment
                get_workers
                run_all_tasks

                if [ "1" -eq "$(echo "${exe_time} > 0" | bc)" ]
                then
                    sleep_time="$(echo "${exe_time}*${run_time}/${run_times}" | bc)"
                    
                    echo "wait ${sleep_time}s before kill the machine..."
                    sleep ${sleep_time}
                    stop_all_tasks
                    workers=( ${workers[@]/${workers[${machine_dead}]}} )

                    run_all_tasks "${machine_dead}"

                    get_worker_logs ${#workers[@]}
                fi
            done
        fi
    done
done