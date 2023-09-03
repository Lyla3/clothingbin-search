//
//  LocationStore.swift
//  daummap
//
//  Created by Lyla on 2023/08/06.
//

import Foundation

struct CurrentLocationManager {
    
    let DEFAULT_POSITION = MTMapPointGeo(latitude: 37.576568, longitude: 127.029148)

    // MTMapPointGeo로 변환
    func changeMTMapPoint(latitude: Double?, longitude: Double?) -> MTMapPoint {
        if latitude != nil && longitude != nil {
            return MTMapPoint(geoCoord: MTMapPointGeo(latitude: latitude!, longitude: longitude!))
        }
        return  MTMapPoint(geoCoord: DEFAULT_POSITION)
    }
}
