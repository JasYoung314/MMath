from __future__ import division
import random

class Player():
    def __init__(self,arrival_date):
        self.arrival_date = arrival_date
        self.Service_time = 0
        self.Service_end = 0
        self.cost = 0

class Queue():
    def __init__(self,mu,Reward,C):
        self.mu = mu
        self.R = Reward
        self.C = C
        self.Earliest = [ 0 for e in range(C)]
        self.queue = []
        self.avail = 0
    def Cleanup(self,t,Players,Simulation_Time):
        for e in self.queue:
            if Players[e].Service_end < t:
                #Players[e].cost -= self.R
                self.queue.remove(e)

def RandomVariables(Param):
        return random.expovariate(Param)

def Simul8(lmbda = False, mu = False, Reward = False,Policy =False,alpha = 1, Simulation_Time = 250, warm_up = 0,C = 1,epsilon = 0.01):

    t = 0
    Players = {}
    Station = Queue(mu,Reward,C)
    if not Policy:
        Policy = int(Reward*mu)
    while t < Simulation_Time:
        t += RandomVariables(lmbda)
        Players[len(Players)] = Player(t)
        Current = len(Players) - 1
        Station.Cleanup(t,Players,Simulation_Time)

        if len(Station.queue) < Policy:
            Players[Current].Service_time = RandomVariables(Station.mu)
            Station.queue.append(Current)


            Players[Current].Service_end = max(t + Players[Current].Service_time, min(Station.Earliest)+Players[Current].Service_time)
            Station.Earliest[Station.Earliest.index(min(Station.Earliest))] = Players[Current].Service_end

            Players[Current].cost = Players[Current].Service_end - Players[Current].arrival_date - Reward
            if  Players[Current].Service_end - Players[Current].arrival_date < 0 :
				return 'NOOOOOOOOOOO'
    Average_cost = 0
    count = 0
    skips = 0
    for e in Players:

        if Players[e].arrival_date <= Simulation_Time and Players[e].arrival_date >= warm_up:
            Average_cost += (Players[e].cost)
            count += 1
    Average_cost /= count

    return Average_cost

if __name__ == '__main__':
    Trials =  [Simul8(5,4,2.5,Policy = 18 , C = 2,Simulation_Time = 100 ,warm_up = 20) for e in range(500)]
    TrialsAve = sum(Trials)/len(Trials)
    print TrialsAve
