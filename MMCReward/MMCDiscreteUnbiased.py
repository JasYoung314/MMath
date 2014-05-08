from __future__ import division
import random

class Player():
    def __init__(self,arrival_date):
        self.arrival_date = arrival_date
        self.Service_time = 0
        self.Service_end = 0
        self.cost = 0

class Server():
    def __init__(self):
        self.Serving = False

def DiscreteSim(lmbda = False, mu = False,C = 1, Reward = False,Policy =False, Simulation_Time = 10 , alpha = 0.8,epsilon = 0.01):

    time_unit = 1/(lmbda+C*mu)

    Probabilities = [lmbda*time_unit]

    for e in range(C):
        Probabilities.append(mu*time_unit)

    Waiting = []

    Players = {}
    Servers = {}
    for e in range(C):
        Servers[e+1] = Server()

    # Simulation Stuff
    t = 0
    while t < Simulation_Time :
        if t == 0:
            Event = 0
        else:

            Roulette = random.uniform(0,1)
            for i in range(len(Probabilities)):
                if Roulette < sum(Probabilities[:i+1]):

                    Event = i
                    break

        if Event == 0:

            Players[len(Players)] = Player(t)
            current = len(Players) - 1

            if len(Waiting) + sum([1 for e in Servers if Servers[e].Serving]) < Policy:

                if len(Waiting) == 0:

                    All_busy = 0
                    for e in Servers :

                        if Servers[e].Serving == False:
                            Servers[e].Serving = True
                            Servers[e].Serving_Player = current
                            break


                        else:
                            All_busy += 1

                    if All_busy == C:
                        Waiting.append(current)
                else:
                    Waiting.append(current)

        else:
            if Servers[Event].Serving == True:
                if len(Waiting) > 0 :
                    Players[Servers[Event].Serving_Player].cost = (t - Players[Servers[Event].Serving_Player].arrival_date)*time_unit - Reward
                    Servers[Event].Serving_Player = Waiting[0]
                    Waiting.remove(Waiting[0])

                else:
                    Players[Servers[Event].Serving_Player].cost = (t - Players[Servers[Event].Serving_Player].arrival_date)*time_unit - Reward
                    Servers[Event].Serving = False

        t += 1
    Total_cost = 0
    for e in Players:
        #if True:
        if alpha**(Players[e].arrival_date - 1) > epsilon:
            Total_cost += Players[e].cost*(alpha**(Players[e].arrival_date))

    return Total_cost
'''
for e in range(30):
    trials = [DiscreteSim(e,5,2,1,10,200,alpha = 0.6,epsilon = 0.01) for k in range(2000)]
    trialsAve = sum(trials)/len(trials)
    print trialsAve
'''

