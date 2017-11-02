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

struct AWSConfig {

    static private let awsCredentialsPath = Bundle.main.path(forResource: "credentials", ofType: Constants.JSON)
    static var credentialsJSON: [String: Any]? {
        do {
            let data = try Data(contentsOf: URL(fileURLWithPath: awsCredentialsPath!))
            return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
        } catch {
            //Process error
        }
        return nil
    }

    static let AWSConfig: [String: Any] = [
        "bucket": "logmessenger",
        "bucketRegion": AWSRegionType.USWest2,
        "cognitoRegion": AWSRegionType.USEast2,
        "cognitoID": credentialsJSON!["aws_cognito_pool_id"]!
    ]

    static func setAWS() {
        if let cognitoRegion = AWSConfig["cognitoRegion"] as? AWSRegionType,
           let idendityPoolId = AWSConfig["cognitoID"] as? String,
           let bucketRegion = AWSConfig["bucketRegion"] as? AWSRegionType {

            let credentialProvider = AWSCognitoCredentialsProvider(regionType: cognitoRegion, identityPoolId: idendityPoolId)
            let awsServiceConfig = AWSServiceConfiguration(region: bucketRegion, credentialsProvider: credentialProvider)
            AWSServiceManager.default().defaultServiceConfiguration = awsServiceConfig
        }
        print("What is in here? \(String(describing: credentialsJSON))")
    }

}
