//
//  AWSConfig.swift
//  Log
//
//  Created by Andrei Villasana on 9/19/17.
//  Copyright © 2017 Andrei Villasana. All rights reserved.
//
import Foundation
import AWSCognito
import AWSCore

private let awsCredentialsPath = Bundle.main.path(forResource: "credentials", ofType: EnumType.ext.JSON.rawValue);
private let awsCredentialsData = try! Data(contentsOf: URL(fileURLWithPath: awsCredentialsPath!));
private let credentialsJSON = try! JSONSerialization.jsonObject(with: awsCredentialsData, options: []) as! NSDictionary;

struct AWSConfig {
    
    static let AWSConfig: [String: Any] = [
        "bucket": "logmessenger",
        "bucketRegion": AWSRegionType.USWest2,
        "cognitoRegion": AWSRegionType.USEast2,
        "cognitoID": credentialsJSON["aws_cognito_pool_id"]!,
    ];
    
    static func setAWS() {
        let credentialProvider = AWSCognitoCredentialsProvider(regionType: AWSConfig["cognitoRegion"] as! AWSRegionType,
                                                               identityPoolId: AWSConfig["cognitoID"] as! String);
        let awsServiceConfig = AWSServiceConfiguration(region: AWSConfig["bucketRegion"] as! AWSRegionType,
                                                       credentialsProvider: credentialProvider);
        
        AWSServiceManager.default().defaultServiceConfiguration = awsServiceConfig;
        print("What is in here? \(credentialsJSON)");
    }
    
}
