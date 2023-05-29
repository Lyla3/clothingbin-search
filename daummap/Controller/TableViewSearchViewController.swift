//
//  tableViewSearchViewController.swift
//  daummap
//
//  Created by Lyla on 2023/05/29.
//

import Foundation
import UIKit
import MapKit

class TableViewSearchViewController: UIViewController, MKLocalSearchCompleterDelegate, UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        <#code#>
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        <#code#>
    }
    
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchbar: UISearchBar!
    
    //검색을 도와줌
    private var searchCompleter: MKLocalSearchCompleter?
    
    //검색 지역 범위를 결정
    private var searchRegion: MKCoordinateRegion = MKCoordinateRegion(MKMapRect.world)
    
    //검색한 결과를 담는 변수
    var completerResults: [MKLocalSearchCompletion]?

    // tableView에서 선택한 Location의 정보를 담는 변수
    private var places: MKMapItem? {
           didSet {
               tableView.reloadData()
           }
       }
    
    //tableView에서 선택한 Location의 정보를 가져오는 변수
    private var localSearch: MKLocalSearch? {
          willSet {
              // Clear the results and cancel the currently running local search before starting a new search.
              places = nil
              localSearch?.cancel()
          }
      }
    
    
    override func viewDidLoad() {
           super.viewDidLoad()
           
           searchCompleter = MKLocalSearchCompleter()
           searchCompleter?.delegate = self
              searchCompleter?.resultTypes = .address // 혹시 값이 안날아온다면 이건 주석처리 해주세요
           searchCompleter?.region = searchRegion
           
            searchbar.delegate = self
            tableView.dataSource = self
            tableView.delegate = self
       }
       
       override func viewDidDisappear(_ animated: Bool) {
           super.viewDidDisappear(animated)
           searchCompleter = nil
       }

}
