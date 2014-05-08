import multiprocessing,time
action = {}

class Queue: #A class for the queueing system
    def __init__(self,lmbda,mu,R,TimeCost = 1,K = False,alpha = 1,epsilon = 10**-2):

        self.lmbda = lmbda
        self.mu = mu
        self.R = R
        self.TC = TimeCost

        self.queuelength = 0
        self.Selfish =  int(R*self.mu)

        self.alpha = alpha
        self.epsilon = epsilon

        self.A = [0,1]

        self.BaseDict = {}
        self.TDict = {}
        self.cpus = multiprocessing.cpu_count()
        print multiprocessing.cpu_count()
        self.ParaT = 'Nope'

        if K == False:
            self.K = self.Selfish
        else:
            self.K = K

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

        nodes = [(MaxT -T, r[0], r[1]) for r in nodes]
        self.ParaT = MaxT - T
        return nodes

    def Branch(self,state):

        if state[1] == True:
            return [[max(state[0] - 1,0), True],[state[0],False]]

        else:
            return [[max(state[0] - 1,0), True],[state[0],False],[state[0] + 1,False],[state[0],True]]

    def Submit(self,T = 6):
        self.BaseDict = {}
        jobs = self.find_nodes(MaxT = T)
        print jobs
        B = self.SolveNHor(jobs)
        for r in B:
            self.BaseDict['%s%s' %(r[0][0][1],r[0][0][2])] = r[1]
    def findQ(self): #Transition rate matrix for the queue
        Q = MatrixSpace(QQ,self.K,self.K)
        rowdata = []

        for e in range(self.K):

            for i in range(self.K):
                if i == e+1:
                    rowdata.append(self.lmbda)
                elif i == e-1:
                        rowdata.append(self.mu)
                else:
                    rowdata.append(0)

        self.Q = Q(rowdata)
        rowsums = [sum(e) for e in self.Q]
        for i in range(self.K):
            self.Q[i,i] = -rowsums[i]

    def findP(self): #Converts Q to P
        Diag = []

        for e in range(self.K):

            Diag.append(abs(self.Q[e][e]))

        t = 1/max(Diag)
        self.P = self.Q*t + identity_matrix(self.Q.nrows())
        self.P2 = [self.P[0][0],self.P[0][1]]
    def obtainpi(self):
        uniteigenvector = [e for e in self.P.eigenvectors_left() if e[0]==1][0][1][0]

        self.pi = uniteigenvector / sum(uniteigenvector)



    def Pij(self,i):

        return self.P2[i]


    def Cost(self,state,action): # Returns the cost
        if action == 0:
            return 0
        else:
            return (state+1)*(self.mu)**-1 - self.R

    @parallel
    def SolveNHor(self,T=0,N=0,service = False): #Recursively calculates cost for current state

        values = {}
        values[N] = []
        if T == self.ParaT and '%s%s' %(N,service) in self.BaseDict:
            print 'woof'
            return self.BaseDict[ '%s%s' %(N,service)]
        if not T==0:
            if not service:
                for e in self.A:
                    values[N].append(((self.Cost(N,e)+self.Pij(0)*self.SolveNHor(T-1,max(N+e-1,0),True))+self.Pij(1)*self.SolveNHor(T-1,N+e)))
            else:
                values[N].append((self.Pij(0)*self.SolveNHor(T-1,max(N-1,0),True))+self.Pij(1)*self.SolveNHor(T-1,N))

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



Simple = Queue(2,3,1.0)

Start1 = time.time()
A = Simple.SolveNHor(10,0)
Time1 = time.time() - Start1
print A
print 'Boring Serial ' , Time1

Start2 = time.time()
Simple.Submit(10)
B = Simple.SolveNHor(10,0)
Time2 = time.time()- Start2
print B
print 'New Paralell', Time2
