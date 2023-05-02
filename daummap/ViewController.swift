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
    
    var locationCalculatorManager = LocationCalculatorManager()
    
    //mapview 터치시 피커뷰 내려가도록
    func mapView(_ mapView: MTMapView!, singleTapOn mapPoint: MTMapPoint!) {
        locationSelectButton.resignFirstResponder()
    }
    
    public var geocoder: MTMapReverseGeoCoder!
    var mapView:MTMapView!
    
    var locationManager: CLLocationManager!
    
    
    //현재 위/경도
    var clLatitude: Double?
    var clLongitude: Double?
    
    var address: String?
    var currentLocationButtonPressed: Bool = false
    
    var pickerViewcityList = [String](["서울시 동작구","서울시 구로구","서울시 양천구","서울시 종로구","서울시 영등포구","서울시 관악구"])
    
    var pickerToFileDictionary : [String:String] = ["서울시 동작구":"ClothingBin_Dongjak",
                                                    "서울시 구로구":"Seoul_guro",
                                                    "서울시 양천구":"Seoul_Yangcheon",
                                                    "서울시 종로구":"Seoul_Gongro",
                                                    "서울시 영등포구":"Seoul_Yeoungdeungpo",
                                                    "서울시 관악구":"Seoul_gwanak"]
    
    var selectedCity : String = "서울시 동작구"
    
    var pickerViewcityListIsOn = [Bool]([false,false,false,false,false,false])
    
    var currentRow : Int = 0
    
    
    //엑셀 파일 불러오기
    var CVSdataArray : [[String]] = []
    
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
    private let currentMapButton: UIButton = {
        let currentMapbutton = UIButton(type: .system)
        var config = UIButton.Configuration.filled()
        config.cornerStyle = .capsule
        //currentMapbutton
        let imageConfig = UIImage.SymbolConfiguration(pointSize: 30, weight: .light)
        //currentMapbutton.setImage(UIImage(systemName: "circle.dotted"), for: .normal)
        currentMapbutton.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1)
        currentMapbutton.setTitleColor(.black, for: .normal)
        currentMapbutton.setTitle("현 위치 검색", for: .normal)
        currentMapbutton.configuration?.cornerStyle = .capsule
        currentMapbutton.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        currentMapbutton.translatesAutoresizingMaskIntoConstraints = false
        //currentMapbutton.invalidateIntrinsicContentSize()
        currentMapbutton.layer.cornerRadius = 14
        currentMapbutton.layer.shadowColor = UIColor.gray.cgColor
        currentMapbutton.layer.shadowOpacity = 0.3
        currentMapbutton.layer.shadowOffset = CGSize.zero
        currentMapbutton.layer.shadowRadius = 6
        //currentMapbutton.layer.borderWidth = 5
        //currentMapbutton.edgein
        currentMapbutton.translatesAutoresizingMaskIntoConstraints = false
        return currentMapbutton
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
        
        
        //모서리 및 그림자
        locationSelectButton.layer.cornerRadius = 5
        locationSelectButton.layer.shadowColor = UIColor.gray.cgColor
        locationSelectButton.layer.shadowOpacity = 0.3
        locationSelectButton.layer.shadowOffset = CGSize.zero
        locationSelectButton.layer.shadowRadius = 6
        
        
        
        return locationSelectButton
    }()
    
    
    //마커 커스텀 뷰 생성(크기는?_?)
    private lazy var makerInfoView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.darkGray
