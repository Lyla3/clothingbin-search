//
//  AddressSearch.swift
//  daummap
//
//  Created by Lyla on 2023/05/21.
//
// AddressSearchView - 주소 추가(firebase에 업로드)

import Foundation
import UIKit
import FirebaseStorage
import Firebase
import FirebaseDatabase
import FirebaseFirestore
import CoreLocation


class AddressSearchViewController: UIViewController, UINavigationControllerDelegate, SendDataProtocol, SendUpdateLocationDelegate {
    
    
    var location:[String] = []
    func sendUpdate(location: CLLocationCoordinate2D?) {
        //
        selectedLocation = location
        DispatchQueue.main.async {
            if let latitude = self.selectedLocation?.latitude {
                self.addressLabel.text = "\(latitude)"
            }
        }
        print("sendUpdate 실행완료")
    }
    
    
    
    
    //MARK: - Properites
    private var clotingBinImage: UIImage?
    
    func sendUpzdate(location: CLLocationCoordinate2D?) {
        print("sendUpdate-addressView")
        selectedLocation = location
        print("\(selectedLocation)")
        if let nonOptionalLocation = selectedLocation?.longitude {
            print("nonOptionalLocation")
            addressLabel.text = String(format:"%f",nonOptionalLocation)
        }
    }
    
    
    var firebaseDB: DatabaseReference!
    @IBOutlet var addressLabel: UILabel!
    @IBOutlet var clothingBinImageButton: UIButton!
    
    @IBOutlet var cordinateLabel: UILabel!
    
    let imagePicker = UIImagePickerController()
    let storage = Storage.storage()
    var selectedLocation : CLLocationCoordinate2D?
    
    var locationString : String = "" {

        willSet(newValue){
            print(newValue)
        }
    }

    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?){
        self.view.endEditing(true)
    }
    //storyboardName : 파일이름, storyboardID : ViewController의 ID
    let storyboardName = "AddressSearchView"
    let storyboardID = "addressSearchVC1"
    
    override func viewDidLoad() {
        
        let vc = TableViewSearchViewController()
        
        vc.delegate = self
        
        super.viewDidLoad()
        
        // Create a root reference
        let storageRef = storage.reference()
        
        
        let riversRef = storageRef.child("images/rivers.jpg")
        
        // Create a reference to "mountains.jpg"
        let mountainsRef = storageRef.child("mountains.jpg")
        
        // Create a reference to 'images/mountains.jpg'
        let mountainImagesRef = storageRef.child("images/mountains.jpg")
        
        // Create a reference to the file you want to upload
        "\(selectedLocation?.latitude)"
    }
    override func viewWillAppear(_ animated: Bool) {
        print("주소:\(String(describing: selectedLocation))")
        //addressLabel.text = String(describing: selectedLocation)
    }
    
    func dataSend(data: String) {
        print("dataSend 실행 ")
        addressLabel.text = data
    }
    
    @IBAction func addLoctionButtonTapped(_ sender: UIButton) {
        print("Button Pressed")
        
        let vc = TableViewSearchViewController()
        
        let storyboardName = vc.storyboardName
        let storyboardID = vc.storyboardID
        
        let storyboard = UIStoryboard(name: storyboardName, bundle: Bundle.main)
        let viewController = storyboard.instantiateViewController(identifier: storyboardID) as TableViewSearchViewController
        vc.delegate = self
        vc.dataDelegate = self
        vc.modalPresentationStyle = UIModalPresentationStyle.fullScreen
        
        viewController.delegate = self
        //self.navigationController?.pu
        
        present(viewController, animated: true)
        //
        
        
        
        present(vc, animated: true, completion: nil)

        
        
        
        
    }
    
    
    
    
    @IBAction func submitButtonTapped(_ sender: Any) {
        //        guard let content = "test data" else {return}
        //        let message = Message(id: "234", content: content)
        //
        //        storage.
        let storageRef = Storage.storage().reference()
        //new for database
        firebaseDB = Database.database().reference()
        //firebaseDB.child(Date().toString()).setValue(addressTextfield.text)
        firebaseDB.child("냥냥").setValue("\(String(describing: addressLabel.text))")
        // Data in memory
        let data = Data()
        
        
        let dbRef = Firestore.firestore().collection("location")
        
        dbRef.getDocuments { (snapshot, error) in
            if let snapshot {
                var tempLocation: [String] = []
                
                for document in snapshot.documents {
                    let id: String = document.documentID
                    
                    let docData: [String : Any] = document.data()
                    let loc: String = docData["loc"] as? String ?? ""
                    
                    //self.location[0] = self.addressLabel.text ?? ""
                    
                    //tempLocation.append(self.location[0])
                    
                    // 데이터 올리기 loc인 데이터에 올린다, id는 새로 생성
                    // dbRef.document(id).setData(["loc":String(describing: self.addressLabel.text)])
                    dbRef.document(id).setData(["loc":self.locationString])
                    print("locationString: \(self.locationString)")
                }
                self.location = tempLocation
            }
        }
        
        // Create a reference to the file you want to upload
        let riversRef = storageRef.child("currentLocation.jpg")
        
        // Upload the file to the path "images/rivers.jpg"
        let uploadTask = riversRef.putData(data, metadata: nil) { (metadata, error) in
            guard let metadata = metadata else {
                // Uh-oh, an error occurred!
                return
            }
            // Metadata contains file metadata such as size, content-type.
            let size = metadata.size
            // You can also access to download URL after upload.
            riversRef.downloadURL { (url, error) in
                guard let downloadURL = url else {
                    // Uh-oh, an error occurred!
                    return
                }
            }
        }
        
        
    }
    
  
    @IBAction func closeButtonTapped(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
    @IBAction func clothingbinImageButtonTapped(_ sender: UIButton) {
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        present(imagePicker,animated: true, completion: nil)
    }
    
    
    func uploadData(input: String) {
        var data = Data()
        //data = "test String"
        let fileName = "name"
        let metaData = StorageMetadata()
        metaData.contentType = ""
    }
    
    func checkData(str : String) -> Void {
        print("잘 받았나? :\(str)")
        locationString = "경도: \(str)"
    }
}


extension Encodable {
    var asDictionary: [String: Any]? {
        guard let object = try? JSONEncoder().encode(self),
              let dictinoary = try? JSONSerialization.jsonObject(with: object, options: []) as? [String: Any] else { return nil }
        return dictinoary
    }
}


extension Date {
    func toString() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateFormatter.timeZone = TimeZone(identifier: "UTC")
        return dateFormatter.string(from: self)
    }
}

extension AddressSearchViewController : UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let userPickedImage = info[UIImagePickerController.InfoKey.originalImage]
        
        guard let selectedImage = info[.editedImage] as? UIImage else {return}
        
        clotingBinImage = selectedImage
        clothingBinImageButton.setImage(selectedImage.withRenderingMode(.alwaysOriginal), for: .normal)
        //clothingBinImageButton.setImage(selectedImage.withRenderingMode(.alwaysOriginal), for: .)
        //photoImageView.image = clotingBinImage
        
        self.dismiss(animated: true, completion: nil)
    }
}
