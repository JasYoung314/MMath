import StaticPolicy
import csv
import math

def Pi(j, k, t,Lambda,c,mu):
    pA = Lambda / (c*mu+Lambda)
    pS = lambda x: (min([c, x]) * mu ) / (Lambda + mu * c)
    pN = lambda x: 1- pS(x) - pA

    if t == 0 and j == k:
        return 1
    if abs(k-j) > t:
        return 0
    if k == 0:
        return Pi(j, k, t-1,Lambda,c,mu) * pN(k) + Pi(j, k+1, t-1,Lambda,c,mu) * pS(k+1)
    return Pi(j, k-1, t-1,Lambda,c,mu) * pA + Pi(j, k, t-1,Lambda,c,mu) * pN(k) + Pi(j, k+1, t-1,Lambda,c,mu) * pS(k+1)

def expectednumber(j,t,Lambda,c,mu):
    #print j,t,[Pi(j,k,t,Lambda,c,mu) for k in range(j+t+1)]
    return sum([k*Pi(j,k,t,Lambda,c,mu) for k in range(j+t+1)])

def nCr(n,r):
    if n <= 0 or r <= 0:
        return 1
    c = math.factorial
    return c(n)/(c(r)*c(n-r))

def probtime1stqueue(t,i,Lambda,c,mu):
    phat = exp((-mu)/(Lambda + mu*c))*((mu)/(Lambda + mu*c))

    if t < i - c + 2 :
        return 0
    if i < c:
        return phat*((1-phat)**(t-1))
    T = t - 2 - (i - c)
    return phat*(((mu*c)/(Lambda + mu*c))**(i  + 1 - c))*sum( [ nCr(t - (T - tdash) - 2 ,tdash)*(((Lambda)/(Lambda + mu*c))**(tdash))*((1 - phat)**(T - tdash )) for tdash in range(t  - 1-(i - c) )] )
    #return phat*sum([(((mu*c)/(Lambda + mu*c))**(tdash))*((1 - phat)**(t - tdash - 1)) for tdash in range(i - c + 1,t)])

class Queue:

    def __init__(self,lmbda,mu,c,beta,pol,run_time = 600):


        self.mu = mu
        self.c = c
        self.beta = beta

        self.run_time = run_time
        self.static_policy = pol
        self.Di = {}
        self.indexpol = {}


        self.lmbda_list = lmbda
        self.rho = [(self.lmbda_list[e])/(mu[e]*c[e]) for e in range(2)]


    def find_P0(self):
            p0_list = []
            for e in range(2 ) :
                p0 = sum([((self.c[e]*self.rho[e])**(n))/(math.factorial(n)) for n in range(self.c[e] )])
                p0 += (((self.c[e]*self.rho[e])**(self.c[e]))/(math.factorial(self.c[e])*(1 - self.rho[e])))
                p0_list.append(p0**(-1))
            return p0_list

    def interpolate(self,t):
        realt = t * (self.lmbda_list[1] + self.mu[1]*self.c[1])
        interp_point = 18
        for e in self.tdict:
            #print e,e*(self.lmbda_list[0] + self.mu[0]*self.c[0]), realt
            if realt > e*(self.lmbda_list[0] + self.mu[0]*self.c[0]) and realt <= (e+1)*(self.lmbda_list[0] + self.mu[0]*self.c[0]):

                interp_point = min(e,18)
        #print self.tdict[interp_point],self.tdict[interp_point + 1],
        return self.tdict[interp_point] + ((realt - interp_point*(self.lmbda_list[0] + self.mu[0]*self.c[0]))/( (interp_point+1)*(self.lmbda_list[0] + self.mu[0]*self.c[0]) - interp_point*(self.lmbda_list[0])))*(self.tdict[interp_point+1] - self.tdict[interp_point])


def matrixform(Lambda,mu,c,t,k):
    v = [0 for e in range(min([t, k]))] + [1] + [0 for e in range(t)]
    m = MatrixSpace(QQ,t + min([t, k ])+1,t + min([t,k ])+1)
    step = 1/(Lambda + mu*c )
    rowdata = []

    for e in range(max([k - t,0]),k + t+1):
        for i in range(max([k - t,0]),k + t+1):
            if e + 1 == i :
                rowdata.append(Lambda*step)
            elif e - 1 == i:
                rowdata.append(min([e,c])*mu*step)
            elif e == i:
                rowdata.append(max([c - e,0])*mu*step)
            else:
                rowdata.append(0)

    m = m(rowdata)
    v = vector(v)
    dist = (v*(m**(t)) )

    j = max([k - t,0])
    value = 0
    for e in dist:
        value += j*e
        j += 1

    return value

