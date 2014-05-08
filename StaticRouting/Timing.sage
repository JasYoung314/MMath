import time
import KTValues
import random
import csv
def timer():
    mu = [random.uniform(2,5) for e in range(2)]
    c = [random.randint(2,4) for e in range(2)]
    beta = [random.uniform(0.5,2) for e in range(2)]

    for e in range(1,5):

        lmbda = (mu[0]*c[0]*e)/(5)

        start = time.time()
        a = KTValues.Func(lmbda,mu,c,beta,200,[0.25,0.5,0.25],True,50000,True)
        end = time.time()

        n1,n2 = a[0],a[1]

        outfile = open('./out/timings.csv','ab')
        output = csv.writer(outfile)
        outrow = [lmbda,mu[0],mu[1],c[0],c[1],beta[0],beta[1],n1,n2,end-start]
        output.writerow(outrow)
        outfile.close()
while True:
    count = 1
    print "Trial %s" %count
    timer()
    count += 1
