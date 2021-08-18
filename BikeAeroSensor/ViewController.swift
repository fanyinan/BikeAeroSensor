//
//  ViewController.swift
//  BikeAeroSensor
//
//  Created by 范祎楠 on 2021/8/16.
//

import UIKit

class ViewController: UIViewController {
    
    @IBAction func onUDPTest(_ sender: UIButton) {
        self.navigationController?.pushViewController(UDPTestViewController(), animated: true)
    }
    
    @IBAction func onMainTest(_ sender: UIButton) {
        self.navigationController?.pushViewController(MainViewController(), animated: true)
    }
}
