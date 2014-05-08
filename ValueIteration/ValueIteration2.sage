
class Queue: #A class for the queueing system
    def __init__(self,lmbda,mu,C,R,Thresh = False,epsilon = 0.01):
        self.lmbda = lmbda
        self.mu = mu
        self.R = R
        self.servers = C
        self.epsilon = epsilon

        self.StateValues = {}
        self.StateValues[0] = {}
        self.StateActions = {}
        self.StateActions[0] = {}
        self.states = []
        self.Selfish =  int(R*mu*C) - 1

        for e in range(self.Selfish + 1):
            self.states.append([e,0])
            self.StateValues[0]['%s' %([e,0])] = 0
            self.StateActions[0]['%s' %([e,0])] = 0
            self.states.append([e,1])
            self.StateValues[0]['%s' %([e,1])] = 0
            self.StateActions[0]['%s' %([e,1])] = 0


        self.A = {}
        if Thresh == False:
            for N in range(20):
                self.A[N] = [0,1]
        else:
            for N in range(Thresh):
                self.A[N] = [1]
            for N in range(Thresh,10*Thresh):
                self.A[N] = [0]
        self.A = [0,1]
        self.findQ()
        self.findP()


    def findQ(self): #Transition rate matrix for the queue
        Q = MatrixSpace(QQ,5*self.servers,5*self.servers)
        rowdata = []

        for e in range(5*self.servers):

            for i in range(5*self.servers):
                if i == e+1:
                    rowdata.append(self.lmbda)
                elif i == e-1:
                        if e<= self.servers:
                            rowdata.append(e*self.mu)
                        else:
                            rowdata.append(self.servers*self.mu)
                else:
                    rowdata.append(0)

        self.Q = Q(rowdata)
        rowsums = [sum(e) for e in self.Q]
        for i in range(5*self.servers):
            self.Q[i,i] = -rowsums[i]

    def findP(self): #Converts Q to P
        Diag = []

        for e in range(5*self.servers):

            Diag.append(abs(self.Q[e][e]))

        t = 1/max(Diag)
        self.P = self.Q*t + identity_matrix(self.Q.nrows())
        self.P2 = [self.P[0][0],self.P[0][1]]
    def Pij(self,i,j = 0):

        return self.P[i][j]


    def Cost(self,state,action): # Returns the cost
        if action == 0:
            return 0
        else:
            if state < self.servers:

                return 1/(self.mu) - self.R
            else:
                return (state+1)/((self.mu*self.servers)) - self.R
    def ValueIter(self,T=1,StartingState = [0,0]): #Recursively calculates cost for current state
       end = False
       while not end:
            self.StateValues[T] = {}
            self.StateActions[T] = {}

            for e in self.states:
                ActionValues = []

                if e[0] == 0 or e[0] >= self.servers:
                    if  e[1] == 0 and not e[0] == self.Selfish and not e[0] == 0:

                        for i in self.A:
                            ActionValues.append(self.Cost(e[0],i) + self.P2[1]*self.StateValues[T-1]['%s' %( [e[0]+i,0] )] + self.P2[0] *self.StateValues[T-1]['%s' %([max(e[0] + i - 1,0),1])] )

                    if  e[1] == 0 and  e[0] == 0:
                        for i in self.A:
                            ActionValues.append(self.Cost(e[0],i) + self.P2[1]*self.StateValues[T-1]['%s' %( [e[0]+i,0] )] + i*self.Pij(e[0]+i,e[0]+i)*self.StateValues[T-1]['%s' %([e[0],1])] + self.Pij(e[0] + i,0)*self.StateValues[T-1]['%s' %([max(e[0] + i - 1,0),1])] )

                    else:

                            ActionValues.append(self.P2[1]*self.StateValues[T-1]['%s' %( [e[0],0] )] + self.P2[0]*self.StateValues[T-1]['%s' %([max(e[0] - 1,0),1])])


                else:

                    if e[1] == 0 and not e[0] == self.servers - 1:

                        for i in self.A:

                            ActionValues.append(self.Cost(e[0],i) + self.P2[1]*self.StateValues[T-1]['%s' %( [e[0]+i,0] )] + self.Pij(e[0]+i,e[0]+i)*self.StateValues[T-1]['%s' %([e[0]+ i ,1])] + self.Pij(e[0]+i,e[0] + i - 1)*self.StateValues[T-1]['%s' %([e[0] + i - 1,1])] )
                    elif e[1] == 0 and e[0] == self.servers - 1:

                        for i in self.A:

                            ActionValues.append(self.Cost(e[0],i) + self.P2[1]*self.StateValues[T-1]['%s' %( [e[0]+i,0] )] + (1-i)*self.Pij(e[0]+i,e[0]+i)*self.StateValues[T-1]['%s' %([e[0]+ i ,1])] + self.Pij(e[0]+i,e[0] + i - 1)*self.StateValues[T-1]['%s' %([e[0] + i - 1,1])] )

                    else:

                        ActionValues.append(self.P2[1]*self.StateValues[T-1]['%s' %( [e[0],0] )] + self.Pij(e[0],e[0])*self.StateValues[T-1]['%s' %([e[0],1])] + self.Pij(e[0],e[0]-1)*self.StateValues[T-1]['%s' %([e[0] - 1,1])] )


                self.StateValues[T]['%s' %(e)] = min(ActionValues)
                self.StateActions[T]['%s' %(e)] = ActionValues.index(min(ActionValues))


            epsilonlist = [abs(self.StateValues[T][e] - self.StateValues[T -1][e]) for e in self.StateValues[T] ]
            Max = max(epsilonlist)
            Min = min(epsilonlist)

            T +=1

            end = Max - Min < self.epsilon*Min
            print Max - Min


       OptimalPolicy = self.Selfish
       for e in self.StateActions[T-1]:

            if  self.StateActions[T-1][e] == 0 and eval(e[1:-4]) < OptimalPolicy and e[-2] == '0' :
                OptimalPolicy = eval(e[1:-4])

       return -Max,OptimalPolicy

Simple = Queue(2,3,6,0.5,epsilon = 0.0001)

Results = Simple.ValueIter()
print '%.2f,%s' %(Results[0],Results[1])
