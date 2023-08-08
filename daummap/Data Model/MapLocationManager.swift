//
//  MapLocationManager.swift
//  daummap
//
//  Created by Lyla on 2023/05/09.
//

import Foundation


struct MapLocationManager {
    
    var locationDataArray : [[String]] = []
    
    //문자열 가공("\r 제거")
    func processingStringInLocationArray(locationDataArray:[[String]]) -> [[String]] {
        
        var currentMapPonitArray : [[String]] = []
        
        for clothingBox in locationDataArray {
            let clothingBoxInfo = clothingBox[0]
            let clothingBoxLat = clothingBox[1]
            let clothingBoxLon = clothingBox[2].remove(target: "\r")
            currentMapPonitArray.append([clothingBoxInfo,clothingBoxLat,clothingBoxLon])
        }
        
        return currentMapPonitArray
    }
    
    
    func processingStringInLocationArray2(locationDataArray:[[String]]) -> [ClothingBin] {
        
        var currentMapPonitArray : [ClothingBin] = []
        
        for clothingBox in locationDataArray {
            let clothingBoxInfo = clothingBox[0]
            let clothingBoxLat = clothingBox[1]
            let clothingBoxLon = clothingBox[2].remove(target: "\r")
            currentMapPonitArray.append(ClothingBin(info: clothingBoxInfo, lat: clothingBoxLat, lon: clothingBoxLon))
        }
        
        return currentMapPonitArray
    }
    
    
}

