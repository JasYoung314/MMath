import time
import multiprocessing as mp
action = {}
class Queue: #A class for the queueing system
    def __init__(self,lmbda,mu,C,R,Thresh = False,alpha = 1,epsilon = 10**-2,end_T = 0):
        self.lmbda = lmbda
        self.mu = mu
        self.R = R
        self.servers = C
        self.action = {}
        self.ParaT = False
        self.end_T = end_T
        self.Selfish =  int(R*self.mu)
        self.alpha = alpha
        self.epsilon = epsilon
        self.A = {}
        self.cpus = mp.cpu_count()
        self.BaseDict = {}
        if Thresh == False:
            for N in range(20):
                self.A[N] = [0,1]
        else:
            for N in range(Thresh):
                self.A[N] = [1]
            for N in range(Thresh,10*Thresh):
                self.A[N] = [0]

        self.findQ()
        self.findP()

    def find_nodes(self,nodes = [[0,0]],MaxT=0):
        T = 0
        Tdict = {}
        while len(nodes) <= self.cpus:
            new_nodes = []
            for i in nodes:
                for e in self.Branch(i):
                    if e not in new_nodes:
                        new_nodes.append(e)

            if len(new_nodes)> self.cpus :
                break
            else:
                T += 1
                nodes = new_nodes

        nodes = [(T, r[0], r[1]) for r in nodes]
        self.ParaT = T
        return nodes

    def Branch(self,state):
        if state >= self.servers or state == 0 :
            if state[1] == True:
                return [[max(state[0] - 1,0), True],[state[0],False]]

            else:
                return [[max(state[0] - 1,0), True],[state[0],False],[state[0] + 1,False],[state[0],True]]

        else:
            if state[1] == True:
                return [[max(state[0] - 1,0), True],[state[0],True],[state[0],False]]

            else:
                return [[max(state[0] - 1,0), True],[state[0] + 1,True],[state[0],False],[state[0] + 1,False],[state[0],True]]

    def Submit(self,T = 6):
        self.BaseDict = {}
        jobs = self.find_nodes()
        B = self.SolveNHor(jobs)
        for r in B:
            self.BaseDict['%s%s' %(r[0][0][1],r[0][0][2])] = r[1]


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
                return 1*((self.mu)**-1) - self.R
            else:
                return (state+1)/((self.mu*self.servers)) - self.R
    @parallel
    def SolveNHor(self,T=0,N=0,service = False): #Recursively calculates cost for current state

        values = {}
        values[N] = []

        if T == self.ParaT and '%s%s' %(N,service) in self.BaseDict:
            return self.BaseDict[ '%s%s' %(N,service)]

        if not self.alpha**T < self.epsilon:
        #if not T == self.end_T:

            if N >= self.servers or N == 0:

                if not service:

                    for e in self.A[N]:
                        values[N].append((( (self.alpha**T)*(self.Cost(N,e))+self.P2[0]*self.SolveNHor(T+1,max(N+e-1,0),True))+self.P2[1]*self.SolveNHor(T+1,N+e)))
                    if N in action:

                        action[N][T] = values[N].index(min(values[N]))
                    else:

                        action[N] = {T:values[N].index(min(values[N]))}

                else:
                    values[N].append((self.P2[0]*self.SolveNHor(T+1,max(N-1,0),True))+self.P2[1]*self.SolveNHor(T+1,N))

            else:
                if not service:

                    for e in self.A[N]:
                        values[N].append((( (self.alpha**T)*(self.Cost(N,e)) + self.Pij(N+e,N+e-1)*self.SolveNHor(T+1,N+e-1,True)) + self.Pij(N + e,N + e)*self.SolveNHor(T + 1, N + e,True )  + self.P2[1]*self.SolveNHor(T + 1,N+e)))
                    if N in action:

                        action[N][T] = values[N].index(min(values[N]))
                    else:

                        action[N] = {T:values[N].index(min(values[N]))}

                else:
                    values[N].append( self.Pij(N,N-1)*self.SolveNHor(T+1,N-1,True) + self.Pij(N,N)*self.SolveNHor(T+1,N,True) + self.P2[1]*self.SolveNHor(T+1,N) )
            #action[N] = values[N].index(min(values[N]))
            if T == 0:

                policy = 0
                found = False
                for e in action:
                    if action[e] == 0 and e >policy:
                        policy = e
                        found = True
                if found == False:
                    policy = len(action)
                return min(values[N]),policy
            else:
                return min(values[N])

        else:
            if not service:
                for e in self.A[N]:
                    values[N].append( ( self.alpha**T ) * ( self.Cost(N,e) ) )
            else:
                for e in self.A[N]:
                    values[N].append(0)
            return min(values[N])
Simple = Queue(4,5,2,0.5,alpha = 0.6,epsilon = 0.01)
A = Simple.SolveNHor(0,0)
for e in action:
    print e, action[e]
