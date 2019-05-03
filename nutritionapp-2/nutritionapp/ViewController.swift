//
//  ViewController.swift
//  nutritionapp
//
//  Created by Yun, Yeji on 4/22/19.
//  Copyright © 2019 Yun, Yeji. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var waterLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()

        self.waterLabel.text = "No water drunk today!"

        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

