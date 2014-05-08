# This file was *autogenerated* from the file Comparisons.sage.
from sage.all_cmdline import *   # import sage library
_sage_const_2 = Integer(2); _sage_const_1 = Integer(1); _sage_const_0 = Integer(0); _sage_const_7 = Integer(7); _sage_const_6 = Integer(6); _sage_const_60 = Integer(60); _sage_const_61 = Integer(61); _sage_const_0p5 = RealNumber('0.5'); _sage_const_30 = Integer(30); _sage_const_2000 = Integer(2000)
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
    colors = rainbow(_sage_const_2 )

    for e in range(_sage_const_1 ,_sage_const_61 ):
        print "Testing %s" %(e)
        MDP = FHMM1.Queue(e,_sage_const_60 ,_sage_const_0p5 )
        MDPVal = MDP.SolveNHor(T=_sage_const_6 ,N=_sage_const_0 )

        Trials = [MM1Sim.Simul8(e,_sage_const_60 ,_sage_const_0p5 ,Policy=_sage_const_30 ,Simulation_Time =_sage_const_7 /e  ,warm_up = _sage_const_0 ) for k in range(_sage_const_2000 )]
        TrialsAve =  sum(Trials)/len(Trials)
        Sim_Plot_data.append([e,abs(TrialsAve-MDPVal)/abs(TrialsAve)])

        MDPAlt = FHMM1Alt.Queue(e,_sage_const_60 ,_sage_const_0p5 )
        MDPAltVal = MDPAlt.SolveNHor(T=_sage_const_6 ,N=_sage_const_0 )

        TrialsAlt = [MM1Sim.Simul8(e,_sage_const_60 ,_sage_const_0p5 ,Policy=_sage_const_30 ,Simulation_Time =_sage_const_7 /(e+_sage_const_60 )  ,warm_up = _sage_const_0 ) for k in range(_sage_const_2000 )]
        TrialsAveAlt =  sum(TrialsAlt)/len(TrialsAlt)
        SimAlt_Plot_data.append([e,abs(TrialsAveAlt-MDPAltVal)/abs(TrialsAveAlt)])
        print MDPVal,TrialsAve,MDPAltVal,TrialsAveAlt
    p += line(Sim_Plot_data,color = colors[_sage_const_1 ],legend_label= 'Jason')
    p += line(SimAlt_Plot_data,color =  colors[_sage_const_0 ],linestyle = '--',legend_label= 'Rob' )

    p.save('Comparisons.pdf')


