# Import the Model Module
from Model import *

# Create the class that gives the solution of the suggested routes


class Solution:
    def __init__(self):
        self.cost = 0.0
        self.profit = 0
        self.routes = []

# -----------------------------------------     Local Search  Classes  ----------------------------------------------------

# Create the objects that will be used to perform Relocation of Nodes on the initial suggested routes


class RelocationMove(object):
    def __init__(self):
        self.originRoutePosition = None
        self.targetRoutePosition = None
        self.originNodePosition = None
        self.targetNodePosition = None
        self.costChangeOriginRt = None
        self.costChangeTargetRt = None
        self.moveCost = None

    def Initialize(self):
        self.originRoutePosition = None
        self.targetRoutePosition = None
        self.originNodePosition = None
        self.targetNodePosition = None
        self.costChangeOriginRt = None
        self.costChangeTargetRt = None
        self.moveCost = 10 ** 9

# Create the objects that will be used to perform Swap of Nodes on the initial suggested routes


class SwapMove(object):
    def __init__(self):
        self.positionOfFirstRoute = None
        self.positionOfSecondRoute = None
        self.positionOfFirstNode = None
        self.positionOfSecondNode = None
        self.costChangeFirstRt = None
        self.costChangeSecondRt = None
        self.moveCost = None

    def Initialize(self):
        self.positionOfFirstRoute = None
        self.positionOfSecondRoute = None
        self.positionOfFirstNode = None
        self.positionOfSecondNode = None
        self.costChangeFirstRt = None
        self.costChangeSecondRt = None
        self.moveCost = 10 ** 9

# Create the objects that will be used to perform insertion


class InsertionMove(object):
    def __init__(self):
        self.targetRoutePosition = None
        self.targetNodePosition = None
        self.costChangeTargetRt = None
        self.moveCost = None
        self.profit = None
        self.temp_cust = None

    def Initialize(self):
        self.targetRoutePosition = None
        self.targetNodePosition = None
        self.costChangeTargetRt = None
        self.moveCost = 10 ** 9
        self.profit = 0
        self.temp_cust = None


class ProfitableSwapMove(object):
    def __init__(self):
        self.firstRouteIndex = None
        self.positionOfFirstNode = None
        self.positionOfSecondNode = None
        self.costChangeFirstRt = None
        self.moveCost = None
        self.profitChange = None
        self.temp_cust = None

    def Initialize(self):
        self.firstRouteIndex = None
        self.positionOfFirstNode = None
        self.positionOfSecondNode = None
        self.costChangeFirstRt = None
        self.moveCost = 10 ** 9
        self.profitChange = None
        self.temp_cust = None

# ------------------------------------------------- Customers Insertion Classes------------------------------------------------------


class CustomerInsertion(object):
    def __init__(self):
        self.customer = None
        self.route = None
        self.cost = 10 ** 9


class CustomerInsertionAllPositions(object):
    def __init__(self):
        self.customer = None
        self.route = None
        self.insertionPosition = None
        self.ratio = -1
        self.profit = -1
        self.cost = 0

# ------------------------------------------------   Solver   ------------------------------------------------------------


