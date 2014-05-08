import StaticHeuristic
import TwoQueueVia3 as TwoQueueVia
import Simm
import csv
import random
import time

@parallel
def func(n):
    while True :
        for e in range(20,50):
            lmbda = random.uniform(20,100)
            mu = [random.uniform(2,10),random.uniform(2,10)]
            c = [random.randint(2,7),random.randint(2,7)]
            skip = [random.uniform(0.5,5),random.uniform(0.5,5)]
            print lmbda
            print mu
            print c
            print skip

            start = time.time()
            Object2 = TwoQueueVia.Queue(lmbda,mu,c,skip,bounds = [e-1,e-1])
            ViaOut = Object2.VIA(0.1)
            viatime = time.time() - start

            Object5 = Simm.RoutingSimm(lmbda,mu,c,skip,500,ViaOut[2],100,[0,0],Policy_type = 'Matrix')

            start = time.time()
            Object6 = StaticHeuristic.independant(lmbda,mu,c,skip)
            indepPolicy = Object6.calculate_D(e,e)
            indeptime = time.time() - start

            Object7 = TwoQueueVia.Queue(lmbda,mu,c,skip,Policy = indepPolicy)
            Object8 = Simm.RoutingSimm(lmbda,mu,c,skip,500,indepPolicy,100,[0,0],Policy_type = 'Matrix')
            indepCost = Object7.VIA(0.1)[0]

            start = time.time()
            Object9 = StaticHeuristic.n2Simm(lmbda,mu,c,skip,run_time = 7200)
            SimmN2Policy = Object9.calculate_D(e,e)
            SimmN2time = time.time() - start

            Object10 = TwoQueueVia.Queue(lmbda,mu,c,skip,Policy = SimmN2Policy)
            SimmN2Cost = Object10.VIA(0.1)[0]
            Object11 = Simm.RoutingSimm(lmbda,mu,c,skip,500,SimmN2Policy,100,[0,0],Policy_type = 'Matrix')

            start = time.time()
            Object12 = StaticHeuristic.simulation(lmbda,mu,c,skip,run_time = 7200)
            SimmPolicy = Object12.calculate_D(e,e)
            Simmtime = time.time() - start

            Object13 = TwoQueueVia.Queue(lmbda,mu,c,skip,Policy = SimmPolicy)
            SimmCost = Object13.VIA(0.1)[0]
            Object14 = Simm.RoutingSimm(lmbda,mu,c,skip,500,SimmPolicy,100,[0,0],Policy_type = 'Matrix')

            start = time.time()
            Object15 = StaticHeuristic.n2Ana(lmbda,mu,c,skip,run_time = 7200)
            n2AnaPolicy = Object15.calculate_D(e,e)
            n2Anatime = time.time() - start

            Object16 = TwoQueueVia.Queue(lmbda,mu,c,skip,Policy = n2AnaPolicy)
            n2AnaCost = Object16.VIA(0.1)[0]
            Object17 = Simm.RoutingSimm(lmbda,mu,c,skip,500,n2AnaPolicy,100,[0,0],Policy_type = 'Matrix')

            start = time.time()
            Object18 = StaticHeuristic.n2approx(lmbda,mu,c,skip,run_time = 7200)
            n2approxPolicy = Object18.calculate_D(e,e)
            n2approxtime = time.time() - start

            Object19 = TwoQueueVia.Queue(lmbda,mu,c,skip,Policy = n2approxPolicy)
            n2approxCost = Object19.VIA(0.1)[0]
            Object20 = Simm.RoutingSimm(lmbda,mu,c,skip,500,n2approxPolicy,100,[0,0],Policy_type = 'Matrix')

            outfile = open('./Static/MDP/Comparisons/out/TimingsNew.csv','ab')
            output = csv.writer(outfile)

            outrow = []
            outrow.append(e)
            outrow.append(lmbda)
            outrow.append(mu[0])
            outrow.append(mu[1])
            outrow.append(c[0])
            outrow.append(c[1])
            outrow.append(skip[0])
            outrow.append(skip[1])

            outrow.append(indepCost)
            outrow.append(Object8[0])
            outrow.append(indeptime)
            outrow.append(indepPolicy.str())

            outrow.append(ViaOut[0])
            outrow.append(Object5[0])
            outrow.append(viatime)
            outrow.append(ViaOut[2].str())

            outrow.append(SimmCost)
            outrow.append(Simmtime)
            outrow.append(Object14[0])
            outrow.append(SimmPolicy.str())

            outrow.append(SimmN2Cost)
            outrow.append(Object11[0])
            outrow.append(SimmN2time)
            outrow.append(SimmN2Policy.str())

            outrow.append(n2AnaCost)
            outrow.append(Object17[0])
            outrow.append(n2Anatime)
            outrow.append(n2AnaPolicy.str())

            outrow.append(n2approxCost)
            outrow.append(Object20[0])
            outrow.append(n2approxtime)
            outrow.append(n2approxPolicy.str())

            output.writerow(outrow)
            outfile.close()

#list(func([1,2,3,4,5,6,7]))
func(1)
