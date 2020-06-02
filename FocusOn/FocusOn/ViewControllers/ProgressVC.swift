//
//  ProgressVC.swift
//  FocusOn
//
//  Created by Matthew Sousa on 11/12/19.
//  Copyright © 2019 Matthew Sousa. All rights reserved.
//

import UIKit
import Charts

class ProgressVC: UIViewController {
    
    let graphs = Graph()

    @IBOutlet weak var timeSegControl: UISegmentedControl!
    
    @IBOutlet var completedTaskAverageLabel: UIView!

    @IBOutlet weak var averageLabel: UILabel!
    
    @IBOutlet weak var barChart: BarChartView!
    
    @IBAction func timeSegControlWasChanged(_ sender: Any) {
        switch timeSegControl.selectedSegmentIndex {
        case 0:
            
            reload(graph: barChart, to: .weekly, update: averageLabel)
//            graphs.displayMode = .weekly
//            print(graphs.displayMode.rawValue)
//            graphs.loadGraph(barChart)
//            averageLabel.text = "\(graphs.average)"
        case 1:
            reload(graph: barChart, to: .monthly, update: averageLabel)
//            graphs.displayMode = .monthly
//            print(graphs.displayMode.rawValue)
//            graphs.loadGraph(barChart)
//            averageLabel.text = "\(graphs.average)"
        case 2:
            reload(graph: barChart, to: .all, update: averageLabel)
//            graphs.displayMode = .all
//            print(graphs.displayMode.rawValue)
//            graphs.loadGraph(barChart)
//            averageLabel.text = "\(graphs.average)"
        default:
            print("Out of index")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Progress"
        
        graphs.loadGraph(barChart)
        
        averageLabel.text = "\(graphs.average)"
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        graphs.loadGraph(barChart)
        
        averageLabel.text = "\(graphs.average)"
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    func reload(graph: BarChartView, to mode: GraphDisplayMode, update label: UILabel) {
        print(graphs.displayMode.rawValue)
        graphs.displayMode = mode
        graphs.loadGraph(graph)
        label.text = "\(graphs.average)"
    }

}
