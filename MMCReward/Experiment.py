# This file was *autogenerated* from the file Experiment.sage.
from sage.all_cmdline import *   # import sage library
_sage_const_3 = Integer(3); _sage_const_1 = Integer(1); _sage_const_0 = Integer(0); _sage_const_5 = Integer(5); _sage_const_1000 = Integer(1000); _sage_const_0p6 = RealNumber('0.6'); _sage_const_30 = Integer(30); _sage_const_0p01 = RealNumber('0.01'); _sage_const_50 = Integer(50)
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
    colors = rainbow(_sage_const_30 )


    for i in range(_sage_const_1 ):
        MDP_Plot_Data = []
        Sim_Plot_data = []
        DiscretePlotData = []
        DiffData = []

        for e in range(_sage_const_1 ,_sage_const_50 ):
            print "Testing %s" %(e)

            MDP = Paralell.Queue(e,_sage_const_5 ,_sage_const_3 ,_sage_const_1 ,Thresh = False,alpha = _sage_const_0p6 ,epsilon = _sage_const_0p01 )
            Dummy = MDP.SolveNHor(T=_sage_const_0 ,N=_sage_const_0 )
            MDPVal,m =Dummy[_sage_const_0 ],Dummy[_sage_const_1 ]
            print m
            DiscreteTrials = [MMCDiscreteUnbiased.DiscreteSim(e,_sage_const_5 ,_sage_const_3 ,_sage_const_1 ,m,_sage_const_50 ,_sage_const_0p6 ,_sage_const_0p01 ) for k in range(_sage_const_1000 ) ]
            DiscreteAve = sum(DiscreteTrials)/len(DiscreteTrials)
            DiscretePlotData.append([e,DiscreteAve])

            MDP_Plot_Data.append([e,MDPVal])
            #Trials = [MMCSimInf.Simul8(e,5,1,C = 3,Policy = m,epsilon = 0.01,alpha = 0.6,Simulation_Time = 5 ,warm_up = 0) for k in range(1000)]
            #TrialsAve =  sum(Trials)/len(Trials)

            #Sim_Plot_data.append([e,TrialsAve])

            if len(MDP_Plot_Data) == _sage_const_1 :

                p += line(DiscretePlotData,color = 'blue',legend_label = 'Discrete Simulation')
                p += line(MDP_Plot_Data,color = 'red',legend_label = 'MDP')
#                p += line((Sim_Plot_data),color =  'blue',linestyle = '--',legend_label = 'Continuous Simulation')
            else:
                p += line(DiscretePlotData,color = 'blue')
                p += line(MDP_Plot_Data,color = 'red')
#                p += line((Sim_Plot_data),color =  'blue',linestyle = '--')
            p.save('./out/DemandRates/Woof.pdf')



