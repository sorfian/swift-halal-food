//
//  NewRestaurantController.swift
//  Halal Food
//
//  Created by Sorfian on 01/03/23.
//

import UIKit
import PhotosUI
import Photos
import CoreData
import FirebaseCore
import FirebaseFirestore
import FirebaseStorage

class NewRestaurantController: UITableViewController {
    
    @IBOutlet var nameTextField: RoundedTextField! {
        didSet {
            nameTextField.tag = 1
            nameTextField.becomeFirstResponder()
            nameTextField.delegate = self
        }
    }
    
    @IBOutlet var typeTextField: RoundedTextField! {
        didSet {
            typeTextField.tag = 2
            typeTextField.delegate = self
        }
    }
    
    @IBOutlet var addressTextField: RoundedTextField! {
        didSet {
            addressTextField.tag = 3
            addressTextField.delegate = self
        }
    }
    
    @IBOutlet var phoneTextField: RoundedTextField! {
        didSet {
            phoneTextField.tag = 4
            phoneTextField.delegate = self
        }
    }
    
    @IBOutlet var descriptionTextView: UITextView! {
        didSet {
            descriptionTextView.tag = 5
            descriptionTextView.layer.cornerRadius = 10.0
            descriptionTextView.layer.masksToBounds = true
        }
    }
    
    @IBOutlet var photoImageView: UIImageView! {
        didSet {
            photoImageView.layer.cornerRadius = 10
            photoImageView.layer.masksToBounds = true
        }
    }
    
    var restaurant: Restaurant!
    
    let db = Firestore.firestore()
    let firebaseStorage = Storage.storage().reference()
    var filePath: URL?
    var spinner = UIActivityIndicatorView()
    
    let dateFormatter = DateFormatter()
    var imageReadyToUpload: Data?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.separatorStyle = .none
        
//        Customize the navigation bar appearance
        if let appearance = navigationController?.navigationBar.standardAppearance {
            
            if let customFont = UIFont(name: "Nunito-Bold", size: 40) {
                appearance.titleTextAttributes = [.foregroundColor: UIColor(named: "NavigationBarTitle")!]
                
                appearance.largeTitleTextAttributes = [.foregroundColor: UIColor(named: "NavigationBarTitle")!, .font: customFont]
            }
            
            navigationController?.navigationBar.standardAppearance = appearance
            navigationController?.navigationBar.compactAppearance = appearance
            navigationController?.navigationBar.scrollEdgeAppearance = appearance
        }
        
        // Get the superview's layout
        let margins = photoImageView.superview!.layoutMarginsGuide
        
        // Disable auto resizing mask to use auto layout programmatically
        photoImageView.translatesAutoresizingMaskIntoConstraints = false
        
        // Pin the leading edge of the image view to the margin's leading edge
        photoImageView.leadingAnchor.constraint(equalTo: margins.leadingAnchor).isActive = true
        
        // Pin the trailing edge of the image view to the margin's trailing edge
        photoImageView.trailingAnchor.constraint(equalTo: margins.trailingAnchor).isActive = true
        
        // Pin the top edge of the image view to the margin's top edge
        photoImageView.topAnchor.constraint(equalTo: margins.topAnchor).isActive = true
        
        // Pin the bottom edge of the image view to the margin's bottom edge
        photoImageView.bottomAnchor.constraint(equalTo: margins.bottomAnchor).isActive = true
        
        let onTap = UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing))
        onTap.cancelsTouchesInView = false
        view.addGestureRecognizer(onTap)

    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            let photoSourceRequestController = UIAlertController(title: "", message: NSLocalizedString("Choose your photo source", comment: "Choose your photo source"), preferredStyle: .actionSheet)
            
            let cameraAction = UIAlertAction(title: String(localized: "Camera", comment: "Camera"), style: .default) { action in
                if UIImagePickerController.isSourceTypeAvailable(.camera) {
                    let imagePicker = UIImagePickerController()
                    imagePicker.allowsEditing = false
                    imagePicker.sourceType = .camera
                    
                    self.present(imagePicker, animated: true, completion: nil)
                }
            }
            
            let photosAction = UIAlertAction(title: NSLocalizedString("Photos", comment: "Photos"), style: .default) { action in
                
                var config = PHPickerConfiguration(photoLibrary: .shared())
                config.selectionLimit = 3
                config.filter = PHPickerFilter.any(of: [.images, .livePhotos, .panoramas, .screenshots])
                let vc = PHPickerViewController(configuration: config)
                vc.delegate = self
                self.present(vc, animated: true, completion: nil)
                
            }
            
            let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: "Cancel"), style: .cancel)
            
            photoSourceRequestController.addAction(cameraAction)
            photoSourceRequestController.addAction(photosAction)
            photoSourceRequestController.addAction(cancelAction)
            
