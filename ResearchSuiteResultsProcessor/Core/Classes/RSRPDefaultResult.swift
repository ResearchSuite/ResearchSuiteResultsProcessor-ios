//
//  RSRPDefaultResult.swift
//  ResearchSuiteResultsProcessor
//
//  Created by James Kizer on 10/19/17.
//

import UIKit
import ResearchKit

public protocol RSRPDefaultValueTransformer {
    var defaultValue: AnyObject? { get }
}

//default results

//ORKScaleQuestionResult
extension ORKScaleQuestionResult: RSRPDefaultValueTransformer {
    
    public var defaultValue: AnyObject? {
        if let answer = self.scaleAnswer {
            return answer
        }
        return nil
    }
}

extension ORKChoiceQuestionResult: RSRPDefaultValueTransformer {
    
    public var defaultValue: AnyObject? {
        if let answers = self.choiceAnswers {
            return answers as NSArray
        }
        return nil
    }
    
}

//ORKBooleanQuestionResult
extension ORKBooleanQuestionResult: RSRPDefaultValueTransformer {
    
    public var defaultValue: AnyObject? {
        if let answer = self.booleanAnswer {
            return answer
        }
        return nil
    }
    
}


extension ORKTextQuestionResult: RSRPDefaultValueTransformer {
    
    public var defaultValue: AnyObject? {
        if let answer = self.textAnswer {
            return answer as NSString
        }
        return nil
    }
    
}

//ORKNumericQuestionResult
extension ORKNumericQuestionResult: RSRPDefaultValueTransformer {
    
    public var defaultValue: AnyObject? {
        if let answer = self.numericAnswer {
            return answer
        }
        return nil
    }
    
}

//ORKTimeOfDayQuestionResult

//ORKTimeIntervalQuestionResult
extension ORKTimeIntervalQuestionResult: RSRPDefaultValueTransformer {
    
    public var defaultValue: AnyObject? {
        if let answer = self.intervalAnswer {
            return answer
        }
        return nil
    }
}


//ORKDateQuestionResult

//ORKLocationQuestionResult


public class RSRPDefaultResultHelpers {
    
    public class func extractResults(parameters: [String : AnyObject]) -> [String: AnyObject]? {
        let resultsPairList: [(String, AnyObject)] = parameters.flatMap { (pair) -> (String, AnyObject)? in
            
            guard let stepResult = pair.value as? ORKStepResult,
                let firstResult = stepResult.firstResult as? RSRPDefaultValueTransformer,
                let resultValue: AnyObject = firstResult.defaultValue else {
                    return nil
            }
            
            return (pair.key, resultValue)
        }
        
        var resultsMap: [String: AnyObject] = [:]
        
        resultsPairList.forEach { (pair) in
            resultsMap[pair.0] = pair.1
        }
        
        return resultsMap
        
    }
    
    public class func stepResultsSortedByStartDate(parameters: [String : AnyObject]) -> [ORKStepResult] {
        let results: [ORKStepResult] = parameters.flatMap { $0.value as? ORKStepResult }
        let sortedResults: [ORKStepResult] = results.sorted { (firstResult, secondResult) -> Bool in
            //if first result start time is before second result, return true
            return firstResult.startDate <= secondResult.startDate
        }
        
        return sortedResults
    }
    
    public class func startDate(parameters: [String : AnyObject]) -> Date? {
        return stepResultsSortedByStartDate(parameters: parameters).first?.startDate
    }
    
    public class func endDate(parameters: [String : AnyObject]) -> Date? {
        return stepResultsSortedByStartDate(parameters: parameters).last?.endDate
    }

}


