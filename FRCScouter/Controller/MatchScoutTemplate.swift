//
//  MatchScoutTemplate.swift
//  FRCScouter
//
//  Created by Jin Lin on 2021-12-17.
//

import UIKit
import UnderLineTextField
import CoreData

@available(iOS 13.0, *)
class MatchScoutTemplate: UIViewController {

    @IBOutlet weak var scoutInfoTextField: UnderLineTextField!
    
    @IBOutlet weak var view1: UIView!
    
    var arrMatchScout = [MatchScout]()
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var currentMatchScout: MatchScout? {
        didSet {
            loadMatchScout()
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
       
        scoutInfoTextField.text = self.currentMatchScout?.scoutInfo ?? "Scout Info"
        view1.layer.borderWidth = 1
        view1.layer.borderColor = UIColor.lightGray.cgColor
        
        // Do any additional setup after loading the view.
        
    }
    
    //MARK: - Data Manipulation Methods

    func saveMatchScout(){
        
        do {
            //context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
            try context.save()
            
            
        } catch {
            print("Error saving context \(error)")
        }
        
    }
    
    func loadMatchScout() {
        let request: NSFetchRequest<MatchScout> = MatchScout.fetchRequest()
        let sort = NSSortDescriptor(key: "date", ascending: true)
        request.sortDescriptors = [sort]
        do {
            
            arrMatchScout = try context.fetch(request)
        } catch {
            print("Error fetching data from context \(error)")
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
