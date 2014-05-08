import StaticHeuristic
import TwoQueueVia3 as TwoQueueVia
import Simm
import csv
import random
import time

@parallel
def func(n):
    #infile = open('./out/Timings.csv','rb')
    infile = open('./Static/MDP/Comparisons/out/Timings.csv','rb')
    data = csv.reader(infile)
    data = [row for row in data]
    infile.close()

    for row in data:

        e = eval(row[0])
        lmbda = eval(row[1])
        mu = [eval(row[2]),eval(row[3])]
        c = [eval(row[4]),eval(row[5])]
        skip = [eval(row[6]),eval(row[7])]

        print lmbda
        print mu
        print c
        print skip

        start = time.time()
        Object6 = StaticHeuristic.n2Ana(lmbda,mu,c,skip)
        N2Policy = Object6.calculate_D(e,e)
        N2time = time.time() - start

        Object7 = TwoQueueVia.Queue(lmbda,mu,c,skip,Policy = N2Policy)
        Object8 = Simm.RoutingSimm(lmbda,mu,c,skip,500,N2Policy,100,[0,0],Policy_type = 'Matrix')
        N2Cost = Object7.VIA(0.1)[0]

        outfile = open('./Static/MDP/Comparisons/out/Timings2.csv','ab')
        #outfile = open('./out/Timings2.csv','ab')
        output = csv.writer(outfile)
        outrow = row + [N2Cost,Object8[0],N2time,N2Policy.str()]

        output.writerow(outrow)
        outfile.close()

func(1)
