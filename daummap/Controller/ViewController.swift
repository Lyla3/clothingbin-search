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
        
    public var geocoder: MTMapReverseGeoCoder!
    var mapView:MTMapView!
    var locationManager: CLLocationManager!
    
    //현재 위경도
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
    
    //엑셀 파일에서 불러온 의류수거함 위치 데이터 배열
    var clothingBinLocationArray : [[String]] = []
    
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
        currentLocationSearchMapbutton.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1)
        currentLocationSearchMapbutton.setTitleColor(.black, for: .normal)
        currentLocationSearchMapbutton.setTitle("현재 지도 검색", for: .normal)
        currentLocationSearchMapbutton.configuration?.cornerStyle = .capsule
        currentLocationSearchMapbutton.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        currentLocationSearchMapbutton.translatesAutoresizingMaskIntoConstraints = false
        currentLocationSearchMapbutton.layer.cornerRadius = 14
        currentLocationSearchMapbutton.layer.shadowColor = UIColor.gray.cgColor
        currentLocationSearchMapbutton.layer.shadowOpacity = 0.3
        currentLocationSearchMapbutton.layer.shadowOffset = CGSize.zero
        currentLocationSearchMapbutton.layer.shadowRadius = 6
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
        removePOIItemsData()
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
            
            //현재위치 추가
            mapView.add(currentLocationPOIItem)
            mapView.setMapCenter(MTMapPoint(geoCoord: MTMapPointGeo(latitude: currentLocationLatitude!, longitude: currentLocationLongitude!)), animated: true)
            
            //CVSdataArray 업데이트 -> 전체 의류수거함
            loadDataFromAllCVSAt()
            
            //업데이트된 CVSdataArray를 바탕으로 가까이 있는 의류수거함 데이터를 불러온다.
            loadClothingBinByCurrentLocation(from: clothingBinLocationArray)
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
        removePOIItemsData()
        
        print("현재 지도 검색 검색 버튼이 눌렸습니다.")
        
        loadDataFromAllCVSAt()
        
        //업데이트된 CVSdataArray를 바탕으로 데이터를 불러온다. (가까이 있는 10개)
        let mapCenterPointByMTMapPoint = mapView.mapCenterPoint!
        
        if checkMapViewLevel() {
            loadClothinBinByBound()
        }
    }
    
    
    @objc func locationSelectButtonTapped(sender: UIButton) {
        //print("지역선택 버튼이 눌렸습니다")
        //실행 X
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
    private func loadDataFromAllCVSAt() {
        for resource in datacore.pickerToFileDictionary.values {
            let path = Bundle.main.path(forResource: resource, ofType: "csv")!
            parseCSVAt(url: URL(fileURLWithPath: path))
        }
    }
    
    //MARK: - 현재 위치 근처 데이터 의류수거함을 가져오는 함수 (:사용자 현재위치)
    private func loadClothingBinByCurrentLocation(from cvsArray:[[String]]) {
        let processedCVSData =
        mapLocationManager.processUnusedStringInLocationArray(locationDataArray: clothingBinLocationArray)
        
        //거리 값을 포함하여 담을 배열
        var distanceArray:[[String]] = []
        var distanceArrayToTen:[[String]] = []
        
        for clothingBox in processedCVSData {
            let info = clothingBox[0]
            let lat = clothingBox[1]
            let lon = clothingBox[2]
            
            let CLlocationAtArr = CLLocation(latitude: CLLocationDegrees(clothingBox[1]) ?? 0, longitude: CLLocationDegrees(clothingBox[2]) ?? 0)
            let distanceFromCurrentLocationToClthingBox = locationManager.location?.distance(from: CLlocationAtArr)
            let currentDistance = String(Double(distanceFromCurrentLocationToClthingBox ?? 10000000))
            distanceArray.append([info,lat,lon,currentDistance])
        }
        
        //현위치에서 가까운 의류수거함 10개 찾기 (현 위치에서의 거리가 2km 이상이면 나오지 않도록 함)
        distanceArray.sort(by:{Double($0[3]) ?? 9000000 < Double($1[3]) ?? 9000000 })
        for i in 0...9 {
            distanceArrayToTen.append(distanceArray[i])
        }
        for i in distanceArrayToTen {
            if Double(i[3]) ?? 9000000 < 2000 {
                let poiItem = MTMapPOIItem()
                poiItem.mapPoint = MTMapPoint(geoCoord: MTMapPointGeo(
                    latitude: Double(i[1])!,
                    longitude: Double(i[2])!))
                poiItem.itemName = i[0]
                poiItem.markerType = .redPin
                poiItemArray.append(poiItem)
            }
            
        }
        if poiItemArray.isEmpty == true {
            helpTextView.text = "현재 위치에서 가까운 의류수거함이 없습니다."
            helpTextView.isHidden = false
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
                self.helpTextView.isHidden = true
            }
        } else {
            mapView.addPOIItems(poiItemArray)
            mapView.fitAreaToShowAllPOIItems()
        }
        clearArray()
    }
    
    //화면의 가장자리 값으로 의류수거함 불러오기
    func loadClothinBinByBound(){
        
        clothingBinLocationArray = mapLocationManager.processUnusedStringInLocationArray(locationDataArray: clothingBinLocationArray)
        
        //사용자 화면의 끝점의 좌표
        let bottomLeftLat = mapView.mapBounds.bottomLeft.mapPointGeo().latitude
        let topRightLat = mapView.mapBounds.topRight.mapPointGeo().latitude
        let bottomLeftLon = mapView.mapBounds.bottomLeft.mapPointGeo().longitude
        let topRightLon = mapView.mapBounds.topRight.mapPointGeo().longitude
        
        //위도로 비교
        clothingBinLocationArray = clothingBinLocationArray.filter { Double($0[1]) ?? 0 > bottomLeftLat && Double($0[1]) ?? 50 < topRightLat}
        //경도로 비교
        clothingBinLocationArray = clothingBinLocationArray.filter { Double($0[2]) ?? 0 > bottomLeftLon && Double($0[2]) ?? 150 < topRightLon}
        
        if clothingBinLocationArray.count == 0 {
            // 현재 위치에는 등록된 의류수거함이 없음 -> 알림창
            helpTextView.text = "현 위치에 등록된 의류수거함이 없습니다."
            helpTextView.isHidden = false
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
                self.helpTextView.isHidden = true
            }
        } else {
            for clothinBin in clothingBinLocationArray {
                let poiItem = MTMapPOIItem()
                poiItem.itemName = clothinBin[0]
                poiItem.mapPoint = MTMapPoint(geoCoord: MTMapPointGeo(
                    latitude: Double(clothinBin[1]) ?? 9000000,
                    longitude: Double(clothinBin[2]) ?? 9000000))
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
    
    //데이터를 cvs에서 불러와서 poiItem의 배열에 담아 이를 mapView에 띄움. (:UI 지역구 선택시 사용)
    private func loadClothingBinByDistrict() {
        removePOIItemsData()
        buttonSelectUnable()
        clothingBinLocationArray = mapLocationManager.processUnusedStringInLocationArray(locationDataArray: clothingBinLocationArray)
        
        
        print("loadClothingBinByDistrict:\(clothingBinLocationArray)")
        //mapLocationManager에서 변화된 데이터 받아오기
        for clothingBin in clothingBinLocationArray {
            
            let poiItem = MTMapPOIItem()
            
            //뷰 만들고 클릭되면 띄우기
            poiItem.itemName = clothingBin[0]
            poiItem.mapPoint = MTMapPoint(geoCoord: MTMapPointGeo(latitude: Double(clothingBin[1]) ?? 0, longitude: Double(clothingBin[2]) ?? 0))
            poiItem.markerType = .redPin
            poiItemArray.append(poiItem)
        }
        mapView.addPOIItems(poiItemArray)
        //dataArray 배열 비워주기
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
    }
    
    func UIPickerToCVS (resourceFileName:String) {
        print("activityIndicatorStartAction")
        
        loadDataFromCVSAt(resource: resourceFileName)
        if clothingBinLocationArray.count != 0 {
            loadClothingBinByDistrict()
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
    
    
    
    
    func activityIndicatorStartAction() {
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
