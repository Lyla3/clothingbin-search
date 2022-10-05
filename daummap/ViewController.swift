//
//  ViewController.swift
//  daummap
//
//  Created by 너굴 on 2022/10/04.
//

import UIKit
import CoreLocation

class ViewController: UIViewController,MTMapViewDelegate,CLLocationManagerDelegate {
    
    public var geocoder: MTMapReverseGeoCoder!
    var mapView:MTMapView!
    
    var locationManager: CLLocationManager!
    var clLatitude: Double?
    var clLongitude: Double?
    
    
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
        
        //
        
        
    }
    
    
    func mapView(_ mapView: MTMapView!, longPressOn mapPoint: MTMapPoint!) {
        print("길게 화면이 눌렸습니다")
        print("Point: \(String(describing: mapPoint))")
        
        
    }
    
    
    
    @objc func buttonTapped(sender: UIButton) {
        print("버튼이 눌렸습니다.")
        
        
        let poitem1 = MTMapPOIItem()
        
        //구현: 화면 중심점 추가
        poitem1.itemName = "지점"
        poitem1.mapPoint = MTMapPoint(geoCoord: MTMapPointGeo(latitude: 37.49416901892008, longitude: 127.0091708551989))
        poitem1.markerType = .redPin
        
        mapView.addPOIItems([poitem1])
    }
    
}

