//
//  Graph.swift
//  FocusOn
//
//  Created by Matthew Sousa on 5/31/20.
//  Copyright © 2020 Matthew Sousa. All rights reserved.
//

import Foundation
import Charts

class Graph  {
    
    // DataControllers
    let goalDC = GoalDataController()
    let taskDC = TaskDataController()
    var goals: [GoalData] = []
    var tasks: [TaskData] = []
    // data will be used to store create graph
    var data = BarChartData()
    var dateLabels: [String] = []
    var maxCheckedCount: Double = 0
    // Entries used to build data set for graph
    var checkedEntries: [BarChartDataEntry] = []
    var totalEntries: [BarChartDataEntry] = []
    // dataSets used to interperate entries
    var checkedCellCountSet: BarChartDataSet = BarChartDataSet()
    var totalCellCountSet: BarChartDataSet = BarChartDataSet()
    
    // assign attributes to graph
    func loadGraph(_ view: BarChartView) {
        // Load Goals and Tasks
        fetchDataEntries()
        // setup legend
        configureLegend(in: view)

        setGoalTaskEntries()
        configureGraph(view)
        assignData(to: view)
    }
    
    // Setup legend for bar graph - TEST
    func configureLegend(in barView: BarChartView) {
        let legend = barView.legend
        legend.horizontalAlignment = .left
        legend.verticalAlignment = .bottom
        legend.orientation = .horizontal
//        legend.formSize = 15
//        legend.formToTextSpace = 10
        legend.neededHeight = 30
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
            var totalCheckedCount = Double(0)
            // if goal is checked
            if goal.isChecked == true {
                // add onto variable
                totalCheckedCount += 1
            }
            // get count to checked tasks
            let checkedTaskCount = countOfCheckedTasksForGoal(with: goal.goal_UID!)
            // get number of total tasks
            let goalsTaskCount = numberOfTasksFor(goal: goal.goal_UID!)
            
            // add checked task count onto total count
            totalCheckedCount += checkedTaskCount
            // Set maxCheckedCount to configure x-axis
            if totalCheckedCount > maxCheckedCount {
                maxCheckedCount = totalCheckedCount
            }
            // get location of goal
            let goalXAxis = Double(goals.lastIndex(of: goal)!)
            // create data set using figures
            let checkedEntry = BarChartDataEntry(x: goalXAxis, y: totalCheckedCount)
            let totalEntry = BarChartDataEntry(x: goalXAxis, y: goalsTaskCount + 1)
            // add onto array
            checkedEntries.append(checkedEntry)
            totalEntries.append(totalEntry)
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
    
    // Return number of tasks for goal
    func numberOfTasksFor(goal: String) -> Double {
        var array: [TaskData] = []
        for task in tasks {
            if task.goal_UID == goal {
                array.append(task)
            }
        }
        return Double(array.count)
    }
    
    // Configure Graph
    func configureGraph(_ view: BarChartView) {
        // Assign Sets
        checkedCellCountSet = BarChartDataSet(entries: checkedEntries, label: "Checked Tasks")
        totalCellCountSet = BarChartDataSet(entries: totalEntries, label: "Toatal Tasks")
        
        // Assign bar width
        data.barWidth = 0.8
        // Get Dates for Xaxis
        for goal in goals {
            dateLabels.append(goalDC.formatDate(from: goal.dateCreated!))
        }
        // Set Vertical axies
        // assign Dates as xAxis labels
        view.xAxis.valueFormatter  = IndexAxisValueFormatter(values: dateLabels)
        view.xAxis.granularityEnabled = true
        view.xAxis.granularity = 1
        view.xAxis.labelPosition = .bothSided
        
        // Set left axis
        view.leftAxis.axisMaximum = maxCheckedCount + 4
        view.leftAxis.granularityEnabled = true
        view.leftAxis.granularity = 1

        // Hide right axis labels
        view.rightAxis.enabled = true
        view.rightAxis.valueFormatter = IndexAxisValueFormatter(values: [""])
        
        // Set colors for sets
        checkedCellCountSet.colors = [NSUIColor(red: 62/255.0, green: 105/255.0, blue: 144/255.0, alpha: 1.0)]
        totalCellCountSet.colors = [NSUIColor(red: 56/255.0, green: 29/255.0, blue: 42/255.0, alpha: 1.0),]
        // Set grid line colors
        view.xAxis.gridColor = UIColor.gray
        view.leftAxis.gridColor = UIColor.gray
        view.rightAxis.gridColor = UIColor.clear
        
    }
    
    // Assign data to graph
    func assignData(to view: BarChartView) {
        // Configure data from both sets
        data.dataSets = [totalCellCountSet, checkedCellCountSet]
        data.setValueFont(.systemFont(ofSize: 12, weight: .light))

        // add data to graph
        view.data = data
        view.noDataText = "Need more data to display goals."
        view.animate(xAxisDuration: 2, easingOption: .easeOutBack)
    }
    
}
