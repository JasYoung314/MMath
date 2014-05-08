# This file was *autogenerated* from the file GameExperiment.sage.
from sage.all_cmdline import *   # import sage library
_sage_const_1 = Integer(1); _sage_const_0 = Integer(0); _sage_const_7 = Integer(7); _sage_const_5 = Integer(5); _sage_const_100 = Integer(100); _sage_const_0p0001 = RealNumber('0.0001'); _sage_const_0p3 = RealNumber('0.3'); _sage_const_10 = Integer(10); _sage_const_0p01 = RealNumber('0.01')
import ParalellGame as Social
import GameSelfish as Selfish
import random
if __name__ == "__main__":

    colors = rainbow(_sage_const_10 )
    while True:
        p = plot([],axes_labels = ['$\lambda$','PoA'])
        mu = random.uniform(_sage_const_1 ,_sage_const_10 )
        C = random.randint(_sage_const_1 ,_sage_const_5 )
        R = random.uniform(_sage_const_0p0001 ,_sage_const_0p3 )
        for i in range(_sage_const_1 ,_sage_const_7 ):
            disc = i/_sage_const_10 

            PoA_data = []
            for e in range(_sage_const_1 ,_sage_const_100 ):
                print "Testing %s" %(e)

                SocialQueue = Social.Queue(e,mu,C,R,alpha = disc,epsilon = _sage_const_0p01 )
                Dummy = SocialQueue.SolveNHor(T=_sage_const_0 ,N=_sage_const_0 )
                SocialVal =Dummy[_sage_const_0 ]

                SelfishQueue = Selfish.Queue(e,mu,C,R,alpha = disc,epsilon = _sage_const_0p01 )
                Dummy2 = SelfishQueue.SolveNHor(T=_sage_const_0 ,N=_sage_const_0 )
                SelfishVal = Dummy2[_sage_const_0 ]

                PoA_data.append([e,SelfishVal/SocialVal])


            p += line(PoA_data,color = colors[i],legend_label = '$ \\alpha = %s $' %disc)

            p.save('./out/GameModelBalk/PoABalkCost-%s-%s-%s.pdf'%(mu,C,R))

