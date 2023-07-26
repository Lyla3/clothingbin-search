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
import CoreLocation


class AddressSearchViewController: UIViewController, UINavigationControllerDelegate, SendUpdateLocationDelegate {
    func sendUpdate(location: CLLocationCoordinate2D?) {
        //
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
        //addressLabel.text = 
    
        
        
        //
        
    }
    
    
    var firebaseDB: DatabaseReference!
    
    
    @IBOutlet var addressLabel: UILabel!
    
    @IBOutlet var clothingBinImageButton: UIButton!
    
    let imagePicker = UIImagePickerController()
    
    let storage = Storage.storage()
    
    var selectedLocation : CLLocationCoordinate2D?
    
    // While the file names are the same, the references point to different files
    // mountainsRef.name == mountainImagesRef.name            // true
    // mountainsRef.fullPath == mountainImagesRef.fullPath    // false
        
    
    

    //var firebaseDB: DatabaseReference
    //let myFirestore = MyFir
    
    var locationString : String = ""
    
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
        
        //여기 주석
        //imagePicker.delegate = self
        //imagePicker.allowsEditing = false
        //imagePicker.sourceType = .camera

        //photoImageView.layer.borderWidth  = 0.5
        //photoImageView.layer.borderColor = UIColor.lightGray.cgColor
        
        
        // Create a root reference
        let storageRef = storage.reference()

        
        let riversRef = storageRef.child("images/rivers.jpg")
        
        // Create a reference to "mountains.jpg"
        let mountainsRef = storageRef.child("mountains.jpg")

        // Create a reference to 'images/mountains.jpg'
        let mountainImagesRef = storageRef.child("images/mountains.jpg")

        // Create a reference to the file you want to upload
        
    }
    override func viewWillAppear(_ animated: Bool) {
        print("주소:\(String(describing: selectedLocation))")
        //addressLabel.text = String(describing: selectedLocation)
    }
    
    
    @IBAction func addLoctionButtonTapped(_ sender: UIButton) {
        print("Button Pressed")
        
        let vc = TableViewSearchViewController()
        
        let storyboardName = vc.storyboardName
        let storyboardID = vc.storyboardID
        
        let storyboard = UIStoryboard(name: storyboardName, bundle: Bundle.main)
        let viewController = storyboard.instantiateViewController(identifier: storyboardID)
        vc.delegate = self

        present(viewController, animated: true)
        
        
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
        firebaseDB.child("냥냥").setValue("value값 입니다")
        // Data in memory
        let data = Data()

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
    
    //여기
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
