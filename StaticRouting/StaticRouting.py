# This file was *autogenerated* from the file StaticRouting.sage.
from sage.all_cmdline import *   # import sage library
_sage_const_2 = Integer(2); _sage_const_1 = Integer(1); _sage_const_0 = Integer(0); _sage_const_0p000000000001 = RealNumber('0.000000000001'); _sage_const_100 = Integer(100); _sage_const_0p00000000001 = RealNumber('0.00000000001')
import math
def find_P0(Pol):
    lmbda_list = [lmbda*Pol[_sage_const_0 ],lmbda*(Pol[_sage_const_0 ]+Pol[_sage_const_1 ]),lmbda*Pol[_sage_const_2 ]]
    p0_list = []
    for e in range(len(lmbda_list) -_sage_const_1  ) :
        rho = lmbda_list[e]/(servers[e]*mu[e])
        p0 = sum([((servers[e]*rho)**(n))/(math.factorial(n)) for n in range(servers[e] )])
        p0 += (((servers[e]*rho)**(servers[e]))/(math.factorial(servers[e])*(_sage_const_1  - rho)))
        p0_list.append(p0**(-_sage_const_1 ))
    return p0_list[_sage_const_0 ],p0_list[_sage_const_1 ]
def StaticRoute(Pol):
    lmbda_list = [lmbda*Pol[_sage_const_0 ],lmbda*(Pol[_sage_const_0 ]+Pol[_sage_const_1 ]),lmbda*Pol[_sage_const_2 ]]
    W_list = []
    for e in range(len(lmbda_list)-_sage_const_1 ) :
        rho = lmbda_list[e]/(servers[e]*mu[e])

        p0 = sum([((servers[e]*rho)**(n))/(math.factorial(n)) for n in range(servers[e] )])
        p0 += (((servers[e]*rho)**(servers[e]))/(math.factorial(servers[e])*(_sage_const_1  - rho)))
        p0 = p0**(-_sage_const_1 )
        W = p0*((mu[e]*(lmbda_list[e]/mu[e])**(servers[e]))/((math.factorial(servers[e]) - _sage_const_1 )*(servers[e]*mu[e] - lmbda_list[e])**(_sage_const_2 )))
        W += _sage_const_1 /(mu[e])
        W_list.append(W)

    W_list.append(sum(skip))

    Total = _sage_const_0 
    for e in range(len(lmbda_list)):
        Total += lmbda_list[e]*W_list[e]

    Total += Pol[_sage_const_1 ]*lmbda*skip[_sage_const_0 ]

    return Total

def StaticRoute2(Pol):
    lmbda_list = [lmbda*Pol[_sage_const_0 ],lmbda*(Pol[_sage_const_0 ]+Pol[_sage_const_1 ]),lmbda*Pol[_sage_const_2 ]]
    W_list = []
    for e in range(len(lmbda_list)-_sage_const_1 ) :
        rho = lmbda_list[e]/(servers[e]*mu[e])
        print rho
        p0 = sum([((servers[e]*rho)**(n))/(math.factorial(n)) for n in range(servers[e] )])
        p0 += (((servers[e]*rho)**(servers[e]))/(math.factorial(servers[e])*(_sage_const_1  - rho)))
        p0 = p0**(-_sage_const_1 )
        print 'p0 ', p0

        Sum = _sage_const_0 
        for i in range(servers[e] + _sage_const_1 ):
            Sum += p0*((servers[e]*rho)**(i))/(mu[e]*(math.factorial(i)))
        for i in range(servers[e] + _sage_const_1 ,_sage_const_100 ):
            Sum += ((i+_sage_const_1 )/(mu[e]*servers[e]))*(p0*(servers[e]**(servers[e]))*(rho**(i)))/(math.factorial(servers[e]))
        W_list.append(Sum)

    W_list.append(sum(skip))

    Total = _sage_const_0 
    for e in range(len(lmbda_list)):
        Total += lmbda_list[e]*W_list[e]

    Total += Pol[_sage_const_1 ]*lmbda*skip[_sage_const_0 ]

    return Total

def find_opt(arriv,serve,c,beta) :
    global lmbda
    global mu
    global servers
    global skip
    lmbda = arriv
    mu = serve
    servers = c
    skip = beta


    c_1 = lambda p: -sum(p) + _sage_const_1 
    c_2 = lambda p:  sum(p) - _sage_const_1 

    c_3 = lambda p:  p[_sage_const_0 ]
    c_4 = lambda p:  p[_sage_const_1 ]
    c_5 = lambda p:  p[_sage_const_2 ]

    c_6 = lambda p:  -p[_sage_const_0 ]*lmbda + (_sage_const_1  - _sage_const_0p00000000001 )*mu[_sage_const_0 ]*servers[_sage_const_0 ]
    c_7 = lambda p:  -(p[_sage_const_0 ]+p[_sage_const_1 ])*lmbda + (_sage_const_1  - _sage_const_0p000000000001 )*mu[_sage_const_1 ]*servers[_sage_const_1 ]

    opt = list(minimize_constrained(StaticRoute,[c_1,c_2,c_3,c_4,c_5,c_6,c_7],[_sage_const_0 ,_sage_const_0 ,_sage_const_1 ]))

    p0 = find_P0(opt)
    for e in opt :
        print 'Lambda_{%s} = %.02f' %(opt.index(e),e)
    return opt,StaticRoute(opt)

#print find_opt(20,[4,4],[2,4],[2,2])
