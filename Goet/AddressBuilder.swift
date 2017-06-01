//
//  AddressBuilder.swift
//  Goet
//
//  Created by Zhe Cui on 8/30/16.
//  Copyright © 2016 Zhe Cui. All rights reserved.
//

import Foundation

class Address {
    var address1 = ""
    var address2 = ""
    var address3 = ""
    var city = ""
    var state = ""
    var zip_code = ""
    var country = ""
    
    init?(of location: [String: Any]) {
        
        if let addr1 = location["address1"] as? String {
            self.address1 = addr1
        }
        if let addr2 = location["address2"] as? String {
            self.address2 = addr2
        }
        if let addr3 = location["address3"] as? String {
            self.address3 = addr3
        }
        if let city = location["city"] as? String {
            self.city = city
        }
        if let state = location["state"] as? String {
            self.state = state
        }
        if let zipCode = location["zip_code"] as? String {
            self.zip_code = zipCode
        }
        if let country = location["country"] as? String {
            self.country = country
        }
        
    }
    
    func composeAddress() -> String {
        var address = ""
        address += address1.isEmpty ? "" : address1 + ", "
        address += address2.isEmpty ? "" : address2 + ", "
        address += address3.isEmpty ? "" : address3 + ", "
        address += city.isEmpty ? "" : city + ", "
        address += state.isEmpty ? "" : state + " "
        address += zip_code.isEmpty ? "" : zip_code + ", "
        address += country.isEmpty ? "" : country
        
        return address
    }
}
