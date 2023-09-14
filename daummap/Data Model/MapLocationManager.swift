//
//  MapLocationManager.swift
//  daummap
//
//  Created by Lyla on 2023/05/09.
//

import Foundation


class MapLocationManager {
    
    
    //문자열 가공("\r 제거")
    func changeStringToClothingBin(from clothinBinStringArray:[[String]]) -> [ClothingBin] {
        var currentMapPonitArray : [ClothingBin] = []
        
        for clothingBox in clothinBinStringArray {
            let clothingBoxInfo = clothingBox[0]
            let clothingBoxLat = clothingBox[1]
            let clothingBoxLon = clothingBox[2].replacingOccurrences(of: "\r", with: "")
            currentMapPonitArray.append(ClothingBin(info: clothingBoxInfo, lat: clothingBoxLat, lon: clothingBoxLon))
        }
        return currentMapPonitArray
    }
}

