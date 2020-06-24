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
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        measure {
            // Put the code you want to measure the time of here.
        }
    }

}
