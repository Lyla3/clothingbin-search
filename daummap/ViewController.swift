//
//  ViewController.swift
//  daummap채ㅣ
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
        
        currentLocationbutton.layer.cornerRadius = 2
        currentLocationbutton.layer.shadowColor = UIColor.gray.cgColor
        currentLocationbutton.layer.shadowOpacity = 0.3
        currentLocationbutton.layer.shadowOffset = CGSize.zero
        currentLocationbutton.layer.shadowRadius = 6
        
        
        return currentLocationbutton
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
        //locationSelectButton.font = UIFont(sy)
        
        
        //모서리 및 그림자
        locationSelectButton.layer.cornerRadius = 2
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
    lazy var activityIndicator: UIActivityIndicatorView = {
            // Create an indicator.
            let activityIndicator = UIActivityIndicatorView()
            activityIndicator.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
            activityIndicator.center = self.view.center
            activityIndicator.color = UIColor.red
            // Also show the indicator even when the animation is stopped.
            activityIndicator.hidesWhenStopped = true
        activityIndicator.style = UIActivityIndicatorView.Style.medium
            // Start animation.
            activityIndicator.stopAnimating()
            return activityIndicator }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        //makeUI()
        
        // 현재 위치 받아와서 centerpoint로 설정.
        mapView = MTMapView(frame: self.view.frame)
        mapView.delegate = self
        mapView.baseMapType = .standard
        
        
        loadcurrentLocation()
        createPickerView()
        
        self.view.addSubview(mapView)
        self.view.addSubview(self.currentLocationButton)
        self.view.addSubview(self.locationSelectButton)
        
        
        
        
        currentLocationButton.addTarget(self, action: #selector(currentLocationButtonTapped), for: .touchUpInside)
        
        
        locationSelectButton.addTarget(self, action: #selector(locationSelectButtonTapped), for: .touchUpInside)
        
        mapView.setZoomLevel(2, animated: false)
        
        //mapView.currentLocationTrackingMode = .onWithoutHeading
        
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
            self.currentLocationButton.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -30),
            self.currentLocationButton.widthAnchor.constraint(equalToConstant: 35),
            self.currentLocationButton.heightAnchor.constraint(equalToConstant: 33)
            
            
            
        ])
        
        
        
        //loadDataFromCVS()
        
        //markerInfoView view 레이아웃 설정
        
       

        
