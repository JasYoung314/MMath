import MMCSimInf
import Paralell
reload(MMCSimInf)
reload(Paralell)
import matplotlib.pyplot as mtlp

if __name__ == "__main__":
    MDP_Plot_Data = []
    Sim_Plot_data = []

    p = plot([],axes_labels = ['$\lambda$','Total Cost'])
    p2 = plot([],axes_labels = ['$\lambda$','Total Cost'])
    colors = rainbow(20)


    for i in range(1,20):
        MDP_Plot_Data = []
        Sim_Plot_data = []
        DiffData = []
        for e in range(1,10):
            print "Testing %s" %(e)

            MDP = Paralell.Queue(i,e,2,1.0,alpha = 0.6,epsilon = 0.01)
            Dummy = MDP.SolveNHor(T=0,N=0)
            MDPVal,m =Dummy[0],Dummy[1]
            MDP_Plot_Data.append([e,MDPVal])

            Trials = [MMCSimInf.Simul8(i,e,1.0,C = 2,Policy=m,epsilon = 0.01,alpha = 0.6,Simulation_Time = 10 ,warm_up = 0) for k in range(2000)]
            TrialsAve =  sum(Trials)/len(Trials)
            Sim_Plot_data.append([e,TrialsAve])
            c = max(MDPVal,TrialsAve)
            d = min(MDPVal,TrialsAve)

            DiffData.append([e,abs(c-d)/abs(c)])


        p += line(MDP_Plot_Data,color = colors[i])
        p += line((Sim_Plot_data),color =  colors[i],linestyle = '--')
        p.save('./out/ServiceRates/Graph.pdf')

        p2 += line(DiffData,color = colors[i])
        p2.save('./out/ServiceRates/DiffData.pdf')
        mtlp.figure()
        mtlp.hist(Trials,20)
        mtlp.savefig('hist.png')