//        view.layer.cornerRadius = 9
//        view.layer.masksToBounds = true
//        view.backgroundColor = UIColor.darkGray
        return view
    }()
    
    //activityIndicator 생성
    //로딩중 표시
    lazy var activityIndicator: UIActivityIndicatorView = {
            // Create an indicator.
        let activityIndicator = UIActivityIndicatorView()
               activityIndicator.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
               activityIndicator.center = CGPoint(x: self.view.center.x, y: self.view.center.y)
               activityIndicator.hidesWhenStopped = false
               activityIndicator.style = UIActivityIndicatorView.Style.medium
               activityIndicator.startAnimating()
               return activityIndicator
    }()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // 현재 위치 받아와서 centerpoint로 설정.
        mapView = MTMapView(frame: self.view.frame)
        mapView.delegate = self
        mapView.baseMapType = .standard
        loadcurrentLocation()
        createPickerView()
    
        self.view.addSubview(mapView)
        self.view.addSubview(self.currentLocationButton)
        self.view.addSubview(self.currentMapButton)
        self.view.addSubview(self.locationSelectButton)
    
        currentLocationButton.addTarget(self, action: #selector(currentLocationButtonTapped), for: .touchUpInside)
        
        currentMapButton.addTarget(self, action: #selector(currentMapButtonTapped), for: .touchUpInside)
        
        locationSelectButton.addTarget(self, action: #selector(locationSelectButtonTapped), for: .touchUpInside)
        
        mapView.setZoomLevel(2, animated: false)
    
        
        //지역선택 버튼 레이아웃
        NSLayoutConstraint.activate([
            self.locationSelectButton.topAnchor.constraint(equalTo: self.view.topAnchor, constant:750),
            self.locationSelectButton.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 10),
            self.locationSelectButton.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -10),
            self.locationSelectButton.heightAnchor.constraint(equalToConstant: 40)
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
            self.currentMapButton.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 70),
            //self.currentMapButton.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 328),
            self.currentMapButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            self.currentMapButton.widthAnchor.constraint(equalToConstant: 85),
            self.currentMapButton.heightAnchor.constraint(equalToConstant: 28)
           
        ])
    }
    
    
    //사용 안하는 메서드
   func makeUI(){
       makerInfoView.translatesAutoresizingMaskIntoConstraints = false
       makerInfoView.heightAnchor.constraint(equalToConstant: 30).isActive = true
       makerInfoView.widthAnchor.constraint(equalToConstant: 30).isActive = true
       makerInfoView.topAnchor.constraint(equalTo: view.topAnchor, constant: 100).isActive = true
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
    
    
    func loadcurrentLocation() {
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
        let coor = locationManager.location?.coordinate
        
        
        if coor?.latitude != nil && coor?.longitude != nil {
            clLatitude = coor?.latitude
            clLongitude = coor?.longitude
            
            mapView.setMapCenter(MTMapPoint(geoCoord: MTMapPointGeo(latitude: clLatitude!, longitude: clLongitude!)), animated: true)
        } else {
            self.alertCurrentLocation()
        }
        
    }
    
    @objc func currentLocationButtonTapped(sender: UIButton) {
        
        print("현재위치 버튼이 눌렸습니다. ")
        
        switch locationManager.authorizationStatus {
        case .denied, .notDetermined, .restricted:
            self.alertCurrentLocation()
             
        case .authorizedAlways, .authorizedWhenInUse:
                loadcurrentLocation()
                mapView.setMapCenter(MTMapPoint(geoCoord: MTMapPointGeo(latitude: clLatitude!, longitude: clLongitude!)), animated: true)
                
                let poCurrentItem = MTMapPOIItem()
                
                poCurrentItem.itemName = "현재위치"
                poCurrentItem.mapPoint = MTMapPoint(geoCoord: MTMapPointGeo(latitude: clLatitude!, longitude: clLongitude!))
                poCurrentItem.markerType = .yellowPin
                
                mapView.removeAllPOIItems()
                mapView.addPOIItems([poCurrentItem])
                mapView.setMapCenter(MTMapPoint(geoCoord: MTMapPointGeo(latitude: clLatitude!, longitude: clLongitude!)), animated: true)
                
                
                //현재 위치 근처의 의류수거함 데이터 불러오는 함수 실행,CVSdataArray 업데이트
                loadDataFromCVSAt(resource:"ClothingBin_all")
                
                //업데이트된 CVSdataArray를 바탕으로 데이터를 불러온다. (가까이 있는 10개)
                nearCurrentloadData(cvsArray: CVSdataArray)
           
            
            
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
    
    @objc func currentMapButtonTapped(sender: UIButton) {
        
        print("현 위치 검색 버튼이 눌렸습니다.")
        
        //ClothingBin_all인지 확인해서 이미 all 이면 다시 검색 안하도록
        loadDataFromCVSAt(resource:"ClothingBin_all")
        
        //업데이트된 CVSdataArray를 바탕으로 데이터를 불러온다. (가까이 있는 10개)
        let mapCenterPointByMTMapPoint = mapView.mapCenterPoint!
        nearCurrentMaploadData(cvsArray: CVSdataArray, currentMapPoint: MTMapPoint.mapPointGeo(mapCenterPointByMTMapPoint)())
        // ⭐️
        // 1) 현재 중심점 받아오기
        //let mapCenterPointByMTMapPoint = mapView.mapCenterPoint!
        MTMapPoint.mapPointGeo(mapCenterPointByMTMapPoint)().latitude
              MTMapPoint.mapPointGeo(mapCenterPointByMTMapPoint)().longitude
        MTMapPoint.mapPointGeo(mapCenterPointByMTMapPoint)().latitude
        //print(String(MTMapPoint.mapPointGeo(mapCenterPointByMTMapPoint)()))
       
        
        // 2) 현재 지도 줌 설정에 따라 검색할 반경 값 다르게 설정(switch로 범위 값 설정)
        // 3) 반경 내의 위 경도 값 검색
        // 4) 알고리즘 -> 위도 && 경도
        // 5) mapView에 띄우기
         
         
    }

    
    @objc func locationSelectButtonTapped(sender: UIButton) {
        
    }
    
    //MARK: - 엑셀 파일 파싱 함수
    private func parseCSVAt(url:URL) {
        do {
            let data = try Data(contentsOf: url)
            let dataEncoded = String(data: data, encoding: .utf8)
            
            if let dataArr = dataEncoded?.components(separatedBy: "\n").map({$0.components(separatedBy: ",")}) {
                
                for item in dataArr{
                    CVSdataArray.append(item)
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
    
    //현재 위치 근처 데이터 의류수거함 뽑는 함수
    private func nearCurrentloadData(cvsArray dataArr:[[String]]) {
    
        var distanceArray:[[String]] = []
        print("clLatitude:\(String(describing: clLatitude)) clLongitude: \(String(describing: clLongitude))")
        if clLatitude != nil && clLongitude != nil {
            for i in 0..<dataArr.count {
                
                let info = dataArr[i][0]
                
                let lat = dataArr[i][1]
                let lon = dataArr[i][2].split(separator: "\r")
                
                let CLlocationAtArr = CLLocation(latitude: CLLocationDegrees(dataArr[i][1]) ?? 0, longitude: CLLocationDegrees(dataArr[i][2].split(separator: "\r")[0]) ?? 0)
                
                let nowDistance = locationManager.location?.distance(from: CLlocationAtArr)
                print("---nowDistance---")
                print(nowDistance ?? "nowDistance 값이 없습니다")
                
                //let distance = CLLocationDistance(locationManager.location,CLlocationArr)
                
                let latDistance = ((Double(lat) ?? 0) - clLatitude!)
                
                //String(lon[0])이 실제 값
                let lonDistance = ((Double(String(lon[0])) ?? 0) - clLongitude!)
                
                
                let currentDistance = String(Double(nowDistance ?? 10000000))

                
                //let currentDistance = String((pow(latDistance,2) + pow(lonDistance,2)))
                distanceArray.append([currentDistance,lat,String(lon[0]),info])
                
                
            
            }
            
            let sortedArray = distanceArray.sorted(by: {Double($0[0]) ?? 9000000 < Double($1[0]) ?? 9000000 })
            dump(sortedArray)
            //print(sortedArray)
            if sortedArray.count != 0 {
                print("----------가까운 10개만 반환-----------")
                dump(sortedArray[0...9])
                
                //poitem1으로 추가해서 화면에 표시한다.
                for i in 0...10{
                    let poitem1 = MTMapPOIItem()
                    poitem1.mapPoint = MTMapPoint(geoCoord: MTMapPointGeo(latitude: Double(sortedArray[i][1])!, longitude: Double(sortedArray[i][2])!))
                    poitem1.itemName = sortedArray[i][3]
                    poitem1.markerType = .redPin
        
                    mapView.addPOIItems([poitem1])
                }
                           
                
            }
        } else {
            alertCurrentLocation()
        }
        
    
        
    }
    
    //현재 지도 근처에 위치한 의류수거함 불러오기
    private func nearCurrentMaploadData(cvsArray dataArr:[[String]], currentMapPoint: MTMapPointGeo ) {
        
        // 1) distanceArray가 전체 데이터인가?
        var distanceArray:[[String]] = []
        print("clLatitude:\(String(describing: clLatitude)) clLongitude: \(String(describing: clLongitude))")
        if clLatitude != nil && clLongitude != nil {
            removePOIItemsData()
            for i in 0..<dataArr.count - 1 {
                
                let info = dataArr[i][0]
                
                let lat = dataArr[i][1]
                let lon = dataArr[i][2].split(separator: "\r")
                
                let CLlocationAtArr = CLLocation(latitude: CLLocationDegrees(dataArr[i][1]) ?? 0, longitude: CLLocationDegrees(dataArr[i][2].split(separator: "\r")[0]) ?? 0)
                
               
                let CLlocationCurrentMapPoint = CLLocation(latitude: currentMapPoint.latitude, longitude:currentMapPoint.longitude)
                
                let nowDistance = CLlocationCurrentMapPoint.distance(from: CLlocationAtArr)
                print(nowDistance)
                
                
                print("---nowDistance---")
                print(nowDistance)
               
                let currentDistance = String(Double(nowDistance))
                
                distanceArray.append([currentDistance,lat,String(lon[0]),info])
                
            }
            
            //거리 값이 400미만인 인자만 추출
            
            var nearDistanceArray = distanceArray.filter{Double($0[0]) ?? 90000000 < 500}
            print(mapView.zoomLevel)
            
            switch mapView.zoomLevel {
            case 0...2:
                nearDistanceArray = distanceArray.filter{Double($0[0]) ?? 90000000 < 400}
                print("\(mapView.zoomLevel)zoomLevel")
            case 3:
                nearDistanceArray = distanceArray.filter{Double($0[0]) ?? 90000000 < 900}
            case 4:
                nearDistanceArray = distanceArray.filter{Double($0[0]) ?? 90000000 < 1500}
            case 5..<15:
                nearDistanceArray = distanceArray.filter{Double($0[0]) ?? 90000000 < 2500}
                // 지도를 확대해주세요.(알림창)
            default:
                nearDistanceArray = distanceArray.filter{Double($0[0]) ?? 90000000 < 1800}
            }
            
            //poitem1으로 추가해서 화면에 표시한다.
            
            if nearDistanceArray.count == 0 {
                //현재 위치에는 등록된 의류수거함이 없습니다.
                
            } else {
                for i in 1...nearDistanceArray.count - 1 {
                    let poitem1 = MTMapPOIItem()
                    poitem1.mapPoint = MTMapPoint(geoCoord: MTMapPointGeo(latitude: Double(nearDistanceArray[i][1])!, longitude: Double(nearDistanceArray[i][2])!))
                    poitem1.itemName = nearDistanceArray[i][3]
                    poitem1.markerType = .redPin
                    
                    mapView.addPOIItems([poitem1])
                }
            }
            
        }
    }
    
    
    //데이터를 cvs에서 불러와서 poitem1의 배열에 담아 이를 mapView에 띄움.
    private func loadData(cvsArray dataArr:[[String]],  completionHandler: @escaping () -> Void ) {
        
        //로딩중 표시
        print("ㅇㅅㅇ?\(dataArr.count)")
        DispatchQueue.main.async {
            
            //self.view.backgroundColor = UIColor.white
            self.activityIndicator.startAnimating()
            self.view.addSubview(self.activityIndicator)
        }
        print("로딩중 표시 - loadData3")
        print(dataArr.count - 1 )
                for i in 0 ..< dataArr.count - 1 {
        
                   
                    let info = dataArr[i][0]
        
                    print()
                    let lat = dataArr[i][1]
                    let lon = dataArr[i][2].split(separator: "\r")
                    
                    let stringLon = String(lon[0])
        
                    let poitem1 = MTMapPOIItem()
        
                    //뷰 만들고 클릭되면 띄우기..?
                    poitem1.itemName = info
                    
                    poitem1.mapPoint = MTMapPoint(geoCoord: MTMapPointGeo(latitude: Double(lat) ?? 0, longitude: Double(stringLon) ?? 0))
                    poitem1.markerType = .redPin
                    
                    mapView.addPOIItems([poitem1])
                }
        print("컴플리션 핸들러 호출")
        print("로딩중 표시 - loadData4")

        completionHandler()
       
        
    }
    
    func removePOIItemsData() {
        mapView.removeAllPOIItems()
    }
    
    //MARK: - PickerView, UI 설정
    func createPickerView() {
        let pickerView = UIPickerView()
        pickerView.delegate = self
        //pickerView.dataSourece = self
        
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
        case "서울시 동작구":
            if pickerViewcityListIsOn[currentRow] == false {
                UIPickerToCVS(resourceFileName:pickerToFileDictionary["서울시 동작구"]!)
            }
        case "서울시 구로구":
            if pickerViewcityListIsOn[currentRow] == false {
                UIPickerToCVS(resourceFileName:pickerToFileDictionary["서울시 구로구"]!)
            }
        case "서울시 영등포구":
            if pickerViewcityListIsOn[currentRow] == false {
                UIPickerToCVS(resourceFileName:pickerToFileDictionary["서울시 영등포구"]!)
            }
        case "서울시 양천구":
            if pickerViewcityListIsOn[currentRow] == false {
                UIPickerToCVS(resourceFileName:pickerToFileDictionary["서울시 양천구"]!)
            }
        case "서울시 관악구":
            if pickerViewcityListIsOn[currentRow] == false {
                UIPickerToCVS(resourceFileName:pickerToFileDictionary["서울시 관악구"]!)
            }
        case "서울시 종로구":
            if pickerViewcityListIsOn[currentRow] == false {
                UIPickerToCVS(resourceFileName:pickerToFileDictionary["서울시 종로구"]!)
            }
            
            
        default:
            locationSelectButton.resignFirstResponder()
        }
        locationSelectButton.resignFirstResponder()
        /// 피커뷰 내림
    }
    
    func UIPickerToCVS (resourceFileName:String) {
        CVSdataArray = []
        removePOIItemsData()
        loadDataFromCVSAt(resource: resourceFileName)
        if CVSdataArray.count != 0 {
            
            loadData(cvsArray:CVSdataArray) {
                print("클로저 실행1")
                DispatchQueue.main.async {
                    if self.activityIndicator.isAnimating {
                        self.activityIndicator.stopAnimating()
                        self.activityIndicator.isHidden = true
                    }
                       }
                
                print("클로저 stopAnimating")
                
            }
            
            //mapView의 시점을 배열의 목록 중 가운데 지점의 좌표로 보냄.
            mapView.setMapCenter(MTMapPoint(geoCoord: MTMapPointGeo(latitude: Double(CVSdataArray[Int(trunc(Double(CVSdataArray.count/2)))][1]) ?? 126.978179, longitude: Double(CVSdataArray[Int(trunc(Double(CVSdataArray.count/2)))][2].split(separator: "\r")[0]) ?? 126.978179)), animated: true)
            mapView.setZoomLevel(1, animated: true)
            mapView.fitAreaToShowAllPOIItems()
            //mapView.fit
    //mapView.
            
        }
        
        for i in 0..<pickerViewcityListIsOn.count {
            pickerViewcityListIsOn[i] = false
        }
        
        pickerViewcityListIsOn[currentRow] = true
    }
    
    @objc func onPickCancel() {
        locationSelectButton.resignFirstResponder() /// 피커뷰 내림
    }
    
    
    
}


//MARK: - PickerView 익스텐션 구현

extension ViewController: UITextFieldDelegate,UIPickerViewDelegate,UIPickerViewDataSource{
    
    //PickerView의 component 개수
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    //PickerView의 component별 행수
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerViewcityList.count
    }
    
    //PickerView의 component의 내용에 들어갈 list
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return "\(pickerViewcityList[row])"
    }
    //피커뷰에서 선택된 행을 처리할 수 있는 메서드
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        //선택된 city를 selectedCity에 넣어줌.
        selectedCity = pickerViewcityList[row]
        
        currentRow=row
        
    }
    
    
    
    
    
}
