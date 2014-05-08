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
    def Cleanup(self,t,Players):
        for e in self.queue:
            if Players[e].Service_end < t:
                #Players[e].cost -= self.R
                self.queue.remove(e)

def RandomVariables(Param):
        return random.expovariate(Param)

def Simul8(lmbda = False, mu = False, Reward = False,Policy =False,alpha = 1, Simulation_Time = 250, warm_up = 0,C = 1,epsilon = 0.01,end_T = False):

    t = 0
    Players = {}
    Station = Queue(mu,Reward,C)

    while t < Simulation_Time:
        Players[len(Players)] = Player(t)
        Current = len(Players) - 1
        Station.Cleanup(t,Players)

        if len(Station.queue) < Policy:
            Players[Current].Service_time = RandomVariables(Station.mu)
            Station.queue.append(Current)

            Players[Current].Service_end = max(t + Players[Current].Service_time, min(Station.Earliest)+Players[Current].Service_time)
            Station.Earliest[Station.Earliest.index(min(Station.Earliest))] = Players[Current].Service_end

            Players[Current].cost = Players[Current].Service_end - Players[Current].arrival_date - Reward

        t += RandomVariables(lmbda)

    count = 0
    Average_cost = 0
    for e in Players:
        if Players[e].arrival_date <= Simulation_Time and Players[e].arrival_date >= warm_up and (alpha)**(int(Players[e].arrival_date*(lmbda+C*mu))  ) > epsilon:
         #if int(Players[e].arrival_date*(lmbda+C*mu)) < end_T:
            Average_cost += (Players[e].cost)*((alpha)**(int(Players[e].arrival_date*(lmbda+mu*C))))
    return Average_cost
'''
if __name__ == '__main__':
    for e in range(1,10):
        Trials = [Simul8(e,2,1.0,Policy = 20, C = 2,alpha = 0.5,epsilon = 0.01 ,Simulation_Time = 10 ,warm_up = 0)for k in range(1000)]
        TrialsAve = sum(Trials)/len(Trials)
        print TrialsAve
'''

