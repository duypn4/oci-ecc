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


# write matrix data
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
        num_rows,
        parameter_code,
        machine_dead=0,
        shifted_cyclic=0,
        verbose=False):
    # machine_id: n = 1,2,...,N
    # total_machine: N
    # all_tasks: F
    # code_parameter: L
    # machine_dead: n0
    # --- no dead machine -------
    # CHANGED: F -> num_tasks
    num_tasks = 210
    d = 0
    if (machine_dead!=0) and (shifted_cyclic==1): # shifted cyclic=True
        d = (total_machine - machine_dead) - \
            math.floor( (total_machine + parameter_code-2)/2 ) * num_tasks/total_machine/(total_machine-1)
        # d = (N-n0) - [(N+L-2)/2] F/(N(N-1)) - ASSUMING THAT THE SYSTEM STARTS FROM A 0-SHIFTED CYCLIC (NO SHIFT) AND IS TRANSITIONED ONCE ONLY
    a1 = (machine_current-1) * num_tasks / total_machine # (n-1)*F/N
    b1 = a1 + parameter_code * num_tasks / total_machine - 1
    a2 = (machine_current-2) * num_tasks / total_machine # (n-1)*F/N
    b2 = a2 + parameter_code * num_tasks / total_machine - 1
    if (machine_dead>0) and (machine_current>machine_dead):
        a,b = a2+d,b2+d
    else:
        a,b = a1+d,b1+d
    tasks = [t % num_tasks for t in range(int(a),int(b)+1)]
    # sn
    if verbose:
        print('SHIFTED AMOUNT d = ',d)
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
def compute_tasks(tasks,A,X,filename,\
        verbose=False,log_file='',time_sleep=0,time_start=0,step_save=1):
    # for simplicity now, each task is just an multiplication of a row of matrix A and X
    # HOANG: NOW WE MAKE EACH TASK CORRESPOND TO MATRIX A (FUTURE: EVERY WORKER HAS A DIFFERENT MATRIX A FOR EACH TASK
    completed_tasks = []
    completed_value = []
    #buffer = []
    count = 0
    for t in tasks:
        #count += 1
        task_values = []  # stores values corresponding to one task
        for i in range(len(A)):
            Ai = A[i]
            value = 0
            for a,x in zip(Ai,X):
                value += a*x
            task_values.append(value);
        completed_tasks.append(t) # after the for loop, task t has been completed
        completed_value += task_values # append the task value
        count += 1  # HOANG: to signify that a new task (t) has been completed
        #time.sleep(time_sleep) # to simulate the computation time  HOANG: NOT SURE WHY SLEEP HERE?
        #buffer.append([t])     # HOANG: NO USAGE FOR 'BUFFER'? REPLACED BY 'COMPLETED_TASKS'
        if count>=step_save:
            time_completed = time.time() - time_start
            #for b in buffer:   #HOANG: 'b' IS JUST 't'?
                #write_data(filename,b,mode='a')
            write_data(filename, [t], mode='a')
                #log = 'Task {} completed with value {} after time of {}.'.format(b[0],task_values,time_completed)
            log = 'Task {} completed after time of {}.'.format(t, time_completed)
            if verbose:
                print(log)
            if len(log_file)>0:
                write_data(log_file,[log],mode='a')
            count = 0 # reset counter
            #buffer = [] # reset buffer
    return completed_tasks,completed_value

start_time_worker = time.time()

