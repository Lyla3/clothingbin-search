//
//  tableViewSearchViewController.swift
//  daummap
//
//  Created by Lyla on 2023/05/29.
//

import Foundation
import UIKit
import MapKit

protocol SendUpdateLocationDelegate: AnyObject {
    func sendUpdate(location: CLLocationCoordinate2D?)
}

class LocationCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
}

class TableViewSearchViewController: UIViewController, UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate {
    
    var delegate: SendUpdateLocationDelegate?
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchbar: UISearchBar!
    
    let storyboardName = "TableViewSearchAddressView"
    let storyboardID = "addressTableSearchVC"
    
    
    //검색을 도와줌
    private var searchCompleter: MKLocalSearchCompleter?
    
    //검색 지역 범위를 결정
    private var searchRegion: MKCoordinateRegion = MKCoordinateRegion(MKMapRect.world)
    
    //검색한 결과를 담는 변수
    var completerResults: [MKLocalSearchCompletion]?
    
    // tableView에서 선택한 Location의 정보를 담는 변수
    private var places: MKMapItem? {
        didSet {
            self.tableView.reloadData()
        }
        willSet{
            print("\(String(describing: places))")
        }
    }
    
    //tableView에서 선택한 Location의 정보를 담는 변수
    private var localSearch: MKLocalSearch? {
        willSet {
            // Clear the results and cancel the currently running local search before starting a new search.
            places = nil
            localSearch?.cancel()
        }
    }
    
    private func search(for suggestedCompletion: MKLocalSearchCompletion) {
        let searchRequest = MKLocalSearch.Request(completion: suggestedCompletion)
        search(using: searchRequest)
    }
    
    func closeView(location:CLLocationCoordinate2D?) {
        let vc = AddressSearchViewController()
        vc.selectedLocation = location
        print("\(location?.latitude)")
        if let a = location?.latitude {
            print(a)
            vc.locationString = String(a)
            //vc.addressLabel.text = String(a)
        }
        
        self.dismiss(animated: true)
    }
    
    private func search(using searchRequest: MKLocalSearch.Request) {
        // 검색 지역 설정
        searchRequest.region = searchRegion
        
        // 검색 유형 설정
        searchRequest.resultTypes = .address
        // MKLocalSearch 생성
        localSearch = MKLocalSearch(request: searchRequest)
        // 비동기로 검색 실행
        localSearch?.start { [unowned self] (response, error) in
            guard error == nil else {
                return
            }
            // 검색한 결과 : reponse의 mapItems 값을 가져온다.
            self.places = response?.mapItems[0]
            
            print(places?.placemark.coordinate) // 위경도 가져옴
            
            //다른 페이지로 넘겨주고 종료..?
            closeView(location: places?.placemark.coordinate)
            
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchCompleter = MKLocalSearchCompleter()
        searchCompleter?.delegate = self
        //searchCompleter?.resultTypes = .address // 혹시 값이 안날아온다면 이건 주석처리 해주세요
        searchCompleter?.region = searchRegion
        
        searchbar.delegate = self
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    //메모리에서 직접 해제
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        searchCompleter = nil
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if delegate == nil {
            print("delegate = nil")
        }
        delegate?.sendUpdate(location: places?.placemark.coordinate)
        print("TableViewSearchController - viewWillDisappear")
    }
    
}

extension TableViewSearchViewController {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText == "" {
            completerResults = nil
        }
        
        searchCompleter?.queryFragment = searchText
    }
}

extension TableViewSearchViewController: MKLocalSearchCompleterDelegate {
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        completerResults = completer.results
        tableView.reloadData()
    }
    
    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        if let error = error as NSError? {
            print("MKLocalSearchCompleter encountered an error: \(error.localizedDescription). The query fragment is: \"\(completer.queryFragment)\"")
        }
    }
}
extension TableViewSearchViewController{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return completerResults?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as? LocationCell else { return UITableViewCell()}
        
        if let suggestion = completerResults?[indexPath.row] {
            cell.titleLabel.text = suggestion.title
            cell.subtitleLabel.text = suggestion.subtitle
        }
        return cell
    }
}

// 결과에서 행 선택 시 결과값을 담는다.
extension TableViewSearchViewController {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true) // 선택 표시 해제
        
        
        if let suggestion = completerResults?[indexPath.row] {
            search(for: suggestion)
        }
    }
}
