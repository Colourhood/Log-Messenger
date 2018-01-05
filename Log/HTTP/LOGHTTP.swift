//
//  HTTP.swift
//  Log
//
//  Created by Andrei Villasana on 8/30/17.
//  Copyright © 2017 Andrei Villasana. All rights reserved.
//

import Foundation
import Alamofire

private let apiURL: String = "http://192.168.0.105:7555/api"
// private let apiURL: String = "http://127.0.0.1:7555/api"
private let httpHeaders: HTTPHeaders = [ "Accept": "application/json" ]

struct LOGHTTP {

    static func get(url: String, completionHandler: @escaping ([String: Any]?) -> Void) {
        let request = Alamofire.request(apiURL+url, method: .get, encoding: URLEncoding.default, headers: httpHeaders)
        request.responseJSON() { (response) in
            let JSON = handle(response: response)
            completionHandler(JSON)
        }
    }

    static func post(url: String, parameters: [String: Any], completionHandler: @escaping ([String: Any]?) -> Void) {
        let request = Alamofire.request(apiURL+url, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: httpHeaders)
        request.responseJSON() { (response) in
            let JSON = handle(response: response)
            completionHandler(JSON)
        }
    }

    static func put(url: String, completionHandler: @escaping ([String: Any]?) -> Void) {
        let request = Alamofire.request(apiURL+url, method: .put, encoding: URLEncoding.default, headers: httpHeaders)
        request.responseJSON() { (response) in
            let JSON = handle(response: response)
            completionHandler(JSON)
        }
    }

    static private func handle(response: DataResponse<Any>) -> [String: Any]? {
        switch response.result {
        case .success(let json):
            return json as? [String: Any]
        case .failure(let error):
            print("There was an error with the response: \(error)")
            break
        }
    }

}
