//
//  LOGS3.swift
//  Log
//
//  Created by Andrei Villasana on 9/20/17.
//  Copyright © 2017 Andrei Villasana. All rights reserved.
//

import Foundation
import AWSS3

struct LOGS3 {

    private static let S3Bucket = AWSConfig.AWSConfig["bucket"] as? String
    private static let transferManager = AWSS3TransferManager.default()

    static func uploadToS3(key: String, fileURL: URL, completionHandler: @escaping (Any?) -> Void) {
        if let uploadRequest = AWSS3TransferManagerUploadRequest() {
            uploadRequest.bucket = S3Bucket
            uploadRequest.key = key
            uploadRequest.body = fileURL

            startUploadRequest(uploadRequest: uploadRequest).continueWith(executor: AWSExecutor.mainThread()) { (task) -> Void in
                if let error = task.error {
                    print("There was an error with upload task \(error)")
                }
                if let result = task.result {
                    completionHandler(result)
                }
                completionHandler(nil)
            }
        }
    }

    private static func startUploadRequest(uploadRequest: AWSS3TransferManagerUploadRequest) -> AWSTask<AnyObject> {
        return (transferManager.upload(uploadRequest))
    }

    static func downloadFromS3(key: String?, fileURLPath: URL, completionHandler: @escaping (Any?) -> Void) {
        if let downloadRequest = AWSS3TransferManagerDownloadRequest() {
            downloadRequest.bucket = S3Bucket
            downloadRequest.key = key
            downloadRequest.downloadingFileURL = fileURLPath

            startDownloadRequest(downloadRequest: downloadRequest).continueWith(executor: AWSExecutor.mainThread()) { (task) -> Void in
                if let error = task.error {
                    print("There was an error with download task \(error)")
                }
                if let result = task.result {
                    completionHandler(result)
                }
                completionHandler(nil)
            }
        }
    }

    private static func startDownloadRequest(downloadRequest: AWSS3TransferManagerDownloadRequest) -> AWSTask<AnyObject> {
        return (transferManager.download(downloadRequest))
    }

}
