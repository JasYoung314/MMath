import StaticHeuristic
import TwoQueueVia3 as TwoQueueVia
import Simm
import csv
import random
@parallel
def func(n):
    while True :
        lmbda = random.uniform(20,50)
        mu = [random.uniform(5,10),random.uniform(5,10)]
        c = [random.randint(4,7),random.randint(4,7)]
        skip = [random.uniform(0.5,0.8),random.uniform(0.5,0.8)]

        print lmbda
        print mu
        print c
        print skip

        Object2 = TwoQueueVia.Queue(lmbda,mu,c,skip)
        ViaOut = Object2.VIA(0.1)
        Object5 = Simm.RoutingSimm(lmbda,mu,c,skip,500,ViaOut[2],100,[0,0],Policy_type = 'Matrix')


        Object6 = StaticHeuristic.independant(lmbda,mu,c,skip)
        indepPolicy = Object6.calculate_D(20,20)

        Object7 = TwoQueueVia.Queue(lmbda,mu,c,skip,Policy = indepPolicy)
        Object8 = Simm.RoutingSimm(lmbda,mu,c,skip,500,indepPolicy,100,[0,0],Policy_type = 'Matrix')
        indepCost = Object7.VIA(0.1)[0]

        Object9 = StaticHeuristic.n2Simm(lmbda,mu,c,skip)
        SimmN2Policy = Object9.calculate_D(20,20)
        Object10 = TwoQueueVia.Queue(lmbda,mu,c,skip,Policy = SimmN2Policy)

        SimmN2Cost = Object10.VIA(0.1)[0]
        Object11 = Simm.RoutingSimm(lmbda,mu,c,skip,500,SimmN2Policy,100,[0,0],Policy_type = 'Matrix')

        Object12 = StaticHeuristic.simulation(lmbda,mu,c,skip)
        SimmPolicy = Object9.calculate_D(20,20)
        Object13 = TwoQueueVia.Queue(lmbda,mu,c,skip,Policy = SimmPolicy)
        SimmCost = Object13.VIA(0.1)[0]
        Object14 = Simm.RoutingSimm(lmbda,mu,c,skip,500,SimmPolicy,100,[0,0],Policy_type = 'Matrix')

        outfile = open('./Static/MDP/Comparisons/out/Qinvestigation.csv','ab')
        output = csv.writer(outfile)
        outrow = []
        outrow.append(lmbda)
        outrow.append(mu[0])
        outrow.append(mu[1])
        outrow.append(c[0])
        outrow.append(c[1])
        outrow.append(skip[0])
        outrow.append(skip[1])

        outrow.append(indepCost)
        outrow.append(Object8[0])
        outrow.append(indepPolicy.str())

        outrow.append(ViaOut[0])
        outrow.append(Object5[0])
        outrow.append(ViaOut[2].str())

        outrow.append(SimmCost)
        outrow.append(Object14[0])
        outrow.append(SimmPolicy.str())

        outrow.append(SimmN2Cost)
        outrow.append(Object11[0])
        outrow.append(SimmN2Policy.str())

        output.writerow(outrow)
        outfile.close()
list(func([1,2,3,4,5,6,7]))
