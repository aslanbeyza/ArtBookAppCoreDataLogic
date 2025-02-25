//
//  ViewController.swift
//  artBookProject
//
//  Created by Beyza Aslan on 25.02.2025.
//

import UIKit
import CoreData

class ViewController: UIViewController , UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    //Aslında core dataya kaydettiğimiz şeylerden sadece ismi ve id yi çekmemiz yeterli olacaktır diğer görseli yılı vs çekmenin hiçbir manası yoktur çünkü kullanıcı tabloda tıklıcak diğer tarafta görücek zaten id sini öbür tarafa aktarsam yeter id den bakarız çekeriz diğer taraf içinde filtreleme yaparak sadece şu id ye ait şeyi bana getir gibi
    
    
    var nameArray = [String]()
    var idArray = [UUID]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        // Navigation Bar'ın sağ tarafına "+" butonu ekle
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addButtonClicked))
        
        getData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(getData),name: NSNotification.Name(rawValue: "newData"), object:nil )
    }
    
    @objc func getData() {
        //duplicate veriler olamsın diye arraylarımı temizleyip yaparsam bu işlemi
        nameArray.removeAll(keepingCapacity: false)
        idArray.removeAll(keepingCapacity: false)
        
        //Burada core datadan verilerimizi çekicez
        let appDelegate = UIApplication.shared.delegate as! AppDelegate //AppDelegate değişken olarak tanımladık
        let context = appDelegate.persistentContainer.viewContext
        //çekme işlemine geldik fetch request atalım  tut getirmekten geliyor
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Paintings")
        fetchRequest.returnsObjectsAsFaults = false  //cache den okuma daha hızlı okusun diye
        do{
           let results =  try context.fetch(fetchRequest)//bunun geri döndüreceği şey dizi olucaktır
            for result in results as! [NSManagedObject]{
                if let name = result.value(forKey : "name") as? String {
                    self.nameArray.append(name)
                }
                if let id = result.value(forKey: "id") as? UUID {
                    self.idArray.append(id)
                }
                //veri eklendikten sonra tableview refresh etmeliyim güncellenmeli
                self.tableView.reloadData()
            }
            
        }catch{
            print("error")
        }
    }
    
    @objc func addButtonClicked() {
        print("birinci ekran üstteki artı butonunun fonksiyonuyum")
        performSegue(withIdentifier: "toDetailsVC", sender: nil)
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return nameArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
           let cell  = UITableViewCell()
        cell.textLabel?.text = nameArray[indexPath.row] //kaçıncı sırasına denk geliyorsa onu göstericem
           return cell
       }
    
    // + tuşuna basılınca DetailsVC gelsin ama eğer tableview kısmından tıklanırsa içi dolu olan görünüm gelsin istiyorum hangi isme tıkladıysam onun id sini detay sayfasında gerekli yerleri doldurarak getirsin 
    
    
    
    
    
    
    
}

