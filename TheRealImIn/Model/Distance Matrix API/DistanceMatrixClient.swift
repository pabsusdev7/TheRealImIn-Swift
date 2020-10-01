//
//  DistanceMatrixClient.swift
//  TheRealImIn
//
//  Created by Pablo Albuja on 7/18/20.
//  Copyright © 2020 Ingenuity Applications. All rights reserved.
//

import Foundation

class DistanceMatrixClient {
    
    enum Endpoints {
        static let base = "https://maps.googleapis.com/maps/api/distancematrix"
        
        static let apiKey = ConfigUtils.getConfigs()?.googleAPIKey
        
        case getDistanceData(Double,Double,Double,Double)
        
        var stringValue: String {
            switch self {
            case .getDistanceData(let latOrigin, let lonOrigin, let latDest, let lonDest): return Endpoints.base + "/json?units=imperial&origins=\(latOrigin),\(lonOrigin)&destinations=\(latDest),\(lonDest)&key=" + (Endpoints.apiKey ?? "")
                
            }
        }
        
        var url: URL {
            return URL(string: stringValue)!
        }
    }
    
    class func taskForGETRequest<ResponseType: Decodable>(endpoint: Endpoints, responseType: ResponseType.Type, completion: @escaping (ResponseType?, Error?) -> Void) -> URLSessionTask{
        let task = URLSession.shared.dataTask(with: endpoint.url) { data, response, error in
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
                return
            }
            
            guard let httpStatusCode = (response as? HTTPURLResponse)?.statusCode else {
                return
            }
            //debugPrint(String(decoding: data, as: UTF8.self))
            if httpStatusCode >= 200 && httpStatusCode < 300 {
                let decoder = JSONDecoder()
                do {
                    let responseObject = try decoder.decode(ResponseType.self, from: data)
                    DispatchQueue.main.async {
                        completion(responseObject, nil)
                    }
                } catch {
                    debugPrint(error)
                    DispatchQueue.main.async {
                        completion(nil, error)
                    }
                }
            }
            else{
                completion(nil, error)
            }
            
            
        }
        task.resume()
        
        return task
    }
    
    class func getDistanceData(latOrigin: Double, lonOrigin: Double,latDest: Double, lonDest: Double, completion: @escaping (Element?, Error?) -> Void) {
        
        taskForGETRequest(endpoint: Endpoints.getDistanceData(latOrigin, lonOrigin, latDest, lonDest), responseType: DistanceDataResponse.self, completion: {(response, error)
            in
            if let response=response{
                debugPrint("Response Status: \(response.status)")
                completion(response.rows[0].elements[0],nil)
            }else{
                completion(nil, error)
            }
        })
    }
    
    class func getOrgImage(url: URL, completion: @escaping (Data?, Error?) -> ()) {
        
        let task = URLSession.shared.dataTask(with: url){ data, response, error in
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
                return
            }
            
            guard let httpStatusCode = (response as? HTTPURLResponse)?.statusCode else {
                return
            }
            if httpStatusCode >= 200 && httpStatusCode < 300 {
                DispatchQueue.main.async {
                    completion(data, error)
                }
            }
            else{
                completion(nil, error)
            }
            
            
        }
        task.resume()
    }
    
}
