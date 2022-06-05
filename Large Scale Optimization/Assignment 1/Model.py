# import libraries
import random
import math

# create class Model


class Model:
    def __init__(self):
        self.allNodes = []
        self.customers = []
        self.matrix = []
        self.matrix_profit = []
        self.capacity = -1

    def BuildModel(self):
        random.seed(1)
        # The warehouse is located in the coordinates (50,50)
        depot = Node(0, 50, 50, 0, 0)
        self.allNodes.append(depot)
        self.capacity = 150
        totalCustomers = 300
        # create Node for each customer that holds their attributes (id, longitude, latitude, time, profit)
        for i in range(0, totalCustomers):
            x = random.randint(0, 100)
            y = random.randint(0, 100)
            # the service time for each customer is a random number between 5 and 10 time units
            Servicetime = random.randint(5, 10)
            # The profit for each customer is a random number between 5 and 20
            Profit = random.randint(5, 20)
            cust = Node(i + 1, x, y, Servicetime, Profit)
            self.allNodes.append(cust)
            self.customers.append(cust)
        # create 2 empty matrices
        rows = len(self.allNodes)
        self.matrix = [[0.0 for x in range(rows)] for y in range(rows)]
        self.matrix_profit = [[0.0 for x in range(rows)] for y in range(rows)]

        for i in range(0, len(self.allNodes)):
            for j in range(0, len(self.allNodes)):
                a = self.allNodes[i]
                b = self.allNodes[j]
                dist = ((a.x - b.x)**2 + (a.y - b.y)**2)**(1/2)
                # fill the first empty matrix with the euclidean distance for each pair of Nodes
                self.matrix[i][j] = dist
                if a == b:
                    ratio = -2
                else:
                    ratio = round(b.profit / (b.time + dist), 4)
                # fill the second empty matrix with the ratio of profit to the total cost (where cost is the time and distance) per pair of Nodes
                self.matrix_profit[i][j] = ratio

# Create class Node which objects will represent the customers and their attributes


class Node:
    def __init__(self, idd, xx, yy, time, profit):
        self.x = xx
        self.y = yy
        self.ID = idd
        self.time = time
        self.profit = profit
        self.isRouted = False

# Create class Route that will create Objects of the sequence of the Nodes each vehicle will follow


class Route:
    def __init__(self, dp, cap, cost=0, profit=0):
        self.sequenceOfNodes = []
        self.sequenceOfNodes.append(dp)
        self.cost = cost
        self.capacity = cap
        self.profit = profit
