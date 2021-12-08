import argparse,sys,time,math
import commons



# read matrix data
def read_data(filename):
    try:
        data = commons.read_csv(filename,type='int',header_lines=0)
        result = (commons.transpose(data))[0]
    except:
        pass
        result = []
    return result


# read matrix data
def write_data(filename,task_list,mode='w'):
    commons.write_csv(task_list,file=filename,mode=mode)
    

# read matrix data
def read_matrix(filename,verbose=False):
    data = commons.read_csv(filename,type='float')
    X = data[0]
    A = data[1:]
    if verbose==True:
        print('X:',X,'\nA',A)
    return A,X


# convert from taskset ID and machine ID to assigned tasks
def assigned_tasks(total_machine,
        machine_current,
        tasks_all,
        parameter_code,
        machine_dead=0,
        verbose=True):
    # machine_id: n = 1,2,...,N
    # total_machine: N
    # all_tasks: F
    # code_parameter: L
    # machine_dead: n0
    # --- no dead machine -------
    a1 = (machine_current-1) * tasks_all / total_machine # (n-1)*F/N
    b1 = a1 + parameter_code * tasks_all / total_machine - 1
    a2 = (machine_current-2) * tasks_all / total_machine # (n-1)*F/N
    b2 = a2 + parameter_code * tasks_all / total_machine - 1
    if (machine_dead>0) and (machine_current>machine_dead):
        a,b = a2,b2
    else:
        a,b = a1,b1
    tasks = [t % tasks_all for t in range(int(a),int(b))]
    if verbose:
        print('TASKS:',tasks)
    # tasks = []
    # if taskset_id<total_machine:
        # for simpl icity divide task equally - this algorithm must be improved by Hoang
        # tasks_by_amachine = math.ceil(total_task/total_machine)
        # tasklist_start = (taskset_id-1)*tasks_by_amachine
        # tasklist_end = min(taskset_id*tasks_by_amachine,total_task)
        # tasks = [i for i in range(tasklist_start,tasklist_end)]
    #    if verbose:
    #        print(tasklist_start,tasklist_end)
    #        print('Tasks:',tasks)
    #else:
    #    print('The task assign is simple now, requiring taskset_id<total_machine')
    return tasks
    

# def compute tasks
def compute_tasks(tasks,A,X,filename,verbose=True,log_file='',time_start=0):
    # for simplicity now, each task is just an multiplication of a row of matrix A and X
    completed_tasks = []
    completed_value = []
    for t in tasks:
        At = A[t]
        value = 0
        for a,x in zip(At,X):
            value += a*x
        completed_tasks.append(t) # store value in case it must be stop
        completed_value = [value] # in case we want to store value
        time.sleep(5) # to simulate the computation time - should change in real case **********
        write_data(filename,[t],mode='a')
        time_completed = time.time() - time_start
        log = 'Task {} completed with value {} after time of {}.'.format(t,value,time_completed)
        if verbose:
            print(log)
        if len(log_file)>0:
            write_data(args.log_file,[log],mode='a')
    return completed_tasks,completed_value
    

# program starts herein
if __name__ == '__main__':
    time_start = time.time()
    parser = argparse.ArgumentParser()
    main_path = 'data/'
    parser.add_argument('--machine_id', type=int, default=1,
        help='ID of machine/server that does computation A*X (0 mean inactive machine ID)')
    #parser.add_argument('--taskset_id', type=int, default=3,
    #    help='ID of task set which consist a list of tasks (0 mean no task)')
    parser.add_argument('--total_machine', type=int, default=4,
        help='total number of machine/server used (0 mean no computation)')
    parser.add_argument('--data_file', type=str, default='data/input-matrix.txt',
        help='input file that stores the data (matrix A and vector X)')
    parser.add_argument('--task_file', type=str, default='data/output-tasks.txt',
        help='output file that stores the completed tasks (default: data/output-tasks.txt)')
    parser.add_argument('--status_file', type=str, default='data/output-status.txt',
        help='output file that stores the outcomes (default: data/output-status.txt)')
    parser.add_argument('--log_file', type=str, default='data/output-log.txt',
        help='output file that stores the outcomes (default: data/output-log.txt)')
    parser.add_argument('--restart', type=bool, default=False,
        help='restart running all tasks (True) or continue the uncompleted tasks listed in task_file (False, defaut)')
    parser.add_argument('--verbose', type=bool, default=True,
        help='print every steps (True, default) or not (False)')
    args = parser.parse_args()
    status = read_data(args.status_file)


    # default mode
    if args.restart: # reset
        status = [0]
        write_data(args.status_file,status)
        write_data(args.task_file,[])
        write_data(args.log_file,[])


    print('status',status)
    if (len(status)==0) or (status[0]==0): # only run when there is no stop requirement
        if (args.machine_id>0) and len(args.data_file)>0 and (args.total_machine>0):
            log = '# Machine ID: {}\n# Total machines: {}\n# Data file: {}\nRunning...'.format(args.machine_id,args.total_machine,args.data_file)
            print(log)
            write_data(args.log_file,[log],mode='a')
            A,X = read_matrix(args.data_file)
            total_task = len(A) # this should be fixed because now we consider one multiplication line as a task
            parameter_code = 3
            tasks_all = assigned_tasks(args.total_machine,args.machine_id,total_task,parameter_code)
            if args.restart:
                tasks_done = []
            else:
                tasks_done = read_data(args.task_file) # [] # read from file
            tasks_remain = []
            for t in tasks_all:
                if t not in tasks_done:
                    tasks_remain.append(t)
            if args.verbose:
                print('Tasks done:',tasks_done)
                print('Tasks remain:',tasks_remain)
            write_data(args.log_file,['Tasks done:',tasks_done],mode='a')
            write_data(args.log_file,['Tasks remain:',tasks_remain],mode='a')
            compute_tasks(tasks_remain,A,X,args.task_file,log_file=args.log_file,time_start=time_start)
        else:
            print('Something wrong with arguments.')
        time_completed = time.time() - time_start
        print('Execution time: ',time_completed)
        write_data(args.log_file,['Execution time: ',time_completed],mode='a')
        write_data(args.status_file,[1])
    else:
        log = 'All tasks completed. No computation required.'
        print(log)
        write_data(args.log_file,[log])

