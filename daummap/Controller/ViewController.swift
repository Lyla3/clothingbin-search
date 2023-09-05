//
//  ViewController.swift
//  daummap
//
//  Created by Lyla on 2022/10/04.
//

import UIKit
import CoreLocation
import Foundation

class ViewController: UIViewController,MTMapViewDelegate,CLLocationManagerDelegate, MTMapReverseGeoCoderDelegate {
    //MARK: - Properties
    
    public var geocoder: MTMapReverseGeoCoder!
    var mapView:MTMapView!
    var locationManager: CLLocationManager!
    
    //현재 위경도
    var currentLocationLatitude: Double?
    var currentLocationLongitude: Double?
    var currentLocationButtonPressed: Bool = false
    var poiItemArray : [MTMapPOIItem] = []
    let datacore = DataCore()
    var pickerViewcityListNew : [String] = []
    var selectedCity : Region = .Gangnam
    
    // Manager로 이동(삭제 예정)
    var poiItemIsOnMap: Bool = false
    
    var currentLocationCoordinate = CurrentLocationCoordinate()
    var currentlocationManager = CurrentLocationManager()
    var clothingBinManager: ClothingBinManager = ClothingBinManager()
    
    // 주소 검색 데이터
    var address: String?
    var currentRow : Int = 0
    
    // 현재 위치 button이 몇번 눌렸는지 감지
    var currentLocationButtonTapCount : Int = 0
    
    
    
    //mapLocationManager (Model)
    var mapLocationManager = MapLocationManager()
    
    //엑셀 파일에서 불러온 의류수거함 위치 데이터 배열
    var clothingBinLocationArray : [[String]] = []
    
    // activityIndicator
    let activityIndicator = UIActivityIndicatorView(style: .large)
    
    
    
    //MARK: - UISetting
    
