import random


class Point():
    def __init__(self,initial_position_x = 0,initial_position_y = 0,Policy = False):
        self.pos = [initial_position_x,initial_position_y]
        self.Policy = Policy
        self.Dim = [Policy.nrows(),Policy.ncols()]
        self.value = Policy[self.pos[0]][self.pos[1]]
        self.Valid = True

    def Map(self,z):
        if z == 1:
            return -1
        elif z == 2:
            return 1

    def Move(self):
        if self.value == 0:

            Queue = random.randint(0,1)
            Movement = self.Map(random.randint(1,2))

        elif self.value == 1:
            Queue = random.randint(0,1)
            if Queue == 1:
                Movement = -1
            else:
                Movement = self.Map(random.randint(1,2))

        elif self.value == 2:
            Queue = random.randint(0,1)
            Movement = -1

        self.pos[Queue] = max(Movement+self.pos[Queue],0)
        if self.pos[Queue] >= self.Dim[Queue]:
            self.Valid = False
            return

        self.value = self.Policy[self.pos[0]][self.pos[1]]

    def evaluate(self,iterations = 100):
        k = 0
        while iterations > k and self.Valid:
            self.Move()
            k+=1
        return self.Valid

Pol = matrix([[0,0,0,2,0,0,0,1],[0,0,0,0,0,0,0,1],[2,2,2,2,2,2,2,2]])

Test = Point(Policy = Pol)
print Test.evaluate(100000)
