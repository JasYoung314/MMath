S = [0,1]
A = [['a','a*'],['b','b*']]
F = [1,2]
Policy = []
optimal = [{},{}]
def Cost(state,action):
    if state == 0:
        if action == 'a':
            return 1
        elif action == 'a*':
            return 0.75
    if state == 1:
        if action == 'b':
            return 4
        if action == 'b*':
            return 3

def Pij(j,A):

    if A == 'a':
        M = [0.5,0.5]
    if A == 'a*':
        M = [0.25,0.75]
    if A == 'b':
        M = [1,0]
    if A == 'b*':
        M = [0.5,0.5]

    return M[j]

def Solve(N,i):
    cost = []
    if N == 0:
        return F[i],'done'
    else:
        for e in A[i]:
            cost.append(Cost(i,e)+Pij(0,e)*Solve(N-1,0)[0]+Pij(1,e)*Solve(N-1,1)[0])

        if cost[0] == cost[1]:
            optimal[i][N] = A[i]
        else:
            optimal[i][N] = A[i][cost.index(min(cost))]
        return min(cost),A[i][cost.index(min(cost))]

def ValueIter():
    StateValues = {}
    StateActions = {}

    StateActions[0] = {}
    StateActions[0][0] = 'a'
    StateActions[0][1] = 'b'

    StateValues[0] = {}
    StateValues[0][0] = 1
    StateValues[0][1] = 2
    k = 0

    end = False
    while not end:
        k+=1

        StateValues[k] = {}
        StateActions[k] = {}

        for X in S:
            costs = []
            for a in A[X]:

                costs.append(Cost(X,a) + Pij(0,a)*StateValues[k - 1][0] + Pij(1,a)*StateValues[k - 1][1]  )

            print costs
            StateValues[k][X] = min(costs)
            StateActions[k][X] = A[X][costs.index(min(costs))]
            StateValues[k][X] -= StateValues[k-1][0]


        end = True
        epsilonlist = [ abs(StateValues[k][X] -  StateValues[k-1][X]) for X in S]
        for e in epsilonlist:
            if e > 0.00001:
                end = False
    return StateActions[k]

print Solve(5,1)
print optimal
print ValueIter()
