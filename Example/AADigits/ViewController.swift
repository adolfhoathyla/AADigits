//
//  ViewController.swift
//  AADigits
//
//  Created by adolfhoathyla on 08/02/2020.
//  Copyright (c) 2020 adolfhoathyla. All rights reserved.
//


import UIKit
import AADigits

class ViewController: UIViewController {

    @IBOutlet var fields: [UITextField]!
    
    var digits: AADigitsProtocol!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        prepareFields()
        
        digits.full = { [weak self] (text) in
            guard let weakself = self else { return }
            weakself.digits.fix()
            print("FULL: \(text)")
        }
        
        digits.incomplete = { [weak self] in
            guard let weakself = self else { return }
            weakself.digits.err()
            print("INCOMPLETE")
        }
    }
    
    private func prepareFields() {
        let mainColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
        let errorColor = #colorLiteral(red: 0.7450980544, green: 0.1568627506, blue: 0.07450980693, alpha: 1)
        digits = AADigits(fields: fields,
                                       isSecureTextEntry: false,
                                       isSMSCode: true,
                                       mainColor: mainColor,
                                       errorColor: errorColor,
                                       borderWidth: 2.0,
                                       borderRadius: 5.0,
                                       keyboardType: .numberPad)
    }

}
