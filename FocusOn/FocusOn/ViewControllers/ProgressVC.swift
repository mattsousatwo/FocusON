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
            // Reload graph depending on graphDispalyMode
            print("ONE")
            graphs.reload(graph: barChart, to: .weekly, update: averageLabel)
        case 1:
            print("TWO")
            graphs.reload(graph: barChart, to: .monthly, update: averageLabel)
        case 2:
            print("THREE")
            graphs.reload(graph: barChart, to: .all, update: averageLabel)
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

}
