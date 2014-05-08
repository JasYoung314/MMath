from __future__ import division
import random

class Player():
    def __init__(self,arrival_date):
        self.arrival_date = arrival_date
        self.Service_time = 0
        self.Service_end = 0
        self.cost = 0

class Queue():
    def __init__(self,mu,Reward):
        self.mu = mu
        self.R = Reward
        self.queue = []
        self.avail = 0
    def Cleanup(self,t,Players,Simulation_Time):
        for e in self.queue:
            if Players[e].Service_end < t:
                #Players[e].cost -= self.R
                self.queue.remove(e)

def RandomVariables(Param):
        return random.expovariate(Param)

def Simul8(lmbda = False, mu = False, Reward = False,Policy =False,alpha = 1, Simulation_Time = 250, warm_up = 0):

    t = 0
    Players = {}
    Station = Queue(mu,Reward)
    if not Policy:
        Policy = int(Reward*mu)
        Policy = 0
    while t < Simulation_Time:
        t += RandomVariables(lmbda)
        Players[len(Players)] = Player(t)
        Current = len(Players) - 1
        Station.Cleanup(t,Players,Simulation_Time)

        if len(Station.queue) < Policy:
            Players[Current].Service_time = RandomVariables(Station.mu)
            Station.queue.append(Current)


            if len(Station.queue) == 1:
                Players[Current].Service_end = t + Players[Current].Service_time
            else:

                Players[Current].Service_end = max(t + Players[Current].Service_time, Players[Station.queue[-2]].Service_end + Players[Current].Service_time)

            #Players[Current].cost = Players[Current].Service_end - Players[Current].arrival_date

            Players[Current].cost = Players[Current].Service_end - Players[Current].arrival_date - Reward

    Average_cost = 0
    count = 0
    for e in Players:

        if Players[e].arrival_date <=Simulation_Time and Players[e].arrival_date >= warm_up and not (alpha)**(int(Players[e].arrival_date*(lmbda)))<0.01:
            Average_cost += (Players[e].cost)*(alpha**(int(Players[e].arrival_date*(lmbda))))

            count += 1
        #Average_cost += (Players[e].cost)
    return Average_cost
if __name__ == '__main__':
    Trials = [Simul8(2,3,1.0,Policy=4,alpha = 1,Simulation_Time = 7/5 ,warm_up = 0) for k in range(2000)]
    TrialsAve =  sum(Trials)/len(Trials)
    print TrialsAve
    Trials = [Simul8(8,10,0.5,Policy=4,alpha = 1,Simulation_Time = 7/18 ,warm_up = 0) for k in range(2000)]
    TrialsAve =  sum(Trials)/len(Trials)
    print TrialsAve
