import MM1Sim
import FHMM1
import FHMM1Alt
import matplotlib.pyplot as mtlp

if __name__ == "__main__":
    MDP_Plot_Data = []
    Sim_Plot_data = []
    MDPAlt_Plot_Data = []
    SimAlt_Plot_data = []
    p = plot([],axes_labels = ['$\lambda$','Percentage Difference'])
    colors = rainbow(2)

    for e in range(1,61):
        print "Testing %s" %(e)
        MDP = FHMM1.Queue(e,60,0.5)
        MDPVal = MDP.SolveNHor(T=6,N=0)

        Trials = [MM1Sim.Simul8(e,60,0.5,Policy=30,Simulation_Time =7/e  ,warm_up = 0) for k in range(2000)]
        TrialsAve =  sum(Trials)/len(Trials)
        Sim_Plot_data.append([e,abs(TrialsAve-MDPVal)/abs(TrialsAve)])

        MDPAlt = FHMM1Alt.Queue(e,60,0.5)
        MDPAltVal = MDPAlt.SolveNHor(T=6,N=0)

        TrialsAlt = [MM1Sim.Simul8(e,60,0.5,Policy=30,Simulation_Time =7/(e+60)  ,warm_up = 0) for k in range(2000)]
        TrialsAveAlt =  sum(TrialsAlt)/len(TrialsAlt)
        SimAlt_Plot_data.append([e,abs(TrialsAveAlt-MDPAltVal)/abs(TrialsAveAlt)])
        print MDPVal,TrialsAve,MDPAltVal,TrialsAveAlt
    p += line(Sim_Plot_data,color = colors[1],legend_label= 'Jason')
    p += line(SimAlt_Plot_data,color =  colors[0],linestyle = '--',legend_label= 'Rob' )

    p.save('Comparisons.pdf')


