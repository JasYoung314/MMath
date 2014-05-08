action = {}
class Queue: #A class for the queueing system
    def __init__(self,lmbda,mu,C,R,TimeCost = 1,K = False,alpha = 1,epsilon = 10**-2):
        self.lmbda = lmbda
        self.mu = mu
        self.R = R
        self.TC = TimeCost
        self.servers = C
        self.queuelength = 0
        self.Selfish =  int(R*self.mu)
        self.alpha = alpha
        self.epsilon = epsilon
        self.A = [0,1]

        if K == False:
            self.K = self.Selfish
        else:
            self.K = K
        print self.servers
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
        print t
        self.P = self.Q*t + identity_matrix(self.Q.nrows())
        self.P2 = [self.P[0][0],self.P[0][1]]
        print self.P2
        for e in self.P:
            print [i for i in e]
    def Pij(self,i,j = 0):

        return self.P[i][j]


    def Cost(self,state,action): # Returns the cost
        if action == 0:
            return 0
        else:
            if state < self.servers:
                return 1*((self.mu)**-1) - self.R
            else:
                return (state+1)*(self.mu*self.servers)**-1 - self.R

    def SolveNHor(self,T=0,N=0,service = False): #Recursively calculates cost for current state

        values = {}
        values[N] = []
        if not T==0:

            if N >= self.servers or N == 0:

                if not service:

                    for e in self.A:
                        values[N].append(((self.Cost(N,e)+self.P2[0]*self.SolveNHor(T-1,max(N+e-1,0),True))+self.P2[1]*self.SolveNHor(T-1,N+e)))
                else:
                    values[N].append((self.P2[0]*self.SolveNHor(T-1,max(N-1,0),True))+self.P2[1]*self.SolveNHor(T-1,N))
            else:
                if not service:

                    for e in self.A:
                        values[N].append((( self.Cost(N,e) + self.Pij(N+e,N+e-1)*self.SolveNHor(T-1,N+e-1,True)) + self.Pij(N + e,N + e)*self.SolveNHor(T - 1, N + e,True )  + self.P2[1]*self.SolveNHor(T-1,N+e)))
                else:
                    values[N].append( self.Pij(N,N-1)*self.SolveNHor(T-1,N-1,True) + self.Pij(N,N)*self.SolveNHor(T-1,N,True) + self.P2[1]*self.SolveNHor(T-1,N) )

            action[N] = values[N].index(min(values[N]))
            return min(values[N])

        else:
            if not service:
                for e in self.A:
                    values[N].append((self.Cost(N,e)))
            else:
                for e in self.A:
                    values[N].append(0)
            return min(values[N])
simple = Queue(3,5,4,1.0)
print simple.SolveNHor(8,0)
