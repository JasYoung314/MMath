# This file was *autogenerated* from the file /home/c1012211/Static/MDP/Comparisons/RunExpTime.sage.
from sage.all_cmdline import *   # import sage library
import StaticHeuristic
import TwoQueueVia3 as TwoQueueVia
import Simm
import csv
import random

@parallel
def func(n):
    while True :
        lmbda = random.uniform(Integer(20),Integer(50))
        mu = [random.uniform(Integer(2),Integer(5)),random.uniform(Integer(2),Integer(5))]
        c = [random.randint(Integer(2),Integer(4)),random.randint(Integer(2),Integer(4))]
        skip = [random.uniform(RealNumber('0.5'),RealNumber('0.8')),random.uniform(RealNumber('0.5'),RealNumber('0.8'))]


        for e in range(Integer(1),Integer(10)):
            print lmbda
            print mu
            print c
            print skip

            Object2 = TwoQueueVia.Queue(lmbda,mu,c,skip)
            ViaOut = Object2.VIA(RealNumber('0.1'))

            Object1 = StaticHeuristic.n2approx(lmbda,mu,c,skip)
            HeuristicPolicy = Object1.calculate_D(Integer(20),Integer(20))
            Object3 = TwoQueueVia.Queue(lmbda,mu,c,skip,Policy = HeuristicPolicy)
            HeuristicCost = Object3.VIA(RealNumber('0.1'))[Integer(0)]

            Object4 = Simm.RoutingSimm(lmbda,mu,c,skip,Integer(500),HeuristicPolicy,Integer(100),[Integer(0),Integer(0)],Policy_type = 'Matrix')
            Object5 = Simm.RoutingSimm(lmbda,mu,c,skip,Integer(500),ViaOut[Integer(2)],Integer(100),[Integer(0),Integer(0)],Policy_type = 'Matrix')

            Object6 = StaticHeuristic.independant(lmbda,mu,c,skip)
            indepPolicy = Object6.calculate_D(Integer(20),Integer(20))

            Object7 = TwoQueueVia.Queue(lmbda,mu,c,skip,Policy = indepPolicy)
            Object8 = Simm.RoutingSimm(lmbda,mu,c,skip,Integer(500),indepPolicy,Integer(100),[Integer(0),Integer(0)],Policy_type = 'Matrix')
            indepCost = Object7.VIA(RealNumber('0.1'))[Integer(0)]

            Object9 = StaticHeuristic.simulation(lmbda,mu,c,skip,e*Integer(3600))
            SimmPolicy = Object9.calculate_D()
            Object10 = TwoQueueVia.Queue(lmbda,mu,c,skip,Policy = SimmPolicy)
            SimmCost = Object10.VIA(RealNumber('0.1'))[Integer(0)]
            Object11 = Simm.RoutingSimm(lmbda,mu,c,skip,Integer(500),SimmPolicy,Integer(100),[Integer(0),Integer(0)],Policy_type = 'Matrix')


            outfile = open('./Static/MDP/Comparisons/out/RunTimeExp(%s,%s,%s,%s).csv' %(lmbda,mu,c,skip),'ab')
            output = csv.writer(outfile)
            outrow = [e*Integer(3600)]
            outrow.append(lmbda)
            outrow.append(mu[Integer(0)])
            outrow.append(mu[Integer(1)])
            outrow.append(c[Integer(0)])
            outrow.append(c[Integer(1)])
            outrow.append(skip[Integer(0)])
            outrow.append(skip[Integer(1)])

            outrow.append(HeuristicCost)
            outrow.append(Object4[Integer(0)])
            outrow.append(HeuristicPolicy.str())

            outrow.append(indepCost)
            outrow.append(Object8[Integer(0)])
            outrow.append(indepPolicy.str())

            outrow.append(ViaOut[Integer(0)])
            outrow.append(Object5[Integer(0)])
            outrow.append(ViaOut[Integer(2)].str())

            outrow.append(SimmCost)
            outrow.append(Object11[Integer(0)])
            outrow.append(SimmPolicy.str())

            output.writerow(outrow)
            outfile.close()


list(func([Integer(1),Integer(2),Integer(3),Integer(4),Integer(5),Integer(6),Integer(7),Integer(8)]))
