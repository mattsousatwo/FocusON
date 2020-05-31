//
//  Graph.swift
//  FocusOn
//
//  Created by Matthew Sousa on 5/31/20.
//  Copyright © 2020 Matthew Sousa. All rights reserved.
//

import Foundation
import Charts

class Graph {
    
    let goalDC = GoalDataController()
    let taskDC = TaskDataController()
    var dataEntries: [BarChartDataEntry] = []
    var set: BarChartDataSet = BarChartDataSet()
    var goals: [GoalData] = []
    var tasks: [TaskData] = []
    let barWidth = Double(6)
    
    // assign attributes to graph
    func loadGraph(_ view: BarChartView) {
        fetchDataEntries()
        configureLegend(in: view)

        setGoalTaskEntries()
        configureGraph()
        assignData(to: view)
    }
    
    // Setup legend for bar graph - TEST
    func configureLegend(in barView: BarChartView) {
        let legend = barView.legend
        legend.horizontalAlignment = .right
        legend.verticalAlignment = .top
        legend.orientation = .vertical
    }
    
    // load goals and tasks
    func fetchDataEntries() {
        // Load Goals
        goals = goalDC.fetchAllGoals()
        tasks = taskDC.fetchAllTasks()
    }
    
    // Create data entries using goals/tasks
    func setGoalTaskEntries() {
        // Iterate through goals
        for goal in goals {
            // set count variable
            var totalCount = Double(0)
            // if goal is checked
            if goal.isChecked == true {
                // add onto variable
                totalCount += 1
            }
            // get count to checked tasks
            let checkedTaskCount = countOfCheckedTasksForGoal(with: goal.goal_UID!)
            // add checked task count onto total count
            totalCount += checkedTaskCount
            // get location of goal
            let goalXAxis = Double(goals.lastIndex(of: goal)!)
            // create data set using figures
            let entry = BarChartDataEntry(x: goalXAxis, y: totalCount)
            // add onto array
            dataEntries.append(entry)
            
        }

    }
        
    // Return count of checked tasks with matching goalUID
    func countOfCheckedTasksForGoal(with goalUID: String) -> Double {
        var matchingTaskCount: Double = 0
        for task in tasks {
            if task.goal_UID == goalUID && task.isChecked == true {
                matchingTaskCount += 1
            }
        }
        return matchingTaskCount
    }
    
    // Configure Graph - TEST
    func configureGraph() {
        set = BarChartDataSet(entries: dataEntries, label: "configureGraph")
        // this might animate the bars
        set.drawIconsEnabled = false
        set.colors = ChartColorTemplates.material()
        set.stackLabels = ["Label 1", "Label 2"]
    }
    
    // Assign data to graph - TEST
    func assignData(to view: BarChartView) {
        let data = BarChartData(dataSet: set)
        data.setValueFont(.systemFont(ofSize: 12, weight: .light))
        data.barWidth = 1
        // add data to graph
        view.data = data
        view.animate(xAxisDuration: 2, easingOption: .easeOutBack)
    }
    
}
