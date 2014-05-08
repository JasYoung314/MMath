import random

import ValueIteration2
import MMCDiscreteUnbiased
reload(MMCDiscreteUnbiased)
reload(ValueIteration2)

if __name__ == "__main__":

    while True:
        p = plot([],axes_labels = ['$\lambda$','Total Cost'])
        colors = rainbow(30)
        MDP_Plot_Data = []
        DiscretePlotData = []
        testmu = random.uniform(5,10)
        testC = random.randint(1,5)
        testR = random.uniform(1,10)
        for e in range(1,50):
            print "Testing %s" %(e)

            MDP = ValueIteration2.Queue(lmbda = e, mu = testmu ,C = testC,R = testR,epsilon = 0.00001)
            MDPVal = MDP.ValueIter()

            DiscreteTrials = [MMCDiscreteUnbiased.DiscreteSim(lmbda = e,mu = testmu,C = testC ,Reward = testR,Policy = MDPVal[1],Simulation_Time = 200,warm_period = 50) for k in range(500) ]
            DiscreteAve = sum(DiscreteTrials)/len(DiscreteTrials)

            DiscretePlotData.append([e,DiscreteAve])
            MDP_Plot_Data.append([e,MDPVal[0]])

            if len(MDP_Plot_Data) == 1:
                p += line(MDP_Plot_Data,color = 'red',legend_label = 'MDP' )
                p += line(DiscretePlotData,color = 'blue', legend_label = 'Discrete Sim')
            else:
                p += line(MDP_Plot_Data,color = 'red')
                p += line(DiscretePlotData,color = 'blue' )

            p.save('./out/LongRunComp/VIA2-%s-%s-%s.pdf' %(testmu,testC,testR))


