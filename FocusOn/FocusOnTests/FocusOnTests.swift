//
//  FocusOnTests.swift
//  FocusOnTests
//
//  Created by Matthew Sousa on 6/4/20.
//  Copyright © 2020 Matthew Sousa. All rights reserved.
//

import XCTest

@testable import FocusOn

class FocusOnTests: XCTestCase {

    override class func setUp() {
        super.setUp()

    }
    
    override func tearDown() {

    }

    // Checking if there are any doubles of the current goal in past goal container
    func testForCurrentGoalDoubles() {
        let goals = GoalDataController()
        goals.getGoals()
        let goalUID = goals.goalContainer.first?.goal_UID!
        print("Test 109 + pastGoalsContainerCount = \(goals.pastGoalContainer.count)")
        for goal in goals.pastGoalContainer {
            if goal.goal_UID! == goalUID {
                XCTAssert(false)
            }
        }
        var counter = 0
        for goal in goals.goalContainer {
            if goal.goal_UID! == goalUID {
                counter += 1
            }
        }
        if counter >= 2 {
            XCTAssert(false)
        }
        XCTAssert(true)
    }
    
    // Check for any missing goals
    func testAllGoalsAccountedFor() {
//        let goalDC = GoalDataController()
        
//        let taskDC = TaskDataController()
//        var tasks: [TaskData] = []
//
//
//        goalDC.fetchAllGoals()
//        tasks = taskDC.fetchAllTasks()
    }
    
    // Checking to see if multiple fetch calls will cause doubles to appear in goals array
    func testForDoublesWhenFetching() {
        let goalDC = GoalDataController()
        print("test 201: inital count = \(goalDC.goalContainer.count + goalDC.pastGoalContainer.count)")
        goalDC.fetchGoals()
        let firstCount = goalDC.goalContainer.count + goalDC.pastGoalContainer.count
        print("test 201: firstCall count = \(goalDC.goalContainer.count + goalDC.pastGoalContainer.count)")
        goalDC.fetchGoals()
        let secondCount = goalDC.goalContainer.count + goalDC.pastGoalContainer.count
        print("test 201: secondCallCount count = \(goalDC.goalContainer.count + goalDC.pastGoalContainer.count)")
        if secondCount == firstCount {
            print("test 201: outcome = \(secondCount) == \(firstCount)")
            XCTAssert(true)
        } else if secondCount != firstCount {
            print("test 201: outcome = \(secondCount) != \(firstCount)")
            XCTAssert(false)
        }
    }
    
    // test to see if fetchGoal(withUID: ) is working properly
    func testFetchForSpecificGoal() {
        let goalDC = GoalDataController()
        var counter = 0
        goalDC.fetchGoals()
        if goalDC.goalContainer.count != 0 {
            for goal in goalDC.goalContainer {
                let x = goalDC.fetchGoal(withUID: goal.goal_UID!)
                print("test 203: goal \(x.goal_UID!) has been fetched : CURRENT")
                counter += 1
            }
        }
        
        if goalDC.pastGoalContainer.count != 0 {
            for goal in goalDC.pastGoalContainer {
                let x = goalDC.fetchGoal(withUID: goal.goal_UID!)
                print("test 203: goal \(x.goal_UID!) has been fetched : PAST")
                counter += 1
            }
        }
        
        
        print("test 203: number of goals fetched: \(counter)")
        if counter > 0 {
            XCTAssert(true)
        } else {
            XCTAssert(false)
        }
        
            
    }

    // test to see if all goals are sorted by date
    func testIfGoalsAreSortedByDate() {
        let goalDC = GoalDataController()
        goalDC.getGoals()
        goalDC.sortPastGoalsByDate()
        for goal in goalDC.pastGoalContainer {
            print("sorting - \(goalDC.pastGoalContainer.firstIndex(of: goal)!) : \(goal.dateCreated!)")
        }
        
        guard let firstGoal = goalDC.pastGoalContainer.first else { return }
        guard let lastGoal = goalDC.pastGoalContainer.last else { return }
        
        if firstGoal.dateCreated! > lastGoal.dateCreated! {
            XCTAssert(true)
        } else {
            XCTAssert(false)
        }
        
    }
    
    
    // Test if find(goal) method is working
    func testIfFindGoalInSetWorks() {
        let goalDC = GoalDataController()
        goalDC.retrieveGoals()
        let firstUID = goalDC.goalContainer.first!.goal_UID!
        if goalDC.comparisonSet.find(goal: firstUID) != nil {
            XCTAssert(true)
        } else {
            XCTAssert(false)
        }
    }
    
