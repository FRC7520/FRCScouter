//
//  TemplatesViewController.swift
//  FRCScouter
//
//  Created by Jin Lin on 2021-11-29.
//

import UIKit
import CoreData
@available(iOS 13.0, *)
@available(iOS 13.0, *)
class TemplatesViewController: UIViewController {
    
    @IBOutlet weak var menuView: UIView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var addView: UIView!
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var arrMatchScout = [MatchScout]()
    var scrollVisbleWidth = 0
   
    //set iBool is true, load all template when the View Controller is loaded
    //Set IBool is false, add a new template when Match Scount button is pressed
    var iBool = false
    
    //gCount to judge whether is add or not
    var gCount = 0
    
//MARK: - UIViewController Method
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        // set navigationBar's title color
        let textAttributes = [NSAttributedString.Key.foregroundColor:UIColor.white]
        navigationController?.navigationBar.titleTextAttributes = textAttributes
        addView.isHidden = true
        
        //set shade for addView
        setShadeForAddView()
        
        //load Table MatchScout
        loadMatchScout()
        
        
        let count = arrMatchScout.count
        
        // Show all template from Table Match Scout
        if (count >= 1) {
            //set iBool is true, load all template when the View Controller is loaded
            iBool = true
            
            self.matchScoutPressed(self)
        }
    }
    
    @IBAction func addPressed(_ sender: UIBarButtonItem) {
        addView.isHidden = false
    }
    
    @IBAction func cancelPressed(_ sender: Any) {
        addView.isHidden = true
    }
    
    func setShadeForAddView(){
        addView.layer.shadowColor = UIColor.lightGray.cgColor
        addView.layer.shadowOpacity = 0.5
        //menuView.layer.shadowOffset = .zero
        addView.layer.shadowRadius = 30
    }
    
    @IBAction func matchScoutPressed(_ sender: Any) {
        for view in menuView.subviews{
            view.removeFromSuperview()
        }
        
        //show segmentedControl base on Table MatchScout
        var count = arrMatchScout.count

        // Set IBool is false, add a new template when Match Scount button is pressed
        if (!iBool){
            count = count + 1
        }
        gCount = count
        
        iBool = false
        
        var arrItems: [String] = []
        for index in stride(from: count, through: 1, by: -1) {
            arrItems.append("Template" + String(index))
        }
      
        let mySegmentedControl = UISegmentedControl (items: arrItems)
        
        let xPostion:CGFloat = 0
        let yPostion:CGFloat = 20
        let elementWidth:CGFloat = CGFloat(100 * count)
        let elementHeight:CGFloat = 30
            
        mySegmentedControl.frame = CGRect(x: xPostion, y: yPostion, width: elementWidth, height: elementHeight)
            
        
        // Make First segment selected
        mySegmentedControl.selectedSegmentIndex = 0
                
        // Change text color
        let titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        let titleTextAttributes1 = [NSAttributedString.Key.foregroundColor: UIColor.black]
        
        
        mySegmentedControl.setTitleTextAttributes(titleTextAttributes, for: .normal)
        mySegmentedControl.setTitleTextAttributes(titleTextAttributes1, for: .selected)
        
        
        
        //Change UISegmentedControl background colour
        mySegmentedControl.backgroundColor = UIColor.blue
        
        
        // Add function to handle Value Changed events
        mySegmentedControl.addTarget(self, action: #selector(self.segmentedValueChanged(_:)), for: .valueChanged)
        
        self.menuView.addSubview(mySegmentedControl)
        segmentedValueChanged(mySegmentedControl)
        addView.isHidden = true
    }
    
    @objc func segmentedValueChanged(_ sender:UISegmentedControl!)
    {
        //Scoll to current index of SegmentedControl
        let screenWidth = Int(UIScreen.main.bounds.width)
        let selSegWidth = (sender.selectedSegmentIndex+2) * 100
        if  selSegWidth >= screenWidth {
            let x = selSegWidth
            scrollVisbleWidth = x
            scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            let targetRect = CGRect(x: x, y: 20, width: 1, height: 1)
            scrollView.scrollRectToVisible(targetRect, animated: true)
        } else if (scrollVisbleWidth - selSegWidth + 200) > screenWidth {
            var x = sender.selectedSegmentIndex*100-200
            if x < 0 {
                x = 0
            }
            let targetRect = CGRect(x: x, y: 20, width: screenWidth+x, height: 1)
            scrollView.scrollRectToVisible(targetRect, animated: true)
        }
        
        //Show current Match scout template
        let matchScoutTemplate = MatchScoutTemplate(nibName: "MatchScoutTemplate", bundle: nil)
        var  i = 0
        if gCount > arrMatchScout.count {
            let newMatchScout = MatchScout(context: self.context)
            newMatchScout.scoutInfo = "Scout Info"
            let date = Date()
            newMatchScout.setValue(date.format(), forKey: "date")
            
            let type = 1
            newMatchScout.setValue(type, forKey: "type")
            
            newMatchScout.setValue(false, forKey: "auto_taxi")
            newMatchScout.setValue(false, forKey: "teleop_hangar_low")
            newMatchScout.setValue(false, forKey: "teleop_hangar_mid")
            newMatchScout.setValue(false, forKey: "teleop_hangar_high")
            newMatchScout.setValue(true, forKey: "teleop_hangar_traversal")
            newMatchScout.setValue(false, forKey: "rankingPoints_cargoBonus")
            newMatchScout.setValue(false, forKey: "rankingPoints_hangarBonus")
            newMatchScout.setValue(false, forKey: "rankingPoints_tie")
            newMatchScout.setValue(false, forKey: "rankingPoints_win")
            newMatchScout.setValue(true, forKey: "rankingPoints_lost")
            
            matchScoutTemplate.currentMatchScout = newMatchScout
            matchScoutTemplate.saveMatchScout()
            loadMatchScout()
        } else {
            for index in arrMatchScout{
               
                if (i == sender.selectedSegmentIndex) {
                    matchScoutTemplate.currentMatchScout = index
//                    matchScoutTemplate.scoutInfoTextField.text = index.scoutInfo ?? "Scout Info"
/*                    matchScoutTemplate.currentMatchScout?.setValue(matchScoutTemplate.scoutInfoTextField.text, forKey: "scoutInfo")
                    matchScoutTemplate.saveMatchScout()
 */
                    break
                }
                i = i+1
                
            }
        }
        DispatchQueue.main.async  {
            self.contentView.addSubview(matchScoutTemplate.view)
            self.addChild(matchScoutTemplate)
        }
    }
    
    @IBAction func pitScoutPressed(_ sender: Any) {
    }
    
    @IBAction func blankScoutPressed(_ sender: Any) {
    }
    
    //MARK: - Data Manipulation Methods
    
    func saveMatchScout(){
        do {
            try context.save()
        } catch {
            print("Error saving context \(error)")
        }
        
    }
    
    func loadMatchScout() {
        let request: NSFetchRequest<MatchScout> = MatchScout.fetchRequest()
        let sort = NSSortDescriptor(key: "date", ascending: true)
        request.sortDescriptors = [sort]
        //Create the component predicates
        let typePredicate = NSPredicate(format: "type == %i", 1)
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [typePredicate])
        
        do {
            
            arrMatchScout = try context.fetch(request)
        } catch {
            print("Error fetching data from context \(error)")
        }
    }
}

extension Date {
    /**
     Formats a Date

     - parameters format: (String) for eg dd-MM-yyyy hh-mm-ss
     */
    func format(format:String = "dd-MM-yyyy hh-mm-ss") -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        let dateString = dateFormatter.string(from: self)
        if let newDate = dateFormatter.date(from: dateString) {
            return newDate
        } else {
            return self
        }
    }
}


