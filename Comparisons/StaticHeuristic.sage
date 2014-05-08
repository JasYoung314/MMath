import StaticPolicy
reload(StaticPolicy)
import Simm
reload(Simm)
import N2Anlytic
reload(N2Anlytic)

import math

class heuristic:

    def __init__(self,lmbda,mu,c,beta,run_time = 600):

        self.lmbda = lmbda
        self.mu = mu
        self.c = c
        self.beta = beta

        self.run_time = run_time

        self.Di = {}
        self.indexpol = {}

        self.static_policy,self.longrun = StaticPolicy.find_opt(self.lmbda,self.mu,self.c,self.beta)
        self.lmbda_list = [max(0,lmbda*self.static_policy[0]),max(0,lmbda*(self.static_policy[0] + self.static_policy[1]))]
        self.rho = [(self.lmbda_list[e])/(mu[e]*c[e]) for e in range(2)]

        self.p0 = self.find_P0(self.static_policy)


    def find_P0(self,Pol):
        p0_list = []
        for e in range(2 ) :
            p0 = sum([((self.c[e]*self.rho[e])**(n))/(math.factorial(n)) for n in range(self.c[e] )])
            p0 += (((self.c[e]*self.rho[e])**(self.c[e]))/(math.factorial(self.c[e])*(1 - self.rho[e])))
            p0_list.append(p0**(-1))
        return p0_list

class simulation(heuristic):

    def calculate_D(self,max1,max2):
        self.find_KT()
        print len(self.State),self.Maxi
        m = matrix(self.Maxi[0],self.Maxi[1])
        for e in self.State:
            if self.State[e].i1  >self.Maxi[0] - 1  or self.State[e].i2  >self.Maxi[1] - 1:
                continue
            self.Di[e] = []

            i1,i2 = self.State[e].i1,self.State[e].i2

            if i1 >= self.c[0]:
                value1 = (i1+1)/(self.mu[0]*self.c[0])
            else:
                value1 = 1/self.mu[0]


            value1 += self.State['%s,%s' %(i1+1,i2)].Ki
            value1 -= self.State[e].Ki
            value1 -= self.longrun*(self.State['%s,%s' %(i1+1,i2)].Ti - self.State[e].Ti)

            if i2 >= self.c[1]:
                value2 = (i2+1)/(self.mu[1]*self.c[1])
            else:
                value2 = 1/self.mu[1]

            value2 += self.State['%s,%s' %(i1,i2+1)].Ki
            value2 -= self.State[e].Ki
            value2 -= self.longrun*(self.State['%s,%s' %(i1,i2+1)].Ti - self.State[e].Ti)

            self.Di[e].append(value1)
            self.Di[e].append(self.beta[0] + value2)
            self.Di[e].append(sum(self.beta))

            self.indexpol[e] = self.Di[e].index(min(self.Di[e]))
            m[i1,i2] = self.indexpol[e]
        m[0,0] = 0
        return m[0:max1,0:max2]
    def find_KT(self):

        self.State,self.Maxi = Simm.Func(self.lmbda,self.mu,self.c,self.beta,100,self.static_policy,False,10000,True,self.run_time)

