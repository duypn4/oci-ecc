import argparse,sys,time,math
import commons


# read matrix data
def read_data(filename,verbose=False):
    data = commons.read_csv(filename,type='float')
    X = data[0]
    A = data[1:]
    if verbose==True:
        print('X:',X,'\nA',A)
    return A,X


# convert from taskset ID and machine ID to assigned tasks
def assigned_tasks(machine_id,taskset_id,total_machine,total_task,verbose=True):
    tasks = []
    if taskset_id<total_machine:
        # for simpl icity divide task equally - this algorithm must be improved by Hoang
        tasks_by_amachine = math.ceil(total_task/total_machine)
        tasklist_start = (taskset_id-1)*tasks_by_amachine
        tasklist_end = min(taskset_id*tasks_by_amachine,total_task)
        tasks = [i for i in range(tasklist_start,tasklist_end)]
        if verbose:
            print(tasklist_start,tasklist_end)
            print('Tasks:',tasks)
    else:
        print('The task assign is simple now, requiring taskset_id<total_machine')
    return tasks
    

# def compute tasks
def compute_tasks(tasks,A,X,verbose=True):
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
        if verbose:
            print('Task {} completed with value {}.'.format(t,value))
    return completed_tasks,completed_value
    

# program starts herein
if __name__ == '__main__':
    time_start = time.time()
    parser = argparse.ArgumentParser()
    main_path = 'data/'
    parser.add_argument('--machine_id', type=int, default=1,
        help='ID of machine/server that does computation A*X (0 mean inactive machine ID)')
    parser.add_argument('--taskset_id', type=int, default=3,
        help='ID of task set which consist a list of tasks (0 mean no task)')
    parser.add_argument('--total_machine', type=int, default=4,
        help='total number of machine/server used (0 mean no computation)')
    parser.add_argument('--data_file', type=str, default='data/input-matrix.csv',
        help='file name that stores the data (matrix A and vector X) (blank name mean no data)')
    args = parser.parse_args()
    
    
    if (args.machine_id>0) and (args.taskset_id>0) and len(args.data_file)>0 and (args.total_machine>0):
        print('# Machine ID: {}\n# Taskset ID: {}\nRunning...'.format(args.machine_id,args.taskset_id))
        A,X = read_data(args.data_file)
        total_task = len(A) # this should be fixed because now we consider one multiplication line as a task
        tasks = assigned_tasks(args.machine_id,args.taskset_id,args.total_machine,total_task)
        compute_tasks(tasks,A,X)
    else:
        print('Something wrong with arguments.')
    time_completed = time.time() - time_start
    print('Execution time: ',time_completed)
    time.sleep(3600)
