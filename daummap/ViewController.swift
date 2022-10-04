//
//  ViewController.swift
//  daummap
//
//  Created by 너굴 on 2022/10/04.
//

import UIKit

class ViewController: UIViewController,MTMapViewDelegate {
    
    var mapView:MTMapView!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    
        mapView = MTMapView(frame: self.view.frame)
        mapView.delegate = self
        mapView.baseMapType = .standard
        self.view.addSubview(mapView)
    
    
    
    }


}

