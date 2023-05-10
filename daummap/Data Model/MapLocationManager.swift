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
    var currentMapPonitArray : [[String]] = []
    var locationManager: CLLocationManager!
    
    //현재 사용자 위치 불러오기 (:까지는 view에서 해야하나..?)
    mutating func loadClotingBinDataFromCurrentLocation(currentLocationLatitude:Double,currentLocationLongitude:Double,locationDataArray:[[String]]) ->[[String]] {
        
        //거리를 담을 배열
        var distanceArray:[[String]] = []
        
        //문자열 가공("\r 제거")
        for clothingBox in locationDataArray {
            let clothingBoxInfo = clothingBox[0]
            let clothingBoxLat = clothingBox[1]
            let clothingBoxLon = clothingBox[2].remove(target: "\r")
            
            currentMapPonitArray.append([clothingBoxInfo,clothingBoxLat,clothingBoxLon])
            
            let currentUserLocation = CLLocation(latitude:currentLocationLatitude,longitude: currentLocationLongitude)
            //CLLocation(la)
            
            //거리 추가(현재위치가 없어서인가..?) -> main으로 넘기기
            
            //let nowDistance = locationManager.location?.distance(from: currentUserLocation)
            
            //let distance = String(Double(nowDistance ?? 10000000))
            
            //distanceArray.append([clothingBoxInfo,clothingBoxLat,clothingBoxLon,distance])
            return currentMapPonitArray
        }
        
        let sortedArray = distanceArray.sorted(by: {Double($0[3]) ?? 9000000 < Double($1[3]) ?? 9000000 }).prefix(10)
        
        let sortedArrayNew = sortedArray.map{$0}
        
        print("sortedArray")
        print(sortedArray)
        for i in 0...9 {
            
            //사용자 가까이의 데이터만 반환 (거리: 1500)
            if let distanceNumber = Double(sortedArray[i][0]) {
                if distanceNumber < 1500 {
                    
                    //배열만 반환하도록..?
                    let poiItem = MTMapPOIItem()
                    poiItem.mapPoint = MTMapPoint(geoCoord: MTMapPointGeo(latitude: Double(sortedArray[i][1])!, longitude: Double(sortedArray[i][2])!))
                    poiItem.itemName = sortedArray[i][3]
                    poiItem.markerType = .redPin
                    
                    //poiItemArray.append(poiItem)
                    print("현재 위치 근처 의류수거함")
                    dump(poiItem.itemName)
                    
                } else {
                    print()
                    return [[]]
                }
                
                
                print("----locationDataArray----")
                //print(currentMapPonitArray)
                
                
                
                
                
                
            }
            
            //전체 CVS에서 데이터 가져오기
            func loadLocationDataFromAllCVS() {
                
            }
            
            
            
            
        }
        return sortedArrayNew
    }
}
