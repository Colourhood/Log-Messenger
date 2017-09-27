//
//  LOGFileManager.swift
//  Log
//
//  Created by Andrei Villasana on 9/20/17.
//  Copyright © 2017 Andrei Villasana. All rights reserved.
//

import Foundation

struct LOGFileManager {

    private static let fileManager = FileManager.default;
    private static let documentsDirectoryPath = try! fileManager.url(for: .documentDirectory,
                                                                     in: .userDomainMask,
                                                                     appropriateFor: nil,
                                                                     create: false);
    //static let temporaryDirectoryPath = fileManager.temporaryDirectory; - currently not in use
    
    
    //# Mark - Creating Directories
    static func createDirectoriesInDocuments() {
        for directory in EnumType.allDirectories {
            let directoryPath = documentsDirectoryPath.appendingPathComponent(directory.rawValue, isDirectory: true);

            do {
                try fileManager.createDirectory(at: directoryPath, withIntermediateDirectories: false, attributes: nil);
            } catch {
//                print("Directory \(directoryPath) already exists");
            }
        }
    }
    
    //# Mark - Creating Files
    static func createFileInDocuments(file: Data?, fileName: String, directory: String) {
        let storedFilePath = "\(directory)/\(fileName)";
        let targetDirectoryPath = documentsDirectoryPath.appendingPathComponent(storedFilePath);
        do {
            if let _ = file {
                try file?.write(to: targetDirectoryPath);
            }
        } catch {
            print(error);
        }
    }
    
    //# Mark - Fetching Files
    static func getAllFilesAtDirectory(directory: String?) -> [String]? {
        let targetDirectoryPath = documentsDirectoryPath.appendingPathComponent(directory!).path;
        
        do {
            let contents = try fileManager.contentsOfDirectory(atPath: targetDirectoryPath);
            return (contents);
        } catch {
            print("There was a problem getting contents in directory \(targetDirectoryPath)")
        }
        return nil;
    }
    
    static func getFileInDocuments(filename: String) -> Data? {
        let targetDirectoryPath = documentsDirectoryPath.appendingPathComponent(filename).path;
        return (fileManager.contents(atPath: targetDirectoryPath));
    }
    
    static func getFileInDocuments(filename: String, directory: String) -> Data? {
        let storedFilePath = "\(directory)/\(filename)";
        let targetDirectoryPath = documentsDirectoryPath.appendingPathComponent(storedFilePath).path;
        return (fileManager.contents(atPath: targetDirectoryPath));
    }
    
    static func getFile(filepath: String) -> Data? {
        return (fileManager.contents(atPath: filepath));
    }
    
    //# Mark - Get URL Paths
    static func getFileURLInDocumentsForDirectory(filename: String, directory: String) -> URL {
        let storedFilePath = "\(directory)/\(filename)";
        let urlPath = documentsDirectoryPath.appendingPathComponent(storedFilePath);
        return urlPath;
    }
    
    static func getFileURLInDocuments(filename: String) -> URL {
        let urlPath = documentsDirectoryPath.appendingPathComponent(filename);
        return urlPath;
    }
    
}