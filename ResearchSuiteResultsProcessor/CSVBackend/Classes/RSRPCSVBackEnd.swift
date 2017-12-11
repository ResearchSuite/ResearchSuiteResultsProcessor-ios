//
//  RSRPCSVBackEnd.swift
//  Pods
//
//  Created by James Kizer on 4/29/17.
//
//

import UIKit
import SecureQueue


public class TempQueueElement: NSObject, NSSecureCoding {
    public static var supportsSecureCoding: Bool = true
    let typeString: String
    let header: String
    let records: [CSVRecord]
    
    private enum CoderKeys: String {
        case TypeString = "typeString"
        case Header = "header"
        case Records = "Records"
    }
    
    init(typeSting: String, header: String, records: [CSVRecord]) {
        self.typeString = typeSting
        self.header = header
        self.records = records
    }
    
    public func encode(with aCoder: NSCoder) {
        aCoder.encode(self.typeString as NSString, forKey: CoderKeys.TypeString.rawValue)
        aCoder.encode(self.header as NSString, forKey: CoderKeys.Header.rawValue)
        aCoder.encode(self.records as NSArray, forKey: CoderKeys.Records.rawValue)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        guard let typeString = aDecoder.decodeObject(of: NSString.self, forKey: CoderKeys.TypeString.rawValue),
            let header = aDecoder.decodeObject(of: NSString.self, forKey: CoderKeys.Header.rawValue),
            let records = aDecoder.decodeObject(of: NSArray.self, forKey: CoderKeys.Records.rawValue) else {
            return nil
        }
        
        self.typeString = typeString as String
        self.header = header as String
        self.records = records.flatMap({ (record) -> CSVRecord? in
            return record as? CSVRecord
        })
        
        return nil
    }
    
    
}
public class RSRPCSVBackEnd: RSRPBackEnd {
    
//    var datapoints : [RSRPCSVDatapoint] = []
    
    let outputDirectory: URL
    let secureQueue: SecureQueue
    var protectedDataAvaialbleObserver: NSObjectProtocol!
    
