//
//  CSVConvertible.swift
//  ResearchSuiteResultsProcessor
//
//  Created by James Kizer on 12/7/17.
//

public typealias CSVRecord = String
//want to make this a protocol for transforming object into a csv record and vice-versa
//issue here is that multiple records could come from one datapoint
//i.e., datapoint -> [record] is fine, but not necessarily [record] -> datapoint
public protocol CSVConvertible {
    static var typeString: String { get }
    static var header: String { get }
}

public protocol CSVEncodable: CSVConvertible {
    func toRecords() -> [CSVRecord]
}

public protocol CSVDecodable: CSVConvertible {
    //for now, only support 1 record to 1 object decoding
    //in the future, we could support multiple records for a single object,
    //but we would also probbaly want to provide some grouping method as well
    init?(record: CSVRecord)
}