# program starts herein
if __name__ == '__main__':
    time_start = time.time()
    parser = argparse.ArgumentParser()
    main_path = 'data/'
    parser.add_argument('--machine_id', type=int, default=1,
        help='ID of machine/server that does computation A*X (0 mean inactive machine ID)')
    parser.add_argument('--machine_dead', type=int, default=0,
        help='ID of machine/server to be turn off (0 mean no dead machine)')
    parser.add_argument('--code_parameter', type=int, default=3,
        help='code parameter (default: 3)')
    parser.add_argument('--total_machine', type=int, default=7,
        help='total number of machine/server used (0 mean no computation)')
    parser.add_argument('--data_file', type=str, default='data/input-matrix.txt',
        help='input file that stores the data (matrix A and vector X)')
    parser.add_argument('--task_file', type=str, default='data/output-tasks.txt',
        help='output file that stores the completed tasks (default: data/output-tasks.txt)')
    parser.add_argument('--status_file', type=str, default='data/output-status.txt',
        help='output file that stores the outcomes (default: data/output-status.txt)')
    parser.add_argument('--time_file', type=str, default='data/output-status.txt',
        help='output file that stores the running time (default: data/output-time.txt)')
    parser.add_argument('--log_file', type=str, default='data/output-log.txt',
        help='output file that stores the outcomes (default: data/output-log.txt)')
    parser.add_argument('--time_sleep', type=int, default=0,
        help='sleep time (0: no sleep, default) or time (in second)')
    parser.add_argument('--step_save', type=int, default=1,
        help='save data after step_save task')
    parser.add_argument('--shifted_cyclic', type=int, default=0,
        help='no shifted cyclic (False, default) or not (True)')
    parser.add_argument('--restart', type=bool, default=False,
        help='restart running all tasks (True) or continue the uncompleted tasks listed in task_file (False, default)')
    parser.add_argument('--verbose', type=bool, default=False,
        help='print every steps (True) or not (False, default)')
    args = parser.parse_args()
    status = read_data(args.status_file)
    #time_completed = time.time() - time_start
    #print('Reading time: ',time_completed)  #HOANG: REAL READING TIME IS WHEN A, X ARE READ, NOT HERE

    # default mode
    if args.restart: # reset
        status = [0]
        write_data(args.status_file,status)
        write_data(args.task_file,[])
        write_data(args.log_file,[])

    #start_time = time.time()
    write_data(args.log_file,['Start time: ',start_time_worker],mode='a')
    # write_data(args.time_file,[start_time],mode='a')

    #print('status',status)
    if (len(status)==0) or (status[0]==0): # only run when there is no stop requirement
        if (args.machine_id>0) and len(args.data_file)>0 and (args.total_machine>0):
            log = '# Machine ID: {}\n# Total machines: {}\n# Data file: {}\nRunning...'.format(args.machine_id,args.total_machine,args.data_file)
            print(log)
            write_data(args.log_file,[log],mode='a')
            A,X = read_matrix(args.data_file)
            time_completed = time.time() - time_start
            print('Reading time: ',time_completed)  #HOANG: REAL READING TIME WHEN A, X ARE READ
            num_rows = len(A) # this should be fixed because now we consider one multiplication line as a task
            #parameter_code = 3
            tasks_all = assigned_tasks(args.total_machine,\
                args.machine_id,num_rows,args.code_parameter,\
                machine_dead=args.machine_dead,shifted_cyclic=args.shifted_cyclic, verbose=args.verbose)
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
            compute_tasks(tasks_remain,A,X,args.task_file,step_save=args.step_save,\
                log_file=args.log_file,time_start=time_start,time_sleep=args.time_sleep)
            #compute_tasks(tasks_remain,A,X,args.task_file,step_save=args.step_save,\
            #    log_file=args.log_file,time_sleep=args.time_sleep)
        else:
            if args.verbose:
                print('Something wrong with arguments.')
            write_data(args.log_file,['Something wrong with arguments'],mode='a')
        time_end = time.time()
        completed_time = time_end-time_start
        print('End time: ',time_end)
        write_data(args.log_file,['End time: ',time_end],mode='a')
        write_data(args.time_file,[completed_time])
        write_data(args.status_file,[1])
    else:
        log = 'All tasks completed. No computation required.'
        if args.verbose:
            print(log)
        write_data(args.log_file,[log])

    time_completed = time.time() - time_start
    print('Execution time : ',time_completed)
