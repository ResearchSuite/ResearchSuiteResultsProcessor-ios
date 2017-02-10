//
//  RSRPResultsProcessor.swift
//  Pods
//
//  Created by James Kizer on 2/10/17.
//
//

import UIKit
import ResearchKit

public class RSRPResultsProcessor: NSObject {
    
    let frontEnd: RSRPFrontEndService
    let backEnd: RSRPBackEnd
    
    public init(frontEndTransformers: [RSRPFrontEndTransformer.Type], backEnd: RSRPBackEnd) {
        self.frontEnd = RSRPFrontEndService(frontEndTransformers: frontEndTransformers)
        self.backEnd = backEnd
        super.init()
    }
    
    public func processResult(taskResult: ORKTaskResult, resultTransforms: [RSRPResultTransform]) {
        let intermediateResults = self.frontEnd.processResult(taskResult: taskResult, resultTransforms: resultTransforms)
        intermediateResults.forEach { (intermediateResult) in
            
            self.backEnd.add(intermediateResult: intermediateResult)
            
            
        }
    }

}
