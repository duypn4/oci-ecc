import random,csv,time,argparse
import commons


# generate matrix A consists of rows x cols and vector X consists of cols
def generate_data(rows, cols,
        min_range=-100, max_range=100, verbose=False, filename='default.csv'):
    X = [random.randint(min_range,max_range) for i in range(0,cols)]
    A = [[random.randint(min_range,max_range) for _ in range(0,cols)] for _ in range(0,rows)]
    if verbose:
        print('X:',X,'\nA',A)
    header = [rows,cols,' # nrows, ncols, first numeric row is X vector, and the rest is X matrix']
    commons.write_csv([header]+[X]+A,file=filename)
    



# program starts herein
if __name__ == '__main__':
    time_start = time.time()
    parser = argparse.ArgumentParser()
    main_path = 'data/'
    parser.add_argument('--rows', type=int, default=5000, help='number of rows')
    parser.add_argument('--cols', type=int, default=2000, help='number of columns')
    parser.add_argument('--file', type=str, default='data/input-matrix.txt',
        help='file name that stores the data (matrix A and vector X)')
    args = parser.parse_args()
    generate_data(args.rows,args.cols,filename=args.file)
    time_completed = time.time() - time_start
    print('Execution time: ',time_completed)

