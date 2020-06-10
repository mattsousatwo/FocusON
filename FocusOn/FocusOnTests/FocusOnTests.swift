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
        let goalUID = goals.goalContainer.first?.goal_UID!
        print("Test 109 + pastGoalsContainerCount = \(goals.pastGoalContainer.count)")
        for goal in goals.pastGoalContainer {
            if goal.goal_UID! == goalUID {
                XCTAssert(false)
            }
        }
        XCTAssert(true)
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        measure {
            // Put the code you want to measure the time of here.
        }
    }

}
