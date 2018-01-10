//
//  HTTP.swift
//  Log
//
//  Created by Andrei Villasana on 8/30/17.
//  Copyright © 2017 Andrei Villasana. All rights reserved.
//

import Foundation
import Alamofire

// private let apiURL = "http://192.168.0.105:7555/api"
private let apiURL = "http://127.0.0.1:7555/api"
private let httpHeaders: HTTPHeaders = [ "Accept": "application/json" ]

protocol HTTPMethods {
    func get(url: String, completionHandler: @escaping ([String: Any]) -> Void)
    func post(url: String, parameters: [String: Any], completionHandler: @escaping ([String: Any]) -> Void)
    func put(url: String, completionHandler: @escaping  ([String: Any]) -> Void)
}

class HTTP: HTTPMethods {

    func get(url: String, completionHandler: @escaping ([String: Any]) -> Void) {
        let request = Alamofire.request(apiURL+url, method: .get, encoding: URLEncoding.default, headers: httpHeaders)
        request.responseJSON { [weak self] (response) in
            guard let JSON = self?.handle(response: response) else { return }
            completionHandler(JSON)
        }
    }

    func post(url: String, parameters: [String: Any], completionHandler: @escaping ([String: Any]) -> Void) {
        let request = Alamofire.request(apiURL+url, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: httpHeaders)
        request.responseJSON { [weak self] (response) in
            guard let JSON = self?.handle(response: response) else { return }
            completionHandler(JSON)
        }
    }

    func put(url: String, completionHandler: @escaping ([String: Any]) -> Void) {
        let request = Alamofire.request(apiURL+url, method: .put, encoding: URLEncoding.default, headers: httpHeaders)
        request.responseJSON { [weak self ](response) in
            guard let JSON = self?.handle(response: response) else { return }
            completionHandler(JSON)
        }
    }

    private func handle(response: DataResponse<Any>) -> [String: Any]? {
        switch response.result {
        case .success(let json):
            guard let JSON = json as? [String: Any] else { return nil }
            return JSON
        case .failure(let error):
            print("There was an error with the response: \(error)")
            return nil
        }
    }

}
