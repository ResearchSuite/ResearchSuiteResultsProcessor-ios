//
//  RSRPFrontEndService.swift
//  Pods
//
//  Created by James Kizer on 2/10/17.
//
//

import UIKit
import ResearchKit

class RSRPFrontEndService: NSObject {
    
    let transformers: [RSRPFrontEndTransformer.Type]
    
    public init(frontEndTransformers: [RSRPFrontEndTransformer.Type]) {
        self.transformers = frontEndTransformers
    }
    
    public func processResult(taskResult: ORKTaskResult, resultTransforms: [RSRPResultTransform]) -> [RSRPIntermediateResult] {
        
        let intermediateResults = resultTransforms.flatMap { (resultTransform) -> RSRPIntermediateResult? in
            
            var selectedResults: [String: ORKStepResult] = [:]
            resultTransform.inputMapping.forEach({ (inputMapping) in
                
                if let result = taskResult.stepResult(forStepIdentifier: inputMapping.stepIdentifier) {
                    selectedResults[inputMapping.parameter] = result
                }
                
            })
            
            return self.transformResult(
                type: resultTransform.transform,
                taskIdentifier: taskResult.identifier,
                taskRunUUID: taskResult.taskRunUUID,
                parameters: selectedResults
            )
        }
        
        
        return intermediateResults
        
    }
    
    
    private func transformResult(
        type: String,
        taskIdentifier: String,
        taskRunUUID: UUID,
        parameters: [String: ORKStepResult]
    ) -> RSRPIntermediateResult? {
        
        for transformer in self.transformers {
            if transformer.supportsType(type: type),
                let intermediateResult = transformer.transform(taskIdentifier: taskIdentifier, taskRunUUID: taskRunUUID, parameters: parameters) {
                return intermediateResult
            }
        }
        
        return nil
        
    }

}
