import random
import csv

class Player:
    def __init__(self,Arrival,Dec,arrivestate):
        self.arrival_date = Arrival
        self.Decision = Dec
        self.cost = 0
        self.Queue1end = 'None'
        self.Queue2end = 'None'
        self.arrivalstate = arrivestate
        self.queue2state = 'None'
class Queue:
    def __init__(self,Servers,Rate):
        self.Service_Rate = Rate
        self.Servers = Servers
        self.queue = []
        self.earliest = []
        for e in range(self.Servers):
            self.earliest.append(0)

class State:
    def __init__(self,i1,i2):
        self.i1 = i1
        self.i2 = i2
        self.times = []
        self.TimeDiff = []
        self.Ti =0
        self.costs = []
        self.CostDiff = []
        self.Ki = 0
        self.queue2states = []
        self.expectedi2 = i2
def RandExpo(Param):
    return random.expovariate(Param)

def Decision(Policy,Policy_type,state):
    if Policy_type == 'Routing':
        RandValue = random.uniform(0,1)
        for e in range(3):
            if RandValue <= sum(Policy[:e+1]):
                return e
    else:
        if state[0] < Policy.nrows() and state[1] < Policy.ncols():

            return Policy[state[0],state[1]]
        else:
            return 2
def RoutingSimm(lmbda,Rate,Servers,Skip,MaxTime,Policy,Warm_up,i0 = [0,0],Policy_type = 'Routing'):
    global States
    t = 0
    queues  = {}
    Players = {}
    for e in range(2):
        queues[e] = Queue(Servers[e],Rate[e])

    for e in range(i0[0]):
        NoPlay = len(Players)
        Players[NoPlay] = Player(t,0,[len(queues[0].queue),len(queues[1].queue)])
        if Players[NoPlay].Decision == 1:
            Players[NoPlay].cost = Skip[0]

        Players[NoPlay].ServiceTime = RandExpo(queues[Players[NoPlay].Decision].Service_Rate)
        Players[NoPlay].cost += max(min(queues[Players[NoPlay].Decision].earliest),Players[NoPlay].arrival_date) - Players[NoPlay].arrival_date  + Players[NoPlay].ServiceTime
        queues[Players[NoPlay].Decision].earliest[ queues[Players[NoPlay].Decision].earliest.index( min(queues[Players[NoPlay].Decision].earliest))] = max(min(queues[Players[NoPlay].Decision].earliest),Players[NoPlay].arrival_date) + Players[NoPlay].ServiceTime

        if Players[NoPlay].Decision == 0:
            queues[0].queue.append(NoPlay)
            Players[NoPlay].Queue1end = Players[NoPlay].arrival_date + Players[NoPlay].cost
        elif Players[NoPlay].Decision == 1:
            queues[1].queue.append(NoPlay)
            Players[NoPlay].Queue2end = Players[NoPlay].arrival_date + Players[NoPlay].cost - Skip[0]

    for e in range(i0[1]):
        NoPlay = len(Players)
        Players[NoPlay] = Player(t,1,[len(queues[0].queue),len(queues[1].queue)])
        if Players[NoPlay].Decision == 1:
            Players[NoPlay].cost = Skip[0]

        Players[NoPlay].ServiceTime = RandExpo(queues[Players[NoPlay].Decision].Service_Rate)
        Players[NoPlay].cost += max(min(queues[Players[NoPlay].Decision].earliest),Players[NoPlay].arrival_date) - Players[NoPlay].arrival_date  + Players[NoPlay].ServiceTime
        queues[Players[NoPlay].Decision].earliest[ queues[Players[NoPlay].Decision].earliest.index( min(queues[Players[NoPlay].Decision].earliest))] = max(min(queues[Players[NoPlay].Decision].earliest),Players[NoPlay].arrival_date) + Players[NoPlay].ServiceTime

        if Players[NoPlay].Decision == 0:
            queues[0].queue.append(NoPlay)
            Players[NoPlay].Queue1end = Players[NoPlay].arrival_date + Players[NoPlay].cost
        elif Players[NoPlay].Decision == 1:
            queues[1].queue.append(NoPlay)
            Players[NoPlay].Queue2end = Players[NoPlay].arrival_date + Players[NoPlay].cost - Skip[0]

    if not '%s,%s' %(len(queues[0].queue),len(queues[1].queue)) in States:
        States['%s,%s' %(len(queues[0].queue),len(queues[1].queue))] = State(len(queues[0].queue),len(queues[1].queue))
    States['%s,%s' %(len(queues[0].queue),len(queues[1].queue))].times.append(t )
    States['%s,%s' %(len(queues[0].queue),len(queues[1].queue))].costs.append( sum([Players[e].cost for e in Players]) )

    while t < MaxTime+ 50:
        NoPlay = len(Players)
        Players[NoPlay] = Player(t,Decision(Policy,Policy_type,[len(queues[0].queue),len(queues[1].queue)]),[len(queues[0].queue),len(queues[1].queue)])
        print [len(queues[0].queue),len(queues[1].queue)]
        if Players[NoPlay].Decision == 2 :
            Players[NoPlay].cost = sum(Skip)
        else:
            if Players[NoPlay].Decision == 1:
                Players[NoPlay].cost = Skip[0]

            Players[NoPlay].ServiceTime = RandExpo(queues[Players[NoPlay].Decision].Service_Rate)
            Players[NoPlay].cost += max(min(queues[Players[NoPlay].Decision].earliest),Players[NoPlay].arrival_date) - Players[NoPlay].arrival_date  + Players[NoPlay].ServiceTime
            queues[Players[NoPlay].Decision].earliest[ queues[Players[NoPlay].Decision].earliest.index( min(queues[Players[NoPlay].Decision].earliest))] = max(min(queues[Players[NoPlay].Decision].earliest),Players[NoPlay].arrival_date) + Players[NoPlay].ServiceTime

            if Players[NoPlay].Decision == 0:
                queues[0].queue.append(NoPlay)
                Players[NoPlay].Queue1end = Players[NoPlay].arrival_date + Players[NoPlay].cost
            if Players[NoPlay].Decision == 1:
                queues[1].queue.append(NoPlay)
                Players[NoPlay].Queue2end = Players[NoPlay].arrival_date + Players[NoPlay].cost - Skip[0]

        if '%s,%s' %(len(queues[0].queue),len(queues[1].queue)) in States:
            States['%s,%s' %(len(queues[0].queue),len(queues[1].queue))].times.append(t )
            States['%s,%s' %(len(queues[0].queue),len(queues[1].queue))].costs.append(sum([Players[e].cost for e in Players]) )
        else:
            States['%s,%s' %(len(queues[0].queue),len(queues[1].queue))] = State(len(queues[0].queue),len(queues[1].queue))
            States['%s,%s' %(len(queues[0].queue),len(queues[1].queue))].times.append(t )
            States['%s,%s' %(len(queues[0].queue),len(queues[1].queue))].costs.append(sum([Players[e].cost for e in Players]) )

        t += RandExpo(lmbda)

        if not len(queues[0].queue + queues[1].queue) == 0 :
            queue1exit = [Players[e].Queue1end for e in queues[0].queue]
            queue2exit = [Players[e].Queue2end for e in queues[1].queue]

            while min(queue1exit + queue2exit) < t :

                nextPlayer = (queues[0].queue + queues[1].queue)[0]
                nexttime = Players[nextPlayer].Queue1end
                for e in queues[0].queue :
                    if Players[e].Queue1end < nexttime:
                        nextPlayer = e
                        nexttime = Players[nextPlayer].Queue1end
                for e in queues[1].queue :
                    if Players[e].Queue2end < nexttime:
                        nextPlayer = e
                        nexttime = Players[nextPlayer].Queue2end

                if nextPlayer in queues[0].queue :

                    Players[nextPlayer].ServiceTime2 = RandExpo(queues[1].Service_Rate)
                    Players[nextPlayer].cost += max(min(queues[1].earliest),Players[nextPlayer].Queue1end) - Players[nextPlayer].Queue1end + Players[nextPlayer].ServiceTime2
                    Players[nextPlayer].Queue2end = max(min(queues[1].earliest),Players[nextPlayer].Queue1end) + Players[nextPlayer].ServiceTime2
                    queues[1].earliest[ queues[1].earliest.index( min(queues[1].earliest))] = max(min(queues[1].earliest),Players[nextPlayer].Queue1end) + Players[nextPlayer].ServiceTime2
                    Players[nextPlayer].queue2state = len(queues[1].queue)
                    queues[0].queue.remove(nextPlayer)
                    queues[1].queue.append(nextPlayer)

                    if '%s,%s' %(len(queues[0].queue),len(queues[1].queue)) in States:
                        States['%s,%s' %(len(queues[0].queue),len(queues[1].queue))].times.append(Players[nextPlayer].Queue1end )
                        States['%s,%s' %(len(queues[0].queue),len(queues[1].queue))].costs.append(sum([Players[e].cost for e in Players]) )
                    else:
                        States['%s,%s' %(len(queues[0].queue),len(queues[1].queue))] = State(len(queues[0].queue),len(queues[1].queue))
                        States['%s,%s' %(len(queues[0].queue),len(queues[1].queue))].costs.append(sum([Players[e].cost for e in Players]) )
                        States['%s,%s' %(len(queues[0].queue),len(queues[1].queue))].times.append(Players[nextPlayer].Queue1end )
                else:
                    queues[1].queue.remove(nextPlayer)

                    if '%s,%s' %(len(queues[0].queue),len(queues[1].queue)) in States:
                        States['%s,%s' %(len(queues[0].queue),len(queues[1].queue))].times.append(Players[nextPlayer].Queue2end )
                        States['%s,%s' %(len(queues[0].queue),len(queues[1].queue))].costs.append(sum([Players[e].cost for e in Players]) )
                    else:
                        States['%s,%s' %(len(queues[0].queue),len(queues[1].queue))] = State(len(queues[0].queue),len(queues[1].queue))
                        States['%s,%s' %(len(queues[0].queue),len(queues[1].queue))].costs.append(sum([Players[e].cost for e in Players]))
                        States['%s,%s' %(len(queues[0].queue),len(queues[1].queue))].times.append(Players[nextPlayer].Queue2end )
                if len(queues[0].queue + queues[1].queue) == 0 :
                    break
                else:
                    queue1exit = [Players[e].Queue1end for e in queues[0].queue]
                    queue2exit = [Players[e].Queue2end for e in queues[1].queue]
    for e in Players:
        if not Players[e].queue2state == 'None' and '%s,%s' %(Players[e].arrivalstate[0],Players[e].arrivalstate[0]) in States:
            States['%s,%s' %(Players[e].arrivalstate[0],Players[e].arrivalstate[1])].queue2states.append(Players[e].queue2state)
    #print 'Measure = ', sum([Players[e].cost for e in Players ])/MaxTime
    #return sum([Players[e].cost for e in Players if Players[e].arrival_date > Warm_up ])/(MaxTime-Warm_up),States
    return sum([Players[e].cost for e in Players if Players[e].arrival_date > Warm_up and Players[e].arrival_date < MaxTime ])/((MaxTime-Warm_up)*(lmbda + sum([Rate[e]*Servers[e] for e in range(2)]))),States
    #return sum([Players[e].cost for e in Players if Players[e].arrival_date > Warm_up ])/len(Players)


