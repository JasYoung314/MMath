import StaticHeuristic
import TwoQueueVia3 as TwoQueueVia
import Simm
import csv
import random
import StaticPolicy

@parallel
def func(n):
    while True :
        lmbda = random.uniform(20,50)
        mu = [random.uniform(2,5),random.uniform(2,5)]
        c = [random.randint(2,4),random.randint(2,4)]
        skip = [random.uniform(0.5,0.8),random.uniform(0.5,0.8)]

        print lmbda
        print mu
        print c
        print skip
        static_pol = StaticPolicy.find_opt(lmbda,mu,c,skip)[0]
        State = Simm.Func(lmbda,mu,c,skip,100,static_pol,False,500000,True,3600)[0]

        outfile = open('./Static/MDP/Comparisons/out/Ndata/Ndata(%.02f,%s,%s,%s).csv' %(lmbda,mu,c,skip),'ab')
        output = csv.writer(outfile)
        outrow = []
        outrow.append(lmbda)
        outrow.append(mu[0])
        outrow.append(mu[1])
        outrow.append(c[0])
        outrow.append(c[1])
        outrow.append(skip[0])
        outrow.append(skip[1])

        output.writerow(outrow)

        for i in range(20):
            for e in range(20):
                outrow = [e,i,State['%s,%s' %(e,i)].expectedi2]
                output.writerow(outrow)

        outfile.close()


list(func([1,2,3,4,5,6,7]))