    //초기 안내 창 뷰
    private let guideView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.3)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    //초기 안내 창 뷰 - nextButton
    private let guideViewNextButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1)
        button.setTitle("다음", for: .normal)
        
        button.layer.cornerRadius = 10
        button.layer.shadowRadius = 10
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(closeGuideView), for: .touchUpInside)
        return button
    }()
    
    // 안내창 예시이미지 - 현재 지도 검색
    private let guideViewImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = .red
        imageView.image = UIImage(named: "guidemap_1")
        imageView.contentMode = .scaleAspectFit
        //imageView.heightAnchor = 100
        return imageView
    }()
    
    //현위치 버튼
    private let currentLocationButton: UIButton = {
        let currentLocationbutton = UIButton()
        let imageConfig = UIImage.SymbolConfiguration(pointSize: 30, weight: .light)
        currentLocationbutton.setImage(UIImage(named: "currentLoction.png"), for: .normal)
        currentLocationbutton.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1)
        currentLocationbutton.setTitleColor(.black, for: .normal)
        currentLocationbutton.translatesAutoresizingMaskIntoConstraints = false
        currentLocationbutton.layer.cornerRadius = 4
        currentLocationbutton.layer.shadowColor = UIColor.gray.cgColor
        currentLocationbutton.layer.shadowOpacity = 0.3
        currentLocationbutton.layer.shadowOffset = CGSize.zero
        currentLocationbutton.layer.shadowRadius = 6
        return currentLocationbutton
    }()
    
    //현재 지도 검색 버튼
    private let currentLocationSearchMapButton: UIButton = {
        let button = UIButton(type: .system)
        var config = UIButton.Configuration.filled()
        config.cornerStyle = .capsule
        
        //currentMapbutton
        let imageConfig = UIImage.SymbolConfiguration(pointSize: 30, weight: .light)
        button.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1)
        button.setTitleColor(.black, for: .normal)
        button.setTitle("현재 지도 검색", for: .normal)
        button.configuration?.cornerStyle = .capsule
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 14
        button.layer.shadowColor = UIColor.gray.cgColor
        button.layer.shadowOpacity = 0.3
        button.layer.shadowOffset = CGSize.zero
        button.layer.shadowRadius = 6
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    //주소검색 버튼
    //    private let searchAddressButton: UIButton = {
    //        let searchAddressbutton = UIButton()
    //        let imageConfig = UIImage.SymbolConfiguration(pointSize: 30, weight: .light)
    //        searchAddressbutton.setImage(UIImage(systemName: "magnifyingglass"), for: .normal)
    //        searchAddressbutton.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1)
    //        searchAddressbutton.setTitleColor(.black, for: .normal)
    //        searchAddressbutton.tintColor = .black
    //        searchAddressbutton.layer.borderColor = UIColor.black.cgColor
    //        searchAddressbutton.layer.borderWidth = 1
    //        searchAddressbutton.translatesAutoresizingMaskIntoConstraints = false
    //        searchAddressbutton.layer.cornerRadius = 2
    //        searchAddressbutton.layer.shadowColor = UIColor.gray.cgColor
    //        searchAddressbutton.layer.shadowOpacity = 0.3
    //        searchAddressbutton.layer.shadowOffset = CGSize.zero
    //        searchAddressbutton.layer.shadowRadius = 6
    //        searchAddressbutton.translatesAutoresizingMaskIntoConstraints = false
    //        return searchAddressbutton
    //    }()
    
    //지역 선택 버튼
    private let regionButton: UITextField = {
        let button = UITextField()
        let imageConfig = UIImage.SymbolConfiguration(pointSize: 30, weight: .light)
        button.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1)
        button.minimumFontSize = 20
        button.textColor = UIColor.black
        button.translatesAutoresizingMaskIntoConstraints = false
        button.text = "지역선택"
        button.textAlignment = .center
        button.tintColor = UIColor.clear
        //모서리 및 그림자
        button.layer.cornerRadius = 5
        button.layer.shadowColor = UIColor.gray.cgColor
        button.layer.shadowOpacity = 0.3
        button.layer.shadowOffset = CGSize.zero
        button.layer.shadowRadius = 6
        return button
    }()
    
    //안내 알림창 mapView 안내창
    private let helpTextView : UITextField = {
        let helpTextView = UITextField()
        let imageConfig = UIImage.SymbolConfiguration(pointSize: 30, weight: .light)
        helpTextView.tag = 100
        helpTextView.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1)
        helpTextView.minimumFontSize = 20
        helpTextView.textColor = UIColor.white
        helpTextView.backgroundColor = UIColor.darkGray
        helpTextView.alpha = 0.8
        helpTextView.translatesAutoresizingMaskIntoConstraints = false
        helpTextView.isUserInteractionEnabled = false
        helpTextView.text = "지도를 확대해주세요"
        helpTextView.textAlignment = .center
        helpTextView.layer.cornerRadius = 20
        return helpTextView
    }()
    
    
    //마커 커스텀 뷰 생성
    private lazy var makerInfoView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.darkGray
        return view
    }()
    
    //    activityIndicator 생성
    private let loadingView: LoadingView = {
        let view = LoadingView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView = MTMapView(frame: self.view.frame)
        mapView.delegate = self
        mapView.baseMapType = .standard
        makeUI()
        
        pickerViewcityListNew =
        Region.allCases.map{$0.rawValue}
        
        self.loadLocation()
        
        let coor = locationManager.location?.coordinate
        if let currentLocationLat = coor?.latitude , let currentLocationLon = coor?.longitude {
            mapView.setMapCenter(MTMapPoint(geoCoord: MTMapPointGeo(latitude: currentLocationLat, longitude: currentLocationLon)), animated: true)
        }
    }
    
    
    
    
    //MARK: - Actions
    func loadLocation() {
        print("")
        print("===============================")
        print("[ViewController >> testMain() :: loadLocation 함수 수행]")
        print("===============================")
        print("")
        
        self.locationManager = CLLocationManager.init() // locationManager 초기화
        self.locationManager.delegate = self // 델리게이트 넣어줌
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest // 거리 정확도 설정
        self.locationManager.requestAlwaysAuthorization() // 위치 권한 설정 값을 받아옵니다
        self.locationManager.startUpdatingLocation() // 위치 업데이트 시작
    }
    
    // MARK: - [위치 서비스에 대한 권한 확인 실시]
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedAlways {
            print("")
            print("===============================")
            print("[ViewController > locationManager() : 위치 사용 권한 항상 허용]")
            print("===============================")
            print("")
        }
        if status == .authorizedWhenInUse {
            print("")
            print("===============================")
            print("[ViewController > locationManager() : 위치 사용 권한 앱 사용 시 허용]")
            print("===============================")
            print("")
        }
        if status == .denied {
            print("")
            print("===============================")
            print("[ViewController > locationManager() : 위치 사용 권한 거부]")
            print("===============================")
            print("")
        }
        if status == .restricted || status == .notDetermined {
            print("")
            print("===============================")
            print("[ViewController > locationManager() : 위치 사용 권한 대기 상태]")
            print("===============================")
            print("")
        }
    }
    
    // MARK: - [위치 정보 지속적 업데이트]
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = manager.location as CLLocation? {
            if location.coordinate.latitude == 0 {
                return
            }
            
            locationManager.stopUpdatingLocation()
            
            // do stuff with location
            
            if let location = locations.first {
                // [위치 정보가 nil 이 아닌 경우]
                print("")
                print("===============================")
                print("[ViewController > didUpdateLocations() : 위치 정보 확인 실시]")
                print("[위도 : \(location.coordinate.latitude)]")
                print("[경도 : \(location.coordinate.longitude)]")
                print("===============================")
                print("")
                currentLocationCoordinate.latitude = location.coordinate.latitude
                currentLocationCoordinate.longitude = location.coordinate.longitude
            }
        }
        
    }
    
    
    
    
    
    // MARK: - [위도, 경도 받아오기 에러가 발생한 경우]
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("")
        print("===============================")
        print("[ViewController > didFailWithError() : 위치 정보 확인 에러]")
        print("[error : \(error)]")
        print("[localizedDescription : \(error.localizedDescription)]")
        print("===============================")
        print("")
    }
    //MARK: - mapLongTap
    
    // 길게 지도 눌리면 의류수거함 추가됨
    func mapView(_ mapView: MTMapView!, longPressOn mapPoint: MTMapPoint!) {
        print("길게 화면이 눌렸습니다 - longtap")
        print("Point: \(String(describing: mapPoint))")
        
        // 안내: 의류수거함 추가
        let alert = UIAlertController(title: "이 위치에 의류수거함을 추가하시겠습니까?", message: "", preferredStyle: UIAlertController.Style.alert)
        let cancle = UIAlertAction(title: "취소", style: .default ,handler: nil)
        
        // 확인 버튼(:버튼 추가)
        let ok = UIAlertAction(title: "확인", style: .destructive, handler: { action in
            let poitemLongtapped = MTMapPOIItem()
            poitemLongtapped.itemName = "New"
            poitemLongtapped.mapPoint = mapPoint
            poitemLongtapped.markerType = .bluePin
            mapView.addPOIItems([poitemLongtapped])
        })
        
        // 버튼을 알림창에 추가해줌
        alert.addAction(cancle)
        alert.addAction(ok)
        present(alert,animated: true, completion: nil)
    }
    
    
    
    //MARK: - 현재 위치 버튼 실행시
    @objc func currentLocationButtonTapped(sender: UIButton) {
        self.loadingView.isLoading = true
        print("현재위치 버튼이 눌렸습니다. ")
        // ❤️
        print("::checkButtonStatus::")
        print(clothingBinManager.checkButtonFunction(pressedButtonStatus: .currentLocation))
        
        // locationManager 상태에 따라 실행되는 함수가 달라짐
        switch locationManager.authorizationStatus {
        case .denied, .notDetermined, .restricted:
            self.alertCurrentLocation()
            
        case .authorizedAlways, .authorizedWhenInUse:
            
            guard let currentLocationLatitude = currentLocationCoordinate.latitude,
                  let currentLocationLongitude = currentLocationCoordinate.longitude
            else {
                alertCurrentLocation()
                return
            }
            
//            let currentLocationMTMapPoint = MTMapPoint(geoCoord: MTMapPointGeo(latitude: currentLocationLatitude, longitude: currentLocationLongitude)) ?? DEFAULT_POSITION
            
            clothingBinManager.locationManager = locationManager
            
            print("poiItemIsOnMap:\(poiItemIsOnMap)")
            
            
            // 버튼 타입 지정
            let buttonType = clothingBinManager.checkButtonFunction(pressedButtonStatus: .currentLocation)
            
            if buttonType == .currentLocation || buttonType == .changeMapCenter {
                mapView.setMapCenter(MTMapPoint(geoCoord: MTMapPointGeo(latitude: currentLocationLatitude, longitude: currentLocationLongitude)),zoomLevel: 2, animated: true)
            }
            
            // 현재 위치 보내기
            clothingBinManager.userLocation = MTMapPoint(geoCoord: MTMapPointGeo(latitude: currentLocationLatitude, longitude: currentLocationLongitude))
            
            self.getSomeData { [weak self] in
                self?.loadDataFromAllCVS()
//                let allClothingBinArray =  self?.mapLocationManager.changeStringToClothingBin(from: self?.clothingBinLocationArray ?? [[""]])
//                self?.clothingBinManager.clothingBinArray = allClothingBinArray
                
                guard let allClothingBinArray = self?.mapLocationManager.changeStringToClothingBin(from: self?.clothingBinLocationArray ?? [[""]] ) else {
                    return print("allClothingBinArray is nil")
                }
                self?.clothingBinManager.clothingBinArray = allClothingBinArray
                
                do{
                    let poiItems = try self?.clothingBinManager.executeButtonFunction(buttonStatus: buttonType)
                    self?.mapView.addPOIItems(poiItems)
                } catch ClothingBinError.noneClothingBin {
                    print("currentLocationButtonTapped - ClothingBinError.noneClothingBin")
                } catch {
                    print("Error: processing loadClothinBinByBound")
                }
                self?.clearArray()
              self?.loadingView.isLoading = false
            }
            // 의류수거함 업데이트

            
            //------------------
            // 지도 지역구 버튼이 눌린 경우 한번 누르면 현재 위치만을 받아오도록 함
            //            if (!poiItemIsOnMap && currentLocationButtonTapCount == 0) || ( currentLocationButtonTapCount > 0)  {
            //                currentLocationButtonTapCount = 0
            //                removePOIItemsData()
            //
            //                // 현재 위치를 지도의 중앙으로 맞춤 : mapView
            //                mapView.setMapCenter(MTMapPoint(geoCoord: MTMapPointGeo(latitude: currentLocationLatitude, longitude: currentLocationLongitude)), animated: true)
            //
            //                // 사용자의 현재위치 MTMapPOIItem 형식으로 반환
            //                let currentLocationPOIItem = clothingBinManager.makePOIItemsByCurrentLoaction(at: currentLocationMTMapPoint)
            //
            //
            //                // 현재위치 추가 : mapView
            //                mapView.add(currentLocationPOIItem)
            //                mapView.setMapCenter(MTMapPoint(geoCoord: MTMapPointGeo(latitude: currentLocationLatitude, longitude: currentLocationLongitude)), animated: true)
            //
            //                // CVSdataArray 업데이트 -> 전체 의류수거함
            //                loadDataFromAllCVS()
            //
            //                // 업데이트된 CVSdataArray를 바탕으로 가까이 있는 의류수거함 데이터를 불러온다.
            //                loadClothingBinByCurrentLocation(from: clothingBinLocationArray)
            //                clearArray()
            //            } else {
            //                currentLocationButtonTapCount += 1
            //
            //                // 사용자의 현재위치 MTMapPOIItem 형식으로 반환
            //                let currentLocationPOIItem = clothingBinManager.makePOIItemsByCurrentLoaction(at: currentLocationMTMapPoint)
            //
            //
            //                // 현재위치 추가
            //                mapView.add(currentLocationPOIItem)
            //
            //                mapView.setMapCenter(currentlocationManager.changeMTMapPoint(latitude: currentLocationCoordinate.latitude, longitude: currentLocationCoordinate.longitude), zoomLevel: 2, animated: true)
            //            }
        @unknown default:
            self.alertCurrentLocation()
        }
    }
    
    //현재 위치 설정 알림
    func alertCurrentLocation() {
        print("현재 위치를 활성화 해주세요")
        let alert = UIAlertController(title: "위치 데이터 권한 설정", message: "'설정>의류수거함 검색>위치'에서 현재 위치 데이터 이용을 허용해주세요.", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "확인", style: .default){ _ in
            //설정 - 위치데이터 권한설정 창 오픈
            UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
        }
        alert.addAction(okAction)
        present(alert,animated: false)
        
    }
    
    // 현재 지도 검색
    @objc func currentMapButtonTapped(sender: UIButton) {
        //        removePOIItemsData()
        //
        //        print("현재 지도 검색 검색 버튼이 눌렸습니다.")
        //        // ❤️
        //        print("::checkButtonStatus::")
        //        print(clothingBinManager.checkButtonFunction(pressedButtonStatus: .map))
        //
        //        loadDataFromAllCVS()
        //
        //        //let mapCenterPointByMTMapPoint = mapView.mapCenterPoint!
        //
        //        if checkMapViewLevel() {
        //            loadClothingBinByBound()
        //        }
        
        loadingView.isLoading = true
        self.getSomeData { [weak self] in
            
            self?.removePOIItemsData()
            
            print("현재 지도 검색 검색 버튼이 눌렸습니다.")
            // ❤️
            print("::checkButtonStatus::")
            print(self?.clothingBinManager.checkButtonFunction(pressedButtonStatus: .map))
            
            self?.loadDataFromAllCVS()
            
            //let mapCenterPointByMTMapPoint = mapView.mapCenterPoint!
            
            if ((self?.checkMapViewLevel()) != nil) {
                self?.loadClothingBinByBound()
            }
            self?.loadingView.isLoading = false
            print("loading")
        }
        //        self.getSomeData { [weak self] in
        //
        //          self?.loadingView.isLoading = false
        //        }
        
    }
    
    //searchAddressButton 눌릴 시 실행되는 함수
    //    @objc func searchAddressButtonTapped(sender: UIButton) {
    //        print("::searchAddressButtonTapped::")
    //
    //        let vc = AddressSearchViewController()
    //        let storyboardName = vc.storyboardName
    //        let storyboardID = vc.storyboardID
    //
    //        let storyboard = UIStoryboard(name: storyboardName, bundle: Bundle.main)
    //        let viewController = storyboard.instantiateViewController(identifier: storyboardID)
    //        vc.modalPresentationStyle = UIModalPresentationStyle.fullScreen
    //
    //        present(viewController, animated: true)
    //    }
    //
    
    @objc func locationSelectButtonTapped(sender: UIButton) {
        //print("지역선택 버튼이 눌렸습니다")
        //실행 X
    }
    
    @objc func closeGuideView() {
        // guideViewNextButton 버튼이 눌렸을 때 실행된다.
        guideView.removeFromSuperview()
        self.guideView.removeFromSuperview()
        
    }
    
    
    //MARK: - 엑셀 파일 파싱 함수
    private func parseCSVAt(url:URL) {
        do {
            let data = try Data(contentsOf: url)
            let dataEncoded = String(data: data, encoding: .utf8)
            
            if let dataArr = dataEncoded?.components(separatedBy: "\n").map({$0.components(separatedBy: ",")}) {
                for item in dataArr{
                    clothingBinLocationArray.append(item)
                }
            }
        } catch {
            print("Error reading CVS file.")
        }
    }
    
    //MARK: - CVS 데이터 로드 - csv파일을 선택해서 경로로 지정
    private func loadDataFromCVSAt(resource:String) {
        let path = Bundle.main.path(forResource: resource, ofType: "csv")!
        parseCSVAt(url: URL(fileURLWithPath: path))
    }
    
    
    //MARK: - CVS 전체 파일 데이터 로드 - 전체 csv파일을 경로로 지정
    private func loadDataFromAllCVS() {
        for resource in Region.allCases {
            let path = Bundle.main.path(forResource: resource.getFileName(), ofType: "csv") ?? "\(Region.Gangnam.getFileName())"
            print("path: \(path)")
            parseCSVAt(url: URL(fileURLWithPath: path))
        }
    }
    
    //MARK: - 1) 사용자 현재위치 ->
    private func loadClothingBinByCurrentLocation(from cvsArray:[[String]]) {
        let clotingbinDataArray =  clothingBinManager.loadClothingBinCloseCurrentLocation(from: cvsArray, locationManager: locationManager)
        
        // poiItemArray에 POIItem 업데이트
        poiItemArray = clothingBinManager.makeMapPOIItem(with: clotingbinDataArray)
        
        let poiItemArrayInclothingBinManager = clothingBinManager.makeMapPOIItem(with: clotingbinDataArray)
        
        if poiItemArrayInclothingBinManager.isEmpty == true {
            helpTextView.text = "현재 위치에서 가까운 의류수거함이 없습니다."
            helpTextView.isHidden = false
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
                self.helpTextView.isHidden = true
            }
        } else {
            mapView.addPOIItems(poiItemArrayInclothingBinManager)
            mapView.fitAreaToShowAllPOIItems()
        }
        clearArray()
        
        
        //        let buttonType = clothingBinManager.checkButtonFunction(pressedButtonStatus: .currentLocation)
        //
        //        let clotingbinDataArray =  clothingBinManager.loadClothingBinCloseCurrentLocation(from: cvsArray, locationManager: locationManager)
        //
        //        // changeStringToClothingBin
        //        let allClothingBinArray =  mapLocationManager.changeStringToClothingBin(from: clothingBinLocationArray)
        //
        //        do {
        //            let poiItems = try clothingBinManager.executeButtonFunction(buttonStatus: buttonType)
        //            mapView.addPOIItems(poiItems)
        //        } catch ClothingBinError.noneClothingBin {
        //            print("loadClothingBinByCurrentLocation - ClothingBinError.noneClothingBin")
        //        }  catch {
        //            print("Error: processing loadClothingBinByCurrentLocation")
        //        }
        //        clearArray()
        
        // poiItemArray에 POIItem 업데이트
        // poiItemArray = clothingBinManager.makeMapPOIItem(with: clotingbinDataArray)
        //
        //        let poiItemArrayInclothingBinManager = clothingBinManager.makeMapPOIItem(with: clotingbinDataArray)
        //
        //        if poiItemArrayInclothingBinManager.isEmpty == true {
        //            helpTextView.text = "현재 위치에서 가까운 의류수거함이 없습니다."
        //            helpTextView.isHidden = false
        //            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
        //                self.helpTextView.isHidden = true
        //            }
        //        } else {
        //            mapView.addPOIItems(poiItemArrayInclothingBinManager)
        //            mapView.fitAreaToShowAllPOIItems()
        //        }
        //        clearArray()
    }
    //MARK: - 2) 유저 화면 상 -> 의류수거함
    func loadClothingBinByBound() {
        //        let allClothingBinArray = mapLocationManager.changeStringToClothingBin(from: clothingBinLocationArray)
        
        //사용자 화면의 끝점의 좌표
        let bottomLeftLat = mapView.mapBounds.bottomLeft.mapPointGeo().latitude
        let topRightLat = mapView.mapBounds.topRight.mapPointGeo().latitude
        let bottomLeftLon = mapView.mapBounds.bottomLeft.mapPointGeo().longitude
        let topRightLon = mapView.mapBounds.topRight.mapPointGeo().longitude
        //
        //        do {
        //            let clothingArrayByBound = try clothingBinManager.makePOIItemsInUserScreen(from: allClothingBinArray, topRightLat: topRightLat, topRightLon: topRightLon, bottomLeftLat: bottomLeftLat, bottomLeftLon: bottomLeftLon)
        //
        //            self.helpTextView.isHidden = true
        //            mapView.addPOIItems(clothingArrayByBound)
        //            clearArray()
        //
        //            //clothingBinManager.clothingBinsFromCSV = districtClothingBinArray
        //            let mapClothingBinArray =  mapLocationManager.changeStringToClothingBin(from: clothingBinLocationArray)
        //
        //            clothingBinManager.clothingBinsFromCSV = mapClothingBinArray
        //
        //            clothingBinManager.mapCornerCoordinate =
        //            CoordinateUserScreen(
        //                bottomLeftLat: bottomLeftLat,
        //                topRightLat: topRightLat,
        //                bottomLeftLon: bottomLeftLon,
        //                topRightLon: topRightLon )
        //
        //
        //        } catch ClothingBinError.noneClothingBin {
        //            helpTextView.text = "현 위치에 등록된 의류수거함이 없습니다."
        //            helpTextView.isHidden = false
        //            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
        //                self.helpTextView.isHidden = true
        //            }
        //        }  catch {
        //            print("Error: processing loadClothinBinByBound")
        //        }
        
        let buttonType = clothingBinManager.checkButtonFunction(pressedButtonStatus: .map)
        
        // changeStringToClothingBin
        //        let districtClothingBinArray = mapLocationManager.changeStringToClothingBin(from: clothingBinLocationArray)
        
        let allClothingBinArray = mapLocationManager.changeStringToClothingBin(from: clothingBinLocationArray)
        
        clothingBinManager.clothingBinArray = allClothingBinArray
        clothingBinManager.mapCornerCoordinate = CoordinateUserScreen(
            bottomLeftLat: bottomLeftLat,
            topRightLat: topRightLat,
            bottomLeftLon: bottomLeftLon,
            topRightLon: topRightLon)
        
        // checkButtonFunction에서 계산된 버튼을 실행한다.
        do {
            let poiItems = try clothingBinManager.executeButtonFunction(buttonStatus: buttonType)
            mapView.addPOIItems(poiItems)
        } catch ClothingBinError.noneClothingBin {
            helpTextView.text = "현 위치에 등록된 의류수거함이 없습니다."
            helpTextView.isHidden = false
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
                self.helpTextView.isHidden = true
            }
        }  catch {
            print("Error: processing loadClothinBinByBound")
        }
        clearArray()
        
    }
    
    func checkMapViewLevel() -> Bool{
        switch mapView.zoomLevel {
        case 0...2:
            print("\(mapView.zoomLevel)zoomLevel")
            return true
        case 3..<15:
            // 지도를 확대해주세요.(알림창 띄움)
            helpTextView.text = "지도를 확대해 주세요."
            helpTextView.isHidden = false
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {                    self.helpTextView.isHidden = true
            }
            return false
        default:
            print("\(mapView.zoomLevel)zoomLevel")
            return false
        }
    }
    
    //전역변수 초기화
    func clearArray() {
        poiItemArray = []
        clothingBinLocationArray = []
        clothingBinLocationArray = []
    }
    //MARK: - 3) 지역 선택 -> 의류수거함
    
    //지역 선택 버튼 눌림
    //데이터를 cvs에서 불러와서 poiItem의 배열에 담아 이를 mapView에 띄움. (:UI 지역구 선택시 사용)
    private func loadClothingBinByDistrict() {
        removePOIItemsData()
        buttonSelectUnable()
        mapView.removeAllPOIItems()
        // 타입 변환: [[Sting]] -> [ClothingBin]
        let buttonType = clothingBinManager.checkButtonFunction(pressedButtonStatus: .region)
        
        // changeStringToClothingBin
        let districtClothingBinArray =  mapLocationManager.changeStringToClothingBin(from: clothingBinLocationArray)
        
        clothingBinManager.clothingBinsFromCSV = districtClothingBinArray
        
        // checkButtonFunction에서 계산된 버튼을 실행한다.
        do { let poiItems = try clothingBinManager.executeButtonFunction(buttonStatus: buttonType)
            
            mapView.addPOIItems(poiItems)
        } catch ClothingBinError.noneClothingBin {
            print("loadClothingBinByDistrict: ClothingBinError.noneClothingBin")
        }  catch {
            print("Error: processing loadClothinBinByBound")
        }
        clearArray()
        
        buttonSelectAble()
    }
    
    func removePOIItemsData() {
        mapView.removeAllPOIItems()
    }
    
    //MARK: - PickerView, UI 설정
    func createPickerView() {
        let pickerView = UIPickerView()
        pickerView.delegate = self
        
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        let btnDone = UIBarButtonItem(title: "확인", style: .done, target: self, action: #selector(onPickDone))
        let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let btnCancel = UIBarButtonItem(title: "취소", style: .done, target: self, action: #selector(pickerViewResign))
        toolbar.setItems([btnCancel , space , btnDone], animated: true)
        toolbar.isUserInteractionEnabled = true
        
        //텍스트필드 입력 수단 연결
        regionButton.inputView = pickerView
        regionButton.inputAccessoryView = toolbar
    }
    
    
    //MARK: - PickerView 확인 버튼
    @objc func onPickDone() {
        // 확인 눌렀을 때 액션 정의 -> 아래 코드에서는 라벨 텍스트 업데이트
        // ❤️
        getSomeData {
            
        }
        regionButton.text = "\(selectedCity.rawValue)"
        UIPickerToCVS(resourceFileName:selectedCity.getFileName())
        regionButton.resignFirstResponder()
    }
    
    func UIPickerToCVS (resourceFileName:String) {
        print("activityIndicatorStartAction")
        // 로딩 중 구현
        self.loadingView.isLoading = true
        self.getSomeData { [weak self] in
            self?.loadDataFromCVSAt(resource: resourceFileName)
            if self?.clothingBinLocationArray.count != 0 {
                self?.loadClothingBinByDistrict()
                self?.mapView.fitAreaToShowAllPOIItems()
            }
          self?.loadingView.isLoading = false
        }
//        loadDataFromCVSAt(resource: resourceFileName)
//        if clothingBinLocationArray.count != 0 {
//            loadClothingBinByDistrict()
//            mapView.fitAreaToShowAllPOIItems()
//        }
    }
    
    @objc func pickerViewResign() {
        regionButton.resignFirstResponder() /// 피커뷰 내림
    }
    
    // 로딩 뷰 실행
    private func getSomeData(completion: @escaping () -> ()) {
        DispatchQueue.main.async {
            completion()
        }
    }
}



extension ViewController: UITextFieldDelegate,UIPickerViewDelegate,UIPickerViewDataSource{
    
    //MARK: - UI 설정
    func makeUI(){
        createPickerView()
        self.view.addSubview(mapView)
        self.mapView.addSubview(self.loadingView)
        //loadingView.addSubview(activityIndicator)
        
        self.view.addSubview(currentLocationButton)
        // self.view.addSubview(searchAddressButton)
        self.view.addSubview(currentLocationSearchMapButton)
        self.view.addSubview(regionButton)
        self.view.addSubview(helpTextView)
        self.view.addSubview(guideView)
        self.guideView.addSubview(guideViewNextButton)
        self.guideView.addSubview(guideViewImageView)
        //self.view.addSubview(guideViewImageView)
        
        
        helpTextView.isHidden = true
        
        // 현재 위치 버튼 눌림
        currentLocationButton.addTarget(self, action: #selector(currentLocationButtonTapped), for: .touchUpInside)
        
        currentLocationSearchMapButton.addTarget(self, action: #selector(currentMapButtonTapped), for: .touchUpInside)
        
        //searchAddressButton 버튼 눌릴 시
        // searchAddressButton.addTarget(self, action: #selector(searchAddressButtonTapped), for: .touchUpInside)
        
        //지역선택 버튼 눌리면 locationSelectButtonTapped 실행, pickerView가 실질적으로 실행
        regionButton.addTarget(self, action: #selector(locationSelectButtonTapped), for: .touchUpInside)
        mapView.setZoomLevel(2, animated: false)
        
        
        //지역선택 버튼 레이아웃
        NSLayoutConstraint.activate([
            self.regionButton.topAnchor.constraint(equalTo: self.view.topAnchor, constant:750),
            self.regionButton.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 10),
            self.regionButton.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -10),
            self.regionButton.heightAnchor.constraint(equalToConstant: 40)
        ])
        
        //안내 알림창 버튼 레이아웃
        NSLayoutConstraint.activate([
            self.helpTextView.topAnchor.constraint(equalTo: self.view.topAnchor, constant:600),
            self.helpTextView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 50),
            self.helpTextView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -50),
            self.helpTextView.heightAnchor.constraint(equalToConstant: 60)
        ])
        
        
        //현재위치 버튼 레이아웃
        NSLayoutConstraint.activate([
            self.currentLocationButton.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 100),
            self.currentLocationButton.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 328),
            self.currentLocationButton.widthAnchor.constraint(equalToConstant: 32),
            self.currentLocationButton.heightAnchor.constraint(equalToConstant: 32)
        ])
        
        //주소검색 버튼 레이아웃
        //        NSLayoutConstraint.activate([
        //            self.searchAddressButton.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 150),
        //            self.searchAddressButton.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 328),
        //            self.searchAddressButton.widthAnchor.constraint(equalToConstant: 32),
        //            self.searchAddressButton.heightAnchor.constraint(equalToConstant: 32)
        //        ])
        
        //현재지도 검색 버튼 레이아웃
        NSLayoutConstraint.activate([
            self.currentLocationSearchMapButton.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 70),
            self.currentLocationSearchMapButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            self.currentLocationSearchMapButton.widthAnchor.constraint(equalToConstant: 95),
            self.currentLocationSearchMapButton.heightAnchor.constraint(equalToConstant: 28)
        ])
        
        //초기 안내 뷰 레이아웃
        NSLayoutConstraint.activate([
            self.guideView.topAnchor.constraint(equalTo: self.view.topAnchor),
            self.guideView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            self.guideView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.guideView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor)
        ])
        
        //안내 뷰 버튼 레이아웃
        NSLayoutConstraint.activate([
            self.guideViewNextButton.bottomAnchor.constraint(equalTo: self.guideView.bottomAnchor, constant: -100 ),
            self.guideViewNextButton.centerXAnchor.constraint(equalTo: self.guideView.centerXAnchor),
            self.guideViewNextButton.widthAnchor.constraint(equalToConstant: 50)
        ])
        
        // 예시이미지 레이아웃
        NSLayoutConstraint.activate([
            self.guideViewImageView.bottomAnchor.constraint(equalTo: self.guideView.bottomAnchor, constant: -200 ),
            self.guideViewImageView.centerXAnchor.constraint(equalTo: self.guideView.centerXAnchor),
            self.guideViewImageView.leadingAnchor.constraint(equalTo: self.guideView.leadingAnchor, constant: 10 ),
            self.guideViewImageView.trailingAnchor.constraint(equalTo: self.guideView.trailingAnchor, constant: 10 )
        ])
        
        // loadingView
        NSLayoutConstraint.activate([
            self.loadingView.leftAnchor.constraint(equalTo: self.mapView.leftAnchor),
            self.loadingView.rightAnchor.constraint(equalTo: self.mapView.rightAnchor),
            self.loadingView.bottomAnchor.constraint(equalTo: self.mapView.bottomAnchor),
            self.loadingView.topAnchor.constraint(equalTo: self.mapView.topAnchor),
        ])
    }
    
    //MARK: - PickerView 설정
    //PickerView의 component 개수
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    // PickerView의 component별 행수
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerViewcityListNew.count
    }
    
    // PickerView의 component의 내용에 들어갈 list
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return "\(pickerViewcityListNew[row])"
    }
    
    // 피커뷰에서 선택된 행을 처리할 수 있는 메서드
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        //선택된 city를 selectedCity에 넣어줌.
        selectedCity = Region(rawValue: pickerViewcityListNew[row]) ?? .Gangnam
        currentRow=row
        
        // ❤️
        print("::checkButtonStatus::")
        print(clothingBinManager.checkButtonFunction(pressedButtonStatus: .region))
        
        let excuteButton = clothingBinManager.checkButtonFunction(pressedButtonStatus: .region)
        
    }
    
    //mapview 터치시 피커뷰 내려가도록
    func mapView(_ mapView: MTMapView!, singleTapOn mapPoint: MTMapPoint!) {
        regionButton.resignFirstResponder()
    }
    
    //poiItem 선택시 poiItem 지도 메서드 실행되도록
    func mapView(_ mapView: MTMapView!, touchedCalloutBalloonOf poiItem: MTMapPOIItem!) {
        UIPasteboard.general.string = poiItem.itemName
        
        //네이버 지도 앱 실행
        if poiItem.itemName != nil {
            let urlStr = "nmap://search?query=\( poiItem.itemName!)&appname=sumsum.daummap"
            let appStoreURL = URL(string: "http://itunes.apple.com/app/id311867728?mt=8")!
            guard let encodedStr = urlStr.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else { return }
            let url = URL(string: encodedStr)!
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
            } else {
                UIApplication.shared.open(appStoreURL)
            }
        }
    }
    
    //    func activityIndicatorStartAction() {
    //        self.activityIndicator.startAnimating()
    //        if !activityIndicator.isAnimating {
    //            self.activityIndicator.isHidden = false
    //            DispatchQueue.main.async {
    //
    //            }
    //        }
    //    }
    
    //    func activityIndicatorStopAction() {
    //        print("activityIndicator.isAnimating:\(activityIndicator.isAnimating)")
    //        self.activityIndicator.stopAnimating()
    //
    //        if activityIndicator.isAnimating {
    //            DispatchQueue.main.async {
    //
    //            }
    //        }
    //    }
    
    func switchActivityIndicator() {
        
    }
    
    //마커 로드중일때 다른 버튼 선택 막는 메서드
    func buttonSelectUnable() {
        currentLocationButton.isEnabled = false
        currentLocationSearchMapButton.isEnabled = false
    }
    
    //마커 로드중일때 다른 버튼 선택 방지 해제 메서드
    func buttonSelectAble() {
        currentLocationButton.isEnabled = true
        currentLocationSearchMapButton.isEnabled = true
    }
}

//MARK: - String - remove 익스텐션 구현
extension String {
    func remove(target string: String) -> String {
        return components(separatedBy: string).joined()
    }
}


extension CLLocation {
    
    /// Get distance between two points
    ///
    /// - Parameters:
    ///   - from: first point
    ///   - to: second point
    /// - Returns: the distance in meters
    class func distance(from: CLLocationCoordinate2D, to: CLLocationCoordinate2D) -> CLLocationDistance {
        let from = CLLocation(latitude: from.latitude, longitude: from.longitude)
        let to = CLLocation(latitude: to.latitude, longitude: to.longitude)
        return from.distance(from: to)
    }
}
