//
//  TeamDetailViewController.swift
//  FRCScouter
//
//  Created by Jin Lin on 2021-12-06.
//

import UIKit
import CoreData

@available(iOS 13.0, *)
class TeamDetailViewController: UIViewController {
    let arrMenu = ["Share", "Team details", "Edit next Scout template", "Move to new window", "Delete scout"]
    var selectedTeam : Teams? = nil
    var iLoad = false
    var gIndex = 0         //current record of arrMatchScount
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var arrMatchScout = [MatchScout]()
    
    let matchScoutTemplate = MatchScoutTemplate(nibName: "MatchScoutTemplate", bundle: nil)
    
    var scrollVisbleWidth = 0
   
    //set iBool is true, load all template when the View Controller is loaded
    //Set IBool is false, add a new template when Match Scount button is pressed
    var iBool = false
    
    //gCount to judge whether is add or not
    var gCount = 0
    
    //define viewMenu,viewTop and viewTeamDetail
    @IBOutlet weak var viewMenu: UIView!
    @IBOutlet weak var viewTop: UIView!
    @IBOutlet weak var viewTeamDetail: UIView!
    
    @IBOutlet weak var menuView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    //define imgLogo
    
    @IBOutlet weak var scrollView1: UIScrollView!
    
    
    @IBOutlet weak var scrollView2: UIScrollView!
    
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var imgLogo: UIImageView!
    
    @IBOutlet weak var contentView: UIView!
    
    //define text field
    @IBOutlet weak var txtFieldMediaUrl: UITextField!
    @IBOutlet weak var txtFieldWebsite: UITextField!
    @IBOutlet weak var txtFieldAddress: UITextField!
    @IBOutlet weak var txtFieldCity: UITextField!
    @IBOutlet weak var txtFieldCountry: UITextField!
    @IBOutlet weak var txtFieldLocationName: UITextField!
    @IBOutlet weak var txtFieldMotto: UITextField!
    @IBOutlet weak var txtFieldName: UITextField!
    @IBOutlet weak var txtFieldNickname: UITextField!
    @IBOutlet weak var txtFieldPostalCode: UITextField!
    @IBOutlet weak var txtFieldRookieYear: UITextField!
    @IBOutlet weak var txtFieldSchoolName: UITextField!
    @IBOutlet weak var txtFieldStateProv: UITextField!
    @IBOutlet weak var txtFieldTeamNumber: UITextField!
    
    //MARK: - UIViewController Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        // hide menu view
        viewMenu.isHidden = true
        
        // hide team detail view
        scrollView.isHidden = true
        
        // set viewTop's background image
        let mediaUrl: String = selectedTeam?.mediaUrl ?? ""
        if mediaUrl != "" {
            let url = URL(string: mediaUrl)
            DispatchQueue.global().async {
                let data = try? Data(contentsOf: url!)
                DispatchQueue.main.async {
                    let image = UIImage(data: data!)
                    self.imgView.image = image
                    self.imgView.contentMode = .scaleToFill
                    
                    //set imgLogo
                    self.imgLogo.image = image
                    self.imgLogo.layer.cornerRadius = 90
                    self.imgLogo.layer.masksToBounds = true
                    self.imgLogo.layer.borderColor = UIColor.lightGray.cgColor
                    self.imgLogo.layer.borderWidth = 2
                    self.imgLogo.contentMode = .scaleToFill
                    
                }
            }
        } else {
            DispatchQueue.main.async {
                let image = UIImage(named: "placeholder-img")
                self.imgView.image = image
                self.imgView.contentMode = .scaleToFill
                
                //set imgLogo
                self.imgLogo.image = image
                self.imgLogo.layer.cornerRadius = 90
                self.imgLogo.layer.masksToBounds = true
                self.imgLogo.layer.borderColor = UIColor.lightGray.cgColor
                self.imgLogo.layer.borderWidth = 2
                self.imgLogo.contentMode = .scaleToFill
            }
        }
        
        
        
        /*
        //set underLine for textfield
        txtFieldMediaUrl.setUnderLine()
        txtFieldWebsite.setUnderLine()
        txtFieldAddress.setUnderLine()
        */
        
        //load Table MatchScout
        loadMatchScout()
        
        let count = arrMatchScout.count
        