class independant(heuristic):

    def calculate_D(self,i1,i2):

        m = matrix(i1,i2)
        for e in range(i1):
            for i in range(i2):

                self.Di['%s,%s' %(e,i)] = []

                if e >= self.c[0]:
                    value1 = (e+1)/(self.mu[0]*self.c[0])
                else:
                    value1 = 1/self.mu[0]

                value1 += self.calculate_k(e+1,0)
                value1 -= self.longrun*self.calculate_t(e+1,0)

                if i >= self.c[1]:
                    value2 = (i+1)/(self.mu[1]*self.c[1])
                else:
                    value2 = 1/self.mu[1]

                value2 += self.calculate_k(i+1,1)
                value2 -= self.longrun*self.calculate_t(i+1,1)

                self.Di['%s,%s' %(e,i)].append(value1 + value2)
                self.Di['%s,%s' %(e,i)].append(self.beta[0] + value2)
                self.Di['%s,%s' %(e,i)].append(sum(self.beta))

                self.indexpol['%s,%s' %(e,i)] = self.Di['%s,%s' %(e,i)].index(min(self.Di['%s,%s' %(e,i)]))
                m[e,i] = self.indexpol['%s,%s' %(e,i)]

        for j in m:
            print j
        return m

    def calculate_k(self,i,station):

        if i == 0:
            return 0
        elif i == 1:
            return self.longrun*(self.calculate_t(1,station) + 1/self.lmbda_list[station] - 1/self.mu[station])
        elif i<= self.c[station]:
            value =  math.factorial(i - 1)*((self.mu[station]/self.lmbda_list[station])**(i - 1))*self.calculate_k(1,station)
            value -= sum( [(math.factorial(i - 1)/math.factorial(j))*( (self.mu[station]/self.lmbda_list[station])**(i - 1 - j) )*(1/self.mu[station] ) for j in range(1,i )  ] )
            return value
        else:
            value = math.factorial(self.c[station])*(self.c[station])**(i - 1 - self.c[station])*((self.mu[station]/self.lmbda_list[station])**(i - 1))*self.calculate_k(1,station)
            value -= (self.c[station]**(i - 1 - self.c[station]))*sum([(math.factorial(self.c[station])/(math.factorial(j)))*((self.mu[station]/self.lmbda_list[station])**(i - 1 - j))*(1/self.mu[station]) for j in range(1,self.c[station] + 1)])
            value -= sum( [( ((self.c[station]*self.mu[station])/self.lmbda_list[station])**(i - 1 - j) )*((j+1)/(self.c[station]*self.mu[station]) ) for j in range(self.c[station] + 1,i)  ] )

            return value

    def calculate_t(self,i,station):
        if i == 0:
            return 0
        elif i > self.c[station]:
            return 1/(self.mu[station]*self.c[station] - self.lmbda_list[station])
        else:
            return (self.lmbda_list[station]*self.calculate_t(i+1,station) + 1)/(i*self.mu[station])

class n2approx(heuristic):

    def calculate_D(self,i1,i2):

        m = matrix(i1,i2)
        for e in range(i1):
            for i in range(i2):
                self.Di['%s,%s' %(e,i)] = []

                if e >= self.c[0]:
                    value1 = (e+1)/(self.mu[0]*self.c[0])
                    wait = (e+1)/(self.mu[0]*self.c[0])
                else:
                    value1 = 1/self.mu[0]
                    wait = 1/self.mu[0]

                value1 += self.calculate_k(e+1,0)
                value1 -= self.longrun*self.calculate_t(e+1,0)

                approxi2 = self.approx_i2(wait,e,i)
                if approxi2 >= self.c[1]:
                    value1 += (approxi2+1)/(self.mu[1]*self.c[1])
                else:
                    value1 += 1/self.mu[1]

                value1 += self.calculate_k(approxi2+1,1)
                value1 -= self.longrun*self.calculate_t(approxi2+1,1)

                if i >= self.c[1]:
                    value2 = (i+1)/(self.mu[1]*self.c[1])
                else:
                    value2 = 1/self.mu[1]

                value2 += self.calculate_k(i+1,1)
                value2 -= self.longrun*self.calculate_t(i+1,1)

                self.Di['%s,%s' %(e,i)].append(value1 )
                self.Di['%s,%s' %(e,i)].append(self.beta[0] + value2)
                self.Di['%s,%s' %(e,i)].append(sum(self.beta))

                self.indexpol['%s,%s' %(e,i)] = self.Di['%s,%s' %(e,i)].index(min(self.Di['%s,%s' %(e,i)]))
                m[e,i] = self.indexpol['%s,%s' %(e,i)]

        for j in m:
            print j
        return m

    def approx_i2(self,wait,current_i1,current_i2):

        i2 = 0
        i2 += self.lmbda_list[1]*wait
        i2 -= self.mu[1]*min(self.c[1],current_i2)*wait
        i2 = int(max(0,i2+current_i2)+0.5)

        return i2

    def calculate_k(self,i,station):

        if i == 0:
            return 0

        elif i == 1:
            return self.longrun*(self.calculate_t(1,station) + 1/self.lmbda_list[station] - 1/self.mu[station])

        elif i<= self.c[station]:
            value =  math.factorial(i - 1)*((self.mu[station]/self.lmbda_list[station])**(i - 1))*self.calculate_k(1,station)
            value -= sum( [(math.factorial(i - 1)/math.factorial(j))*( (self.mu[station]/self.lmbda_list[station])**(i - 1 - j) )*(1/self.mu[station] ) for j in range(1,i )  ] )
            return value

        else:
            value = math.factorial(self.c[station])*(self.c[station])**(i - 1 - self.c[station])*((self.mu[station]/self.lmbda_list[station])**(i - 1))*self.calculate_k(1,station)
            value -= (self.c[station]**(i - 1 - self.c[station]))*sum([(math.factorial(self.c[station])/(math.factorial(j)))*((self.mu[station]/self.lmbda_list[station])**(i - 1 - j))*(1/self.mu[station]) for j in range(1,self.c[station] + 1)])
            value -= sum( [( ((self.c[station]*self.mu[station])/self.lmbda_list[station])**(i - 1 - j) )*((j+1)/(self.c[station]*self.mu[station]) ) for j in range(self.c[station] + 1,i )  ] )

        return value

    def calculate_t(self,i,station):

        if i == 0:
            return 0

        elif i > self.c[station]:
            return 1/(self.mu[station]*self.c[station] - self.lmbda_list[station])

        else:
            return (self.lmbda_list[station]*self.calculate_t(i+1,station) + 1)/(i*self.mu[station])

