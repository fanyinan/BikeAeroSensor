//
//  TestViewController.swift
//  BikeAeroSensor
//
//  Created by 范祎楠 on 2021/8/18.
//

import UIKit

class TestViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func onUDPTest(_ sender: UIButton) {
        self.navigationController?.pushViewController(UDPTestViewController(), animated: true)
    }
    
    @IBAction func onMainTest(_ sender: UIButton) {
        self.navigationController?.pushViewController(MainViewController(), animated: true)
    }

}