class Solver:
    def __init__(self, m):
        self.allNodes = m.allNodes
        self.customers = m.customers
        self.depot = m.allNodes[0]
        self.distanceMatrix = m.matrix
        self.matrix_profit = m.matrix_profit
        self.capacity = m.capacity
        self.sol = None
        self.bestSolution = None

    def solve(self):
        self.SetRoutedFlagToFalseForAllCustomers()
        self.NearestNeighbor()
        self.VND()
        self.ReportSolution(self.sol)
        return self.sol
    # keep all customers initially unrouted as they have not been positioned to a route

    def SetRoutedFlagToFalseForAllCustomers(self):
        for i in range(0, len(self.customers)):
            self.customers[i].isRouted = False
    # keep an empty route to add the node if it does not fit in the already existing routes

    def Always_keep_an_empty_route(self):
        if len(self.sol.routes) == 0:
            rt = Route(self.depot, self.capacity)
            self.sol.routes.append(rt)
        else:
            rt = self.sol.routes[-1]
            if len(rt.sequenceOfNodes) > 2:
                rt = Route(self.depot, self.capacity)
                self.sol.routes.append(rt)

    # finds the lowest cost and highest profit Node to insert to the route keeping in mind the capacity limit
    def IdentifyMinimumCostInsertion(self, best_insertion):
        temp_profit = -1
        for i in range(0, len(self.customers)):
            candidateCust: Node = self.customers[i]
            # check if the node has been routed
            if candidateCust.isRouted is False:
                for rt in self.sol.routes:
                    for j in range(0, len(rt.sequenceOfNodes)):
                        # check if the node exceeds the cost capacity of the available routes
                        if rt.cost + candidateCust.time + self.distanceMatrix[rt.sequenceOfNodes[len(rt.sequenceOfNodes)-1].ID][candidateCust.ID]\
                                + self.distanceMatrix[candidateCust.ID][0] <= rt.capacity:
                            # check if the node has the highest profit between the rest of the nodes
                            # which do not exceed the cost capacity of the available routes
                            if self.matrix_profit[rt.sequenceOfNodes[len(rt.sequenceOfNodes)-1].ID][candidateCust.ID] >= temp_profit:
                                temp_profit = self.matrix_profit[rt.sequenceOfNodes[len(
                                    rt.sequenceOfNodes)-1].ID][candidateCust.ID]
                                best_insertion.customer = candidateCust
                                best_insertion.route = rt
                                best_insertion.cost = candidateCust.time + \
                                    self.distanceMatrix[rt.sequenceOfNodes[len(
                                        rt.sequenceOfNodes)-1].ID][candidateCust.ID]
                                best_insertion.profit = candidateCust.profit
            else:
                continue

    # ------------------------------------------------- NEAREST NEIGHBOR ALGORITHM ------------------------------------------------------------------------
    ''' The algorithm inspects all the customers (nodes) that can fit (considering that the vehicle must return to the
        warehouse) in the open routes, selects the one with the greatest value in the profit matrix and stores them
        and their best route. Upon inspecting all the customers, the warehouse is inserted at the last position of each
        route and the cost is updated with the time spend to travel from the last customer of each route to the warehouse '''

    def NearestNeighbor(self):
        model_is_feasible = True
        self.sol = Solution()
        insertions = 0
        trucks = 4

        while insertions < len(self.customers):
            # find the best insertion
            best_insertion = CustomerInsertionAllPositions()
            if len(self.sol.routes) <= trucks:
                self.Always_keep_an_empty_route()
            self.IdentifyMinimumCostInsertion(best_insertion)

            if best_insertion.customer is not None:
                # add best insertion to the appropriate route
                self.ApplyCustomerInsertionAllPositions(best_insertion)
                insertions += 1
            else:
                insertions += 1

        if model_is_feasible:
            for j in range(0, len(self.sol.routes)):
                seq_of_cust = []
                self.sol.routes[j].sequenceOfNodes.append(self.depot)

                for cust in range(0, len(self.sol.routes[j].sequenceOfNodes)):
                    seq_of_cust.append(
                        self.sol.routes[j].sequenceOfNodes[cust].ID)
                self.sol.routes[j].cost += self.distanceMatrix[self.sol.routes[j].sequenceOfNodes[cust-1].ID][0]
                self.sol.cost += self.distanceMatrix[self.sol.routes[j].sequenceOfNodes[cust-1].ID][0]

                print('Route ', j + 1, ': Profit is',
                      self.sol.routes[j].profit, 'Cost is', self.sol.routes[j].cost, 'Customers:', seq_of_cust)
            print('Solution Cost is:', self.sol.cost,
                  'Solution Profit is:', self.sol.profit)

    def GetLastOpenRoute(self):
        if len(self.sol.routes) == 0:
            return None
        else:
            return self.sol.routes[-1]

    def CalculateTotalCost(self, sol):
        c = 0
        for i in range(0, len(sol.routes)):
            rt = sol.routes[i]
            for j in range(0, len(rt.sequenceOfNodes) - 1):
                a = rt.sequenceOfNodes[j]
                b = rt.sequenceOfNodes[j + 1]
                c += self.distanceMatrix[a.ID][b.ID] + b.time
        return c

    def CalculateTotalProfit(self, sol):
        p = 0
        for i in range(0, len(sol.routes)):
            rt = sol.routes[i]
            for j in range(0, len(rt.sequenceOfNodes)):
                a = rt.sequenceOfNodes[j]
                p += a.profit
        return p

    def ApplyCustomerInsertionAllPositions(self, insertion):
        insCustomer = insertion.customer
        rt = insertion.route
        rt.sequenceOfNodes.append(insCustomer)
        rt.cost += insertion.cost
        self.sol.cost += insertion.cost
        self.sol.profit += insertion.profit
        rt.profit += insertion.profit
        insCustomer.isRouted = True

    def cloneRoute(self, rt: Route):
        cloned = Route(self.depot, self.capacity)
        cloned.cost = rt.cost
        cloned.sequenceOfNodes = rt.sequenceOfNodes.copy()
        return cloned

    def cloneSolution(self, sol: Solution):
        cloned = Solution()
        for i in range(0, len(sol.routes)):
            rt = sol.routes[i]
            clonedRoute = self.cloneRoute(rt)
            cloned.routes.append(clonedRoute)
        cloned.cost = self.sol.cost
        cloned.profit = self.sol.profit
        return cloned
    # --------------------------------------- LOCAL SEARCH ALGORITHMS --------------------------------------------
    # Local searches are procedures that iteratively transition from one solution to another via specific modifications to the current solution structure.

    def LocalSearch(self, operator):
        self.bestSolution = self.cloneSolution(self.sol)
        terminationCondition = False
        localSearchIterator = 0

        rm = RelocationMove()
        sm = SwapMove()
        ins = InsertionMove()
        psm = ProfitableSwapMove()

        while terminationCondition is False:

            self.InitializeOperators(rm, sm, ins, psm)

            # Relocations
            '''The aim of this local search is to minimize the solution’s total cost by relocating covered customers 
            from their current position in the route to another (this is not limited to the route of the vehicle that 
            currently serves the customer but all the possible routes that can feasibly serve him)'''
            if operator == 0:
                self.FindBestRelocationMove(rm)
                local_search = 'Relocation'
                if rm.originRoutePosition is not None:
                    if rm.moveCost < 0:
                        self.ApplyRelocationMove(rm)
                    else:
                        terminationCondition = True

            # Swaps
                '''The aim of this local search is to minimize the solution’s total cost by swapping the position of any pair 
                of covered customers (in the same or different routes), while not violating the capacity constraint for each vehicle examined.'''
            elif operator == 1:
                self.FindBestSwapMove(sm)
                local_search = 'Swap'
                if sm.positionOfFirstRoute is not None:
                    if sm.moveCost < 0:
                        self.ApplySwapMove(sm)
                    else:
                        terminationCondition = True

            # Insertion
                '''The aim of this local search is to maximize the profit per cost ratio of the solution by examining all the possible 
                insertion positions in the current solution for all uncovered customers. The customer selected is the one with the best 
                profit to cost ratio that does not violate the capacity constraint of the route they will be inserted to.'''
            elif operator == 2:
                self.FindBestInsertionMove(ins)
                local_search = 'Insertion'
                if ins.targetRoutePosition is not None:
                    if ins.moveCost < 0 | ins.profit > 0:
                        self.ApplyInsertionMove(ins)
                    else:
                        terminationCondition = True
                else:
                    terminationCondition = True

            # Profitable Swaps
                '''The aim of this local search is to maximize the profit per cost ratio of the solution by replacing any covered 
                customer in the current solution with any uncovered customer. For each possible swap the time constraint for each 
                vehicle is taken into consideration.'''
            elif operator == 3:
                self.FindBestProfitableSwapMove(psm)
                local_search = 'Profitable Swap'
                if psm.firstRouteIndex is not None:
                    if psm.profitChange > 0:
                        self.ApplyProfitableSwapMove(psm)
                    else:
                        terminationCondition = True
                else:
                    terminationCondition = True

            self.TestSolution()
            if ((operator == 0) | (operator == 1)):
                if (self.sol.cost < self.bestSolution.cost):
                    self.bestSolution = self.cloneSolution(self.sol)

                    localSearchIterator = localSearchIterator + 1
                    print(localSearchIterator, self.sol.cost)
            elif operator == 2:
                if (self.sol.cost < self.bestSolution.cost) | (self.sol.profit > self.bestSolution.profit):
                    self.bestSolution = self.cloneSolution(self.sol)

                    localSearchIterator = localSearchIterator + 1
                    print(localSearchIterator, self.sol.cost)

            elif operator == 3:
                if (self.sol.profit > self.bestSolution.profit):
                    self.bestSolution = self.cloneSolution(self.sol)

                    localSearchIterator = localSearchIterator + 1
                    print(localSearchIterator, self.sol.cost)

        self.bestSolution = self.sol
        print(local_search, '  -   Total number of moves:', localSearchIterator,
              'move cost is: ', self.bestSolution.cost, 'Profit is:', self.sol.profit)

    def FindBestRelocationMove(self, rm):
        for originRouteIndex in range(0, len(self.sol.routes)):
            rt1: Route = self.sol.routes[originRouteIndex]
            for originNodeIndex in range(1, len(rt1.sequenceOfNodes) - 1):
                for targetRouteIndex in range(0, len(self.sol.routes)):
                    rt2: Route = self.sol.routes[targetRouteIndex]
                    for targetNodeIndex in range(0, len(rt2.sequenceOfNodes) - 1):

                        if originRouteIndex == targetRouteIndex and (
                                targetNodeIndex == originNodeIndex or targetNodeIndex == originNodeIndex - 1):
                            continue

                        A = rt1.sequenceOfNodes[originNodeIndex - 1]
                        B = rt1.sequenceOfNodes[originNodeIndex]
                        C = rt1.sequenceOfNodes[originNodeIndex + 1]

                        F = rt2.sequenceOfNodes[targetNodeIndex]
                        G = rt2.sequenceOfNodes[targetNodeIndex + 1]

                        if rt1 != rt2:
                            if rt2.cost + B.time + self.distanceMatrix[F.ID][B.ID] + self.distanceMatrix[B.ID][G.ID] \
                                    - self.distanceMatrix[F.ID][G.ID] > rt2.capacity:
                                continue
                        else:
                            if rt2.cost + self.distanceMatrix[F.ID][B.ID] + self.distanceMatrix[B.ID][G.ID] \
                                    - self.distanceMatrix[F.ID][G.ID] > rt2.capacity:
                                continue

                        costAdded = self.distanceMatrix[A.ID][C.ID] + self.distanceMatrix[F.ID][B.ID] + \
                            self.distanceMatrix[B.ID][G.ID]
                        costRemoved = self.distanceMatrix[A.ID][B.ID] + self.distanceMatrix[B.ID][C.ID] + \
                            self.distanceMatrix[F.ID][G.ID]

                        originRtCostChange = self.distanceMatrix[A.ID][C.ID] - self.distanceMatrix[A.ID][B.ID] - \
                            self.distanceMatrix[B.ID][C.ID] - B.time
                        targetRtCostChange = self.distanceMatrix[F.ID][B.ID] + self.distanceMatrix[B.ID][G.ID] - \
                            self.distanceMatrix[F.ID][G.ID] + B.time

                        moveCost = costAdded - costRemoved

                        if (moveCost < rm.moveCost):
                            self.StoreBestRelocationMove(originRouteIndex, targetRouteIndex, originNodeIndex,
                                                         targetNodeIndex, moveCost, originRtCostChange,
                                                         targetRtCostChange, rm)

    def FindBestSwapMove(self, sm):
        for firstRouteIndex in range(0, len(self.sol.routes)):
            rt1: Route = self.sol.routes[firstRouteIndex]
            for secondRouteIndex in range(firstRouteIndex, len(self.sol.routes)):
                rt2: Route = self.sol.routes[secondRouteIndex]
                for firstNodeIndex in range(1, len(rt1.sequenceOfNodes) - 1):
                    startOfSecondNodeIndex = 1
                    if rt1 == rt2:
                        startOfSecondNodeIndex = firstNodeIndex + 1
                    for secondNodeIndex in range(startOfSecondNodeIndex, len(rt2.sequenceOfNodes) - 1):

                        a1 = rt1.sequenceOfNodes[firstNodeIndex - 1]
                        b1 = rt1.sequenceOfNodes[firstNodeIndex]
                        c1 = rt1.sequenceOfNodes[firstNodeIndex + 1]

                        a2 = rt2.sequenceOfNodes[secondNodeIndex - 1]
                        b2 = rt2.sequenceOfNodes[secondNodeIndex]
                        c2 = rt2.sequenceOfNodes[secondNodeIndex + 1]

                        moveCost = None
                        costChangeFirstRoute = None
                        costChangeSecondRoute = None

                        if rt1 == rt2:
                            if rt1.cost - (self.distanceMatrix[a1.ID][b1.ID] + self.distanceMatrix[b1.ID][b2.ID]
                                           + self.distanceMatrix[b2.ID][c2.ID]) + (self.distanceMatrix[a1.ID][b2.ID] + self.distanceMatrix[b2.ID][b1.ID] +
                                                                                   self.distanceMatrix[b1.ID][c2.ID]) > self.capacity:
                                continue
                            else:
                                if firstNodeIndex == secondNodeIndex - 1:
                                    costRemoved = self.distanceMatrix[a1.ID][b1.ID] + self.distanceMatrix[b1.ID][
                                        b2.ID] + self.distanceMatrix[b2.ID][c2.ID]
                                    costAdded = self.distanceMatrix[a1.ID][b2.ID] + self.distanceMatrix[b2.ID][b1.ID] + \
                                        self.distanceMatrix[b1.ID][c2.ID]
                                    moveCost = costAdded - costRemoved
                                else:

                                    costRemoved1 = self.distanceMatrix[a1.ID][b1.ID] + \
                                        self.distanceMatrix[b1.ID][c1.ID]
                                    costAdded1 = self.distanceMatrix[a1.ID][b2.ID] + \
                                        self.distanceMatrix[b2.ID][c1.ID]
                                    costRemoved2 = self.distanceMatrix[a2.ID][b2.ID] + \
                                        self.distanceMatrix[b2.ID][c2.ID]
                                    costAdded2 = self.distanceMatrix[a2.ID][b1.ID] + \
                                        self.distanceMatrix[b1.ID][c2.ID]
                                    moveCost = costAdded1 + costAdded2 - \
                                        (costRemoved1 + costRemoved2)
                        else:
                            if rt1.cost - b1.time + b2.time - (self.distanceMatrix[a1.ID][b1.ID] + self.distanceMatrix[b1.ID][c1.ID])\
                                    + (self.distanceMatrix[a1.ID][b2.ID] + self.distanceMatrix[b2.ID][c1.ID]) > self.capacity:
                                continue
                            if rt2.cost - b2.time + b1.time - (self.distanceMatrix[a2.ID][b2.ID] + self.distanceMatrix[b2.ID][c2.ID])\
                                    + (self.distanceMatrix[a2.ID][b1.ID] + self.distanceMatrix[b1.ID][c2.ID]) > self.capacity:
                                continue

                            costRemoved1 = self.distanceMatrix[a1.ID][b1.ID] + \
                                self.distanceMatrix[b1.ID][c1.ID] - b1.time
                            costAdded1 = self.distanceMatrix[a1.ID][b2.ID] + \
                                self.distanceMatrix[b2.ID][c1.ID] + b2.time
                            costRemoved2 = self.distanceMatrix[a2.ID][b2.ID] + \
                                self.distanceMatrix[b2.ID][c2.ID] - b2.time
                            costAdded2 = self.distanceMatrix[a2.ID][b1.ID] + \
                                self.distanceMatrix[b1.ID][c2.ID] + b1.time

                            costChangeFirstRoute = costAdded1 - costRemoved1
                            costChangeSecondRoute = costAdded2 - costRemoved2

                            moveCost = costAdded1 + costAdded2 - \
                                (costRemoved1 + costRemoved2)

                        if moveCost < sm.moveCost:
                            self.StoreBestSwapMove(firstRouteIndex, secondRouteIndex, firstNodeIndex,
                                                   secondNodeIndex,
                                                   moveCost, costChangeFirstRoute, costChangeSecondRoute, sm)

    def FindBestInsertionMove(self, ins):
        moveCost = 0
        costAdded = 0
        costRemoved = 0
        targetRtCostChange = 0
        temp_cust = 0
        profit = 0
        best_cust_ratio = -1
        for i in range(1, len(self.customers)):
            candidateCust: Node = self.customers[i]
            if candidateCust.isRouted is False:
                for targetRoutePosition in range(0, len(self.sol.routes)):
                    targetRouteIndex: targetRoutePosition = self.sol.routes[targetRoutePosition]
                    for targetNodeIndex in range(1, len(targetRouteIndex.sequenceOfNodes)-1):
                        A = targetRouteIndex.sequenceOfNodes[targetNodeIndex - 1]
                        B = targetRouteIndex.sequenceOfNodes[targetNodeIndex]
                        if targetRouteIndex.cost + self.distanceMatrix[A.ID][candidateCust.ID] + self.distanceMatrix[candidateCust.ID][B.ID]\
                                - self.distanceMatrix[A.ID][B.ID] + candidateCust.time > targetRouteIndex.capacity:
                            continue
                        if self.matrix_profit[A.ID][candidateCust.ID] + self.matrix_profit[candidateCust.ID][B.ID] > best_cust_ratio:
                            best_cust_ratio = self.matrix_profit[A.ID][candidateCust.ID] + \
                                self.matrix_profit[candidateCust.ID][B.ID]
                            costAdded = self.distanceMatrix[A.ID][candidateCust.ID] + \
                                self.distanceMatrix[candidateCust.ID][B.ID] + \
                                candidateCust.time
                            costRemoved = self.distanceMatrix[A.ID][B.ID]
                            targetRtCostChange = costAdded - costRemoved

                            moveCost = costAdded - costRemoved
                            profit = candidateCust.profit
                            temp_cust = candidateCust

                            if ((moveCost < ins.moveCost) | (profit > 0)):
                                self.StoreBestInsertionMove(targetRouteIndex, targetNodeIndex, moveCost, targetRoutePosition,
                                                            targetRtCostChange, profit, temp_cust, ins)

    def FindBestProfitableSwapMove(self, psm):
        profitChange = 0
        temp_cust = None
        moveCost = None
        costChangeFirstRoute = None
        BestRatio = -1
        for i in range(1, len(self.customers)):
            candidateCust: Node = self.customers[i]
            if candidateCust.isRouted is False:
                for firstRouteIndex in range(0, len(self.sol.routes)):
                    rt1: Route = self.sol.routes[firstRouteIndex]
                    for firstNodeIndex in range(1, len(rt1.sequenceOfNodes) - 1):
                        A = rt1.sequenceOfNodes[firstNodeIndex - 1]
                        B = rt1.sequenceOfNodes[firstNodeIndex]
                        C = rt1.sequenceOfNodes[firstNodeIndex + 1]

                        if rt1.cost - (self.distanceMatrix[A.ID][B.ID] + self.distanceMatrix[B.ID][C.ID] + B.time)\
                                + (self.distanceMatrix[A.ID][candidateCust.ID] + self.distanceMatrix[candidateCust.ID][C.ID] + candidateCust.time) > rt1.capacity:
                            continue
                        else:
                            if self.matrix_profit[A.ID][candidateCust.ID] + self.matrix_profit[candidateCust.ID][C.ID]\
                                    > self.matrix_profit[A.ID][B.ID] + self.matrix_profit[B.ID][C.ID]:
                                if self.matrix_profit[A.ID][candidateCust.ID] + self.matrix_profit[candidateCust.ID][C.ID] > BestRatio:
                                    BestRatio = self.matrix_profit[A.ID][candidateCust.ID] + \
                                        self.matrix_profit[candidateCust.ID][C.ID]
                                    temp_profit = candidateCust.profit
                                    costRemoved = self.distanceMatrix[A.ID][B.ID] + \
                                        self.distanceMatrix[B.ID][C.ID] + B.time
                                    costAdded = self.distanceMatrix[A.ID][candidateCust.ID] + \
                                        self.distanceMatrix[candidateCust.ID][C.ID] + \
                                        candidateCust.time
                                    costChangeFirstRoute = costAdded - costRemoved
                                    moveCost = costAdded - costRemoved
                                    profitChange = temp_profit - B.profit
                                    temp_cust = candidateCust

                                    if profitChange >= 0:
                                        self.StoreBestProfitableSwapMove(firstRouteIndex, firstNodeIndex,
                                                                         moveCost, costChangeFirstRoute, profitChange, temp_cust, psm)

    def ApplyRelocationMove(self, rm: RelocationMove):

        oldCost = self.CalculateTotalCost(self.sol)

        originRt = self.sol.routes[rm.originRoutePosition]
        targetRt = self.sol.routes[rm.targetRoutePosition]

        B = originRt.sequenceOfNodes[rm.originNodePosition]

        if originRt == targetRt:
            del originRt.sequenceOfNodes[rm.originNodePosition]
            if (rm.originNodePosition < rm.targetNodePosition):
                targetRt.sequenceOfNodes.insert(rm.targetNodePosition, B)
            else:
                targetRt.sequenceOfNodes.insert(rm.targetNodePosition + 1, B)

            originRt.cost += rm.moveCost
        else:
            del originRt.sequenceOfNodes[rm.originNodePosition]
            targetRt.sequenceOfNodes.insert(rm.targetNodePosition + 1, B)
            originRt.cost += rm.costChangeOriginRt
            targetRt.cost += rm.costChangeTargetRt

        self.sol.cost += rm.moveCost

    def ApplySwapMove(self, sm):
        oldCost = self.CalculateTotalCost(self.sol)
        rt1 = self.sol.routes[sm.positionOfFirstRoute]
        rt2 = self.sol.routes[sm.positionOfSecondRoute]
        b1 = rt1.sequenceOfNodes[sm.positionOfFirstNode]
        b2 = rt2.sequenceOfNodes[sm.positionOfSecondNode]
        rt1.sequenceOfNodes[sm.positionOfFirstNode] = b2
        rt2.sequenceOfNodes[sm.positionOfSecondNode] = b1

        if (rt1 == rt2):
            rt1.cost += sm.moveCost
        else:
            rt1.cost += sm.costChangeFirstRt
            rt2.cost += sm.costChangeSecondRt

        self.sol.cost += sm.moveCost

        newCost = self.CalculateTotalCost(self.sol)

    def ApplyInsertionMove(self, ins):
        oldCost = self.CalculateTotalCost(self.sol)
        targetRt = self.sol.routes[ins.targetRoutePosition]

        temp_cust = ins.temp_cust
        temp_cust.isRouted = True
        targetRt.sequenceOfNodes.insert(ins.targetNodeIndex, temp_cust)

        targetRt.cost += ins.moveCost
        targetRt.profit += ins.profit

        self.sol.cost += ins.moveCost
        self.sol.profit += ins.profit

        newCost = self.CalculateTotalCost(self.sol)
        newProfit = self.CalculateTotalProfit(self.sol)
        if abs((newCost - oldCost) - ins.moveCost) > 0.0001:
            print('Cost Issue')

    def ApplyProfitableSwapMove(self, psm):
        oldCost = self.CalculateTotalCost(self.sol)
        rt1 = self.sol.routes[psm.firstRouteIndex]
        b1 = rt1.sequenceOfNodes[psm.firstNodeIndex]
        b2 = psm.temp_cust
        psm.temp_cust.isRouted = True
        b1.isRouted = False
        rt1.sequenceOfNodes[psm.firstNodeIndex] = b2

        rt1.cost += psm.moveCost
        rt1.profit += psm.profitChange

        self.sol.cost += psm.moveCost
        self.sol.profit += psm.profitChange

        newCost = self.CalculateTotalCost(self.sol)
        newProfit = self.CalculateTotalProfit(self.sol)

    def ReportSolution(self, sol):
        for i in range(0, len(self.sol.routes)):
            rt = sol.routes[i]
            seq_of_cust = []
            for j in range(0, len(rt.sequenceOfNodes)):
                seq_of_cust.append(self.sol.routes[i].sequenceOfNodes[j].ID)
            print('Route ', i + 1, ': Profit is', self.sol.routes[i].profit, ' Cost is', self.sol.routes[i].cost,
                  'Customers:', seq_of_cust)
        print('Solution Cost is:', self.sol.cost,
              'Solution Profit is:', self.sol.profit)

    def StoreBestSwapMove(self, firstRouteIndex, secondRouteIndex, firstNodeIndex, secondNodeIndex, moveCost,
                          costChangeFirstRoute, costChangeSecondRoute, sm):
        sm.positionOfFirstRoute = firstRouteIndex
        sm.positionOfSecondRoute = secondRouteIndex
        sm.positionOfFirstNode = firstNodeIndex
        sm.positionOfSecondNode = secondNodeIndex
        sm.costChangeFirstRt = costChangeFirstRoute
        sm.costChangeSecondRt = costChangeSecondRoute
        sm.moveCost = moveCost

    def StoreBestRelocationMove(self, originRouteIndex, targetRouteIndex, originNodeIndex, targetNodeIndex, moveCost,
                                originRtCostChange, targetRtCostChange,  rm: RelocationMove):
        rm.originRoutePosition = originRouteIndex
        rm.originNodePosition = originNodeIndex
        rm.targetRoutePosition = targetRouteIndex
        rm.targetNodePosition = targetNodeIndex
        rm.costChangeOriginRt = originRtCostChange
        rm.costChangeTargetRt = targetRtCostChange
        rm.moveCost = moveCost

    def StoreBestInsertionMove(self, targetRouteIndex, targetNodeIndex, moveCost, targetRoutePosition,
                               targetRtCostChange, profit, temp_cust, ins: InsertionMove):
        ins.targetRouteIndex = targetRouteIndex
        ins.targetNodeIndex = targetNodeIndex
        ins.moveCost = moveCost
        ins.targetRtCostChange = targetRtCostChange
        ins.profit = profit
        ins.temp_cust = temp_cust
        ins.targetRoutePosition = targetRoutePosition

    def StoreBestProfitableSwapMove(self, firstRouteIndex, firstNodeIndex,
                                    moveCost, costChangeFirstRoute, profitChange, temp_cust, psm: ProfitableSwapMove):
        psm.firstRouteIndex = firstRouteIndex
        psm.firstNodeIndex = firstNodeIndex
        psm.moveCost = moveCost
        psm.costChangeFirstRoute = costChangeFirstRoute
        psm.profitChange = profitChange
        psm.temp_cust = temp_cust

    def TestSolution(self):
        totalSolCost = 0
        for r in range(0, len(self.sol.routes)):
            rt: Route = self.sol.routes[r]
            rtCost = 0
            for n in range(0, len(rt.sequenceOfNodes) - 1):
                A = rt.sequenceOfNodes[n]
                B = rt.sequenceOfNodes[n + 1]
                rtCost += self.distanceMatrix[A.ID][B.ID] + A.time

            totalSolCost += rt.cost

        if abs(totalSolCost - self.sol.cost) > 0.0001:
            print('Solution Cost problem')

    def InitializeOperators(self, rm, sm, ins, psm):
        rm.Initialize()
        sm.Initialize()
        ins.Initialize()
        psm.Initialize()

    # ----------------------------------  VND ALGORITHM ------------------------------------------
    '''Variable Neighborhood Descent is an algorithmic framework for solving combinatorial optimization
    problems. The main idea is the systematic change of the move types (e.g., Relocation, Swap, Insertion,
    Profitable Swap) during the search in the solution space. VND in particular searches the solution space in
    a deterministic way.'''

    def VND(self):
        self.bestSolution = self.cloneSolution(self.sol)
        VNDIterator = 0
        kmax = 3
        rm = RelocationMove()
        sm = SwapMove()
        ins = InsertionMove()
        psm = ProfitableSwapMove()
        k = 0
       #draw = True

        while k <= kmax:
            self.InitializeOperators(rm, sm, ins, psm)
            if k == 0:
                self.FindBestSwapMove(sm)
                if sm.positionOfFirstRoute is not None and sm.moveCost < 0:
                    self.ApplySwapMove(sm)
                    VNDIterator = VNDIterator + 1
                    print('Swap Move  -  ', 'Iteration number:', VNDIterator,
                          'Solution profit:', self.sol.profit, 'Solution Cost:', self.sol.cost)
                    k = 0
                else:
                    k += 1
            elif k == 1:
                self.FindBestRelocationMove(rm)
                if rm.originRoutePosition is not None and rm.moveCost < 0:
                    self.ApplyRelocationMove(rm)
                    VNDIterator = VNDIterator + 1
                    print('Relocation Move  -  ', 'Iteration number:', VNDIterator,
                          'Solution profit:', self.sol.profit, 'Solution Cost:', self.sol.cost)
                    k = 0
                else:
                    k += 1
            elif k == 2:
                self.FindBestInsertionMove(ins)
                if ins.targetRoutePosition is not None and ((ins.moveCost < 0) | (ins.profit > 0)):
                    self.ApplyInsertionMove(ins)
                    VNDIterator = VNDIterator + 1
                    print('Insertion Move  -  ', 'Iteration number:', VNDIterator,
                          'Solution profit:', self.sol.profit, 'Solution Cost:', self.sol.cost)
                    k = 0
                else:
                    k += 1
            elif k == 3:
                self.FindBestProfitableSwapMove(psm)
                if psm.firstRouteIndex is not None and ((psm.profitChange >= 0)):
                    self.ApplyProfitableSwapMove(psm)
                    VNDIterator = VNDIterator + 1
                    print('Profitable Swap Move  -  ', 'Iteration number:', VNDIterator,
                          'Solution profit:', self.sol.profit, 'Solution Cost:', self.sol.cost)
                    k = 0
                else:
                    k += 1

            if ((self.sol.cost < self.bestSolution.cost) | (self.sol.profit > self.bestSolution.profit)):
                self.bestSolution = self.cloneSolution(self.sol)
