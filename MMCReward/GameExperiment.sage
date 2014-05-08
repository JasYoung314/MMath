import ParalellGame as Social
import GameSelfish as Selfish
import random
if __name__ == "__main__":

    colors = rainbow(10)
    while True:
        p = plot([],axes_labels = ['$\lambda$','PoA'])
        mu = random.uniform(1,10)
        C = random.randint(1,5)
        R = random.uniform(0.0001,0.3)
        for i in range(1,7):
            disc = i/10

            PoA_data = []
            for e in range(1,100):
                print "Testing %s" %(e)

                SocialQueue = Social.Queue(e,mu,C,R,alpha = disc,epsilon = 0.01)
                Dummy = SocialQueue.SolveNHor(T=0,N=0)
                SocialVal =Dummy[0]

                SelfishQueue = Selfish.Queue(e,mu,C,R,alpha = disc,epsilon = 0.01)
                Dummy2 = SelfishQueue.SolveNHor(T=0,N=0)
                SelfishVal = Dummy2[0]

                PoA_data.append([e,SelfishVal/SocialVal])


            p += line(PoA_data,color = colors[i],legend_label = '$ \\alpha = %s $' %disc)

            p.save('./out/GameModelBalk/PoABalkCost-%s-%s-%s.pdf'%(mu,C,R))

