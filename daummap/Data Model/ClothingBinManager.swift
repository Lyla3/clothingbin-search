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
    var currentLocationManager: CurrentLocationManager = CurrentLocationManager()
    
    var locationManager: CLLocationManager = CLLocationManager()
    
    var distanceArray:[ClothingBin] = []
    var distanceArrayTenCloseToUser:[ClothingBin] = []
    
    var clothingBinsFromCSV: [ClothingBin] = []
    
    // 이동
    var poiItemIsOnMap: Bool = false
    
    var previousButtonStatus: ButtonStatus = .none
    var presentButtonStatus: ButtonStatus = .none
    
    var mapCornerCoordinate: CoordinateUserScreen = CoordinateUserScreen()
    
//    var userLocation: MTMapPoint
//    
//    init() {
//        userLocation = currentLocationManager.DEFAULT_POSITION
//    }
    
    

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
            if clothingBin.distanceFromUser ?? 999999 < 200000 {
                let poiItem = MTMapPOIItem()
                poiItem.mapPoint = MTMapPoint(geoCoord: MTMapPointGeo(
                    latitude: clothingBin.lat,
                    longitude: clothingBin.lon ))
                poiItem.itemName = clothingBin.info
                poiItem.customImage = UIImage(named: "location")
                poiItem.markerType = .redPin
                poiItemArray.append(poiItem)
            }
            
        }
        return poiItemArray
    }
    
    //MARK: - 1) 현재위치 makePOIItemsByCurrentLoaction

    func makePOIItemsByCurrentLoaction(at poiItem: MTMapPoint) ->  MTMapPOIItem {
        var currentLocationPOIItem = MTMapPOIItem()
        currentLocationPOIItem.itemName = "현재위치"
        currentLocationPOIItem.mapPoint = poiItem
        currentLocationPOIItem.markerType = .yellowPin
        
        return currentLocationPOIItem
    }
    
    // VC: loadClothingBinByDistrict
    
    //MARK: - 2) 지역 makePOIItemsByDistrict
    func makePOIItemsByDistrict(from districtClothingBinArray: [ClothingBin]) ->  [MTMapPOIItem]  {
        // 배열 비워주기
        poiItemArray = []
        clothingBinsFromCSV = []
        
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
    //MARK: - 3) 현재지도 makePOIItemsInUserScreen
//    func makePOIItemsInUserScreen(from screenClothingBinArray: [ClothingBin], topRightLat: Double, topRightLon: Double, bottomLeftLat: Double, bottomLeftLon: Double) throws -> [MTMapPOIItem] {
//        poiItemArray = []
//
//        var screenClotingBinArray: [ClothingBin] = []
//        //위도로 비교
//        screenClotingBinArray = screenClotingBinArray.filter { $0.lat > bottomLeftLat && $0.lat  < topRightLat}
//        //경도로 비교
//        screenClotingBinArray = screenClotingBinArray.filter { $0.lon > bottomLeftLon && $0.lon < topRightLon}
//
//        if screenClotingBinArray.count == 0 {
//            for clothingBin in screenClotingBinArray {
//                let poiItem = MTMapPOIItem()
//                poiItem.itemName = clothingBin.info
//                poiItem.mapPoint = MTMapPoint(geoCoord: MTMapPointGeo(
//                    latitude: clothingBin.lat,
//                    longitude: clothingBin.lon))
//                poiItem.markerType = .redPin
//                poiItemArray.append(poiItem)
//
//            }
//            return poiItemArray
//
//        } else {
//            throw ClothingBinError.noneClothingBin
//        }
//
//    }
    
    //MARK: - 3) 현재지도 makePOIItemsInUserScreen
    func makePOIItemsInUserScreen() throws -> [MTMapPOIItem] {
        poiItemArray = []

        // 저장된 배열 의류수거함 불러오기
        var screenClotingBinArray: [ClothingBin] = clothingBinArray
        //위도로 비교
        screenClotingBinArray = screenClotingBinArray.filter { $0.lat > mapCornerCoordinate.bottomLeftLat && $0.lat  < mapCornerCoordinate.topRightLat}
        //경도로 비교
        screenClotingBinArray = screenClotingBinArray.filter { $0.lon > mapCornerCoordinate.bottomLeftLon && $0.lon < mapCornerCoordinate.topRightLon }
        
        
        print("screenClotingBinArray의 개수: \(screenClotingBinArray.count)")
        if screenClotingBinArray.count != 0 {
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
    
    // 이전 버튼 vs 현재 눌린 버튼 
//    func checkPressedButtonStatus(pressedButtonStatus: ButtonStatus) -> Bool {
//        //
//        if previousButtonStatus == .none {
//            presentButtonStatus = pressedButtonStatus
//        } else {
//            // 1 - 1,2,3 일때
//            if previousButtonStatus == .currentLocation {
//                presentButtonStatus = pressedButtonStatus
//                // 현재위치 버튼이 눌린 경우
//                // 각 버튼에 맞는 내용 실행
//
//                switch pressedButtonStatus {
//                case .currentLocation:
//
//                }
//                // 2,3일때
//            } else {
//                // 2,3 - 1인가?
//                if pressedButtonStatus == .currentLocation {
//                    // 현재위치로만 간다(불러오기 X)
//                    //
//                } else {
//
//                }
//            }
//        }
//
//
//
//
//
//        return false
//    }
    
    func checkButtonFunction(pressedButtonStatus: ButtonStatus) -> ExecuteButton {
        if poiItemIsOnMap && pressedButtonStatus == .currentLocation {
           // 현재위치로만 이동
            presentButtonStatus = pressedButtonStatus
            poiItemIsOnMap = false
            previousButtonStatus = presentButtonStatus
            return .changeMapCenter
        } else if pressedButtonStatus == .currentLocation {
            switch pressedButtonStatus {
            case .currentLocation:
                return .currentLocation
            case .map:
                poiItemIsOnMap = true
                return .map
            case .region:
                poiItemIsOnMap = true
                return .region
            default:
                poiItemIsOnMap = true
                return .currentLocation
            }
        } else {
            switch pressedButtonStatus {
            case .currentLocation:
                return .currentLocation
            case .map:
                poiItemIsOnMap = true
                return .map
            case .region:
                poiItemIsOnMap = true
                return .region
            default:
                poiItemIsOnMap = true
                return .currentLocation
            }
        }
    }
    
    func executeButtonFunction(buttonStatus: ExecuteButton) throws -> [MTMapPOIItem] {
        switch buttonStatus {
        case .currentLocation:
            print("buttonStatus .currentLocation")
            let poiItems = makePOIItemsByDistrict(from: clothingBinsFromCSV)
            
            //
            //let poiItems = makePOIItemsByCurrentLoaction(at: <#T##MTMapPoint#>)
            clearClothingBinCSV()
            return poiItems
        case .region:
            print("buttonStatus .region")
            let poiItems = makePOIItemsByDistrict(from: clothingBinsFromCSV)
            clearClothingBinCSV()
            return poiItems
        case .map:
            print("buttonStatus .map")
            //makePOIItemsInUserScreen(from: clothingBinsFromCSV, topRightLat: <#T##Double#>, topRightLon: <#T##Double#>, bottomLeftLat: <#T##Double#>, bottomLeftLon: <#T##Double#>)
            do {
                let poiItems = try makePOIItemsInUserScreen()
                clearClothingBinCSV()
                return poiItems
            } catch ClothingBinError.noneClothingBin {
                print("ClothingBinError.noneClothingBin")
                throw ClothingBinError.noneClothingBin
            } catch {
                print("Error: processing loadClothinBinByBound")
                return poiItemArray
            }
            //let poiItems = makePOIItemsByDistrict(from: clothingBinsFromCSV)
           
            // return poiItems
        case .changeMapCenter:
            print("buttonStatus .changeMapCenter")
            return makePOIItemsByDistrict(from: clothingBinsFromCSV)
        }
    }
    
    func clearClothingBinCSV() {
        clothingBinsFromCSV = []
    }
}

enum ClothingBinError :Error {
    case noneClothingBin
}