        // Show all template from Table Match Scout
        if (count >= 1) {
            //set iBool is true, load all template when the View Controller is loaded
            iBool = true
            
            self.btnAdd(self)
        }
       // scrollView1.isHidden = true
    }
    override func viewWillDisappear(_ animated: Bool) {
        if matchScoutTemplate.currentMatchScout != nil {
            
            matchScoutTemplate.save()
            
            
        }
    }
    
    @IBAction func btnAdd(_ sender: Any) {
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
        if (gCount == 0) {
            for view in contentView.subviews{
                view.removeFromSuperview()
            }
        } else {
        
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
      //  addView.isHidden = true
        }
        
    }
    
    
    @objc func segmentedValueChanged(_ sender:UISegmentedControl!)
    {
        if matchScoutTemplate.currentMatchScout != nil {
            
            matchScoutTemplate.save()
            iLoad = true
            
            
        }
        
        //Scoll to current index of SegmentedControl
        let screenWidth = Int(UIScreen.main.bounds.width)
        let selSegWidth = (sender.selectedSegmentIndex+2) * 100
        if  selSegWidth >= screenWidth {
            let x = selSegWidth
            scrollVisbleWidth = x
            scrollView2.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            let targetRect = CGRect(x: x, y: 20, width: 1, height: 1)
            scrollView2.scrollRectToVisible(targetRect, animated: true)
        } else if (scrollVisbleWidth - selSegWidth + 200) > screenWidth {
            var x = sender.selectedSegmentIndex*100-200
            if x < 0 {
                x = 0
            }
            let targetRect = CGRect(x: x, y: 20, width: screenWidth+x, height: 1)
            scrollView2.scrollRectToVisible(targetRect, animated: true)
        }
        
        //Show current Match scout template
        
        var  i = 0
        if gCount > arrMatchScout.count {
            let newMatchScout = MatchScout(context: self.context)
            newMatchScout.scoutInfo = "Scout Info"
            let date = Date()
            newMatchScout.setValue(date.format(), forKey: "date")
            let type = 2
            newMatchScout.setValue(type, forKey: "type")
            let team_no = selectedTeam?.team_no
            newMatchScout.setValue(team_no, forKey: "team_no")
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
            gIndex=0;
            if iLoad {matchScoutTemplate.viewDidLoad()}
            
            matchScoutTemplate.saveMatchScout()
            loadMatchScout()
        } else {
            for index in arrMatchScout{
               
                if (i == sender.selectedSegmentIndex) {
                    gIndex = i
                    matchScoutTemplate.currentMatchScout = index
                    print(index.teleop_hangar_traversal)
                    print(index.rankingPoints_lost)
                    if iLoad {
                        matchScoutTemplate.viewDidLoad()
                        
                    }
                    
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
            self.scrollView1.isHidden = false
            self.contentView.addSubview(self.matchScoutTemplate.view)
            self.addChild(self.matchScoutTemplate)
        }
    }
    
    @IBAction func cancelPressed(_ sender: UIButton) {
        scrollView.isHidden = true
    }
    
   
    @IBAction func savePressed(_ sender: UIButton) {
        // update current team's value
        selectedTeam?.setValue(txtFieldWebsite.text, forKey: "website")
        selectedTeam?.setValue(txtFieldAddress.text, forKey: "address")
        selectedTeam?.setValue(txtFieldCity.text, forKey: "city")
        selectedTeam?.setValue(txtFieldCountry.text, forKey: "country")
        selectedTeam?.setValue(txtFieldLocationName.text, forKey: "location_name")
        selectedTeam?.setValue(txtFieldMotto.text, forKey: "motto")
        selectedTeam?.setValue(txtFieldName.text, forKey: "name")
        selectedTeam?.setValue(txtFieldNickname.text, forKey: "nickname")
        selectedTeam?.setValue(txtFieldPostalCode.text, forKey: "postal_code")
        if let rookieYear = Int64(txtFieldRookieYear.text ?? "0") {
            selectedTeam?.setValue(rookieYear, forKey: "rookie_year")
        }
        
        selectedTeam?.setValue(txtFieldSchoolName.text, forKey: "school_name")
        selectedTeam?.setValue(txtFieldStateProv.text, forKey: "state_prov")
        if let teamNo = Int64(txtFieldTeamNumber.text ?? "0") {
            selectedTeam?.setValue(teamNo, forKey: "team_no")
        }
        saveTeams()
        scrollView.isHidden = true
        
    }
    @IBAction func menuPressed(_ sender: UIBarButtonItem) {
        viewMenu.isHidden = false
    }
    
    
    //MARK: - Data Manipulation Methods

    func saveTeams(){
        
        do {
            //context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
            try context.save()
            
            
        } catch {
            print("Error saving context \(error)")
        }
        
    }
    
    func saveMatchScout(){
        do {
            try context.save()
        } catch {
            print("Error saving context \(error)")
        }
        
    }
    
    func loadMatchScout() {
        let request: NSFetchRequest<MatchScout> = MatchScout.fetchRequest()
        let sort = NSSortDescriptor(key: "date", ascending: false)
        request.sortDescriptors = [sort]
        
        //Create the component predicates
        let typePredicate = NSPredicate(format: "type == %i", 2)
        
        if let team_no = selectedTeam?.team_no {
            let teamNoPredicate = NSPredicate(format: "team_no == %i", team_no)
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [typePredicate, teamNoPredicate])
        }
        
        
        
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



//MARK: - UITableViewDataSoure & UITableViewDelegate Methods

@available(iOS 13.0, *)
@available(iOS 13.0, *)
extension TeamDetailViewController:  UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrMenu.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = arrMenu[indexPath.row]
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if arrMenu[indexPath.row] == "Team details" {
            scrollView1.isHidden = true
            //set team detail's value
            
            txtFieldAddress.text = selectedTeam?.address
            txtFieldCity.text = selectedTeam?.city
            txtFieldCountry.text = selectedTeam?.country
            txtFieldLocationName.text = selectedTeam?.location_name
            txtFieldMotto.text = selectedTeam?.motto
            txtFieldName.text = selectedTeam?.name
            txtFieldNickname.text = selectedTeam?.nickname
            txtFieldPostalCode.text = selectedTeam?.postal_code
            if let rookieYear = selectedTeam?.rookie_year {
                txtFieldRookieYear.text = String(rookieYear)
            }
            txtFieldSchoolName.text = selectedTeam?.school_name
            txtFieldStateProv.text = selectedTeam?.state_prov
            if let teamNo = selectedTeam?.team_no {
                txtFieldTeamNumber.text = String(teamNo)
            }
            txtFieldWebsite.text = selectedTeam?.website
            scrollView.isHidden = false
           
            /*
            //show image logo
            let url = URL(string: image.url)

            DispatchQueue.global().async {
                let data = try? Data(contentsOf: url!) //make sure your image in this url does exist, otherwise unwrap in a if let check / try-catch
                DispatchQueue.main.async {
                    imageView.image = UIImage(data: data!)
                }
            }
            */
            
        } else if arrMenu[indexPath.row] == "Delete scout" {
            if arrMatchScout.count != 0 {
                context.delete(arrMatchScout[gIndex])
                arrMatchScout.remove(at: gIndex)
                saveMatchScout()
                iBool = true
                btnAdd(self)
                if gIndex == 0 {
                    iBool = false
                }
            }
        }
        viewMenu.isHidden = true
            
    }
}