class n2Simm(heuristic):

    def calculate_D(self,i1,i2):
        self.find_i2()
        m = matrix(i1,i2)
        for e in range(i1):
            for i in range(i2):
                self.Di['%s,%s' %(e,i)] = []

                if e >= self.c[0]:
                    value1 = (e+1)/(self.mu[0]*self.c[0])
                else:
                    value1 = 1/self.mu[0]

                value1 += self.calculate_k(e+1,0)
                value1 -= self.longrun*self.calculate_t(e+1,0)

                approxi2 = self.approx_i2(e,i)
                if approxi2 >= self.c[1]:
                    value1 += (approxi2+1)/(self.mu[1]*self.c[1])
                else:
                    value1 += 1/self.mu[1]

                value1 += self.calculate_k(approxi2+1,1)
                value1 -= self.longrun*self.calculate_t(approxi2+1,1)

                if i >= self.c[1]:
                    value2 = (i+1)/(self.mu[1]*self.c[1])
                else:
                    value2 = 1/self.mu[1]

                value2 += self.calculate_k(i+1,1)
                value2 -= self.longrun*self.calculate_t(i+1,1)

                self.Di['%s,%s' %(e,i)].append(value1 )
                self.Di['%s,%s' %(e,i)].append(self.beta[0] + value2)
                self.Di['%s,%s' %(e,i)].append(sum(self.beta))

                self.indexpol['%s,%s' %(e,i)] = self.Di['%s,%s' %(e,i)].index(min(self.Di['%s,%s' %(e,i)]))
                m[e,i] = self.indexpol['%s,%s' %(e,i)]

        for j in m:
            print j
        return m

    def find_i2(self):

        self.State,self.Maxi = Simm.Func(self.lmbda,self.mu,self.c,self.beta,100,self.static_policy,False,1000,True,self.run_time)

    def approx_i2(self,i1,i2):

        return self.State['%s,%s' %(i1,i2) ].expectedi2


    def calculate_k(self,i,station):

        if i == 0:
            return 0

        elif i == 1:
            return self.longrun*(self.calculate_t(1,station) + 1/self.lmbda_list[station] - 1/self.mu[station])

        elif i<= self.c[station]:
            value =  math.factorial(i - 1)*((self.mu[station]/self.lmbda_list[station])**(i - 1))*self.calculate_k(1,station)
            value -= sum( [(math.factorial(i - 1)/math.factorial(j))*( (self.mu[station]/self.lmbda_list[station])**(i - 1 - j) )*(1/self.mu[station] ) for j in range(1,i )  ] )
            return value

        else:
            value = math.factorial(self.c[station])*(self.c[station])**(i - 1 - self.c[station])*((self.mu[station]/self.lmbda_list[station])**(i - 1))*self.calculate_k(1,station)
            value -= (self.c[station]**(i - 1 - self.c[station]))*sum([(math.factorial(self.c[station])/(math.factorial(j)))*((self.mu[station]/self.lmbda_list[station])**(i - 1 - j))*(1/self.mu[station]) for j in range(1,self.c[station] + 1)])
            value -= sum( [( ((self.c[station]*self.mu[station])/self.lmbda_list[station])**(i - 1 - j) )*((j+1)/(self.c[station]*self.mu[station]) ) for j in range(self.c[station] + 1,i )  ] )
            return value

    def calculate_t(self,i,station):
        if i == 0:
            return 0

        elif i > self.c[station]:
            return 1/(self.mu[station]*self.c[station] - self.lmbda_list[station])

        else:
            return (self.lmbda_list[station]*self.calculate_t(i+1,station) + 1)/(i*self.mu[station])

