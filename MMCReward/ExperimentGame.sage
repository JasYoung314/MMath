import MMCSimInf
import Paralell
import MMCDiscreteUnbiased
reload(MMCDiscreteUnbiased)
reload(MMCSimInf)
reload(Paralell)
import matplotlib.pyplot as mtlp

if __name__ == "__main__":
    MDP_Plot_Data = []
    Sim_Plot_data = []

    p = plot([],axes_labels = ['$\lambda$','Total Cost'])
    colors = rainbow(30)


    for i in range(1):
        MDP_Plot_Data = []
        Sim_Plot_data = []
        DiscretePlotData = []
        DiffData = []

        for e in range(1,50):
            print "Testing %s" %(e)

            MDP = Paralell.Queue(e,5,3,1,Thresh = False,alpha = 0.6,epsilon = 0.01)
            Dummy = MDP.SolveNHor(T=0,N=0)
            MDPVal,m =Dummy[0],Dummy[1]
            print m
            DiscreteTrials = [MMCDiscreteUnbiased.DiscreteSim(e,5,3,1,m,50,0.6,0.01) for k in range(1000) ]
            DiscreteAve = sum(DiscreteTrials)/len(DiscreteTrials)
            DiscretePlotData.append([e,DiscreteAve])

            MDP_Plot_Data.append([e,MDPVal])
            Trials = [MMCSimInf.Simul8(e,5,1,C = 3,Policy = m,epsilon = 0.01,alpha = 0.6,Simulation_Time = 5 ,warm_up = 0) for k in range(1000)]
            TrialsAve =  sum(Trials)/len(Trials)

            Sim_Plot_data.append([e,TrialsAve])
            c = max(MDPVal,TrialsAve)
            d = min(MDPVal,TrialsAve)


            p += line(DiscretePlotData,color = colors[-1])
            p += line(MDP_Plot_Data,color = colors[i])
            p += line((Sim_Plot_data),color =  colors[i],linestyle = '--')
            p.save('./out/DemandRates/Graph.pdf')

        mtlp.figure()
        mtlp.hist(Trials,40)
        mtlp.savefig('hist.png')


