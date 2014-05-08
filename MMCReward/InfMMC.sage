action = {}
class Queue: #A class for the queueing system
    def __init__(self,lmbda,mu,C,R,Thresh = False,alpha = 1,epsilon = 10**-2):
        self.lmbda = lmbda
        self.mu = mu
        self.R = R
        self.servers = C

        self.Selfish =  int(R*self.mu)
        self.alpha = alpha
        self.epsilon = epsilon
        self.A = {}
        if Thresh == False:
            for N in range(100):
                self.A[N] = [0,1]
        else:
            for N in range(Thresh):
                self.A[N] = [1]
            for N in range(Thresh,10*Thresh):
                self.A[N] = [0]

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
                #return 1*((self.mu)**-1) - self.R
                return (1)/((self.mu)) - self.R
            else:
                return (state+1)/((self.mu*self.servers)) - self.R

    def SolveNHor(self,T=0,N=0,service = False): #Recursively calculates cost for current state

        values = {}
        values[N] = []
        if not self.alpha**T < self.epsilon:

            if N >= self.servers or N == 0:

                if not service:

                    for e in self.A[N]:
                        values[N].append((( (self.alpha**T)*(self.Cost(N,e))+self.P2[0]*self.SolveNHor(T+1,max(N+e-1,0),True))+self.P2[1]*self.SolveNHor(T+1,N+e)))

                else:
                    values[N].append((self.P2[0]*self.SolveNHor(T+1,max(N-1,0),True))+self.P2[1]*self.SolveNHor(T+1,N))

            else:
                if not service:

                    for e in self.A[N]:
                        values[N].append((( (self.alpha**T)*(self.Cost(N,e)) + self.Pij(N+e,N+e-1)*self.SolveNHor(T+1,N+e-1,True)) + self.Pij(N + e,N + e)*self.SolveNHor(T + 1, N + e,True )  + self.P2[1]*self.SolveNHor(T + 1,N+e)))

                else:
                    values[N].append( self.Pij(N,N-1)*self.SolveNHor(T+1,N-1,True) + self.Pij(N,N)*self.SolveNHor(T+1,N,True) + self.P2[1]*self.SolveNHor(T+1,N) )

            action[N] = values[N].index(min(values[N]))

            return min(values[N])

        else:
            if not service:
                for e in self.A[N]:
                    values[N].append( ( self.alpha**T ) * ( self.Cost(N,e) ) )
            else:
                for e in self.A[N]:
                    values[N].append(0)
            return min(values[N])
simple = Queue(4,5,2,1.0,Thresh = 2,alpha = 0.5,epsilon = 0.01)
print simple.SolveNHor(0,0)
