//
//  CalculatorBrain.swift
//  Calculator
//
//  Created by Sam Sneider on 1/19/17.
//  Copyright © 2017 Sam Sneider. All rights reserved.
//

import Foundation

class CalculatorBrain
{
    private var internalProgram = [AnyObject]()
    private var accumulator = 0.0
    func setOperand(operand: Double){
        accumulator = operand
        internalProgram.append(operand as AnyObject)
        descriptionAccumulator = String(format:"%g", operand)
    }
    
    private var currentPrecedence = Int.max
    
    
    var isPartialResult: Bool {
        get {
            return pending != nil
        }
    }
    
    var description: String {
        get {
            if pending == nil {
                return descriptionAccumulator
            } else {
                return pending!.descriptionFunction(pending!.descriptionOperand,
                                        pending!.descriptionOperand != descriptionAccumulator ? descriptionAccumulator : "")
            }
        }
    }
    private var descriptionAccumulator = "0" {
        didSet {
            if pending == nil {
                currentPrecedence = Int.max
            }
        }
    }
    
    private var operations: Dictionary<String,Operation> = [
        "π" : Operation.Constant(M_PI),
        "e" : Operation.Constant(M_E),
        "±" : Operation.UnaryOperation({-$0}, {"-(" + $0 + ")"}),
        "√" : Operation.UnaryOperation(sqrt, {"√(" + $0 + ")"}),
        "cos" : Operation.UnaryOperation(cos, {"cos(" + $0 + ")"}),
        "sin" : Operation.UnaryOperation(sin, {"sin(" + $0 + ")"}),
        "tan" : Operation.UnaryOperation(tan, {"tan(" + $0 + ")"}),
        "x²" : Operation.UnaryOperation({$0*$0}, {"(" + $0 + ")²"}),
        "×" : Operation.BinaryOperation({$0 * $1}, { $0 + " × " + $1 },1),
        "÷" : Operation.BinaryOperation({$0 / $1}, { $0 + " / " + $1 },1),
        "+" : Operation.BinaryOperation({$0 + $1}, { $0 + " + " + $1 },0),
        "-" : Operation.BinaryOperation({$0 - $1}, { $0 + " - " + $1 },0),
        "=": Operation.Equals
        
    ]
    
    private enum Operation {
        case Constant(Double)
        case UnaryOperation((Double) -> Double, (String) -> String)
        case BinaryOperation((Double,Double) -> Double, (String, String) -> String, Int)
        case Equals
    }
    func performOperation(symbol: String) {
        internalProgram.append(symbol as AnyObject)
        if let operation = operations[symbol]{
            switch operation {
            case .Constant(let value):
                accumulator = value
                descriptionAccumulator = symbol
            case .BinaryOperation(let function, let descriptionFunction, let precedence):
                executePendingBinaryOperation()
                pending = PendingBinaryOperationInfo(binaryFunction: function, firstOperand: accumulator, descriptionFunction: descriptionFunction, descriptionOperand: descriptionAccumulator)
                if currentPrecedence < precedence {
                    descriptionAccumulator = "(" + descriptionAccumulator + ")"
                }
                currentPrecedence = precedence
            case .UnaryOperation(let function, let descriptionFunction):
                accumulator = function(accumulator)
                descriptionAccumulator = descriptionFunction(descriptionAccumulator)
            case .Equals:
                executePendingBinaryOperation()
            }
        }
        
    }
    private func executePendingBinaryOperation(){
        if pending != nil {
            accumulator = pending!.binaryFunction(pending!.firstOperand, accumulator)
            descriptionAccumulator = pending!.descriptionFunction(pending!.descriptionOperand, descriptionAccumulator)
            pending = nil
        }
    }
    
    private var pending: PendingBinaryOperationInfo?
    
    private struct PendingBinaryOperationInfo {
        var binaryFunction: ((Double,Double)->Double)
        var firstOperand: Double
        var descriptionFunction: (String, String) -> String
        var descriptionOperand: String
    }
    
    typealias PropertyList = AnyObject
    var program: PropertyList{
        get{
            return internalProgram as CalculatorBrain.PropertyList
}
        set{
            clear()
            if let arrayOfOps = newValue as? [AnyObject]{
                for op in arrayOfOps{
                    if let operand = op as? Double{
                        setOperand(operand: operand)
                        
                    }else if let operation = op as? String{
                        performOperation(symbol: operation)
                    }
                }
            }
}
    }
    
    func clear(){
        accumulator = 0.0
        pending = nil
        internalProgram.removeAll()
    }
    
    var result: Double{
        get{
            return accumulator
        }
    }
}
