# This file was *autogenerated* from the file DiscountingGameSelfish.sage.
from sage.all_cmdline import *   # import sage library
_sage_const_3 = Integer(3); _sage_const_2 = Integer(2); _sage_const_1 = Integer(1); _sage_const_0 = Integer(0); _sage_const_6 = Integer(6); _sage_const_5 = Integer(5); _sage_const_4 = Integer(4); _sage_const_0p1 = RealNumber('0.1'); _sage_const_0p000000000000001 = RealNumber('0.000000000000001'); _sage_const_10 = Integer(10); _sage_const_0p5 = RealNumber('0.5'); _sage_const_20 = Integer(20); _sage_const_0p01 = RealNumber('0.01')
class Queue: #A class for the queueing system
    def __init__(self,lmbda,mu,C,R,Thresh = False,epsilon = _sage_const_0p01 ,alpha = _sage_const_1 ):
        self.lmbda = lmbda
        self.mu = mu
        self.R = R
        self.servers = C
        self.epsilon = epsilon
        self.alpha = alpha

        self.StateValues = {}
        self.StateValues[_sage_const_0 ] = {}
        self.StateActions = {}
        self.StateActions[_sage_const_0 ] = {}
        self.states = []
        self.Selfish = _sage_const_20 

        for e in range(self.Selfish + _sage_const_1 ):
            self.states.append([e,_sage_const_0 ])
            self.StateValues[_sage_const_0 ]['%s' %([e,_sage_const_0 ])] = _sage_const_0 
            self.StateActions[_sage_const_0 ]['%s' %([e,_sage_const_0 ])] = _sage_const_0 
            self.states.append([e,_sage_const_1 ])
            self.StateValues[_sage_const_0 ]['%s' %([e,_sage_const_1 ])] = _sage_const_0 
            self.StateActions[_sage_const_0 ]['%s' %([e,_sage_const_1 ])] = _sage_const_0 


        self.A = {}
        if Thresh == False:
            for N in range(_sage_const_20 ):
                self.A[N] = [_sage_const_0 ,_sage_const_1 ]
        else:
            for N in range(Thresh):
                self.A[N] = [_sage_const_1 ]
            for N in range(Thresh,_sage_const_10 *Thresh):
                self.A[N] = [_sage_const_0 ]
        self.A = [_sage_const_0 ,_sage_const_1 ]
        self.findQ()
        self.findP()


    def findQ(self): #Transition rate matrix for the queue
        Q = MatrixSpace(QQ,_sage_const_5 *self.servers,_sage_const_5 *self.servers)
        rowdata = []

        for e in range(_sage_const_5 *self.servers):

            for i in range(_sage_const_5 *self.servers):
                if i == e+_sage_const_1 :
                    rowdata.append(self.lmbda)
                elif i == e-_sage_const_1 :
                        if e<= self.servers:
                            rowdata.append(e*self.mu)
                        else:
                            rowdata.append(self.servers*self.mu)
                else:
                    rowdata.append(_sage_const_0 )

        self.Q = Q(rowdata)
        rowsums = [sum(e) for e in self.Q]
        for i in range(_sage_const_5 *self.servers):
            self.Q[i,i] = -rowsums[i]

    def findP(self): #Converts Q to P
        Diag = []

        for e in range(_sage_const_5 *self.servers):

            Diag.append(abs(self.Q[e][e]))

        t = _sage_const_1 /max(Diag)
        self.P = self.Q*t + identity_matrix(self.Q.nrows())
        self.P2 = [self.P[_sage_const_0 ][_sage_const_0 ],self.P[_sage_const_0 ][_sage_const_1 ]]
    def Pij(self,i,j = _sage_const_0 ):

        return self.P[i][j]


    def Cost(self,state,action): # Returns the cost
        if action == _sage_const_0 :
            return _sage_const_0 
        else:
            if state < self.servers:

                return _sage_const_1 /(self.mu)
            else:
                return (state+_sage_const_1 )/((self.mu*self.servers))
    def ValueIter(self,T=_sage_const_1 ,StartingState = [_sage_const_0 ,_sage_const_0 ]): #Recursively calculates cost for current state
       end = False
       while not end:
            self.StateValues[T] = {}
            self.StateActions[T] = {}

            for e in self.states:
                ActionValues = []

                if e[_sage_const_0 ] == _sage_const_0  or e[_sage_const_0 ] >= self.servers:
                    if e[_sage_const_1 ] == _sage_const_0  and not e[_sage_const_0 ] == self.Selfish:

                        for i in self.A:
                            ActionValues.append((self.alpha**(T))*self.Cost(e[_sage_const_0 ],i) - i*self.R)

                        self.StateActions[T]['%s' %(e)] = ActionValues.index(min(ActionValues))
                        SA = ActionValues.index(min(ActionValues))

                        self.StateValues[T]['%s' %(e)] = (self.alpha**(T))*self.Cost(e[_sage_const_0 ],SA) - SA*self.R + self.P2[_sage_const_1 ]*self.StateValues[T-_sage_const_1 ]['%s' %( [e[_sage_const_0 ]+SA,_sage_const_0 ] )] + self.P2[_sage_const_0 ] *self.StateValues[T-_sage_const_1 ]['%s' %([max(e[_sage_const_0 ] + SA - _sage_const_1 ,_sage_const_0 ),_sage_const_1 ])] - self.StateValues[T-_sage_const_1 ]['%s' %([_sage_const_0 ,_sage_const_0 ])]

                    else:

                        ActionValues.append(self.P2[_sage_const_1 ]*self.StateValues[T-_sage_const_1 ]['%s' %( [e[_sage_const_0 ],_sage_const_0 ] )] + self.P2[_sage_const_0 ]*self.StateValues[T-_sage_const_1 ]['%s' %([max(e[_sage_const_0 ] - _sage_const_1 ,_sage_const_0 ),_sage_const_1 ])]-self.StateValues[T-_sage_const_1 ]['%s' %([_sage_const_0 ,_sage_const_0 ])])
                        self.StateValues[T]['%s' %(e)] = min(ActionValues)
                        self.StateActions[T]['%s' %(e)] = ActionValues.index(min(ActionValues))


                else:

                    if e[_sage_const_1 ] == _sage_const_0 :

                        for i in self.A:

                            ActionValues.append((self.alpha**(T))*self.Cost(e[_sage_const_0 ],i) - i*self.R)

                        self.StateActions[T]['%s' %(e)] = ActionValues.index(min(ActionValues))
                        SA = ActionValues.index(min(ActionValues))

                        self.StateValues[T]['%s' %(e)] = (self.alpha**(T))*self.Cost(e[_sage_const_0 ],SA) - SA*self.R + self.P2[_sage_const_1 ]*self.StateValues[T-_sage_const_1 ]['%s' %( [e[_sage_const_0 ]+SA,_sage_const_0 ] )] + self.Pij(e[_sage_const_0 ],e[_sage_const_0 ])*self.StateValues[T-_sage_const_1 ]['%s' %([e[_sage_const_0 ],_sage_const_1 ])] + self.Pij(e[_sage_const_0 ],e[_sage_const_0 ]-_sage_const_1 )*self.StateValues[T-_sage_const_1 ]['%s' %([e[_sage_const_0 ] + SA - _sage_const_1 ,_sage_const_1 ])] - self.StateValues[T-_sage_const_1 ]['%s' %([_sage_const_0 ,_sage_const_0 ])]
                    else:

                        ActionValues.append(self.P2[_sage_const_1 ]*self.StateValues[T-_sage_const_1 ]['%s' %( [e[_sage_const_0 ],_sage_const_0 ] )] + self.Pij(e[_sage_const_0 ],e[_sage_const_0 ])*self.StateValues[T-_sage_const_1 ]['%s' %([e[_sage_const_0 ],_sage_const_1 ])] + self.Pij(e[_sage_const_0 ],e[_sage_const_0 ]-_sage_const_1 )*self.StateValues[T-_sage_const_1 ]['%s' %([e[_sage_const_0 ] - _sage_const_1 ,_sage_const_1 ])] - self.StateValues[T-_sage_const_1 ]['%s' %([_sage_const_0 ,_sage_const_0 ])])

                        self.StateValues[T]['%s' %(e)] = min(ActionValues)
                        self.StateActions[T]['%s' %(e)] = ActionValues.index(min(ActionValues))


            '''
            for e in self.StateValues[T]:
                self.StateValues[T][e] -= self.StateValues[T-1]['%s' %([0,0])]
            '''

            epsilonlist = [abs(self.StateValues[T][e] - self.StateValues[T - _sage_const_1 ][e]) for e in self.StateValues[T] ]

            T +=_sage_const_1 

            end = True
            for e in epsilonlist:
                if e > self.epsilon:
                    end = False

       OptimalPolicy = self.Selfish
       for e in self.StateActions[T-_sage_const_1 ]:

            if  self.StateActions[T-_sage_const_1 ][e] == _sage_const_0  and eval(e[_sage_const_1 :-_sage_const_4 ]) < OptimalPolicy and e[-_sage_const_2 ] == '0' :
                OptimalPolicy = eval(e[_sage_const_1 :-_sage_const_4 ])
       #return self.StateValues[T - 1]['%s' %(StartingState)],OptimalPolicy
       return self.StateValues[T - _sage_const_1 ],OptimalPolicy

Simple = Queue(_sage_const_2 ,_sage_const_3 ,_sage_const_6 ,_sage_const_0p5 ,epsilon = _sage_const_0p000000000000001 ,alpha = _sage_const_0p1 )

Results = Simple.ValueIter()
print '%s,%s' %(Results[_sage_const_0 ]['[0, 0]'],Results[_sage_const_1 ])
