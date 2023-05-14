//
//  MapLocationManager.swift
//  daummap
//
//  Created by Lyla on 2023/05/09.
//

import Foundation
import CoreLocation


struct MapLocationManager {
    
    var locationDataArray : [[String]] = []
    var locationManager: CLLocationManager!
    
    //현재 사용자 위치 불러오기 (:까지는 view에서 해야하나..?)
    func processUnusedStringInLocationArray(locationDataArray:[[String]]) -> [[String]] {
        
        //문자열 가공("\r 제거")
        var currentMapPonitArray : [[String]] = []
        
        for clothingBox in locationDataArray {
            let clothingBoxInfo = clothingBox[0]
            let clothingBoxLat = clothingBox[1]
            let clothingBoxLon = clothingBox[2].remove(target: "\r")
            currentMapPonitArray.append([clothingBoxInfo,clothingBoxLat,clothingBoxLon])
        }
        
        return currentMapPonitArray
    }
}