//  makerInfoView.translatesAutoresizingMaskIntoConstraints = false
//
//        NSLayoutConstraint.activate([
//
//            self.makerInfoView.widthAnchor.constraint(equalToConstant: 30),
////            self.makerInfoView.topAnchor.constraint(equalTo: self.view.topAnchor, constant:750),
//            self.makerInfoView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 10),
//            self.makerInfoView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -10),
//            self.makerInfoView.heightAnchor.constraint(equalToConstant: 40)
//        ])
        
        //loadData(cvsArray:CVSdataArray)
        
    }
    
   func makeUI(){
       makerInfoView.translatesAutoresizingMaskIntoConstraints = false
       
       makerInfoView.heightAnchor.constraint(equalToConstant: 30).isActive = true
       makerInfoView.widthAnchor.constraint(equalToConstant: 30).isActive = true
       makerInfoView.topAnchor.constraint(equalTo: view.topAnchor, constant: 100).isActive = true
       
       
    }
    
    //MARK: - longTap
    func mapView(_ mapView: MTMapView!, longPressOn mapPoint: MTMapPoint!) {
        print("길게 화면이 눌렸습니다")
        print("Point: \(String(describing: mapPoint))")
        
        
        let alert = UIAlertController(title: "이 위치에 의류수거함을 추가하시겠습니까?", message: "", preferredStyle: UIAlertController.Style.alert)
        let cancle = UIAlertAction(title: "취소", style: .default ,handler: nil)
        
        //확인 버튼
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
        
        loadcurrentLocation()
        
        
        
        if clLatitude != nil && clLatitude != nil {
            
            mapView.setMapCenter(MTMapPoint(geoCoord: MTMapPointGeo(latitude: clLatitude!, longitude: clLongitude!)), animated: true)
            
            let poCurrentItem = MTMapPOIItem()
            
            poCurrentItem.itemName = "현재위치"
            poCurrentItem.mapPoint = MTMapPoint(geoCoord: MTMapPointGeo(latitude: clLatitude!, longitude: clLongitude!))
            poCurrentItem.markerType = .yellowPin
            
            currentLocationButtonPressed = !currentLocationButtonPressed
            print(currentLocationButtonPressed)
            if currentLocationButtonPressed {
                mapView.addPOIItems([poCurrentItem])
                mapView.setMapCenter(MTMapPoint(geoCoord: MTMapPointGeo(latitude: clLatitude!, longitude: clLongitude!)), animated: true)
                
            
                
            } else {
                mapView.removePOIItems([poCurrentItem])
                mapView.setMapCenter(MTMapPoint(geoCoord: MTMapPointGeo(latitude: clLatitude!, longitude: clLongitude!)), animated: true)
            }
            
            //현재 위치 근처의 의류수거함 데이터 불러오는 함수 실행,CVSdataArray 업데이트
            loadDataFromCVSAt(resource:"ClothingBin_all")
            
            //업데이트된 CVSdataArray를 바탕으로 데이터를 불러온다. (가까이 있는 10개)
            //loadData(cvsArray: CVSdataArray)
            nearCurrentloadData(cvsArray: CVSdataArray)
            
        } else {
            self.alertCurrentLocation()
            print("현재 위치를 활성화 해주세요")
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
        
        for i in 0..<dataArr.count {
            
            let lat = dataArr[i][1]
            let lon = dataArr[i][2].split(separator: "\r")
            
            let latDistance = ((Double(lat) ?? 0) - clLatitude!)
            
            //String(lon[0])이 실제 값
            let lonDistance = ((Double(String(lon[0])) ?? 0) - clLongitude!)
            
            let currentDistance = String((pow(latDistance,2) + pow(lonDistance,2)))
            distanceArray.append([currentDistance,lat,String(lon[0])])
        
        }
        
        let sortedArray = distanceArray.sorted(by: {$0[0] < $1[0]})
        dump(sortedArray)
        print(sortedArray)
        if sortedArray.count != 0 {
            print("----------가까운 10개만 반환-----------")
            dump(sortedArray[0...9])
            
            //poitem1으로 추가해서 화면에 표시한다.
            for i in 0...10{
                let poitem1 = MTMapPOIItem()
                poitem1.mapPoint = MTMapPoint(geoCoord: MTMapPointGeo(latitude: Double(sortedArray[i][1])!, longitude: Double(sortedArray[i][2])!))
                poitem1.markerType = .redPin
    
                mapView.addPOIItems([poitem1])
            }
                       
            
        }
    
        
    }
    
    
    //데이터를 cvs에서 불러와서 poitem1의 배열에 담아 이를 mapView에 띄움.
    private func loadData(cvsArray dataArr:[[String]]) {
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
                    
                    //poitem1.customImageAnchorPointOffset =  .init(offsetX: 0, offsetY: 0)
                    
//                    let view = makerInfoView
//                        view.layer.borderColor = UIColor.black.cgColor
//                        view.layer.borderWidth = 1
//                        view.layer.cornerRadius = 10;
//                        view.layer.masksToBounds = true;
                        //view.title_lb.text = title
                        
                    //poitem1.customCalloutBalloonView = view
                    
                    
                    //poitem1.customCalloutBalloonView = makerInfoView
                    
                    //layout 잡기
//                    makerInfoView.translatesAutoresizingMaskIntoConstraints = false
//                    
//                    makerInfoView.heightAnchor.constraint(equalToConstant: 30).isActive = true
//                    makerInfoView.widthAnchor.constraint(equalToConstant: 30).isActive = true
                    //makerInfoView.topAnchor.constraint(equalTo: view.topAnchor, constant: 100).isActive = true
                    
                    //poitem1.customImageAnchorPointOffset = .init(offsetX: 0, offsetY: 0)
                    //poitem1.markerSelectedType =
                    //poitem1.customImageName =
                    mapView.addPOIItems([poitem1])
                }
        
        
        
        //현재위치에서 가까운 10개 뽑기
        var distanceArray:[[String]] = []
        
        //사용 안하는 메서드
//        for i in 0..<dataArr.count {
//
//            let lat = dataArr[i][1]
//            let lon = dataArr[i][2].split(separator: "\r")
//
//            let latDistance = ((Double(lat) ?? 0) - clLatitude!)
//
//            //String(lon[0])이 실제 값
//            let lonDistance = ((Double(String(lon[0])) ?? 0) - clLongitude!)
//
//            let currentDistance = String((pow(latDistance,2) + pow(lonDistance,2)))
//            distanceArray.append([currentDistance,lat,String(lon[0])])
//
//
//            //              데이터 addPOIItems으로 추가 코드
//            //            let stringLon = String(lon[0])
//            //
//            //            let poitem1 = MTMapPOIItem()
//            //
//            //            poitem1.itemName = info
//            //            poitem1.mapPoint = MTMapPoint(geoCoord: MTMapPointGeo(latitude: Double(lat) ?? 0, longitude: Double(stringLon) ?? 0))
//            //            poitem1.markerType = .redPin
//            //
//            //            mapView.addPOIItems([poitem1])
//        }
        
        
        
        
        
        //dump(distanceArray)
//        let sortedArray = distanceArray.sorted(by: {$0[0] < $1[0]})
//        dump(sortedArray)
//        print(sortedArray)
//        if sortedArray.count != 0 {
//            print("----------가까운 10개만 반환-----------")
//            dump(sortedArray[0...9])
//            //poitem1.itemName = info
//            for i in 0...10{
//                let poitem1 = MTMapPOIItem()
//                poitem1.mapPoint = MTMapPoint(geoCoord: MTMapPointGeo(latitude: Double(sortedArray[i][1])!, longitude: Double(sortedArray[i][2])!))
//                poitem1.markerType = .redPin
//
//                mapView.addPOIItems([poitem1])
//            }
//
//
//        }
        
        //dump(sortedArray[0][0])
        
        
        
        mapView.setZoomLevel(4, animated: true)

    }
    
    func removeData() {
        mapView.removeAllPOIItems()
    }
    
    //MARK: - PickerView
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
        mapView.removeAllPOIItems()
        loadDataFromCVSAt(resource: resourceFileName)
        if CVSdataArray.count != 0 {
            loadData(cvsArray:CVSdataArray)
            
            //mapView의 시점을 배열의 목록 중 가운데 지점의 좌표로 보냄.
            mapView.setMapCenter(MTMapPoint(geoCoord: MTMapPointGeo(latitude: Double(CVSdataArray[Int(trunc(Double(CVSdataArray.count/2)))][1]) ?? 126.978179, longitude: Double(CVSdataArray[Int(trunc(Double(CVSdataArray.count/2)))][2].split(separator: "\r")[0]) ?? 126.978179)), animated: true)
            mapView.setZoomLevel(1, animated: true)
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
