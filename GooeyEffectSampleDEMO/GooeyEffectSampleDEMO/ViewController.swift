//
//  ViewController.swift
//  GooeyEffectSampleDEMO
//
//  Created by Anton Nechayuk on 17.07.18.
//  Copyright © 2018 Anton Nechayuk. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        let movementShow = GooeyMovementShower(frame: self.view.frame)
        view.addSubview(movementShow)
    }
}

