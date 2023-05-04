# Import the Model and Solver Modules
from Model import *
from Solver import *

# create the model object that includes the Nodes (Customers) with their attributes, the cost matrix and the profit matrix
m = Model()
m.BuildModel()
# Feed the solver with the model object
s = Solver(m)
sol = s.solve()
