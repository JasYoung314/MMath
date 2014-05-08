import StaticRouting
reload(StaticRouting)
import KTValues
reload(KTValues)

class heuristic:

    def __init__(self,lmbda,mu,c,beta):

        self.lmbda = lmbda
        self.mu = mu
        self.c = c
        self.beta = beta

        self.Di = {}
        self.indexpol = {}

        self.static_policy,self.longrun = StaticRouting.find_opt(self.lmbda,self.mu,self.c,self.beta)
        self.lmbda_list = [lmbda*self.static_policy[0],lmbda*(self.static_policy[0] + self.static_policy[1])]
        self.rho = [(self.lmbda_list[e])/(mu[e]*c[e]) for e in range(2)]

        self.p0 = self.find_P0(self.static_policy)

        self.longrun = (self.longrun/(self.lmbda+ sum([self.c[k]*self.mu[k] for k in range(2)])))

    def find_P0(self,Pol):
        p0_list = []
        for e in range(2 ) :
            p0 = sum([((self.c[e]*self.rho[e])**(n))/(math.factorial(n)) for n in range(self.c[e] )])
            p0 += (((self.c[e]*self.rho[e])**(self.c[e]))/(math.factorial(self.c[e])*(1 - self.rho[e])))
            p0_list.append(p0**(-1))
        return p0_list

