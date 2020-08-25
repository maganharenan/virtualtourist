//
//  APIClient+NetworkingTasks.swift
//  VirtualTourist
//
//  Created by Renan Maganha on 20/08/20.
//  Copyright © 2020 Renan Maganha. All rights reserved.
//

import Foundation

extension APIClient {
    @discardableResult func taskForGetRequest<ResponseType: Decodable>(url: URL, responseType: ResponseType.Type, completion: @escaping (ResponseType?, Error?) -> Void) -> URLSessionDataTask {
        
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard let data = data else {
                completion(nil, error)
                return
            }
            
            let decoder = JSONDecoder()

            do {
                let responseObject = try decoder.decode(ResponseType.self, from: data)
                completion(responseObject, nil)
            } catch {
                completion(nil, error)
            }
        }
        task.resume()
        
        return task
    }
}
