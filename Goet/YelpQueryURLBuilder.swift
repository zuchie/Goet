//
//  YelpQueryURLBuilder.swift
//  Goet
//
//  Created by Zhe Cui on 8/27/16.
//  Copyright © 2016 Zhe Cui. All rights reserved.
//

import Foundation

class YelpQueryURL {
    
    // MARK: Properties
    private var latitude: Double?
    private var longitude: Double?
    private var category: String?
    private var radius: Int?
    private var limit: Int?
    private var openAt: Int?
    private var sortBy: String?
    
    var queryString: String {
        let parameters: [(Any?, String)] = [(latitude, "latitude"),  (longitude, "longitude"), (category, "categories"), (radius, "radius"), (limit, "limit"), (openAt, "open_at"), (sortBy, "sort_by")]
        
        return parameters.map(formatParameter).reduce("https://api.yelp.com/v3/businesses/search?", { $0 + $1 })
    }
    
    // MARK: Initializers
    init(latitude: Double?, longitude: Double?, category: String?, radius: Int?, limit: Int?, openAt: Int?, sortBy: String?) {
        self.latitude = latitude
        self.longitude = longitude
        self.category = category
        self.radius = radius
        self.limit = limit
        self.openAt = openAt
        self.sortBy = sortBy
    }
    
    // MARK: Helper functions
    private func formatParameter(parameter: (Any?, String)) -> String {
        let param = parameter
        guard var value = param.0 else {
            // If no category specified, cover all restaurants
            if param.1 == "categories" {
                return "&categories=restaurants"
            }
            return ""
        }
        // Use Yelp required strings for special cases
        if value as? String == "All" {
            value = "restaurants"
        }
        if value as? String == "American" {
            value = "newamerican,tradamerican"
        }
        if value as? String == "Indian" {
            value = "indpak"
        }
        
        return "&\(param.1)=\(value)".lowercased()
    }
}