    public init(outputDirectory: URL){
        print(outputDirectory)
        self.outputDirectory = outputDirectory
        self.secureQueue = SecureQueue(directoryName: "RSRPCSVBackEnd/tmpQueue", allowedClasses: [NSArray.self])!
        
        //see if we need to create the directory
        var isDirectory : ObjCBool = false
        
        let shouldCreateDirectory: Bool = {
            if FileManager.default.fileExists(atPath: outputDirectory.path, isDirectory: &isDirectory) {
                
                //if a file, remove file and add directory
                if isDirectory.boolValue {
                    
                    return false
                }
                else {
                    
                    do {
                        try self.removeDirectory(directory: outputDirectory)
                    } catch let error as NSError {
                        print(error.localizedDescription);
                    }
                }
                
            }
            
            return true
        }()
        
        if shouldCreateDirectory {
            do {
                try self.createDirectory(directory: outputDirectory)
            } catch let error as NSError {
                print(error.localizedDescription);
            }
        }
        
        self.protectedDataAvaialbleObserver = NotificationCenter.default.addObserver(forName: .UIApplicationProtectedDataDidBecomeAvailable, object: nil, queue: nil) { [weak self](notification) in
            self?.syncElements()
        }
        
        self.syncElements()
        
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self.protectedDataAvaialbleObserver)
    }
    
    
    
    public func signOut(completion: @escaping ((Error?) -> ())) {
        do {

            try self.secureQueue.clear()
            try self.removeAll()
            
            completion(nil)
            
        } catch let error {
            completion(error)
        }
    }
    
    private func createDirectory(directory: URL) throws {
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true, attributes: nil)
        var url: URL = directory
        var resourceValues: URLResourceValues = URLResourceValues()
        resourceValues.isExcludedFromBackup = true
        try url.setResourceValues(resourceValues)
    }
    
    private func removeDirectory(directory: URL) throws {
        
        try FileManager.default.removeItem(at: directory)
        
    }
    
    private func removeItem(itemName: String) throws {
        
        do {
            
            let fileURL = self.outputDirectory.appendingPathComponent(itemName)
            print(fileURL)
            try FileManager.default.removeItem(at: fileURL)
            
        } catch let error as NSError {
            throw error
        }
    }
    
    public func removeFileForType(type: CSVEncodable.Type) {
        let typeIdentifier = type.typeString
        let fileURL = self.outputDirectory.appendingPathComponent(typeIdentifier + ".csv")
        if FileManager.default.fileExists(atPath: fileURL.path) {
            do {
                try FileManager.default.removeItem(at: fileURL)
            } catch let error as NSError {
                debugPrint(error)
            }
        }
    }
    
    public func removeAll() throws {
        
        //remove directory and recreate
        do {
            
            try self.removeDirectory(directory: self.outputDirectory)
            try self.createDirectory(directory: self.outputDirectory)

        } catch let error as NSError {
            throw error
        }
    }
    
    public func destroy() throws {
        
        //remove directory
        do {
            
            try self.removeDirectory(directory: self.outputDirectory)
            
        } catch let error as NSError {
            throw error
        }
    }
    
    private func addFile(itemName: String, text: String) throws {
        
        do {
            let fileURL = self.outputDirectory.appendingPathComponent(itemName)
            print(fileURL)
            
            guard let data: Data = text.data(using: .utf8) else {
                assertionFailure("failed to convert string to data")
                return
            }

            try data.write(to: fileURL, options: [Data.WritingOptions.completeFileProtectionUnlessOpen, Data.WritingOptions.atomicWrite] )
            
        } catch let error as NSError {
            throw error
        }
        
    }
    
    public func getFileURLs() -> [URL]? {
        do {
            return try FileManager.default.contentsOfDirectory(at: self.outputDirectory, includingPropertiesForKeys: nil)
        } catch let error as NSError {
            return nil
        }
    }
    
    public func getFileURLForType(typeIdentifier: String) -> URL? {
        
        let fileURL = self.outputDirectory.appendingPathComponent(typeIdentifier + ".csv")
        if FileManager.default.fileExists(atPath: fileURL.path) {
            return fileURL
        }
        else {
            return nil
        }
        
    }
    
    private func getOrCreateFileForType(typeIdentifier: String, header: String) throws -> FileHandle? {
        
        let fileURL = self.outputDirectory.appendingPathComponent(typeIdentifier + ".csv")
        //file exists, load file handle
        
        if FileManager.default.fileExists(atPath: fileURL.path) {
            //if this fails, return nil so that we can add to temp queue
            return try? FileHandle(forWritingTo: fileURL)
        }
        else {
            debugPrint(fileURL)
            let fileCreated = FileManager.default.createFile(atPath: fileURL.path, contents: nil, attributes: [FileAttributeKey.protectionKey.rawValue: FileProtectionType.completeUnlessOpen])
            guard fileCreated,
                FileManager.default.fileExists(atPath: fileURL.path) else {
                assertionFailure("failed to create file")
                throw NSError(domain: "RSRPCSVBackEnd", code: 0, userInfo: nil)
            }
            
            let fileHandle = try FileHandle(forWritingTo: fileURL)
            
            //write header to file
            guard let data: Data = header.appending("\n").data(using: .utf8) else {
                assertionFailure("failed to convert header to data")
                throw NSError(domain: "RSRPCSVBackEnd", code: 0, userInfo: nil)
            }
            fileHandle.write(data)
            return fileHandle
        }
        
    }
    
    public func getRecordsOfType<T: CSVDecodable>(type: T.Type) throws -> [T] {
        guard let fileURL = self.getFileURLForType(typeIdentifier: type.typeString) else {
            return []
        }
        
        let fileString = try String(contentsOf: fileURL, encoding: .utf8)
        let lines = fileString.components(separatedBy: .newlines)
        
        return lines.flatMap({ (record) -> T? in
            return T(record: record)
        })
    }
    
    public func add<T: CSVEncodable>(csvRecords: [T]) throws {
        
        guard let first = csvRecords.first else {
            return
        }
        
        let type: CSVEncodable.Type = type(of: first)
        
        let records = csvRecords.flatMap { $0.toRecords() }
        if records.count == 0 {
            return
        }
        
        _ = try self.add(typeString: type.typeString, header: type.header, records: records, shouldAddToQueue: true)
    }
    
    public func add(encodable: CSVEncodable) throws {
        
        let type: CSVEncodable.Type = type(of: encodable)
        
        let records = encodable.toRecords()
        if records.count == 0 {
            return
        }
        
        _ = try self.add(typeString: type.typeString, header: type.header, records: records, shouldAddToQueue: true)
    }
    
    private func add(typeString: String, header: String, records: [CSVRecord], shouldAddToQueue: Bool) throws -> Bool {
        
        //if opening the file handle fails
        if let fileHandle = try self.getOrCreateFileForType(typeIdentifier: typeString, header: header) {
            fileHandle.seekToEndOfFile()
            
            guard let data: Data = records.joined(separator: "\n").appending("\n").data(using: .utf8) else {
                assertionFailure("failed to convert records to data")
                throw NSError(domain: "RSRPCSVBackEnd", code: 1, userInfo: nil)
            }
            fileHandle.write(data)
            fileHandle.closeFile()
            return true
        }
        else if shouldAddToQueue {
            //add to queue
            debugPrint("Adding element to queue")
            let element = TempQueueElement(typeSting: typeString, header: header, records: records)
            try self.secureQueue.addElement(element: element)
            return true
        }
        else {
            return false
        }
        
    }
    
    private func syncElements() {
        
        while (!self.secureQueue.isEmpty) {
            
            do {
                guard let (identifier, codedElement) = try self.secureQueue.getFirstElement(),
                    let element = codedElement as? TempQueueElement else {
                    return
                }
                
                let added = try self.add(typeString: element.typeString, header: element.header, records: element.records, shouldAddToQueue: false)
                if !added {
                    return
                }
                try self.secureQueue.removeElement(elementId: identifier)
            }
            catch _ {
                return
            }
            
            
            
        }
        
    }
    
    public func add(intermediateResult: RSRPIntermediateResult) {
        
        if let datapoint = intermediateResult as? CSVEncodable {
            
            do {
                //note that this may not always work in the background
                try self.add(encodable: datapoint)
            }
            catch let error as NSError {
                print(error)
            }
            
        }
        
    }

    
    //helper method to show email w/ files included
    //takes view controller
    
}
