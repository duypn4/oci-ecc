from worker import Worker
import os

def get_worker_name():
    command = "kubectl get pods -o custom-columns=name:metadata.name --no-headers"
    stream = os.popen(command)

    return stream.readlines()

def run_app(workers):
    args = ""
    for worker in workers:
        args += worker.name
    
    command = "echo '" + args + "' | xargs -I{} kubectl exec {} -- python main.py"
    stream = os.popen(command)

    return stream.readlines()

def stop_app(workers):
    args = ""
    for worker in workers:
        args += worker.name
    
    command = "echo '" + args + "' | xargs -I{} kubectl exec {} -- pkill -9 python"
    stream = os.popen(command)

def show_output(lines):
    for line in lines:
        print(line.strip())

if __name__ == '__main__':
    workers = []
    names = get_worker_name()
    id = 0

    for name in names:
        worker = Worker(name, id)
        id += 1
        workers.append(worker)
    
    while True:
        print("**********************************")
        print("* 1. Run the app on all workers  *")
        print("* 2. Stop the app on all workers *")
        print("* 3. Remove a worker             *")
        print("* 4. Exit                        *")
        print("**********************************")
        
        choice = input("Enter your choice [1-4]: ")

        if choice == "1":
            run_app(workers)
        if choice == "2":
            stop_app(workers)
        if choice == "3":
            index = input("Enter a worker's index [0-4]: ")
            workers.pop(int(index))
            print(workers)
        if choice == "4":
            break