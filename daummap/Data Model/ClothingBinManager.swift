//
//  ClothingBinManager.swift
//  daummap
//
//  Created by Lyla on 2023/08/08.
//

import Foundation
import CoreLocation


class ClothingBinManager {
    
    var poiItemArray: [MTMapPOIItem] = []
    
    var clothingBinArray: [ClothingBin] = []
    
    var maplocationManager: MapLocationManager = MapLocationManager()
    
    var locationManager: CLLocationManager = CLLocationManager()
    
    var distanceArray:[ClothingBin] = []
    var distanceArrayTenCloseToUser:[ClothingBin] = []
    
    // 이동
    var poiItemIsOnMap: Bool = false

    //MARK: - loadLoadLocationManager
    func loadLoadLocationManager() {
        
    }
    
    //MARK: - 현재 위치에서 가까운 10개의 데이터 가져오기
    func loadClothingBinCloseCurrentLocation(from cvsArray:[[String]], locationManager: CLLocationManager) -> [ClothingBin] {
        
        self.locationManager = locationManager
        
        var clothingBinArray: [ClothingBin] = []
        
        clothingBinArray = maplocationManager.changeStringToClothingBin(from: cvsArray)
        
        self.locationManager.startUpdatingLocation() // 위치 업데이트 시작
        
        
        // 현재위치와의 거리를 구한다.
        for clothingBin in clothingBinArray {
            let clothingbinCoordinate = CLLocation(latitude: CLLocationDegrees(clothingBin.lat), longitude: CLLocationDegrees(clothingBin.lon))
            let distanceFromCurrentLocationToClothingBin = Double(locationManager.location?.distance(from: clothingbinCoordinate) ?? 99999999)
            
            let currentDistance = distanceFromCurrentLocationToClothingBin
            distanceArray.append(ClothingBin(info: clothingBin.info, lat: clothingBin.lat, lon: clothingBin.lon, distance: currentDistance))
        }
        
        // distanceArray에서 가까운 순으로 10개를 뽑는다.
        // distanceArrayTenCloseToUser에 넣는다.
        distanceArray.sort(by: {$0.distanceFromUser ?? 9999999 < $1.distanceFromUser ?? 9999999})
        if distanceArray.count >= 10 {
            for i in 0...9 {
                distanceArrayTenCloseToUser.append(distanceArray[i])
            }
            return distanceArrayTenCloseToUser
        } else {
            print("Number of distanceArray less than 10.")
            return []
        }
    }
    
    func makeMapPOIItem(with inputArray: [ClothingBin]) -> [MTMapPOIItem] {
        // 사용자 위치에서 20km이내의 의류수거함만 가져올 수 있도록 한다.
        poiItemArray = []
        
        for clothingBin in inputArray {
            if clothingBin.distanceFromUser ?? 999999 < 20000 {
                let poiItem = MTMapPOIItem()
                poiItem.mapPoint = MTMapPoint(geoCoord: MTMapPointGeo(
                    latitude: clothingBin.lat,
                    longitude: clothingBin.lon ))
                poiItem.itemName = clothingBin.info
                poiItem.customImage = UIImage(named: "location")
                poiItem.markerType = .customImage
                poiItemArray.append(poiItem)
            }
            
        }
        return poiItemArray
    }
    
    //MARK: - 1) 

    func makePOIItemsByCurrentLoaction(at poiItem: MTMapPoint) ->  MTMapPOIItem {
        var currentLocationPOIItem = MTMapPOIItem()
        currentLocationPOIItem.itemName = "현재위치"
        currentLocationPOIItem.mapPoint = poiItem
        currentLocationPOIItem.markerType = .yellowPin
        
        return currentLocationPOIItem
    }
    
    // VC: loadClothingBinByDistrict
    func makePOIItemsByDistrict(from districtClothingBinArray: [ClothingBin]) ->  [MTMapPOIItem]  {
        // 배열 비워주기
        poiItemArray = []
        for clothingBin in districtClothingBinArray {
            
            let poiItem = MTMapPOIItem()
            
            poiItem.itemName = clothingBin.info
            poiItem.mapPoint = MTMapPoint(geoCoord: MTMapPointGeo(
                latitude: clothingBin.lat,
                longitude: clothingBin.lon ))
            poiItem.markerType = .redPin
            poiItemArray.append(poiItem)
        }
        return poiItemArray
    }
    
    // VC: loadClothinBinByBound
    func makePOIItemsInUserScreen(from screenClothingBinArray: [ClothingBin], topRightLat: Double, topRightLon: Double, bottomLeftLat: Double, bottomLeftLon: Double) throws -> [MTMapPOIItem] {
        poiItemArray = []

        var screenClotingBinArray: [ClothingBin] = []
        //위도로 비교
        screenClotingBinArray = screenClotingBinArray.filter { $0.lat > bottomLeftLat && $0.lat  < topRightLat}
        //경도로 비교
        screenClotingBinArray = screenClotingBinArray.filter { $0.lon > bottomLeftLon && $0.lon < topRightLon}
        
        if screenClotingBinArray.count == 0 {
            for clothingBin in screenClotingBinArray {
                let poiItem = MTMapPOIItem()
                poiItem.itemName = clothingBin.info
                poiItem.mapPoint = MTMapPoint(geoCoord: MTMapPointGeo(
                    latitude: clothingBin.lat,
                    longitude: clothingBin.lon))
                poiItem.markerType = .redPin
                poiItemArray.append(poiItem)
            
            }
            return poiItemArray
            
        } else {
            throw ClothingBinError.noneClothingBin
        }
        
        
    }
    
}

enum ClothingBinError :Error {
    case noneClothingBin
}
