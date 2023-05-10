//
//  ViewController.swift
//  daummap
//
//  Created by 너굴 on 2022/10/04.
//

import UIKit
import CoreLocation
import Foundation

class ViewController: UIViewController,MTMapViewDelegate,CLLocationManagerDelegate, MTMapReverseGeoCoderDelegate {
        
    public var geocoder: MTMapReverseGeoCoder!
    var mapView:MTMapView!
    
    var locationManager: CLLocationManager!
    
    //현재 위/경도
    var currentLocationLatitude: Double?
    var currentLocationLongitude: Double?
    
    var address: String?
    var currentLocationButtonPressed: Bool = false
    
    var poiItemArray : [MTMapPOIItem] = []
    
    let datacore = DataCore()
    
    var pickerViewcityListNew : [String] = []
    
    var selectedCity : String = "서울시 강남구"
    
    var currentRow : Int = 0
    
    //MVC패턴 적용
    var mapLocationManager = MapLocationManager()
    
    //엑셀 파일 불러오기
    var cvsLocationArray : [[String]] = []
    
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
        currentLocationbutton.translatesAutoresizingMaskIntoConstraints = false
        return currentLocationbutton
    }()
    
    //현재 지도 검색 버튼
    private let currentLocationSearchMapButton: UIButton = {
        let currentLocationSearchMapbutton = UIButton(type: .system)
        var config = UIButton.Configuration.filled()
        config.cornerStyle = .capsule
        
        //currentMapbutton
        let imageConfig = UIImage.SymbolConfiguration(pointSize: 30, weight: .light)
        //currentMapbutton.setImage(UIImage(systemName: "circle.dotted"), for: .normal)
        currentLocationSearchMapbutton.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1)
        currentLocationSearchMapbutton.setTitleColor(.black, for: .normal)
        currentLocationSearchMapbutton.setTitle("현재 지도 검색", for: .normal)
        currentLocationSearchMapbutton.configuration?.cornerStyle = .capsule
        currentLocationSearchMapbutton.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        currentLocationSearchMapbutton.translatesAutoresizingMaskIntoConstraints = false
        //currentMapbutton.invalidateIntrinsicContentSize()
        currentLocationSearchMapbutton.layer.cornerRadius = 14
        currentLocationSearchMapbutton.layer.shadowColor = UIColor.gray.cgColor
        currentLocationSearchMapbutton.layer.shadowOpacity = 0.3
        currentLocationSearchMapbutton.layer.shadowOffset = CGSize.zero
        currentLocationSearchMapbutton.layer.shadowRadius = 6
        //currentMapbutton.layer.borderWidth = 5
        currentLocationSearchMapbutton.translatesAutoresizingMaskIntoConstraints = false
        return currentLocationSearchMapbutton
    }()
    
    //지역 선택 버튼
    private let locationSelectButton: UITextField = {
        let locationSelectButton = UITextField()
        let imageConfig = UIImage.SymbolConfiguration(pointSize: 30, weight: .light)
        locationSelectButton.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1)
        locationSelectButton.minimumFontSize = 20
        locationSelectButton.textColor = UIColor.black
        locationSelectButton.translatesAutoresizingMaskIntoConstraints = false
        locationSelectButton.text = "지역선택"
        locationSelectButton.textAlignment = .center
        locationSelectButton.tintColor = UIColor.clear
        
        
        //모서리 및 그림자
        locationSelectButton.layer.cornerRadius = 5
        locationSelectButton.layer.shadowColor = UIColor.gray.cgColor
        locationSelectButton.layer.shadowOpacity = 0.3
        locationSelectButton.layer.shadowOffset = CGSize.zero
        locationSelectButton.layer.shadowRadius = 6
        
        
        return locationSelectButton
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
    
    //activityIndicator 생성
    lazy var activityIndicator: UIActivityIndicatorView = {
        // Create an indicator
        let activityIndicator = UIActivityIndicatorView()
        activityIndicator.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        activityIndicator.center = CGPoint(x: self.view.center.x, y: self.view.center.y)
        activityIndicator.hidesWhenStopped = false
        activityIndicator.style = UIActivityIndicatorView.Style.medium
        activityIndicator.stopAnimating()
        activityIndicator.hidesWhenStopped = true
        return activityIndicator
    }()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 현재 위치 받아와서 centerpoint로 설정.
        mapView = MTMapView(frame: self.view.frame)
        mapView.delegate = self
        mapView.baseMapType = .standard
        loadcurrentLocation()
        
        pickerViewcityListNew = datacore.pickerToFileDictionary.keys.map{String($0)}.sorted()
        
        makeUI()
    }
    
    
    //MARK: - UI 설정
    func makeUI(){
        createPickerView()
        
        self.view.addSubview(mapView)
        self.view.addSubview(self.currentLocationButton)
        self.view.addSubview(self.currentLocationSearchMapButton)
        self.view.addSubview(self.locationSelectButton)
        self.view.addSubview(self.helpTextView)
        helpTextView.isHidden = true
        
        //self.view.addSubview(activityIndicator)
        currentLocationButton.addTarget(self, action: #selector(currentLocationButtonTapped), for: .touchUpInside)
        currentLocationSearchMapButton.addTarget(self, action: #selector(currentLocationMapButtonTapped), for: .touchUpInside)
        
        //지역선택 버튼 눌리면 locationSelectButtonTapped 실행, pickerView가 실질적으로 실행
        locationSelectButton.addTarget(self, action: #selector(locationSelectButtonTapped), for: .touchUpInside)
        mapView.setZoomLevel(2, animated: false)
        
        
        //지역선택 버튼 레이아웃
        NSLayoutConstraint.activate([
            self.locationSelectButton.topAnchor.constraint(equalTo: self.view.topAnchor, constant:750),
            self.locationSelectButton.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 10),
            self.locationSelectButton.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -10),
            self.locationSelectButton.heightAnchor.constraint(equalToConstant: 40)
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
        
        //현재지도 검색 버튼 레이아웃
        NSLayoutConstraint.activate([
            self.currentLocationSearchMapButton.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 70),
            self.currentLocationSearchMapButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            self.currentLocationSearchMapButton.widthAnchor.constraint(equalToConstant: 95),
            self.currentLocationSearchMapButton.heightAnchor.constraint(equalToConstant: 28)
        ])
        
    }
    
    //MARK: - longTap
    func mapView(_ mapView: MTMapView!, longPressOn mapPoint: MTMapPoint!) {
        print("길게 화면이 눌렸습니다 - longtap")
        print("Point: \(String(describing: mapPoint))")
        
        let alert = UIAlertController(title: "이 위치에 의류수거함을 추가하시겠습니까?", message: "", preferredStyle: UIAlertController.Style.alert)
        let cancle = UIAlertAction(title: "취소", style: .default ,handler: nil)
        
        //확인 버튼(:버튼 추가)
        let ok = UIAlertAction(title: "확인", style: .destructive, handler: { action in
            let poitemLongtapped = MTMapPOIItem()
            poitemLongtapped.itemName = "New"
            poitemLongtapped.mapPoint = mapPoint
            poitemLongtapped.markerType = .bluePin
            mapView.addPOIItems([poitemLongtapped])
        })
        
        //버튼을 알림창에 추가해줌
        alert.addAction(cancle)
        alert.addAction(ok)
        present(alert,animated: true, completion: nil)
    }
    
    
    //현재 사용자의 위치를 불러옴
    func loadcurrentLocation() {
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
        let coor = locationManager.location?.coordinate
        
        
        if coor?.latitude != nil && coor?.longitude != nil {
            currentLocationLatitude = coor?.latitude
            currentLocationLongitude = coor?.longitude
            
            mapView.setMapCenter(MTMapPoint(geoCoord: MTMapPointGeo(latitude: currentLocationLatitude!, longitude: currentLocationLongitude!)), animated: true)
        } else {
            self.alertCurrentLocation()
        }
        
    }
    
    //MARK: - 현재 위치 버튼 실행시
    @objc func currentLocationButtonTapped(sender: UIButton) {
        print("현재위치 버튼이 눌렸습니다. ")
        
        
       
        
        
        switch locationManager.authorizationStatus {
        case .denied, .notDetermined, .restricted:
            self.alertCurrentLocation()
            
        case .authorizedAlways, .authorizedWhenInUse:
            
            loadcurrentLocation()
            mapView.setMapCenter(MTMapPoint(geoCoord: MTMapPointGeo(latitude: currentLocationLatitude!, longitude: currentLocationLongitude!)), animated: true)
            
            let currentLocationPOIItem = MTMapPOIItem()
            
            currentLocationPOIItem.itemName = "현재위치"
            currentLocationPOIItem.mapPoint = MTMapPoint(geoCoord: MTMapPointGeo(latitude: currentLocationLatitude!, longitude: currentLocationLongitude!))
            currentLocationPOIItem.markerType = .yellowPin
            
            removePOIItemsData()
            
            //현재위치 추가
            mapView.add(currentLocationPOIItem)
            mapView.setMapCenter(MTMapPoint(geoCoord: MTMapPointGeo(latitude: currentLocationLatitude!, longitude: currentLocationLongitude!)), animated: true)
            
            //CVSdataArray 업데이트 -> 전체 의류수거함
            loadDataFromAllCVSAt()
            
            //업데이트된 CVSdataArray를 바탕으로 데이터를 불러온다. (가까이 있는)
            nearCurrentloadData(cvsArray: cvsLocationArray)
            
            
            
            clearArray()
            
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
    
    //현재 지도 검색
    @objc func currentLocationMapButtonTapped(sender: UIButton) {
        
        print("현재 지도 검색 검색 버튼이 눌렸습니다.")
        
        loadDataFromAllCVSAt()
        
        //업데이트된 CVSdataArray를 바탕으로 데이터를 불러온다. (가까이 있는 10개)
        let mapCenterPointByMTMapPoint = mapView.mapCenterPoint!
        //currentMapLoadData(cvsArray: CVSdataArray, currentMapPoint: MTMapPoint.mapPointGeo(mapCenterPointByMTMapPoint)())
        
        //임시
        if checkMapViewLevel() {
            currentMapLoadDataByBound(cvsArray: cvsLocationArray)
        }
    }
    
    
    @objc func locationSelectButtonTapped(sender: UIButton) {
        print("지역선택 버튼이 눌렸습니다")
    }
    
    //MARK: - 엑셀 파일 파싱 함수
    private func parseCSVAt(url:URL) {
        //
        do {
            let data = try Data(contentsOf: url)
            let dataEncoded = String(data: data, encoding: .utf8)
            
            if let dataArr = dataEncoded?.components(separatedBy: "\n").map({$0.components(separatedBy: ",")}) {
                
                for item in dataArr{
                    cvsLocationArray.append(item)
                }
            }
            
        } catch {
            print("Error reading CVS file.")
        }
        
    }
    //MARK: - CVS 데이터 로드
    private func loadDataFromCVSAt(resource:String) {
        let path = Bundle.main.path(forResource: resource, ofType: "csv")!
        parseCSVAt(url: URL(fileURLWithPath: path))
    }
    
    
    //MARK: - CVS 전체 파일 데이터 로드
    private func loadDataFromAllCVSAt() {
        for resource in datacore.pickerToFileDictionary.values {
            let path = Bundle.main.path(forResource: resource, ofType: "csv")!
            parseCSVAt(url: URL(fileURLWithPath: path))
        }
        
    }
    
    //현재 위치 근처 데이터 의류수거함 뽑는 함수 (:사용자 현재위치)
    private func nearCurrentloadData(cvsArray:[[String]]) {
        
        //mapLocationManager.locationDataArray = cvsLocationArray
        
        guard let currentLocationLatitudeNonOptional = currentLocationLatitude, let currentLocationLongitudeNonOptional = currentLocationLongitude else {
            print("현재 위치를 가져올 수 없습니다. ")
            return
        }
        
        //mvc test
        let processedCVSData =
        mapLocationManager.loadClotingBinDataFromCurrentLocation(currentLocationLatitude: currentLocationLatitudeNonOptional, currentLocationLongitude: currentLocationLongitudeNonOptional,locationDataArray: cvsLocationArray)
        
        var distanceArray:[[String]] = []
        
        for i in processedCVSData{
            let info = cvsArray[i][0]
            let lat = cvsArray[i][1]
            let lon = cvsArray[i][2].split(separator: "\r")
        }
        
        if currentLocationLatitude != nil && currentLocationLongitude != nil {
            for i in 0..<cvsArray.count {
                
                let info = cvsArray[i][0]
                
                let lat = cvsArray[i][1]
                let lon = cvsArray[i][2].split(separator: "\r")
                
                let CLlocationAtArr = CLLocation(latitude: CLLocationDegrees(cvsArray[i][1]) ?? 0, longitude: CLLocationDegrees(cvsArray[i][2].split(separator: "\r")[0]) ?? 0)
                
                
                //xxx
                let nowDistance = locationManager.location?.distance(from: CLlocationAtArr)
                
                print("---nowDistance---")
                print(nowDistance ?? "nowDistance 값이 없습니다")
                
                let currentDistance = String(Double(nowDistance ?? 10000000))
                
                distanceArray.append([currentDistance,lat,String(lon[0]),info])
                
            }
            
            let sortedArray = distanceArray.sorted(by: {Double($0[0]) ?? 9000000 < Double($1[0]) ?? 9000000 })
            
            if sortedArray.count != 0 {
                print("----------가까운 10개만 반환-----------")
                dump(sortedArray[0...9])
                
                //var poiItemArray : [MTMapPOIItem] = []
                
                //poiItem으로 추가해서 화면에 표시한다.
                for i in 0...9 {
                    
                    //사용자 가까이의 데이터만 반환 (거리: 1500)
                    if let distanceNumber = Double(sortedArray[i][0]) {
                        if distanceNumber < 1500 {
                            let poiItem = MTMapPOIItem()
                            poiItem.mapPoint = MTMapPoint(geoCoord: MTMapPointGeo(latitude: Double(sortedArray[i][1])!, longitude: Double(sortedArray[i][2])!))
                            poiItem.itemName = sortedArray[i][3]
                            poiItem.markerType = .redPin
                            
                            poiItemArray.append(poiItem)
                            print("현재 위치 근처 의류수거함")
                            dump(poiItem.itemName)
                            
                        } else {
                            return
                        }
                        
                    }
                    
                    
                }
                mapView.setZoomLevel(2, animated: true)
                mapView.addPOIItems(poiItemArray)
                
                
                //배열 초기화
                clearArray()
            }
        } else {
            alertCurrentLocation()
        }
        
        
        
    }
    
    //화면의 가장자리 값으로 의류수거함 불러오기
    func currentMapLoadDataByBound(cvsArray dataArr:[[String]]){
        removePOIItemsData()
        var currentMapPonitArray : [[String]] = []
        for clothingBox in dataArr {
            let clothingBoxInfo = clothingBox[0]
            let clothingBoxLat = clothingBox[1]
            let clothingBoxLon = clothingBox[2].remove(target: "\r")
            
            currentMapPonitArray.append([clothingBoxInfo,clothingBoxLat,clothingBoxLon])
        }
        //사용자 화면의 끝점의 좌표
        let bottomLeftLat = mapView.mapBounds.bottomLeft.mapPointGeo().latitude
        let topRightLat = mapView.mapBounds.topRight.mapPointGeo().latitude
        let bottomLeftLon = mapView.mapBounds.bottomLeft.mapPointGeo().longitude
        let topRightLon = mapView.mapBounds.topRight.mapPointGeo().longitude
        
        //위도로 비교
        currentMapPonitArray = currentMapPonitArray.filter { Double($0[1]) ?? 0 > bottomLeftLat && Double($0[1]) ?? 50 < topRightLat}
        //경도로 비교
        currentMapPonitArray = currentMapPonitArray.filter { Double($0[2]) ?? 0 > bottomLeftLon && Double($0[2]) ?? 150 < topRightLon}
        
        if currentMapPonitArray.count == 0 {
            // 현재 위치에는 등록된 의류수거함이 없음 -> 알림창
            helpTextView.text = "현 위치에 등록된 의류수거함이 없습니다."
            helpTextView.isHidden = false
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
                self.helpTextView.isHidden = true
            }
        } else {
            for i in 0...currentMapPonitArray.count - 1 {
                let poiItem = MTMapPOIItem()
                poiItem.mapPoint = MTMapPoint(geoCoord: MTMapPointGeo(
                    latitude: Double(currentMapPonitArray[i][1])!,
                    longitude: Double(currentMapPonitArray[i][2])!))
                poiItem.itemName = currentMapPonitArray[i][0]
                poiItem.markerType = .redPin
                
                poiItemArray.append(poiItem)
                
                self.helpTextView.isHidden = true
            }
            mapView.addPOIItems(poiItemArray)
            clearArray()
        }
        
    }
    
    func checkMapViewLevel() -> Bool{
        switch mapView.zoomLevel {
        case 0...2:
            //nearDistanceArray = distanceArray.filter{Double($0[0]) ?? 90000000 < 400}
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
        cvsLocationArray = []
    }
    
    //데이터를 cvs에서 불러와서 poiItem의 배열에 담아 이를 mapView에 띄움.(:UI 지역선택시 사용)
    private func loadData(cvsArray dataArr:[[String]]) {
        print(dataArr.count - 1 )
        buttonSelectUnable()
        for i in 0 ..< dataArr.count - 1 {
            let info = dataArr[i][0]
            let lat = dataArr[i][1]
            let lon = dataArr[i][2].split(separator: "\r")
            
            let stringLon = String(lon[0])
            
            let poiItem = MTMapPOIItem()
            
            //뷰 만들고 클릭되면 띄우기
            poiItem.itemName = info
            poiItem.mapPoint = MTMapPoint(geoCoord: MTMapPointGeo(latitude: Double(lat) ?? 0, longitude: Double(stringLon) ?? 0))
            poiItem.markerType = .redPin
            poiItemArray.append(poiItem)
        }
        
        mapView.addPOIItems(poiItemArray)
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
        let btnCancel = UIBarButtonItem(title: "취소", style: .done, target: self, action: #selector(onPickCancel))
        toolbar.setItems([btnCancel , space , btnDone], animated: true)
        toolbar.isUserInteractionEnabled = true
        
        //텍스트필드 입력 수단 연결
        locationSelectButton.inputView = pickerView
        locationSelectButton.inputAccessoryView = toolbar
        
    }
    
    
    //MARK: - PickerView 확인 버튼
    @objc func onPickDone() {
        /// 확인 눌렀을 때 액션 정의 -> 아래 코드에서는 라벨 텍스트 업데이트
        locationSelectButton.text = "\(selectedCity)"
        switch selectedCity {
        case "서울시 강남구":
            UIPickerToCVS(resourceFileName:datacore.pickerToFileDictionary["서울시 강남구"]!)
        case "서울시 동작구":
            UIPickerToCVS(resourceFileName:datacore.pickerToFileDictionary["서울시 동작구"]!)
        case "서울시 구로구":
            UIPickerToCVS(resourceFileName:datacore.pickerToFileDictionary["서울시 구로구"]!)
        case "서울시 마포구":
            UIPickerToCVS(resourceFileName:datacore.pickerToFileDictionary["서울시 마포구"]!)
        case "서울시 영등포구":
            UIPickerToCVS(resourceFileName:datacore.pickerToFileDictionary["서울시 영등포구"]!)
        case "서울시 양천구":
            UIPickerToCVS(resourceFileName:datacore.pickerToFileDictionary["서울시 양천구"]!)
        case "서울시 관악구":
            UIPickerToCVS(resourceFileName:datacore.pickerToFileDictionary["서울시 관악구"]!)
        case "서울시 종로구":
            UIPickerToCVS(resourceFileName:datacore.pickerToFileDictionary["서울시 종로구"]!)
        case "서울시 서대문구":
            UIPickerToCVS(resourceFileName:datacore.pickerToFileDictionary["서울시 서대문구"]!)
        default:
            locationSelectButton.resignFirstResponder()
        }
        locationSelectButton.resignFirstResponder()
        /// 피커뷰 내림
    }
    
    func UIPickerToCVS (resourceFileName:String) {
        print("activityIndicatorStartAction")
        //🌸
        //activityIndicator.isHidden = false
        //self.activityIndicatorStartAction()
        
        clearArray()
        removePOIItemsData()
        
        
        loadDataFromCVSAt(resource: resourceFileName)
        if cvsLocationArray.count != 0 {
            loadData(cvsArray:cvsLocationArray)
            mapView.fitAreaToShowAllPOIItems()
        }
    }
    
    @objc func onPickCancel() {
        locationSelectButton.resignFirstResponder() /// 피커뷰 내림
    }
    
//    func searchAddress() {
//        var geo = MTMapReverseGeoCoder(mapPoint: <#T##MTMapPoint!#>, with: <#T##MTMapReverseGeoCoderDelegate!#>, withOpenAPIKey: <#T##String!#>)
//    }
    
    
}


//MARK: - PickerView 익스텐션 구현

extension ViewController: UITextFieldDelegate,UIPickerViewDelegate,UIPickerViewDataSource{
    
    //PickerView의 component 개수
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    //PickerView의 component별 행수
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerViewcityListNew.count
    }
    
    //PickerView의 component의 내용에 들어갈 list
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return "\(pickerViewcityListNew[row])"
    }
    //피커뷰에서 선택된 행을 처리할 수 있는 메서드
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        //선택된 city를 selectedCity에 넣어줌.
        selectedCity = pickerViewcityListNew[row]
        
        currentRow=row
        
    }
    
    //mapview 터치시 피커뷰 내려가도록
    func mapView(_ mapView: MTMapView!, singleTapOn mapPoint: MTMapPoint!) {
        locationSelectButton.resignFirstResponder()
    }
    
    //poiItem 선택시 poiItem 지도 메서드 실행되도록 (안내가 있어야 하지 않을까요..?)
    func mapView(_ mapView: MTMapView!, touchedCalloutBalloonOf poiItem: MTMapPOIItem!) {
        print("poiitem이 눌렸습니다")
        print("\(String(describing: poiItem.itemName))")
        UIPasteboard.general.string = poiItem.itemName
        
        //네이버 지도 앱 실행
        if poiItem.itemName != nil {
            let urlStr = "nmap://search?query=\( poiItem.itemName!)&appname=sumsum.daummap"
            let appStoreURL = URL(string: "http://itunes.apple.com/app/id311867728?mt=8")!
            guard let encodedStr = urlStr.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else { return }
            let url = URL(string: encodedStr)!
            print(url.absoluteString)
            
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
            } else {
                UIApplication.shared.open(appStoreURL)
            }
            
        }
    }
    
    
    
    
    func activityIndicatorStartAction() {
        
        print("Start: activityIndicator.isAnimating:\(activityIndicator.isAnimating)")
        
        self.activityIndicator.startAnimating()
        
        if !activityIndicator.isAnimating {
            self.activityIndicator.isHidden = false
            
            
            DispatchQueue.main.async {
                
            }
        }
    }
    
    func activityIndicatorStopAction() {
        print("activityIndicator.isAnimating:\(activityIndicator.isAnimating)")
        
        self.activityIndicator.stopAnimating()
        
        if activityIndicator.isAnimating {
            
            DispatchQueue.main.async {
                
            }
            
        }
        
    }
    
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