def Func(lmbda,mu,c,beta,Time,Policy,Plots = False,Data_Points = 10000,Dataout = False):
    global States
    States = {}
    a = RoutingSimm(lmbda,mu,c,beta,Time,Policy,0)

    maxi1 = 0
    maxi2 = 0

    for e in States:
        if States[e].i1 > maxi1:
            maxi1 = States[e].i1
        if States[e].i2 > maxi2:
            maxi2 = States[e].i2
    maxi1,maxi2 = 30,30
    print 'Search space size  = (%s,%s)' %(maxi1,maxi2)

    for i in States['0,0'].times[1:]:
        for e in States:
            for j in States[e].times:
                if j < i and  j > States['0,0'].times[States['0,0'].times.index(i) - 1]:
                    States[e].TimeDiff.append(i - j)

    for i in States['0,0'].costs[1:]:
        for e in States:
            for j in States[e].costs:
                if j < i and  j > States['0,0'].costs[States['0,0'].costs.index(i) - 1]:
                    States[e].CostDiff.append(i - j)


    for e in range(maxi1 + 1):
        for k in range(maxi2 + 1):

            print e,k
            if not '%s,%s' %(e,k) in States:
                States['%s,%s' %(e,k)] = State(e,k)
            while len(States['%s,%s' %(e,k)].TimeDiff) < Data_Points and not [e,k] == [0,0]:
                #print 'data points = %s ' %len(States['%s,%s' %(e,k)].TimeDiff)

                for b in States:

                    States[b].times = []
                    States[b].costs = []
                a = RoutingSimm(lmbda,mu,c,beta,Time/2,Policy,0,[e,k])

                for i in States['0,0'].times:
                    for l in States:
                        for j in States[l].times:
                            if j < States['0,0'].times[0]:
                                States[l].TimeDiff.append(States['0,0'].times[0] - j)
                            if j < i and  j > States['0,0'].times[States['0,0'].times.index(i) - 1]:
                                States[l].TimeDiff.append(i - j)

                for i in States['0,0'].costs:
                    for l in States:
                        for j in States[l].costs:
                            if j < States['0,0'].costs[0]:
                                States[l].CostDiff.append(States['0,0'].costs[0] - j)
                            if j < i and  j > States['0,0'].costs[States['0,0'].costs.index(i) - 1] :

                                States[l].CostDiff.append(i - j)

    for l in States:
        if not len(States[l].queue2states) == 0:
            print States[l].queue2states,sum(States[l].queue2states)
            States[l].expectedi2 = sum(States[l].queue2states)/len(States[l].queue2states)
            print l,len(States[l].queue2states),States[l].expectedi2
        if not len(States[l].TimeDiff) == 0:
            States[l].Ti = sum(States[l].TimeDiff)/len(States[l].TimeDiff)
        if not len(States[l].CostDiff) == 0:
            States[l].Ki = sum(States[l].CostDiff)/len(States[l].CostDiff)

    #for e in range(maxi1 + 1):
    #    for k in range(maxi2 + 1):
            #print e,k,len(States['%s,%s' %(e,k)].TimeDiff),States['%s,%s' %(e,k)].Ti
            #print e,k,len(States['%s,%s' %(e,k)].CostDiff),States['%s,%s' %(e,k)].Ki

    if Dataout == True:
        outfile = open( './out/KTValues-(%s,%s,%s,%s,%s,%s).csv' %(lmbda,mu,c,beta,Policy,Data_Points),'wb')
        output = csv.writer(outfile)
        outrow = [lmbda,mu,c,beta,Policy,Data_Points]
        output.writerow(outrow)
        outrow = ['n1','n2','Data Points Used','T','K']
        output.writerow(outrow)
        for e in range(maxi1 + 1):
            for k in range(maxi2 + 1):
                outrow = [ e,k,len(States['%s,%s' %(e,k)].CostDiff),States['%s,%s' %(e,k)].Ti,States['%s,%s' %(e,k)].Ki]
                output.writerow(outrow)

        outfile.close()
    if Plots == True:
        def f(x,y):
            if x == 0 and y == 0:
                return 0
            return States['%s,%s' %(int(x),int(y))].Ti
        def g(x,y):
            if x == 0 and y == 0:
                return 0
            return States['%s,%s' %(int(x),int(y))].Ki


        for i in range(10):
            point1 = random.uniform(1,maxi1)
            point2 = random.uniform(1,maxi1)

            Total = 0
            count = 0
            plotdata = [[0,0]]
            for e in States['%s,%s' %(int(point1),int(point2)) ].TimeDiff:

                Total += e
                count += 1
                plotdata.append([count,Total/count])

            R = list_plot(plotdata)
            R.save('./out/AverageCost%s.pdf' %i)

        P = contour_plot(f,(0,maxi1),(0,maxi2),contours = 100,colorbar = True)
        P.save('./out/TimeMatrix(%s,%s,%s,%s,%s,%s).pdf' %(lmbda,mu,c,beta,Policy,Data_Points))
        Q = contour_plot(g,(0,maxi1),(0,maxi2),contours = 100,colorbar = True)
        Q.save('./out/CostMatrix(%s,%s,%s,%s,%s,%s).pdf' %(lmbda,mu,c,beta,Policy,Data_Points))
    return States,[maxi1,maxi2]
#Func(10,[4,4],[2,4],[2,2],200,[0.25,0.5,0.25],False,10,False)
global States
States = {}
m = matrix(20)
for e in range(20):
    for i in range(20):

        m[e,i] = 2
#zeroes = [[0,0],[0,1],[0,2],[0,3],[1,0],[1,1],[1,2]]
ones = [[0,0],[0,1],[1,0],[2,0],[3,0]]

for i in ones:
    m[i[0],i[1]] = 1
#for i in zeroes:
#    m[i[0],i[1]] = 0
print m.str()
#a = RoutingSimm(49,[5.38,5.74],[3,2],[0.487,0.4605],1000,m,200,[0,0],Policy_type = 'Matrix')
a = RoutingSimm(5,[3,4],[2,2],[0.1,0.1],1000,m,200,[0,0],Policy_type = 'Matrix')
print a[0]
