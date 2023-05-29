//
//  AddressSearch.swift
//  daummap
//
//  Created by Lyla on 2023/05/21.
//

import Foundation
import UIKit
import FirebaseStorage
import Firebase
import FirebaseDatabase


class AddressSearchViewController: UIViewController,UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var firebaseDB: DatabaseReference!
    
    @IBOutlet var photoImageView: UIImageView!
    
    @IBOutlet var addressTextfield: UITextField!
    
    let imagePicker = UIImagePickerController()
    
    let storage = Storage.storage()
    
    
    // While the file names are the same, the references point to different files
    // mountainsRef.name == mountainImagesRef.name            // true
    // mountainsRef.fullPath == mountainImagesRef.fullPath    // false
        
    
    

    //var firebaseDB: DatabaseReference
    //let myFirestore = MyFir
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?){
             self.view.endEditing(true)
       }
    //storyboardName : 파일이름, storyboardID : ViewController의 ID
    let storyboardName = "AddressSearchView"
    let storyboardID = "addressSearchVC"
    
    override func viewDidLoad() {
         super.viewDidLoad()
        
        imagePicker.delegate = self
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .camera
        addressTextfield.layer.borderColor = UIColor.lightGray.cgColor
        addressTextfield.layer.borderWidth = 0.5
        photoImageView.layer.borderWidth  = 0.5
        photoImageView.layer.borderColor = UIColor.lightGray.cgColor
        
        
        // Create a root reference
        let storageRef = storage.reference()

        
        let riversRef = storageRef.child("images/rivers.jpg")
        
        // Create a reference to "mountains.jpg"
        let mountainsRef = storageRef.child("mountains.jpg")

        // Create a reference to 'images/mountains.jpg'
        let mountainImagesRef = storageRef.child("images/mountains.jpg")

        // Create a reference to the file you want to upload

        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let userPickedImage = info[UIImagePickerController.InfoKey.originalImage]
    }
    
    
    
    
    @IBAction func submitButtonTapped(_ sender: Any) {
//        guard let content = "test data" else {return}
//        let message = Message(id: "234", content: content)
//
//        storage.
        let storageRef = Storage.storage().reference()

        
        
        
        //new for database
        firebaseDB = Database.database().reference()
        firebaseDB.child(Date().toString()).setValue(addressTextfield.text)
        firebaseDB.child("냥냥").setValue("오이시쿠나레")
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
    
    
    @IBAction func closeButtonTapped(_ sender: UIButton) {
        dismiss(animated: true)
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

