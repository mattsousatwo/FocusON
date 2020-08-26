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
    
    // Checking to see if multiple fetch calls will cause doubles to appear in goals array
    func testForDoublesWhenFetching() {
        let goalDC = GoalDataController()
        goalDC.getGoals()
        let firstCount = goalDC.goalContainer.count + goalDC.pastGoalContainer.count
        for goal in goalDC.goalContainer {
            if goal.hasChanges == true {
                goalDC.getGoals()
            }
        }
        let secondCount = goalDC.goalContainer.count + goalDC.pastGoalContainer.count
        if secondCount == firstCount {
            XCTAssert(true)
        } else if secondCount != firstCount {
            XCTAssert(false)
        }
    }
    
    // test to see if fetchGoal(withUID: ) is working properly
    func testFetchForSpecificGoal() {
        let goalDC = GoalDataController()
        var counter = 0
        goalDC.getGoals()
        if goalDC.goalContainer.count != 0 {
            for _ in goalDC.goalContainer {
                counter += 1
            }
        }
        
        if goalDC.pastGoalContainer.count != 0 {
            for _ in goalDC.pastGoalContainer {
                counter += 1
            }
        }
        
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
        
        guard let firstGoal = goalDC.pastGoalContainer.first else { return }
        guard let lastGoal = goalDC.pastGoalContainer.last else { return }
        
        if firstGoal.dateCreated! > lastGoal.dateCreated! {
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
            if goal.isRemoved == true {
                removedGoals.append(goal)
            }
        }
        
        for goal in goalDC.pastGoalContainer {
            if goal.isRemoved == true {
                removedGoals.append(goal)
            }
        }

        if removedGoals.count != 0 {
            XCTAssert(false)
        } else {
            XCTAssert(true)
        }
        
    }
    
    // Check to see if remove(goal: ) works
    func testIfRemoveGoalsWorks() {
        let goalDC = GoalDataController()
        let searchTag = "RemovalTest"
        let date = goalDC.createDate(month: 1, day: 1, year: 2020)
        goalDC.createNewGoal(title: "new goal", date: date, UID: searchTag)
        goalDC.getGoals()
        
        var x: GoalData?
        // remove goal
        if goalDC.pastGoalContainer.count != 0 {
            x = goalDC.pastGoalContainer.first(where: {
                $0.goal_UID == searchTag
            })
            
            
            goalDC.remove(goal: x!)
            // undo remove
            if x?.isRemoved == true {
                goalDC.deleteGoalsWith(UIDs: [searchTag])
                XCTAssert(true)
            } else {
                goalDC.deleteGoalsWith(UIDs: [searchTag])
                XCTAssert(false)
            }
            
            
            goalDC.undoDeleteGoal()
            
            
        }
        
        guard let goal = x else { return }
        let fetchedGoal = goalDC.fetchGoal(withUID: goal.goal_UID!)
        
        
    }
    
    // Testing to see if properties associated with goal removal persist
    func testIfRemovePropertiesPersist() {
        let goalDC = GoalDataController()
        
        let x = GoalData(context: goalDC.context)
        let tag = goalDC.genID()
        x.goal_UID = tag
        x.dateCreated = goalDC.createDate(month: 3, day: 2, year: 2020)
        x.isRemoved = true
        goalDC.saveContext()
        
        
        goalDC.getGoals()
        
        if goalDC.removedGoals.count != 0 {
            XCTAssert(true)
            goalDC.deleteGoalsWith(UIDs: [tag])
        } else {
            goalDC.deleteGoalsWith(UIDs: [tag])
            XCTAssert(false)
        }
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
            XCTAssert(true)
        } else {
            XCTAssert(false)
        }
        
    }
    
    // Test if universial save method works - 7/24/20
    func testIfSaveContextWorks() {
        let uid = "12345"
        let goalDC = GoalDataController()
        let date = goalDC.createDate(month: 2, day: 18, year: 2020)
        goalDC.createNewGoal(title: "my goal", date: date, UID: uid)
        
        goalDC.getGoals()
        if goalDC.pastGoalContainer.contains(where: { $0.goal_UID == uid }) == true {
            goalDC.deleteGoalsWith(UIDs: [uid])
            XCTAssert(true)
        } else {
            goalDC.deleteGoalsWith(UIDs: [uid])
            XCTAssert(false)
        }
    }
    
    
    
    // test if goals are sorted corr
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        measure {
            // Put the code you want to measure the time of here.
        }
    }

}
