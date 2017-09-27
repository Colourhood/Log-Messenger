//
//  HTTP.swift
//  Log
//
//  Created by Andrei Villasana on 8/30/17.
//  Copyright © 2017 Andrei Villasana. All rights reserved.
//

import Foundation
import Alamofire

private let apiURL: String = "http://localhost:7555/api";
private let httpHeaders: HTTPHeaders = [ "Accept": "application/json" ];

struct LOGHTTP {
    
    func get(url: String) -> Alamofire.DataRequest {
        return Alamofire.request(apiURL+url, method: .get, encoding: URLEncoding.default);
    }
    
    func post(url: String, parameters: Parameters) -> Alamofire.DataRequest {
        return Alamofire.request(apiURL+url, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: httpHeaders);
    }
}