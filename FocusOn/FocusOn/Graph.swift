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
    
    func loadGraph(_ view: BarChartView) {
        configureLegend(in: view)
        setDataEntries(in: view)
        configureGraph()
        assignData(to: view)
    }
    
    // Setup legend for bar graph
    func configureLegend(in barView: BarChartView) {
        let legend = barView.legend
        legend.horizontalAlignment = .right
        legend.verticalAlignment = .top
        legend.orientation = .vertical
    }
    
    // Set data entries
    func setDataEntries(in barView: BarChartView) {
        let entry = BarChartDataEntry(x: Double(12), y: Double(12))
        dataEntries.append(entry)
    }
    
    // Configure Graph
    func configureGraph() {
        set = BarChartDataSet(entries: dataEntries, label: "configureGraph")
        // this might animate the bars
        set.drawIconsEnabled = false
        set.colors = ChartColorTemplates.material()
        set.stackLabels = ["Label 1", "Label 2"]
    }
    
    // Assign data to graph
    func assignData(to view: BarChartView) {
        let data = BarChartData(dataSet: set)
        data.setValueFont(.systemFont(ofSize: 17, weight: .medium))
        data.barWidth = 8
        
        view.data = data
        view.animate(xAxisDuration: 2, easingOption: .easeOutBack)
    }
    
}
