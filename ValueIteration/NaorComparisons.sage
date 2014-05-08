import numpy as np
import matplotlib.pyplot as plt
import Naor
import ValueIteration2
p = plot([])
Naorlist = []
MDPlist = []

for e in range(1,15):
    print ' ----- Testing lambda = %s -----' %e
    Testlmbda =e
    Testmu = [15]
    TestReward = [1.5]

    MDP = ValueIteration2.Queue(lmbda = Testlmbda , mu = Testmu[0] ,C = 1,R = TestReward[0],epsilon = 0.000000001)
    MDPVal = MDP.ValueIter()[1]

    Woof = Naor.System(lmbda = Testlmbda,mu = Testmu,beta = TestReward)
    Naor.NaorCalc(Woof)
    OptPolicy = Woof.Threshold[0]

    Naorlist.append(OptPolicy)
    MDPlist.append(MDPVal)

    if OptPolicy == MDPVal:
        print 'Win'
    else:
        print 'loss'

N = len(Naorlist)
ind = np.arange(N)  # the x locations for the groups
width = 0.5       # the width of the bars

fig, ax = plt.subplots()
rects1 = ax.bar(ind, MDPlist, width, color='r')

#rects2 = ax.bar(ind+width, Naorlist, width, color='b')

ax.set_ylabel('Threshold')
ax.set_xlabel(' $ \\lambda $ ')
ax.set_xticks(ind)
xtick = [e + 1 for e in range(N)]
ax.set_xticklabels( xtick )

#ax.legend( (rects1[0] ), ('MDP') )
plt.savefig('./out/NaorComp/%s,%s.pdf' %(Testmu[0],TestReward[0]))
