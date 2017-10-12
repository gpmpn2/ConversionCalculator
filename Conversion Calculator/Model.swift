//
//  Model.swift
//  Conversion Calculator
//
//  Created by Wade Tobin on 10/3/17.
//  Copyright © 2017 Grant Maloney. All rights reserved.
//

import Foundation

enum Fractions : String {
    case oneHalf = "1/2"
    case oneFourth = "1/4"
    case oneThird = "1/3"
    
    static var allCases: [Fractions] = [.oneHalf, .oneThird, .oneFourth]
    
    var doubleValue: Double {
        switch self {
        case .oneHalf:
            return 0.5
        case .oneThird:
            return 0.33
        case .oneFourth:
            return 0.25
        default:
            return 0.0
        }
    }
}

class ConversionCalculator {
    var inputValueString = ""
    var outputValueString = ""
    
    var selection = 0; //Ask about this variable
    //Selection is the selected segmented control for the conversion, so in this case 0 would represent "Length" by default = 0, "Volume" = 1, "Weight" = 2, "Height" = 3
    
    var system = 0;
    //System is the selected segmeneted control for fraction or decimal, Fraction = 0, Decimal = 1
    
    var to: String
    var from: String
    
    init() { // Ask about initializer
        self.to = "mi"
        self.from = "km"
    }
    
    var fractionInputString = ""
    
    var fraction: Double = 0.0
    
    var input: Double {
        return Double(inputValueString) ?? 0.0
    }
    
    var output: Double {
        return Double(outputValueString) ?? 0.0
    }
    
    func clearInput(){
        inputValueString = ""
    }
    
    func backspace() {
        inputValueString = String(inputValueString[..<inputValueString.endIndex])
    }
    
    func append(digit: Int) {
        inputValueString += String(digit)
    }
    
    func negate() {
        if inputValueString.contains("-") {
            if let i = inputValueString.characters.index(of: "-") {
                inputValueString.remove(at: i)
            }
        } else {
            inputValueString = "-" + inputValueString
        }
    }
    
    func appendDecimal(){
        //If the system is currently in fraction
        if system == 1 {
            return
        }
        
        if inputValueString.contains(".") {
            return
        }
        
        if inputValueString.isEmpty {
            inputValueString += "0."
        } else {
            inputValueString += "."
        }
    }
    
    func appendFraction(fractionPicked: Int){
        if system == 0 {
            return
        }
        
        fractionInputString = Fractions.allCases[fractionPicked].rawValue
        fraction = Fractions.allCases[fractionPicked].doubleValue
    }
    
    func setDefaults(from segment: Int){
        switch segment {
        case 0:
            to = "mi"
            from = "km"
        case 1:
            to = "L"
            from = "mL"
        case 2:
            to = "oz"
            from = "lbs"
        case 3:
            to = "°C"
            from = "°F"
            
        default:
            to = "mi"
            from = "km"
        }
    }
    
    func calculate(){
        switch from {
        case "km":
            outputValueString = kilometeresToMiles(speedInKPH: input)
        case "mL":
            outputValueString = milliliterToLiter(milli: input)
        case "lbs":
            outputValueString = poundsToOunces(pounds: input)
        case "°F":
            outputValueString = farenheitToCelcius(farenheit: input)
        default:
            break
        }
    }
    
    func finalizedInput() -> String {
        if system == 0 {
            return (inputValueString.isEmpty ? "0.0" : inputValueString) + " " + from
        } else {
            return (inputValueString.isEmpty ? "0.0" : inputValueString) + " " + fractionInputString + from
        }
    }
    
    func finalizedOutput() -> String {
        if system == 0 {
            return outputValueString + " " + to
        } else {
            let main = Int(output) //10
            let trunc: Double = output.truncatingRemainder(dividingBy: Double(main))
            if trunc.isNaN {
                return outputValueString + " " + to
            }
            let (top, bottom) = rationalApproximation(of: output.truncatingRemainder(dividingBy: Double(main))) //.256
            if top == 0 {
                return   "\(main)" + to
            } else {
                return   "\(main) \(top)/\(bottom) " + to
            }
        }
    }
    
    func kilometeresToMiles(speedInKPH: Double) -> String{
        let speedInMPH = (speedInKPH + fraction) / 1.60934
        return String(speedInMPH)
    }
    
    func milliliterToLiter(milli: Double) -> String {
        let liter = (milli + fraction) / 1000
        return String(liter)
    }
    
    func poundsToOunces(pounds: Double) -> String {
        let ounces = (pounds + fraction) * 16
        return String(ounces)
    }
    
    func farenheitToCelcius(farenheit: Double) -> String {
        let celcius = ((farenheit + fraction) - 32.0) * (5.0/9.0)
        return String(celcius)
    }
    
    func rationalApproximation(of value : Double, withPrecision eps: Double = 1.0E-6) -> (num: Int, den: Int) {
        var x = value
        var a = x.rounded(.down)
        var (h1, k1, h, k) = (1, 0, Int(a), 1)
        
        while x - a > eps * Double(k) * Double(k) {
            x = 1.0/(x - a)
            a = x.rounded(.down)
            (h1, k1, h, k) = (h, k , h1 + Int(a) * h, k1 + Int(a) * k)
        }
        return (h,k)
    }
}


