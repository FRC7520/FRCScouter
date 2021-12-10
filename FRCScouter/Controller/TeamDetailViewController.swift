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
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    //define viewMenu,viewTop and viewTeamDetail
    @IBOutlet weak var viewMenu: UIView!
    @IBOutlet weak var viewTop: UIView!
    @IBOutlet weak var viewTeamDetail: UIView!
    
    @IBOutlet weak var scrollView: UIScrollView!
    //define imgLogo
    
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var imgLogo: UIImageView!
    
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
