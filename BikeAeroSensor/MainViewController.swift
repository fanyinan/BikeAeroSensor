//
//  MainViewController.swift
//  BikeAeroSensor
//
//  Created by yinan17 on 2021/8/18.
//

import UIKit

class MainViewController: UIViewController {

    private let chartView = ChartView()
    private let chartContainerView = UIView()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white
        view.addSubview(chartContainerView)
        chartContainerView.backgroundColor = #colorLiteral(red: 0.03921568627, green: 0.4039215686, blue: 0.7019607843, alpha: 1)
        chartContainerView.addSubview(chartView)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        chartContainerView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 400)
        chartView.frame = CGRect(x: 12, y: view.safeAreaInsets.top + 12, width: view.frame.width - 24, height: chartContainerView.frame.height - view.safeAreaInsets.top - 12)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        chartView.isPause = false
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
