from __future__ import division

class System:
    def __init__(self,lmbda,mu,beta):
		#A series of MM1 queues
        self.lmbda = lmbda
        self.mu = mu
        self.beta = beta
        self.row = [lmbda/e for e in self.mu]
        self.Len = len(self.mu)
        self.exit_list = exit

def NaorCalc(Sys):
    '''
    Takes in the above system object and sets its threshold property to be a list of Naor thresholds for each queue
    '''
    threshold = []
    lmbda_list=[]
    P0_list=[]

    for e in range(Sys.Len):

        Center = Sys.beta[e]*Sys.mu[e]
        Condition = False
        n0 = 0

        while Condition == False:
            LHS = (n0*(1-Sys.row[e])- Sys.row[e]*(1-Sys.row[e]**n0))/(1-Sys.row[e])**2
            RHS = ((n0+1)*(1- Sys.row[e])-Sys.row[e]*(1-Sys.row[e]**(n0+1)))/(1-Sys.row[e])**2

            if LHS <= Center and Center <RHS:
                threshold.append(n0)
                Condition = True

            n0 +=1


    Sys.Threshold = threshold