class simulation(heuristic):

    def calculate_D(self):
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

            if self.State[e].expectedi2 >= self.c[1]:
                value1 += (self.State[e].expectedi2 + 1)/(self.mu[1]*self.c[1])
            else:
                value1 += 1/self.mu[1]

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

            print i1,i2,self.Di[e]

            self.indexpol[e] = self.Di[e].index(min(self.Di[e]))
            m[i1,i2] = self.indexpol[e]

        for j in m:
            print j

    def find_KT(self):

        self.State,self.Maxi = KTValues.Func(self.lmbda,self.mu,self.c,self.beta,200,self.static_policy,False,1000,True)

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
                #value1 += self.calculate_K(e+1,0)
                #value1 -= self.calculate_K(e,0)
                value1 -= self.longrun*self.calculate_t(e+1,0)

                if i >= self.c[1]:
                    value2 = (i+1)/(self.mu[1]*self.c[1])
                else:
                    value2 = 1/self.mu[1]

                value2 += self.calculate_k(i+1,1)
                #value2 += self.calculate_K(i+1,1)
                #value2 -= self.calculate_K(i, 1 )
                value2 -= self.longrun*self.calculate_t(i+1,1)

                self.Di['%s,%s' %(e,i)].append(value1 + value2)
                self.Di['%s,%s' %(e,i)].append(self.beta[0] + value2)
                self.Di['%s,%s' %(e,i)].append(sum(self.beta))

                print e,i,self.Di['%s,%s' %(e,i)]

                self.indexpol['%s,%s' %(e,i)] = self.Di['%s,%s' %(e,i)].index(min(self.Di['%s,%s' %(e,i)]))
                m[e,i] = self.indexpol['%s,%s' %(e,i)]

        for j in m:
            print j
        p = m.plot()
        p.save('./meeting2.pdf')
    def calculate_k(self,i,station):

        k1 = (self.longrun)*((1-self.p0[station])/(self.lmbda_list[station]*self.p0[station]) + 1/self.lmbda_list[station]) - 1/self.mu[station]
        print k1
        ki = k1
        ki -= sum([(self.rho[station]**(j))/self.mu[station] for j in range(1,self.c[station])])
        ki -= sum([((j+1)/(self.mu[station]*self.c[station]))*self.rho[station]**(j) for j in range(self.c[station]+1,i-1)])
        #ki /= self.rho[station]**(i - 1)

        return ki
    def calculate_K(self,i,station):

        if i == 0:
            return 0
        elif i == 1:
            return self.longrun*(1-self.p0[station])/(self.lmbda_list[station]*self.p0[station]) - 1/(self.mu[station])

        elif i >= self.c[station]:
            Total = (self.calculate_K(i - 1,station)*(self.lmbda_list[station] + self.c[station]*self.mu[station]))/(self.lmbda_list[station])
            Total -= self.calculate_K(i - 2,station)*(self.mu[station]*self.c[station])/self.lmbda_list[station]
            Total -= (i + 1)/(self.mu[station]*self.c[station])
            return Total

        elif i < self.c[station]:
            xi = ( i*self.mu[station]  + self.lmbda_list[station] )/self.lmbda_list[station]
            Total = self.calculate_K(i - 1,station)*xi
            Total -= (self.calculate_K(i - 2,station)*i*self.mu[station])/self.lmbda_list[station]
            Total -= (1)/(self.mu[station])

            return Total

    def calculate_t(self,i,station):
        if i == 1:
            return (1 - self.p0[station])/(self.lmbda_list[station]*self.p0[station])
        elif i > self.c[station]:
            return 1/(self.mu[station]*self.c[station] - self.lmbda_list[station])
        elif i <= self.c[station]:
            return (1 - self.p0[station])/(self.lmbda_list[station]*self.p0[station])

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

        p = m.plot()
        p.save('./blah.pdf')
        for j in m:
            print j
        print self.static_policy

    def approx_i2(self,wait,current_i1,current_i2):

        i2 = 0
        i2 += self.lmbda_list[1]*wait
        i2 -= self.mu[1]*self.c[1]*wait
        i2 = int(max(0,i2+current_i2)+0.5)

        return i2

    def calculate_k(self,i,station):

        if self.lmbda_list[station] < 0.000001:
            k1 =  0
        else:
            k1 = (self.longrun)*((1-self.p0[station])/(self.lmbda_list[station]*self.p0[station]) + 1/self.lmbda_list[station]) - 1/self.mu[station]

        ki = k1
        ki -= sum([(self.rho[station]**(j))/self.mu[station] for j in range(1,self.c[station])])
        ki -= sum([((j+1)/(self.mu[station]*self.c[station]))*self.rho[station]**(j) for j in range(self.c[station]+1,i-1)])
        #ki /= self.rho[station]**(i - 1)

        return ki

    def calculate_K(self,i,station):
        if i == 0:
            return 0
        elif i == 1:
            return self.longrun*((1-self.p0[station])/(self.lmbda_list[station]*self.p0[station]) + 1/self.lmbda_list[1]) - 1/(self.mu[station])

        elif i >= self.c[station]:
            Total = (self.calculate_K(i - 1,station)*(self.lmbda_list[station] + self.c[station]*self.mu[station]))/(self.lmbda_list[station])
            Total -= self.calculate_K(i - 2,station)*(self.mu[station]*self.c[station])/self.lmbda_list[station]
            Total -= (i + 1)/(self.mu[station]*self.c[station])
            return Total

        elif i < self.c[station]:
            xi = ( i*self.mu[station]  + self.lmbda_list[station] )/self.lmbda_list[station]
            Total = self.calculate_K(i - 1,station)*xi
            Total -= (self.calculate_K(i - 2,station)*i*self.mu[station])/self.lmbda_list[station]
            Total -= (1)/(self.mu[station])

            return Total

    def calculate_t(self,i,station):
        if i == 1:
            if self.lmbda_list[station] < 0.00001:
                return 0
            return (1 - self.p0[station])/(self.lmbda_list[station]*self.p0[station])
        elif i <= self.c[station]:
            if self.lmbda_list[station] < 0.00001:
                return 0
            return (1 - self.p0[station])/(self.lmbda_list[station]*self.p0[station])
            return 1/(self.mu[station]*self.c[station] - self.lmbda_list[station])
            return 1/(self.mu[station]*i - self.lmbda_list[station])
        elif i > self.c[station]:
            return 1/(self.mu[station]*self.c[station] - self.lmbda_list[station])

#b = simulation(20,[4,4],[2,4],[2,2])
#b.calculate_D()
#c = independant(10,[4,4],[2,4],[100,2])
#c.calculate_D(10,10)

d = n2approx(5,[3,4],[2,2],[1,0.5])
d.calculate_D(40,40)
#c = independant(10,[2,4],[2,2],[2,2])
#c.calculate_D(40,40)

