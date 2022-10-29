//
//  ViewController.swift
//  daummap채ㅣ
//
//  Created by 너굴 on 2022/10/04.
//

import UIKit
import CoreLocation


class ViewController: UIViewController,MTMapViewDelegate,CLLocationManagerDelegate, MTMapReverseGeoCoderDelegate {
    
    
    
    public var geocoder: MTMapReverseGeoCoder!
    var mapView:MTMapView!
    
    var locationManager: CLLocationManager!
    var clLatitude: Double?
    var clLongitude: Double?
    
    var address: String?
    var currentLocationButtonPressed: Bool = false
    
    var pickerViewcityList = [String](["서울시 동작구","서울시 구로구","서울시 양천구","서울시 종로구","서울시 영등포구","서울시 관악구"])
    
    var pickerToFileDictionary : [String:String] = ["서울시 동작구":"ClothingBin_Dongjak","서울시 구로구":"Seoul_guro","서울시 양천구":"Seoul_Yangcheon","서울시 종로구":"Seoul_Gongro","서울시 영등포구":"Seoul_Yeoungdeungpo","서울시 관악구":"Seoul_gwanak"]
    
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
        self.view.addSubview(self.locationSelectButton)
        
        currentLocationButton.addTarget(self, action: #selector(currentLocationButtonTapped), for: .touchUpInside)
        
        
        locationSelectButton.addTarget(self, action: #selector(locationSelectButtonTapped), for: .touchUpInside)
        
        mapView.setZoomLevel(2, animated: false)
        
        //mapView.currentLocationTrackingMode = .onWithoutHeading
        
        
        //현재위치 버튼 레이아웃
        NSLayoutConstraint.activate([
            self.currentLocationButton.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 100),
            self.currentLocationButton.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 328),
            self.currentLocationButton.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -30)
        ])
        
        //지역선택 버튼 레이아웃
        NSLayoutConstraint.activate([
            self.locationSelectButton.topAnchor.constraint(equalTo: self.view.topAnchor, constant:750),
            self.locationSelectButton.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 10),
            self.locationSelectButton.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -10)
        ])
        
        //loadDataFromCVS()
        
        
        loadData(cvsArray:CVSdataArray)
        
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
        clLatitude = coor?.latitude
        clLongitude = coor?.longitude
        
        mapView.setMapCenter(MTMapPoint(geoCoord: MTMapPointGeo(latitude: clLatitude!, longitude: clLongitude!)), animated: true)
    }
    
    @objc func currentLocationButtonTapped(sender: UIButton) {
        
        print("현재위치 버튼이 눌렸습니다. ")
        
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
    
    
    
    private func loadData(cvsArray dataArr:[[String]]) {
        for i in 0..<dataArr.count {
            let lat = dataArr[i][1]
            let lon = dataArr[i][2].split(separator: "\r")
            let info = dataArr[i][0]
            
            
            let stringLon = String(lon[0])
            
            let poitem1 = MTMapPOIItem()
            
            poitem1.itemName = info
            poitem1.mapPoint = MTMapPoint(geoCoord: MTMapPointGeo(latitude: Double(lat) ?? 0, longitude: Double(stringLon) ?? 0))
            poitem1.markerType = .redPin
            
            mapView.addPOIItems([poitem1])
        }
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
                UIPickerToCVS(resourceFileName:pickerToFileDictionary["서울시 종로스위프트 구"]!)
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
        loadData(cvsArray:CVSdataArray)
        
        print("CVSdataArray의 값\(CVSdataArray.count/2)")
        
        print("CVSdataArray: \(Int(trunc(Double(CVSdataArray.count/2))))")
        
        //mapView의 시점을 배열의 목록 중 가운데 지점의 좌표로 보냄.
        mapView.setMapCenter(MTMapPoint(geoCoord: MTMapPointGeo(latitude: Double(CVSdataArray[Int(trunc(Double(CVSdataArray.count/2)))][1]) ?? 126.978179, longitude: Double(CVSdataArray[Int(trunc(Double(CVSdataArray.count/2)))][2].split(separator: "\r")[0]) ?? 126.978179)), animated: true)
        
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
