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
    
    var chosenPainting = ""
    var chosenPaintingId : UUID?

    override func viewDidLoad() {
        super.viewDidLoad()
        //seçilen boş ise boş göster değilse dolu göster dicez burdada
        if chosenPainting != "" {
            //Core Data
            let stringUUID = chosenPaintingId!.uuidString
            print(stringUUID)
            //Burada core datadan verilerimizi çekicez
            let appDelegate = UIApplication.shared.delegate as! AppDelegate //AppDelegate değişken olarak tanımladık
            let context = appDelegate.persistentContainer.viewContext
            //çekme işlemine geldik fetch request atalım  tut getirmekten geliyor
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Paintings")
            fetchRequest.returnsObjectsAsFaults = false  //cache den okuma daha hızlı okusun diye
            //filtreleme yapmam lazım
            let idString = chosenPaintingId!.uuidString
            //kosul yazıcam o kosulu bullup getiricek bana kayıtlı seylerı cek dicem
            fetchRequest.predicate = NSPredicate(format: "id == %@", idString) //id si şurdaki argümana eşit olan şeyi bana bul getir diyo
            //isimden arama yapıyo olsaydım
            //fetchRequest.predicate = NSPredicate(format: "name == %@", self.chosenPainting) derdim
            fetchRequest.returnsObjectsAsFaults = false
            do{
            let results =   try  context.fetch(fetchRequest) //results bize bir dizi verir
                print("results",results)
                if results.count > 0 {
                  for result in results as! [NSManagedObject] {
                      if let  name =   result.value(forKey: "name") as? String
                      {
                          nameTextField.text = name
                      }
                       if let  artist = result.value(forKey: "artist") as? String
                            {
                             artistTextField.text  = artist
                            }
                            if let  year =   result.value(forKey: "year") as? Int{
                                yearTextField.text = String(year)
                            }   //stringe cevir o sekılde göster diyoruz burada
                      
                      if let  imageData = result.value(forKey: "image") as? Data
                           {
                          let image = UIImage(data: imageData)
                          imageView.image = image
                           }
                  }
                }
            }catch{
                print("error")
            }
        }else {
            nameTextField.text = ""
            imageView.image = UIImage(named: "select")
            artistTextField.text = ""
            yearTextField.text = ""
        }
        
        
        
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
