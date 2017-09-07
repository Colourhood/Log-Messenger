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

let httpHeaders: HTTPHeaders = [ "Accept": "application/json" ];

struct LOGHTTP {
    
    func get(url: String, parameters: Parameters) -> Void {
        Alamofire.request(apiURL+url, method: .get, parameters: parameters, encoding: JSONEncoding.default, headers: httpHeaders).responseJSON { (response) in
            print(response.request as Any);
            print(response.response as Any);
            print(response.data as Any);
            print(response.result);
            
            if let JSON = response.result.value {
                print("JSON: \n \(JSON)")
            }
        }
    }
    
    func post(url: String, parameters: Parameters) -> Alamofire.DataRequest {
        let request = Alamofire.request(apiURL+url, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: httpHeaders);
        //{ (response) in
//            print(response.request!);
//            print(response.response!);
//            print(response.data!);
//            print(response.result);
//            
//            switch(response.result) {
//                case .success(let data):
//                    print("It was a success \(data)");
//                    break;
//                case .failure(let error):
//                    print("Error \(error)");
//                    break;
//            }
//        }
        return request;
    }
}
