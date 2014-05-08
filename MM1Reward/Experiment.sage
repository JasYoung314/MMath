import MM1Sim
import InfMM1
reload(MM1Sim)
reload(InfMM1)
import matplotlib.pyplot as mtlp

if __name__ == "__main__":
    MDP_Plot_Data = []
    Sim_Plot_data = []
    p = plot([],axes_labels = ['$\lambda$','Total Cost'])
    colors = rainbow(10)
    for i in range(1,8):
        disc = i/10

        MDP_Plot_Data = []
        Sim_Plot_data = []
        for e in range(1,20):
            print "Testing %s" %(e)
            MDP = InfMM1.Queue(e,10,0.5,Thresh =20 ,alpha = disc,epsilon = 0.01)
            MDPVal = MDP.SolveNHor(T=0,N=0)
            MDP_Plot_Data.append([e,MDPVal])

            Trials = [MM1Sim.Simul8(e,10,0.5,Policy=20,alpha = disc,Simulation_Time = 20 ,warm_up = 0) for k in range(2000)]
            TrialsAve =  sum(Trials)/len(Trials)
            Sim_Plot_data.append([e,TrialsAve])
            if e == 1:
                p += line(MDP_Plot_Data,color = colors[i])
                p += line((Sim_Plot_data),color =  colors[i],linestyle = '--',legend_label= '$ \\alpha = %s $' %disc)
            else:
                p += line(MDP_Plot_Data,color = colors[i])
                p += line((Sim_Plot_data),color =  colors[i])
            p.save('Graph.pdf')

    mtlp.figure()
    mtlp.hist(Trials,20)
    mtlp.savefig('hist.png')


