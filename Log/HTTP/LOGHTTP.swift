//
//  HTTP.swift
//  Log
//
//  Created by Andrei Villasana on 8/30/17.
//  Copyright © 2017 Andrei Villasana. All rights reserved.
//

import Foundation
import Alamofire

private let apiURL: String = "http://192.168.0.10:7555/api"
// private let apiURL: String = "http://127.0.0.1:7555/api"
private let httpHeaders: HTTPHeaders = [ "Accept": "application/json" ]

struct LOGHTTP {

    static func get(url: String) -> Alamofire.DataRequest {
        return Alamofire.request(apiURL+url, method: .get, encoding: URLEncoding.default, headers: httpHeaders)
    }

    static func post(url: String, parameters: [String: Any]) -> Alamofire.DataRequest {
        return Alamofire.request(apiURL+url, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: httpHeaders)
    }

    static func put(url: String) -> Alamofire.DataRequest {
        return Alamofire.request(apiURL+url, method: .put, encoding: URLEncoding.default, headers: httpHeaders)
    }

}
