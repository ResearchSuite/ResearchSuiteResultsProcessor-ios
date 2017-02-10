//
//  RSRPIntermediateResult.swift
//  Pods
//
//  Created by James Kizer on 2/10/17.
//
//

import UIKit

open class RSRPIntermediateResult: NSObject {
    
    open let type: String!
    open var uuid: UUID! = UUID()
    open var startDate: Date?
    open var endDate: Date?
    
    public init(type: String) {
        self.type = type
        
        super.init()
    }
    
}