class n2Ana(heuristic):

    def calculate_D(self,i1,i2):

        m = matrix(i1,i2)
        for e in range(i1):
            for i in range(i2):
                self.Di['%s,%s' %(e,i)] = []

                if e >= self.c[0]:
                    value1 = (e+1)/(self.mu[0]*self.c[0])
                    wait = (e+1)/(self.mu[0]*self.c[0])
                else:
                    value1 = 1/self.mu[0]
                    wait = 1/self.mu[0]

                value1 += self.calculate_k(e+1,0)
                value1 -= self.longrun*self.calculate_t(e+1,0)

                approxi2 = self.approx_i2(e,i)
                if approxi2 >= self.c[1]:
                    value1 += (approxi2+1)/(self.mu[1]*self.c[1])
                else:
                    value1 += 1/self.mu[1]

                value1 += self.calculate_k(approxi2+1,1)
                value1 -= self.longrun*self.calculate_t(approxi2+1,1)

                if i >= self.c[1]:
                    value2 = (i+1)/(self.mu[1]*self.c[1])
                else:
                    value2 = 1/self.mu[1]

                value2 += self.calculate_k(i+1,1)
                value2 -= self.longrun*self.calculate_t(i+1,1)

                self.Di['%s,%s' %(e,i)].append(value1 )
                self.Di['%s,%s' %(e,i)].append(self.beta[0] + value2)
                self.Di['%s,%s' %(e,i)].append(sum(self.beta))

                self.indexpol['%s,%s' %(e,i)] = self.Di['%s,%s' %(e,i)].index(min(self.Di['%s,%s' %(e,i)]))
                m[e,i] = self.indexpol['%s,%s' %(e,i)]

        for j in m:
            print j
        return m

    def approx_i2(self,current_i1,current_i2):

        i2 = N2Anlytic.calcN2(self.lmbda,self.mu,self.c,self.beta,current_i1,current_i2)
        return i2

    def calculate_k(self,i,station):

        if i == 0:
            return 0

        elif i == 1:
            return self.longrun*(self.calculate_t(1,station) + 1/self.lmbda_list[station] - 1/self.mu[station])

        elif i<= self.c[station]:
            value =  math.factorial(i - 1)*((self.mu[station]/self.lmbda_list[station])**(i - 1))*self.calculate_k(1,station)
            value -= sum( [(math.factorial(i - 1)/math.factorial(j))*( (self.mu[station]/self.lmbda_list[station])**(i - 1 - j) )*(1/self.mu[station] ) for j in range(1,i )  ] )
            return value

        else:
            value = math.factorial(self.c[station])*(self.c[station])**(i - 1 - self.c[station])*((self.mu[station]/self.lmbda_list[station])**(i - 1))*self.calculate_k(1,station)
            value -= (self.c[station]**(i - 1 - self.c[station]))*sum([(math.factorial(self.c[station])/(math.factorial(j)))*((self.mu[station]/self.lmbda_list[station])**(i - 1 - j))*(1/self.mu[station]) for j in range(1,self.c[station] + 1)])
            value -= sum( [( ((self.c[station]*self.mu[station])/self.lmbda_list[station])**(i - 1 - j) )*((j+1)/(self.c[station]*self.mu[station]) ) for j in range(self.c[station] + 1,i )  ] )

        return value

    def calculate_t(self,i,station):

        if i == 0:
            return 0

        elif i > self.c[station]:
            return 1/(self.mu[station]*self.c[station] - self.lmbda_list[station])

        else:
            return (self.lmbda_list[station]*self.calculate_t(i+1,station) + 1)/(i*self.mu[station])