//            For Ipad
            if let popoverPresentationController = photoSourceRequestController.popoverPresentationController {
                if let cell = tableView.cellForRow(at: indexPath) {
                    popoverPresentationController.sourceView = cell
                    popoverPresentationController.sourceRect = cell.bounds
                    
                }
            }
            
            present(photoSourceRequestController, animated: true, completion: nil)
        }
    }
    
    @IBAction func buttonTapped(sender: UIButton) {
        if nameTextField.text == "" || typeTextField.text == "" || addressTextField.text == "" || phoneTextField.text == "" || descriptionTextView.text == "" {
            let alertController = UIAlertController(title: "Oops", message: NSLocalizedString("We can't proceed because one of the fields is blank. Please note that all fields are required.", comment: "We can't proceed because one of the fields is blank. Please note that all fields are required."), preferredStyle: .alert)
            let alertAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alertController.addAction(alertAction)
            present(alertController, animated: true, completion: nil)
            
            return
        }
        
//        Spinner configuration
        spinner.style = .large
        spinner.hidesWhenStopped = true
        
        view.addSubview(spinner)
        
        
//        Define layout constraints for the spinner
        spinner.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            spinner.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            spinner.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
        
//        Activate the spinner
        spinner.startAnimating()
        
        print("Name : \(nameTextField.text ?? "")")
        print("Type : \(typeTextField.text ?? "")")
        print("Location : \(addressTextField.text ?? "")")
        print("Phone : \(phoneTextField.text ?? "")")
        print("Description : \(descriptionTextView.text ?? "")")
        
        guard let imageDataReady = imageReadyToUpload else {
            return
        }
        
        let imagePath = "images/\(UUID().uuidString)"
        // Create a reference to the file you want to upload
        let imagesRef = firebaseStorage.child(imagePath)
        
        // Upload the file to the path "images/filename.jpg"
    imagesRef.putData(imageDataReady, metadata: nil) { [self] metadata, error in
       
        if let err = error {
            self.spinner.stopAnimating()
            let alertController = UIAlertController(title: "Oops", message: "\(err.localizedDescription)", preferredStyle: .alert)
            let alertAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alertController.addAction(alertAction)
            present(alertController, animated: true, completion: nil)
            
            return
          }
        
        dateFormatter.dateFormat = "MM-dd-yyyy HH:mm:ss"
            
            db.collection("resto").addDocument(data: [
                "name" : nameTextField.text!,
                "type" : typeTextField.text!,
                "location" : addressTextField.text!,
                "phone" : phoneTextField.text!,
                "description" : descriptionTextView.text!,
                "imageName" : imagePath,
                "created_at" : dateFormatter.string(from: Date())
            ]) { error in
                if let error = error {
                    print(error.localizedDescription)
                } else {
                    print("Document successfully written!")
                }
            }
        
        if let appDelegate = (UIApplication.shared.delegate as? AppDelegate) {
            restaurant = Restaurant(context: appDelegate.persistentContainer.viewContext)

            restaurant.image = imageDataReady
            restaurant.name = nameTextField.text!
            restaurant.type = typeTextField.text!
            restaurant.location = addressTextField.text!
            restaurant.phone = phoneTextField.text!
            restaurant.summary = descriptionTextView.text!
            restaurant.isFavorite = false
            
            
            print("Saving data to context...")
            appDelegate.saveContext()
        }
        spinner.stopAnimating()
        dismiss(animated: true, completion: nil)
        }
    }
}

extension NewRestaurantController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let nextTextField = view.viewWithTag(textField.tag + 1) {
            textField.resignFirstResponder()
            nextTextField.becomeFirstResponder()
        }
        return true
    }
}

extension NewRestaurantController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        
        results.forEach { result in
            
            if result.itemProvider.canLoadObject(ofClass: UIImage.self) {
                result.itemProvider.loadObject(ofClass: UIImage.self) { reading, error in
                    DispatchQueue.main.async {
                        guard let image = reading as? UIImage, error == nil
                        else {
                            return
                        }
                        self.photoImageView.image = image
                        self.photoImageView.contentMode = .scaleAspectFill
                        self.photoImageView.clipsToBounds = true
                        
                        guard let picture = image.pngData() else {
                            return
                        }
                        
                        let scalingFactor = (image.size.width > 1024) ? 1024 / image.size.width : 1
                        let scaledImage = UIImage(data: picture, scale: scalingFactor)!
                        
                        self.imageReadyToUpload = scaledImage.jpegData(compressionQuality: 0.6)
                        
                        //                        Store image to document directory before uploading to Firebase Storage
//                        result.itemProvider.loadFileRepresentation(forTypeIdentifier: UTType.image.identifier) { url, error in
//                            if let url = url {
//
//                                let documentsUrl = FileManager.default.urls(for: .applicationDirectory, in: .userDomainMask).first
//                                //                                print(documentsUrl!)
////                                print(NSTemporaryDirectory() + url.lastPathComponent)
//
//                                let fileURL = documentsUrl?.appendingPathComponent(url.lastPathComponent)
//
//                                if let _ = image.pngData(), let filePath = fileURL {
//                                    let data = try? Data(contentsOf: filePath)
//
//                                    if let imageFile = data {
//                                        let originalImage = UIImage(data: imageFile)!
//                                        let scalingFactor = (originalImage.size.width > 1024) ? 1024 / originalImage.size.width : 1
//                                        let scaledImage = UIImage(data: imageFile, scale: scalingFactor)!
//
//                                        try? scaledImage.jpegData(compressionQuality: 0.8)?.write(to: filePath)
//                                    }
//                                    //                                    try? imageData.write(to: filePath)
//                                                                        self.filePath = filePath
//                                }
//                            }
//                        }
                    }
                }
            }
            
            picker.dismiss(animated: true, completion: nil)
        }
        
        
    }
}
