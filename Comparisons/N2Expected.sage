

class Queue:
    def __init__(self,lmbda,mu,c,policy,bounds = [20,20]):
        self.lmbda  = lmbda
        self.mu = mu
        self.c = c
        self.policy = policy
        self.bounds = bounds
        self.states = []
        self.ExpectDict = {}
        self.ProbDict = {}

        for e in range(self.bounds[0]):
            for k in range(sum(self.bounds)):
                for j in range(-1,max(0,e - self.c[0] + 1 )):
                   self.states.append([e,k,j])

        for e in range(self.bounds[0]):
            for k in range(sum(self.bounds)):
               self.states.append([e,k,-2])
        self.findQ()
        self.findP()

    def findQ(self):
        Q = MatrixSpace(QQ,len(self.states))
        rowdata = []

        for e in self.states:
            for i in self.states:

                valid = False
                if e[-1] > -1:
                    if i[0] == e[0] - 1 and i[1] == e[1] + 1 and e[2] - 1 == i[2]:
                        rowdata.append(self.c[0] * self.mu[0])
                        valid = True
                    elif i[0] == e[0] and i[1]  == e[1] -1  and e[2] == i[2]:
                        rowdata.append(min(self.c[1],e[1]) * self.mu[1])
                        valid = True
                    if e[0] < self.bounds[0] and e[1] < self.bounds[1]:
                        decision = self.policy[e[0],e[1]]
                    else:
                        decision = 2

                    if decision == 0:
                        if i[0] == e[0] + 1 and i[1] == e[1] and e[2]  == i[2]:
                            rowdata.append(self.lmbda)
                            valid = True

                    elif decision == 1:
                        if i[0] == e[0]  and i[1] == e[1] + 1 and e[2]  == i[2]:
                            rowdata.append(self.lmbda)
                            valid = True

                    if not valid:
                        rowdata.append(0)

                elif e[-1] == -1:
                    if i[0] == e[0] - 1 and i[1] == e[1] + 1 and e[2] - 1 == i[2]:
                        rowdata.append(self.mu[0])
                        valid = True
                    elif i[0] == e[0] - 1 and i[1] == e[1] + 1 and e[2] == i[2]:
                        rowdata.append(self.mu[0] *(min(self.c[0],e[0]) - 1 ))
                        valid = True
                    elif i[0] == e[0] and i[1]  == e[1] - 1  and e[2] == i[2]:
                        rowdata.append(min(self.c[1],e[1]) * self.mu[1])
                        valid = True

                    if e[0] < self.bounds[0] and e[1] < self.bounds[1]:
                        decision = self.policy[e[0],e[1]]
                    else:
                        decision = 2

                    if decision == 0:
                        if i[0] == e[0] + 1 and i[1] == e[1] and e[2]  == i[2]:
                            rowdata.append(self.lmbda)
                            valid = True

                    elif decision == 1:
                        if i[0] == e[0]  and i[1] == e[1] + 1 and e[2]  == i[2]:
                            rowdata.append(self.lmbda)
                            valid = True

                    if not valid:
                        rowdata.append(0)

                elif e[-1] == -2:
                    rowdata.append(0)

        self.Q = Q(rowdata)
        rowsums = [sum(e) for e in self.Q]
        for i in range(len(rowsums)):
            self.Q[i,i] = -rowsums[i]

    def findP(self):
        Diag = []
        for i in range(len(self.states)):
            Diag.append(abs(self.Q[i,i]))
        t = 1/max(Diag)
        self.P = self.Q*t + identity_matrix(len(self.states))


    def findabsorbing(self):
        states = 0
        while not self.states[states][-1] == -2:
            states += 1

        T = MatrixSpace(QQ,states)
        B = MatrixSpace(QQ,states,len(self.states) - states)
        rowdata = []
        for e in range(states):
            for i in range(states):

                rowdata.append(self.P[e,i])
        T = T(rowdata)
        rowdata = []
        for e in range(states):
            for i in range(states,len(self.states)):
               rowdata.append(self.P[e,i])
        B = B(rowdata)
        A = ((identity_matrix(states) - T).inverse())*B

        for e in range(states):
            if self.states[e][-1] == max(-1,self.states[e][0] - self.c[0]) :
                self.ExpectDict['%s' %self.states[e][0:2]] = {}
                for i in range(len(self.states) - states):
                    if '%s' %self.states[i + states][1] in self.ExpectDict['%s' %self.states[e][0:2]]:
                        self.ExpectDict['%s' %self.states[e][0:2]]['%s' %self.states[i + states][1]] += A[e,i]
                    else:
                        self.ExpectDict['%s' %self.states[e][0:2]]['%s' %self.states[i + states][1]] = A[e,i]
                self.ProbDict['%s' %self.states[e][0:2]] = sum([eval(i)*self.ExpectDict['%s' %self.states[e][0:2]][i] for i in self.ExpectDict['%s' %self.states[e][0:2]] ])
        return self.ProbDict

