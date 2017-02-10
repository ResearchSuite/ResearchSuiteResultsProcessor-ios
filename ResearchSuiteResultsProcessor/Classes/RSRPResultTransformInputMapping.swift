//
//  RSRPResultTransformInputMapping.swift
//  Pods
//
//  Created by James Kizer on 2/10/17.
//
//

import UIKit
import Gloss

public class RSRPResultTransformInputMapping: Decodable {
    
    public let stepIdentifier: String!
    public let parameter: String!
    
    required public init?(json: JSON) {
        
        guard let stepIdentifier: String = "stepIdentifier" <~~ json,
            let parameter: String = "parameter" <~~ json else {
                return nil
        }
        self.stepIdentifier = stepIdentifier
        self.parameter = parameter
        
    }

}
