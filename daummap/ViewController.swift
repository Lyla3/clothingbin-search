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
    
    //class로 불러오고 싶음..
    var positiondatas : PositionData = PositionData()
    //positiondatas.lat = 37.48140771807268
    //positiondatas.long = 126.97172329551269
    
    //엑셀 파일 불러오기
    var clotingBinDongjak : [[String]] = []
    
    
    //버튼
    private let button: UIButton = {
        let button = UIButton()
        button.setTitle("위치 추가", for: .normal)
        button.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1)
        button.setTitleColor(.black, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        // 현재 위치 받아와서 centerpoint로 설정.
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        
        locationManager.requestWhenInUseAuthorization()
        
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        locationManager.startUpdatingLocation()
        

        
        
        let coor = locationManager.location?.coordinate
        clLatitude = coor?.latitude
        clLongitude = coor?.longitude
        
        mapView = MTMapView(frame: self.view.frame)
        mapView.delegate = self
        mapView.baseMapType = .standard
        self.view.addSubview(mapView)
        self.view.addSubview(self.button)
        
        button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        
        mapView.setMapCenter(MTMapPoint(geoCoord: MTMapPointGeo(latitude: clLatitude!, longitude: clLongitude!)), animated: true)
        
        
        mapView.setZoomLevel(2, animated: false)
        //mapView.currentLocationTrackingMode = .onWithoutHeading
        
        //버튼 레이아웃
        NSLayoutConstraint.activate([
            self.button.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 70),
            self.button.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
        ])
        
        
        loadDataFromCVS()
        
  
        
        //print(clotingBinDongjak)
        print(clotingBinDongjak[0][1])
        
        
      
        for i in 0..<clotingBinDongjak.count {
                var lat1 = clotingBinDongjak[i][1]
            }
      
        loadData(cvsArray:clotingBinDongjak)
        
        
        loadPin()
       
        
    }
    
    //MARK: - longTap
    func mapView(_ mapView: MTMapView!, longPressOn mapPoint: MTMapPoint!) {
        print("길게 화면이 눌렸습니다")
        print("Point: \(String(describing: mapPoint))")
        
        let geocoder = MTMapReverseGeoCoder(mapPoint: mapPoint, with: self, withOpenAPIKey: "c5011a61810b5ec038918fd448cd330d")
        
        self.geocoder = geocoder
        geocoder?.startFindingAddress()
      
        let alert = UIAlertController(title: "이 위치에 의류수거함을 추가하시겠습니까?\(geocoder))", message: "", preferredStyle: UIAlertController.Style.alert)
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
    
//    // 좌표를 통해 얻은 문자열 값을 불러오기 위한 함수
//    func mtMapReverseGeoCoder(_ rGeoCoder: MTMapReverseGeoCoder!, foundAddress addressString: String!) {
//        guard let addressString = addressString else {return}
//        address = addressString
//    }
    
    
    @objc func buttonTapped(sender: UIButton) {
        print("버튼이 눌렸습니다.")
        
        
        let poitem1 = MTMapPOIItem()
        
        //구현: 화면 중심점 추가
        poitem1.itemName = "지점"
        poitem1.mapPoint = MTMapPoint(geoCoord: MTMapPointGeo(latitude: 37.49416901892008, longitude: 127.0091708551989))
        poitem1.markerType = .redPin
        
        mapView.addPOIItems([poitem1])
    }
    
    @objc func loadPin() {
        
        let poitem2 = MTMapPOIItem()
        
        //구현: 화면 중심점 추가
        poitem2.itemName = "헌옷수거함"
        poitem2.mapPoint = MTMapPoint(geoCoord: MTMapPointGeo(latitude: 37.48140771807268, longitude: 126.97172329551269))
        poitem2.markerType = .yellowPin
        
        mapView.addPOIItems([poitem2])
        
        
    }
    
    //MARK: - 엑셀 파일 파싱 함수
    private func parseCSVAt(url:URL) {
        do {
            let data = try Data(contentsOf: url)
            let dataEncoded = String(data: data, encoding: .utf8)
            
            if let dataArr = dataEncoded?.components(separatedBy: "\n").map({$0.components(separatedBy: ",")}) {
                
                for item in dataArr{
                    clotingBinDongjak.append(item)
                }
            }
            
        } catch {
            print("Error reading CVS file.")
        }
    }
    
    private func loadDataFromCVS() {
        let path = Bundle.main.path(forResource: "ClothingBin_Dongjak", ofType: "csv")!
        parseCSVAt(url: URL(fileURLWithPath: path))
    }
    
    private func loadData(cvsArray dataArr:[[String]]) {
        for i in 0..<dataArr.count {
            let lat = dataArr[i][1]
            let lon = dataArr[i][2].split(separator: "\r")
            let info = dataArr[i][0]

            //var stringLon = String(lon)
            
//            let poitem1 = MTMapPOIItem()
//
//            //구현: 화면 중심점 추가
//            poitem1.itemName = "지점"
//            poitem1.mapPoint = MTMapPoint(geoCoord: MTMapPointGeo(latitude: 37.49416901892008, longitude: 127.0091708551989))
//            poitem1.markerType = .redPin
//
//            mapView.addPOIItems([poitem1])
            
            //print("lat: \(lat) lon: \(lon)")
            
            let stringLon = String(lon[0])
            
            let poitem1 = MTMapPOIItem()

            poitem1.itemName = info
            poitem1.mapPoint = MTMapPoint(geoCoord: MTMapPointGeo(latitude: Double(lat) ?? 0, longitude: Double(stringLon) ?? 0))
            poitem1.markerType = .redPin

            mapView.addPOIItems([poitem1])
        }
        
    }
    

}
