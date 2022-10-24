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
    //var pickerList = [String](["서울시 동작구", "서울시 구로구", "서울시 서대문구"])
    var pickerViewcityList = [String](["서울시 동작구","서울시 구로구","서울시 양천구","서울시 종로구","서울시 영등포구","서울시 관악구"])
    var pickerViewcountyList = [String](["동작구", "구로구", "서대문구"])
    
    var selectedCity : String = "서울"
    var selectedCounty : String = "동작구"
    
    
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
        locationSelectButton.text = "\(selectedCity) \(selectedCounty)"
    
        
        switch selectedCity {
        case "서울":
            print("서울이 선택되었습니다.")
            loadDataFromCVSAt(resource: "ClothingBin_Dongjak")
            loadData(cvsArray:CVSdataArray)
            //locationSelectButton.resignFirstResponder()
        default:
            locationSelectButton.resignFirstResponder()
        }
        locationSelectButton.resignFirstResponder()
       /// 피커뷰 내림
    }
    
    @objc func onPickCancel() {
        locationSelectButton.resignFirstResponder() /// 피커뷰 내림
    }
    
}

//MARK: - PickerView 익스텐션 구현

extension ViewController: UITextFieldDelegate,UIPickerViewDelegate,UIPickerViewDataSource{
    
    //PickerView의 component 개수
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    
    //PickerView의 component별 행수
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch component {
        case 0:
            return pickerViewcityList.count
        case 1:
            return pickerViewcountyList.count
        default:
            return 0
        }
    }
    
    //PickerView의 component의 내용에 들어갈 list
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch component {
                case 0:
                    return "\(pickerViewcityList[row])"
                case 1:
                    return "\(pickerViewcountyList[row])"
                default:
                    return ""
                }
    }
    //피커뷰에서 선택된 행을 처리할 수 있는 메서드
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch component {
        case 0:
            selectedCity = pickerViewcityList[row]
        case 1:
            selectedCounty = pickerViewcountyList[row]
        default:
            break
            
        }
    }
    
    
    
}