    // Check to see if goals that are removed show in main view
    func testForRemovedGoalsBeingShown() {
        let goalDC = GoalDataController()
        goalDC.getGoals()
        
        var removedGoals: [GoalData] = []
        
        for goal in goalDC.goalContainer {
            print("testForRemovedGoals - goalContainer - \(goal.name!), isRemoved: \(goal.isRemoved)")
            if goal.isRemoved == true {
                removedGoals.append(goal)
            }
        }
        
        for goal in goalDC.pastGoalContainer {
            print("testForRemovedGoals - pastGoalContainer - \(goal.name!), isRemoved: \(goal.isRemoved)")
            if goal.isRemoved == true {
                removedGoals.append(goal)
            }
        }
        
        for goal in goalDC.removedGoals {
            print("testForRemovedGoals - removedGoals - \(goal.name!), isRemoved: \(goal.isRemoved)")
        }
        
        if removedGoals.count != 0 {
            print("testForRemovedGoals - removedGoals.count = \(removedGoals.count)")
            XCTAssert(false)
        } else {
            XCTAssert(true)
        }
        
    }
    
    // Check to see if remove(goal: ) works
    func testIfRemoveGoalsWorks() {
        let goalDC = GoalDataController()
        let h = HistoryVC()

//        goalDC.createTestGoals(int: 5, month: 1)
        goalDC.getGoals()
        
        
        var x: GoalData?
        // remove goal
        if goalDC.pastGoalContainer.count != 0 {
            x = goalDC.pastGoalContainer.last!
            print("testIfRemoveGoalsWorks:: INITAL - \(x!.goal_UID!), isRemoved: \(x!.isRemoved)")
            
            h.remove(goal: x!)
            print("testIfRemoveGoalsWorks:: removeGoal - \(x!.goal_UID!), isRemoved: \(x!.isRemoved)")
            // undo remove
            
           // h.undoDeleteGoal()
            print("testIfRemoveGoalsWorks:: undoDelete - \(x!.goal_UID!), isRemoved: \(x!.isRemoved)")
            
            
        }
        
        guard let goal = x else { return }
        let fetchedGoal = goalDC.fetchGoal(withUID: goal.goal_UID!)
        print("testIfRemoveGoalsWorks:: 2nd Fetch - \(fetchedGoal.goal_UID!), isRemoved: \(fetchedGoal.isRemoved)")
        
        
    }
    
    // Testing to see if properties associated with goal removal persist
    func testIfRemovePropertiesPersist() {
        let goalDC = GoalDataController()
        let fetchedGoal = goalDC.fetchGoal(withUID: "16HNQ")
        print("testIfRemoveGoalsWorks:: 2nd Fetch - \(fetchedGoal.goal_UID!), isRemoved: \(fetchedGoal.isRemoved)")
        
    }
       
    // test if we can get goals from last three months
    func testIfLastThreeMonthsGraphWorks() {
        let d = DataController()
        
        let january = d.createDate(month: 1, day: 1, year: 2020)
        let feburary = d.createDate(month: 2, day: 1, year: 2020)
        let march = d.createDate(month: 3, day: 1, year: 2020)
        let april = d.createDate(month: 4, day: 1, year: 2020)
        let may = d.createDate(month: 5, day: 1, year: 2020)
        let june = d.createDate(month: 6, day: 1, year: 2020)
        let july = d.createDate(month: 7, day: 1, year: 2020)
        
        let goals = [january, feburary, march, april, may, june, july]
        var threeLastMonths: [Date] = []
        var notWithinLastThreeMonths: [Date] = []
        
        for goal in goals {
            if d.isDateFromLastThreeMonths(goal) == true {
                threeLastMonths.append(goal)
            } else {
                notWithinLastThreeMonths.append(goal)
            }
        }
        
        if threeLastMonths.count == 3 {
            print("lastThreeMonths - threeLastMonths.count = \(threeLastMonths.count)")
            print("lastThreeMonths - notWithinLastThreeMonths.count = \(notWithinLastThreeMonths.count)")
            XCTAssert(true)
        } else {
            print("lastThreeMonths - threeLastMonths.count = \(threeLastMonths.count)")
            print("lastThreeMonths - notWithinLastThreeMonths.count = \(notWithinLastThreeMonths.count)")
            XCTAssert(false)
        }
        
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        measure {
            // Put the code you want to measure the time of here.
        }
    }

}
