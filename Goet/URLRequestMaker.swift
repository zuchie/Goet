//
//  URLRequestMaker.swift
//  Goet
//
//  Created by Zhe Cui on 5/5/17.
//  Copyright © 2017 Zhe Cui. All rights reserved.
//

//import Foundation
import UIKit

extension URLRequest {
    
    public func makeRequest(completion: @escaping (_ error: Error?, _ data: Data?) -> Void) {
        if let cachedResponse = URLCache.shared.cachedResponse(for: self) {
            print("Cached response.")
            print("Disk usage/capacity: \(URLCache.shared.currentDiskUsage)/\(URLCache.shared.diskCapacity), memory usage/capacity: \(URLCache.shared.currentMemoryUsage)/\(URLCache.shared.memoryCapacity)")

            completion(nil, cachedResponse.data)
            
        } else {
            print("Fresh response.")
            let task = URLSession.shared.dataTask(with: self) { data, response, error in
                
                if let err = error {
                    completion(err, nil)
                    return
                }
                guard let data = data, let response = response else {
                    fatalError("No data or response is received.")
                }
                
                let cacheResponse = CachedURLResponse(response: response, data: data)
                URLCache.shared.storeCachedResponse(cacheResponse, for: self)

                completion(nil, data)
            }
            task.resume()
        }
    }
    
}