//MARK: - UIImage methods

extension UIImage {
    enum ContentMode {
        case contentFill
        case contentAspectFill
        case contentAspectFit
    }
    
    func resize(withSize size: CGSize, contentMode: ContentMode = .contentAspectFill) -> UIImage? {
        let aspectWidth = size.width / self.size.width
        let aspectHeight = size.height / self.size.height
        
        switch contentMode {
        case .contentFill:
            return resize(withSize: size)
        case .contentAspectFit:
            let aspectRatio = min(aspectWidth, aspectHeight)
            return resize(withSize: CGSize(width: self.size.width * aspectRatio, height: self.size.height * aspectRatio))
        case .contentAspectFill:
            let aspectRatio = max(aspectWidth, aspectHeight)
            return resize(withSize: CGSize(width: self.size.width * aspectRatio, height: self.size.height * aspectRatio))
        }
    }
    
    private func resize(withSize size: CGSize) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, self.scale)
        defer { UIGraphicsEndImageContext() }
        draw(in: CGRect(x: 0.0, y: 0.0, width: size.width, height: size.height))
        return UIGraphicsGetImageFromCurrentImageContext()
    }
}

//MARK: - UITextField Methods
extension UITextField {

    func setUnderLine() {
        /*let border = CALayer()
        let width = CGFloat(0.5)
        border.borderColor = UIColor.darkGray.cgColor
        border.frame = CGRect(x: 0, y: self.frame.size.height - width, width:  self.frame.size.width - 10, height: self.frame.size.height)
        border.borderWidth = width
        self.borderStyle = UITextField.BorderStyle.none
        self.layer.addSublayer(border)
        //self.layer.masksToBounds = true
        */
        
        let bottomLine = CALayer()
                
       // bottomLine.frame = CGRect(x: 0.0, y: self.bounds.height + 3, width: self.bounds.width, height: 1.5)
        bottomLine.frame = CGRect(x: 0.0, y: self.bounds.height, width: self.bounds.width, height: 0.5)
        bottomLine.backgroundColor = UIColor.darkGray.cgColor
                
        self.borderStyle = UITextField.BorderStyle.none
        self.layer.addSublayer(bottomLine)
         
    }

}
