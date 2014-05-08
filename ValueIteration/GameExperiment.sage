import DiscountingGameSocial as Social
import DiscountingGameSelfish as Selfish
import random
if __name__ == "__main__":

    colors = rainbow(10)
    while True:
        p = plot([],axes_labels = ['$\lambda$','PoA'])
        mu = random.uniform(0.5,1.5)
        C = random.randint(1,1)
        R = random.uniform(0.1,1)
        for i in range(1,10):
            disc = i/10

            PoA_data = []
            for e in range(1,100):
                print "Testing %s" %(e)

                SocialQueue = Social.Queue(e,mu,C,R,alpha = disc,epsilon = 0.0000000001)
                Dummy = SocialQueue.ValueIter()
                SocialVal =Dummy[0]['[0, 0]']

                SelfishQueue = Selfish.Queue(e,mu,C,R,alpha = disc,epsilon = 0.0000000001)
                Dummy2 = SelfishQueue.ValueIter()
                SelfishVal = Dummy2[0]['[0, 0]']
                print SelfishVal
                print SocialVal
                PoA_data.append([e,1/(SelfishVal/SocialVal)])


            p += line(PoA_data,color = colors[i],legend_label = '$ \\alpha = %s $' %disc)

            p.save('./out/GameModel/PoALongRun-%s-%s-%s.pdf'%(mu,C,R))


