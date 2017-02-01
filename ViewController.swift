//
//  ViewController.swift
//  Calculator
//
//  Created by Sam Sneider on 1/19/17.
//  Copyright © 2017 Sam Sneider. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    
    @IBOutlet private weak var display: UILabel!
    
    @IBOutlet weak var tracker: UILabel!
    
    private var userIsInTheMiddleOfTyping = false
    
    
    
    @IBAction private func touchDigit(_ sender: UIButton) {
        
        let digit = sender.currentTitle!
        
        
        if  userIsInTheMiddleOfTyping {
        let textCurrentlyInDisplay = display.text!
            if (digit == "."){
                if (display.text!.range(of:".") == nil){
                    display.text = textCurrentlyInDisplay + digit
                }
                }
            else{
            display.text = textCurrentlyInDisplay + digit
            }}
        else {
            if (digit == "."){
                display.text = "0."
            }else{
            display.text = digit
            }}
        userIsInTheMiddleOfTyping = true
    }
    
    private var displayValue: Double{
        get{
            return Double(display.text!)!
        }
        set{
            display.text = String(newValue)
            tracker.text = brain.description + (brain.isPartialResult ? " ..." : " =")
        
        }
    }
    
   
    
    private var brain = CalculatorBrain()
    
    @IBAction private func performOperation(_ sender: UIButton) {
        if userIsInTheMiddleOfTyping{
            brain.setOperand(operand: displayValue)
            userIsInTheMiddleOfTyping = false
        }
        if let mathmaticalSymbol = sender.currentTitle {
            brain.performOperation(symbol: mathmaticalSymbol)
    }
        displayValue = brain.result
    }
    @IBAction func clear(_ sender: UIButton) {
        brain = CalculatorBrain()
        display.text = "0"
        tracker.text = " "
    }
    

}