'''
files = [f for f in os.listdir('./out/ndata/') if os.path.isfile(os.path.join('out/ndata',f))]
files = [f for f in files if '.csv' in f]
files = [f for f in files if not  'diffdata' in f]
for f in files:
    print f
    infile = open('./out/ndata/' + f,'rb')
    data = csv.reader(infile)
    data = [row for row in data]
    data = [[eval(e) for e in row] for row in data]
    infile.close()
    Lambda,mu,c,skip = data[0][0],[data[0][1],data[0][2]],[data[0][3],data[0][4]],[data[0][5],data[0][6]]
    static_pol = StaticPolicy.find_opt(Lambda,mu,c,skip)[0]
    Lambda = [static_pol[0]*Lambda,(static_pol[0] + static_pol[1])*Lambda]
    plot_data = {}

    a = Queue(Lambda,mu,c,skip,static_pol)
    p0 = a.find_P0()[0]
    print 'woof'
    for row in data[1:101]:
        if row[0] < 10 and row[1] <10:
            value = 0
            a.tdict = {}
            for t in range(1,50):
                a.tdict[t] = probtime1stqueue(t,row[0],Lambda[0],c[0],mu[0])

            for t in range(1,50):
                for j in range(c[0] + 1):
                    if j == 0:
                        value +=  a.interpolate(t)* p0 * matrixform(0 + data[0][0]*static_pol[1],mu[1],c[1],t,row[1])
                    elif j < c:
                        value += a.interpolate(t) * (p0*((Lambda[0]/mu[0])**(j))*(1/math.factorial(j))) * matrixform(j*mu[0] + data[0][0]*static_pol[1],mu[1],c[1],t,row[1])
                    else:
                        value += a.interpolate(t) * (1 - sum([((Lambda[0]/mu[0])**(j))*(1/math.factorial(j)) for j in range(1,c)]) - p0) * matrixform(c[0]*mu[0] + data[0][0]*static_pol[1],mu[1],c[1],t,row[1])


            plot_data[row[0],row[1]] = float(value) - row[2]
            print float(value),row[2],float(value) - row[2]
            outfile = open('./out/ndata/diffdata(%s,%s,%s,%s).csv' %(data[0][0],mu,c,skip),'ab')

            output = csv.writer(outfile)
            outrow = [row[0],row[1],float(value),row[2],float(value) - row[2]]
            output.writerow(outrow)

            outfile.close()

    def f(x,y):
        return plot_data[int(x),int(y)]

    p = contour_plot(f,(0,9),(0,9),axes = ['i1','i2'],contours = 100,colorbar = True)
    p.save('./out/ndata/diffGraph(%s,%s,%s,%s).pdf' %(data[0][0],mu,c,skip))
'''

def calcN2(lmbda,mu,c,skip,n1,n2):
    static_pol = StaticPolicy.find_opt(lmbda,mu,c,skip)[0]
    Lambda = [static_pol[0]*lmbda,(static_pol[0] + static_pol[1])*lmbda]
    plot_data = {}

    a = Queue(Lambda,mu,c,skip,static_pol)
    p0 = a.find_P0()[0]

    value = 0
    a.tdict = {}

    for t in range(1,100):
        a.tdict[t] = probtime1stqueue(t,n1,Lambda[0],c[0],mu[0])

    cumprob = 0
    t = 0
    while cumprob < 0.999:
        t += 1
        for j in range(c[0] + 1):
            if j == 0:
                value +=  a.interpolate(t)* p0 * matrixform(0 + lmbda*static_pol[1],mu[1],c[1],t,n2)
            elif j < c:
                value += a.interpolate(t) * (p0*((Lambda[0]/mu[0])**(j))*(1/math.factorial(j))) * matrixform(j*mu[0] + lmbda*static_pol[1],mu[1],c[1],t,n2)
            else:
                value += a.interpolate(t) * (1 - sum([((Lambda[0]/mu[0])**(j))*(1/math.factorial(j)) for j in range(1,c)]) - p0) * matrixform(c[0]*mu[0] + lmbda*static_pol[1],mu[1],c[1],t,n2)
        cumprob += a.tdict[t]
        print cumprob
    return int(value + 0.5)
#print calcN2(10,[10,2],[2,2],[0.5,20],1,10)
