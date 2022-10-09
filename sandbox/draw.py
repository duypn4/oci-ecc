


# read data file
def read_data(filename,line=0):
    result = 0
    with open(filename) as f:
        for i,number in enumerate(f):
            if i==line:
                result = int(number)
                break
    return result


# read experiment files
def read_experiments(SC=2,RT=3,MD=7,rtime=0):
    result_sc = []
    for sc in range(SC):
        result_rt = []
        for rt in range(RT):
            result_md = []
            for md in range(MD):
                filename = "data/EXP_SC{}_RT{}_MD{}.totaltime.txt".format(sc,rt+1,md+1)
                print(filename)
                datum = read_data(filename)
                result_md.append(datum)
            result_rt.append(sum(result_md)*1./len(result_md)-rtime)
        result_sc.append(result_rt)
    print(result_sc)
    return result_sc


if __name__ == "__main__":
    import matplotlib.pyplot as plt
    clabels = ['Original cyclic','Shifted cyclic']
    #clabels = ['Original cyclic','Shifted cyclic','Optimal cyclic']
    RT=3 # L1,L2,L3
    MD=7 # dead machine 1,2,3,4,5,6,7
    rtime=0 # running time (manual)
    SC=len(clabels) # cyclic=0,1
    colors = ['red','blue','green']
    data = read_experiments(SC=SC,RT=RT,MD=MD,rtime=rtime)
    xlabels = ["L{}".format(i+1) for i in range(RT)]
    width = 1./len(clabels)*0.6
    fig = plt.figure()
    for i,(y,color) in enumerate(zip(data,colors)):
        x = [j+i*width for j,_ in enumerate(y)]
        plt.bar(x,y,color=color,alpha=0.4,width=width)
    plt.xticks(x, xlabels)
    plt.legend(clabels,loc='upper left')
    plt.xlim([-0.5,RT])
    plt.savefig('draw.png')
    #plt.show()
