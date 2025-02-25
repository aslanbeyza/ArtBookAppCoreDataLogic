//  DetailsVC.swift
//  artBookProject
//  Created by Beyza Aslan on 25.02.2025.
import UIKit
import CoreData

class DetailsVC: UIViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var artistTextField: UITextField!
    @IBOutlet weak var yearTextField: UITextField!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // RECOGNİZERS
        // Klavyeyi gizlemek için ekrana dokunmayı algılayan bir gesture recognizer ekleyelim
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        tapGesture.cancelsTouchesInView = false // Diğer etkileşimleri engellememesi için
        view.addGestureRecognizer(tapGesture)
        
        imageView.isUserInteractionEnabled = true // Kullanıcı görsele tıklayabilir
        let imageTagRecognizer = UITapGestureRecognizer(target: self, action: #selector(chooseImage))
        imageView.addGestureRecognizer(imageTagRecognizer)
    }
    
    @objc func chooseImage() {
        print("select image e tıklandı")
        // Kullanıcı tıkladı, galeriye götür
        let picker = UIImagePickerController() // Kullanıcının media kütüphanesine erişmek için kullanıyoruz
        picker.delegate = self // Bu, picker'ın fonksiyonlarını kullanabilmek için
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true  // Kullanıcı zoomlayabilir, kırpabilir vs
        present(picker, animated: true , completion:nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        if let selectedImage = info[.originalImage] as? UIImage {
            imageView.image = selectedImage
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    @objc func hideKeyboard() {
        view.endEditing(true) // Klavyeyi gizler
    }
    
    @IBAction func saveButtonClicked(_ sender: Any) {
        print("ikinci ekran kaydet butonuna tıklandı")
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate // AppDelegate değişken olarak tanımladık
        let context = appDelegate.persistentContainer.viewContext
        let newPainting = NSEntityDescription.insertNewObject(forEntityName: "Paintings", into: context)
        
        // Attributes
        newPainting.setValue(nameTextField.text, forKey: "name")
        newPainting.setValue(artistTextField.text, forKey: "artist")
        
        if let year = Int(yearTextField.text!) {
            newPainting.setValue(year, forKey: "year")
        }
        newPainting.setValue(UUID(), forKey: "id")
        
        if let imageData = imageView.image?.jpegData(compressionQuality: 0.5) {
            newPainting.setValue(imageData, forKey: "image")
        }
        
        do {
            try context.save()
            print("success")
            
            // Veriyi kaydettikten sonra notification gönderilmeli
            NotificationCenter.default.post(name: NSNotification.Name("newData"), object: nil)
            
            // Bir önceki controller kısmına gidebiliyoruz
            self.navigationController?.popViewController(animated: true)
            
        } catch {
            print("error")
        }
    }
}
