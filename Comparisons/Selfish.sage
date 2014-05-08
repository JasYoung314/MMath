import N2Expected as N2
import TwoQueueVia3 as VIA
import random
import copy
import csv

class Queue:
    def __init__(self,lmbda,mu,c,skip,expect,bounds = [20,20]):
        self.lmbda  = lmbda
        self.mu = mu
        self.c = c
        self.beta = skip
        self.bounds = bounds
        self.states = []
        self.ExpectDict = expect

        for e in range(self.bounds[0]):
            for k in range(sum(self.bounds)):
                   self.states.append([e,k])


    def findselfish(self):
        m = MatrixSpace(QQ,self.bounds[0],sum(self.bounds))
        rowdata = []
        for e in self.states:
            print e,self.ExpectDict['%s' %e]
            costs = []
            if e[0] < self.c[0]:
                if self.ExpectDict['%s' %e] < self.c[1]:
                    costs.append(1/self.mu[0] + 1/self.mu[1] )
                else:
                    costs.append(1/self.mu[0] + (self.ExpectDict['%s' %e]+1)/(self.mu[1]*self.c[1])   )
            else:
                if self.ExpectDict['%s' %e] < self.c[1]:
                    costs.append((e[0]+1)/(self.mu[0]*self.c[0]) + 1/self.mu[1] )
                else:
                    costs.append((e[0]+1)/(self.mu[0]*self.c[0]) + (self.ExpectDict['%s' %e]+1)/(self.mu[1]*self.c[1]) )
            if e[1] < self.c[1]:
                costs.append(self.beta[0] + 1/self.mu[1] )
            else:
                costs.append(self.beta[0] + (e[1]+1)/(self.mu[1]*self.c[1] ))
            costs.append(sum(self.beta))
            print e,costs
            rowdata.append(costs.index(min(costs)))
        m = m(rowdata)
        print m.str()
        return m[0:self.bounds[0] ,0:self.bounds[1]  ]

@parallel
def f(n):
    bark = True
    while bark == True:
        try: 
            mu = [random.uniform(1,5),random.uniform(1,5)]
            c = [random.randint(2,4),random.randint(2,4)]
            skip = [random.uniform(0.4,0.5),random.uniform(0.4,0.5)]
            for e in range(5,30):
    
                lmbda = e
    
                A = VIA.Queue(lmbda,mu,c,skip,bounds = [9,9])
                datavia = A.VIA(0.1)
                new = datavia[2]
                Opt = copy.copy(new)
                testpol = None
                count = 0
                while not new == testpol:
                    print 'woof'
                    testpol = new
                    a = N2.Queue(lmbda,mu,c,testpol,bounds = [10,10])
                    expect = a.findabsorbing()
                    b = Queue(lmbda,mu,c,skip,expect,bounds = [10,10])
                    new = b.findselfish()
                    count += 1
                    if count >= 10:
                        break
    
                count -=1
                #A = VIA.Queue(lmbda,mu,c,skip,Policy = Opt[0:5,0:5])
                #datavia = A.VIA(0.1)
    
                B = VIA.Queue(lmbda,mu,c,skip,Policy = new)
                selfcost = B.VIA(0.1)[0]
                print Opt,new
    
    
                outfile = open('./out/poa/poacurve(%s,%s,%s).csv' %(mu,c,skip),'ab')
                output = csv.writer(outfile)
    
                outrow = []
                outrow.append(e)
    
                outrow.append(mu[0])
                outrow.append(mu[1])
                outrow.append(c[0])
                outrow.append(c[1])
                outrow.append(skip[0])
                outrow.append(skip[1])
    
                outrow.append(datavia[0])
                outrow.append(Opt.str())
                outrow.append(selfcost)
                outrow.append(testpol.str())
                outrow.append(count)
    
    
                output.writerow(outrow)
                outfile.close()
                bark = True
        except:
            continue
list(f([1,2]))
#f(7)
