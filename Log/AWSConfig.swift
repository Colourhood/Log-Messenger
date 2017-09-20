//
//  AWSConfig.swift
//  Log
//
//  Created by Andrei Villasana on 9/19/17.
//  Copyright © 2017 Andrei Villasana. All rights reserved.
//
import Foundation
import AWSS3

struct AWSConfig {
    private static let awsCredentialsPath = Bundle.main.path(forResource: "credentials", ofType: "json");
    private static let awsCredentialsData = try! Data(contentsOf: URL(fileURLWithPath: awsCredentialsPath!));
    public static let credentialsJSON = try! JSONSerialization.jsonObject(with: awsCredentialsData, options: []) as! NSDictionary;
    
    
    
    
    
}
