import math
def find_P0(Pol):
    lmbda_list = [lmbda*Pol[0],lmbda*(Pol[0]+Pol[1]),lmbda*Pol[2]]
    p0_list = []
    for e in range(len(lmbda_list) -1 ) :
        rho = lmbda_list[e]/(servers[e]*mu[e])
        p0 = sum([((servers[e]*rho)**(n))/(math.factorial(n)) for n in range(servers[e] )])
        p0 += (((servers[e]*rho)**(servers[e]))/(math.factorial(servers[e])*(1 - rho)))
        p0_list.append(p0**(-1))
    return p0_list[0],p0_list[1]
def StaticRoute(Pol):
    lmbda_list = [lmbda*Pol[0],lmbda*(Pol[0]+Pol[1]),lmbda*Pol[2]]
    W_list = []
    for e in range(len(lmbda_list)-1) :
        rho = lmbda_list[e]/(servers[e]*mu[e])

        p0 = sum([((servers[e]*rho)**(n))/(math.factorial(n)) for n in range(servers[e] )])
        p0 += (((servers[e]*rho)**(servers[e]))/(math.factorial(servers[e])*(1 - rho)))
        p0 = p0**(-1)
        W = p0*((mu[e]*(lmbda_list[e]/mu[e])**(servers[e]))/((math.factorial(servers[e]) - 1)*(servers[e]*mu[e] - lmbda_list[e])**(2)))
        W += 1/(mu[e])
        W_list.append(W)

    W_list.append(sum(skip))

    Total = 0
    for e in range(len(lmbda_list)):
        Total += lmbda_list[e]*W_list[e]

    Total += Pol[1]*lmbda*skip[0]

    return Total

def StaticRoute2(Pol):
    lmbda_list = [lmbda*Pol[0],lmbda*(Pol[0]+Pol[1]),lmbda*Pol[2]]
    W_list = []
    for e in range(len(lmbda_list)-1) :
        rho = lmbda_list[e]/(servers[e]*mu[e])
        print rho
        p0 = sum([((servers[e]*rho)**(n))/(math.factorial(n)) for n in range(servers[e] )])
        p0 += (((servers[e]*rho)**(servers[e]))/(math.factorial(servers[e])*(1 - rho)))
        p0 = p0**(-1)
        print 'p0 ', p0

        Sum = 0
        for i in range(servers[e] + 1):
            Sum += p0*((servers[e]*rho)**(i))/(mu[e]*(math.factorial(i)))
        for i in range(servers[e] + 1,100):
            Sum += ((i+1)/(mu[e]*servers[e]))*(p0*(servers[e]**(servers[e]))*(rho**(i)))/(math.factorial(servers[e]))
        W_list.append(Sum)

    W_list.append(sum(skip))

    Total = 0
    for e in range(len(lmbda_list)):
        Total += lmbda_list[e]*W_list[e]

    Total += Pol[1]*lmbda*skip[0]

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


    c_1 = lambda p: -sum(p) + 1
    c_2 = lambda p:  sum(p) - 1

    c_3 = lambda p:  p[0]
    c_4 = lambda p:  p[1]
    c_5 = lambda p:  p[2]

    c_6 = lambda p:  -p[0]*lmbda + (1 - 0.00000000001)*mu[0]*servers[0]
    c_7 = lambda p:  -(p[0]+p[1])*lmbda + (1 - 0.000000000001)*mu[1]*servers[1]

    opt = list(minimize_constrained(StaticRoute,[c_1,c_2,c_3,c_4,c_5,c_6,c_7],[0,0,1]))

    p0 = find_P0(opt)
    for e in opt :
        print 'Lambda_{%s} = %.02f' %(opt.index(e),e)
    return opt,StaticRoute(opt)

#print find_opt(20,[4,4],[2,4],[2,2])
