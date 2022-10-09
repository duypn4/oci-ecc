#!/bin/bash

# GLOBAL ARGUMENTS
data_folder="data/"
total_machine=6
code_parameter=3
step_save=10
time_sleep=0
run_times=4

# UTILITY FUNCTIONS
setup_experiment () {
    local experiment="EXP_SC${shifted_cyclic}_RT${run_time}_MD${machine_dead}."

    local data_file="${data_folder}input-matrix.txt"
    local task_file="${data_folder}${experiment}output-tasks.txt"
    status_file="${data_folder}${experiment}output-status.txt"
    exit_status_file="${data_folder}${experiment}output-exit-status.txt"
    local time_file0="${data_folder}${experiment}output-time.txt"
    local log_file="${data_folder}${experiment}output-log.txt"

    arguments="--total_machine ${total_machine} --run_time ${run_time} --run_times ${run_times} --code_parameter ${code_parameter} --shifted_cyclic ${shifted_cyclic} --step_save ${step_save} --time_sleep ${time_sleep} --data_file ${data_file} --task_file ${task_file} --status_file ${status_file} --exit_status_file ${exit_status_file} --time_file ${time_file0} --log_file ${log_file}"

	new_arguments="--total_machine $((total_machine-1)) --run_time ${run_time} --run_times ${run_times} --code_parameter ${code_parameter} --shifted_cyclic ${shifted_cyclic} --step_save ${step_save} --time_sleep ${time_sleep} --data_file ${data_file} --task_file ${task_file} --status_file ${status_file} --exit_status_file ${exit_status_file} --time_file ${time_file0} --log_file ${log_file}"

    echo "EXPERIMENT: ${experiment} ................."
}

get_workers () {
    workers=( $(cat workers) )

    echo "This test is run on following workers."
    echo "--------------------------------------"
    for i in $(seq 1 ${total_machine})
    do
        j=$((i-1))
        echo "Name: ${workers[j]} -- ID: ${i}"
    done
}

wait_worker_exited () {
    local run=0

    while true
    do
        echo "Waiting workers exited..."

        local count_machine=0

        sleep 1

        for worker in ${workers[@]}
        do
            exit_status=$(parallel-ssh -H ${worker} -i "cat ${exit_status_file} 2>/dev/null" | sed -n '2 p')
            if [ "${exit_status}" != "" ]
            then
                if [ "${exit_status%,*}" -gt "0" ]
                then
                    echo "${worker} exited"
                    count_machine=$((count_machine+1))
                fi
            fi
         done

         if [ "${count_machine}" -eq "${#workers[@]}" ]
         then
             break
         fi

         if [ "${run}" -eq "200" ]
         then
             break
         fi
         run=$((run+1))
    done
}

get_worker_logs () {
    local run=0

    while true
    do
        echo "Getting logs..."

        sleep 5
        local count_machine=0
        
        for worker in ${workers[@]}
        do
            status=$(parallel-ssh -H ${worker} -i "cat ${status_file} 2>/dev/null" | sed -n '2 p')
            if [ "${status}" != "" ]
            then
                if [ "${status%,*}" -gt "0" ]
                then
                    echo "${worker} did: ${status}"
                    count_machine=$((count_machine+1))
                fi
            fi
        done

        if [ "${count_machine}" -eq "${#workers[@]}" ]
        then
            break
        fi

        if [ "${run}" -eq "200" ]
        then
            break
        fi
        run=$((run+1))
    done
}

run_all_tasks () {
    echo "Run tasks on all workers..."

	for i in $(seq 1 ${total_machine})
 	do
		if [ "$1" = "" ]
		then

			worker=${workers[${i}-1]}
			#echo $worker
            parallel-ssh -H ${worker} -i "python3 main.py ${arguments} --machine_id ${i} >/dev/null 2>&1 &"
			#parallel-ssh -H ${worker} -i "python3 main.py ${arguments} --machine_id ${i}"
    		else
			if [ "${i}" -lt "${machine_dead}" ] 
			then
				worker=${workers[$i-1]}
			fi
			if [ "${i}" -gt "${machine_dead}" ] 
			then
				worker=${workers[$i-2]}
			fi
			if [ "${i}" -ne "${machine_dead}" ]
			then
				parallel-ssh -H ${worker} -i "python3 main.py ${new_arguments} --machine_id ${i} --machine_dead ${machine_dead} >/dev/null 2>&1 &"
				#parallel-ssh -H ${worker} -i "python3 main.py ${new_arguments} --machine_id ${i} --machine_dead ${machine_dead}"

			fi
		fi
	done
 }

#run_all_tasks () {
#    echo "Run tasks on all workers..."

#    i=0
#    for worker in ${workers[@]}
#    do
#        i=$((i+1))
#        if [ "$1" = "" ]
#        then
#            parallel-ssh -H ${worker} -i "python3 main.py ${arguments} --machine_id ${i} >/dev/null 2>&1 &"
#        else
#			new_arguments="--total_machine $((total_machine-1)) --run_time ${run_time} --run_times ${run_times} --code_parameter ${code_parameter} --shifted_cyclic ${shifted_cyclic} --step_save ${step_save} --time_sleep ${time_sleep} --data_file ${data_file} --task_file ${task_file} --status_file ${status_file} --exit_status_file ${exit_status_file} --time_file ${time_file0} --log_file ${log_file}"
#			echo $new_arguments
#         parallel-ssh -H ${worker} -i "python3 main.py ${new_arguments} --machine_id ${i} --machine_dead ${machine_dead} >/dev/null 2>&1 &"
#        fi
#    done
#}


stop_all_tasks () {
    echo "Stop tasks on all workers..."

    parallel-ssh -h workers "pkill python3"
}

compute_time0() {
    exe_time=0

    for worker in ${workers[@]}
    do
        local experiment="EXP_SC${shifted_cyclic}_RT0_MD0."
        local time_file0="${data_folder}${experiment}output-time.txt"

        local exe_time_worker=$(parallel-ssh -H ${worker} -i "cat ${time_file0}" | sed -n '2 p')

        if [ "1" -eq "$(echo "${exe_time_worker%,*} > ${exe_time}" | bc)" ]
        then
            exe_time="${exe_time_worker%,*}"
        fi
    done

    echo "Run time without killing: ${exe_time}s."
}

# CLEAR CONSOLE
clear

# RESET ALL EXPERIMENTS
parallel-ssh -h workers "pkill python3" >/dev/null 2>&1
parallel-ssh -h workers "rm -r data/EXP_*" >/dev/null 2>&1

# START EXPERIMENTS
for shifted_cyclic in {0..2}
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
            get_worker_logs
            compute_time0
        else
            if [ "${run_time}" -lt "${run_times}" ]
            then
                echo -e "\nCASE RT${run_time}: Workers self-exit at l${run_time}."
                for machine_dead in $(seq 1 ${total_machine})
                do
                    setup_experiment
                    get_workers
                    run_all_tasks
                    wait_worker_exited
                    workers=( ${workers[@]/${workers[$((machine_dead-1))]}} )
                    run_all_tasks "${machine_dead}"
                    get_worker_logs
                done
            fi
        fi
    done
done