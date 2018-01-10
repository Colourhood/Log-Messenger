//
//  LOGFileManager.swift
//  Log
//
//  Created by Andrei Villasana on 9/20/17.
//  Copyright © 2017 Andrei Villasana. All rights reserved.
//

import Foundation

struct LOGFileManager {

    private static let fileManager = FileManager.default
    private static let documentsDirectoryPath = try? fileManager.url(for: .documentDirectory,
                                                                     in: .userDomainMask,
                                                                     appropriateFor: nil,
                                                                     create: false)
    // static let temporaryDirectoryPath = fileManager.temporaryDirectory - currently not in use

    // # Mark - Creating Directories
    static func createDirectoriesInDocuments() {
        for directory in Constants.allDirectories {
            if let directoryPath = documentsDirectoryPath?.appendingPathComponent(directory, isDirectory: true) {
                do {
                    try fileManager.createDirectory(at: directoryPath, withIntermediateDirectories: false, attributes: nil)
                } catch {
                    //print("Directory \(directoryPath) already exists")
                }
            }
        }
    }

    // # Mark - Saving Files
    static func save(file: Data, fileName: String, directory: String) {
        let storedFilePath = "\(directory)/\(fileName)"
        if let targetDirectoryPath = documentsDirectoryPath?.appendingPathComponent(storedFilePath) {
            do {
                try file.write(to: targetDirectoryPath)
            } catch {
                print(error)
            }
        }
    }

    // # Mark - Fetching Files

    static func fetch(filename: String) -> Data? {
        guard let filePath = documentsDirectoryPath?.appendingPathComponent(filename).path else { return nil }
        let file = fileManager.contents(atPath: filePath)
        return file
    }

    static func fetch(filename: String, directory: String) -> Data? {
        let filePath = "\(directory)/\(filename)"
        guard let targetDirectoryPath = documentsDirectoryPath?.appendingPathComponent(filePath).path else { return nil }
        let file = fileManager.contents(atPath: targetDirectoryPath)
        return file
    }

    // # Mark - Get URL Paths
    
    static func fetchURL(filename: String, directory: String) -> URL? {
        let storedFilePath = "\(directory)/\(filename)"
        guard let urlPath = documentsDirectoryPath?.appendingPathComponent(storedFilePath) else { return nil }
        return urlPath
    }

    static func fetchURL(filename: String) -> URL? {
        guard let urlPath = documentsDirectoryPath?.appendingPathComponent(filename) else { return nil }
        return urlPath
    }

}
