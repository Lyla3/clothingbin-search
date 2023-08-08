//
//  ClothingBin.swift
//  daummap
//
//  Created by Lyla on 2023/08/08.
//

import Foundation

struct ClothingBin {
    let info: String
    let lat: Double
    let lon: Double
    let distanceFromUser: Double?
    
    init(info: String, lat: String, lon: String) {
        self.info = info
        self.lat = Double(lat) ?? 0
        self.lon = Double(lon) ?? 0
        self.distanceFromUser = nil
    }
    
    init(info: String, lat: Double, lon: Double, distance: Double) {
        self.info = info
        self.lat = lat
        self.lon = lon
        self.distanceFromUser = distance
    }
}
