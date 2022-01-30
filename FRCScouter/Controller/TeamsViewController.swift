//
//  ViewController.swift
//  FRCScouter
//
//  Created by Jin Lin on 2021-11-29.
//

import UIKit
import CoreData
import SideMenu

@available(iOS 13.0, *)

class TeamsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var menu: SideMenuNavigationController?
    
    @IBOutlet weak var tableView: UITableView!
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var arrTeams = [Teams]()
    
    
    //floating button
    lazy var faButton: UIButton = {
        let button = UIButton(frame: .zero)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .red
        button.setTitle("Add", for: .normal)
        button.setTitleColor(UIColor.white, for: .normal)
        button.addTarget(self, action: #selector(fabTapped(_:)), for: .touchUpInside)
        return button
    }()
    
    //MARK: - UIViewController Method
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        menu = SideMenuNavigationController(rootViewController: MenuListController())
        menu?.leftSide = true
        menu?.setNavigationBarHidden(true, animated: false)
        SideMenuManager.default.leftMenuNavigationController = menu
        SideMenuManager.default.addPanGestureToPresent(toView: self.view)
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "CustomTableViewCell")
        
        // set navigationBar's title color
        let textAttributes = [NSAttributedString.Key.foregroundColor:UIColor.white]
        navigationController?.navigationBar.titleTextAttributes = textAttributes
        
        //notification keyboard will show
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(sender:)), name: UIResponder.keyboardWillShowNotification, object: nil);
        
        //notification keyboard will hide
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(sender:)), name: UIResponder.keyboardWillHideNotification, object: nil);
        
        //Load data from Teams
        loadTeams()
        
        
    }
    
    
    
    @IBAction func didTapMenu() {
        present(menu!, animated: true)
    }
    
    @objc func keyboardWillShow(sender: NSNotification) {
        if let keyboardFrame: NSValue = sender.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as?NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            let keyboardHeight = keyboardRectangle.height
            
            self.view.frame.origin.y = -keyboardHeight
        } else {
            self.view.frame.origin.y = -200 // Move view 150 points upward
        }
        
    }

    @objc func keyboardWillHide(sender: NSNotification) {
         self.view.frame.origin.y = 0 // Move view to original position
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let view = UIApplication.shared.keyWindow {
            view.addSubview(faButton)
            setupButton()
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if let view = UIApplication.shared.keyWindow, faButton.isDescendant(of: view) {
            faButton.removeFromSuperview()
        }
    }

    //Setup floating button
    func setupButton() {
        NSLayoutConstraint.activate([
            faButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -36),
            faButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -80),
            faButton.heightAnchor.constraint(equalToConstant: 60),
            faButton.widthAnchor.constraint(equalToConstant: 60)
            ])
        faButton.layer.cornerRadius = 30
        faButton.layer.masksToBounds = true
        faButton.layer.borderColor = UIColor.red.cgColor
        faButton.layer.borderWidth = 4
    }
    
    //Press on floating button
    @objc func fabTapped(_ button: UIButton) {
        var team_number: String = ""
        
        var textField = UITextField()
        let alert = UIAlertController(title: "Add Teams", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add", style: .default) { (action) in
            if let s = textField.text {
               team_number = s
                let newTeams = Teams(context: self.context)
                //self.getJasonDataFromTBA()
                self.getJasonDataFromTBA(teamField: "team", teamName: team_number) { result in
                    guard let teamsItemModel = result else { return }
                    
                    newTeams.team_no = Int64(teamsItemModel.team_number!)
                    newTeams.nickname = teamsItemModel.nickname
                    newTeams.address = teamsItemModel.address
                    newTeams.city = teamsItemModel.city
                    newTeams.country = teamsItemModel.country
                    newTeams.gmaps_place_id = teamsItemModel.gmaps_place_id
                    newTeams.gmaps_url = teamsItemModel.gmaps_url
                    newTeams.key = teamsItemModel.key
                    newTeams.lat = teamsItemModel.lat
                    newTeams.lng = teamsItemModel.lng
                    newTeams.location_name = teamsItemModel.location_name
                    newTeams.motto = teamsItemModel.motto
                    newTeams.name = teamsItemModel.name
                    newTeams.postal_code = teamsItemModel.postal_code
                    newTeams.rookie_year = teamsItemModel.rookie_year!
                    newTeams.school_name = teamsItemModel.school_name
                    newTeams.state_prov = teamsItemModel.state_prov
                    newTeams.website = teamsItemModel.website
                    
                    // if pd is true that can show image from media url
                    var pd = false
                    self.getJasonDataOfMediaUrlFromTBA(teamField: "team", teamName: team_number, mediaField: "media", year: "2019"){ result in
                        guard let mediaList = result else { return }
                        
                        for index in 0..<mediaList.count {
                            let direct_url = mediaList[index].direct_url ?? ""
                            
                            if  !direct_url.isEmpty {
                                let url = URL(string: direct_url)
                                if let _ = try? Data(contentsOf: url!){
                                    newTeams.mediaUrl = direct_url
                                    pd = true
                                    break
                                }
                            }
                            
                        }
                        if pd {
                            self.saveTeams()
                            self.loadTeams()
                        } else {
                            self.getJasonDataOfMediaUrlFromTBA(teamField: "team", teamName: team_number, mediaField: "media", year: "2018"){ result in
                                guard let mediaList = result else { return }
                                
                                for index in 0..<mediaList.count {
                                    let direct_url = mediaList[index].direct_url ?? ""
                                    
                                    if  !direct_url.isEmpty {
                                        let url = URL(string: direct_url)
                                        if let _ = try? Data(contentsOf: url!){
                                            newTeams.mediaUrl = direct_url
                                            break
                                        }
                                    }
                                    
                                }
                                
                                self.saveTeams()
                                self.loadTeams()
                                
                            }
                            
                        }
                    }
                    
                }
                
                

                
            }
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Entry team number"
            textField =  alertTextField
        }
        
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    // Get Jason Data from The Blue Alliance
    func getJasonDataFromTBA(teamField: String, teamName: String, completion: @escaping (TeamsResponseModel?) -> Void){
        // Create URL
        let s = "https://www.thebluealliance.com/api/v3/" + teamField + "/frc" + teamName
        let url = URL(string: s)
        guard let requestUrl = url else { fatalError() }
        // Create URL Request
        var request = URLRequest(url: requestUrl)
        // Specify HTTP Method to use
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("XTaqp0VqsYCDQbYetQWxJfQ9DMjeHItHlBdkQ4UZ5iXCwZkXnETz5NysIAC4gZhi", forHTTPHeaderField: "X-TBA-Auth-Key")
        // Send HTTP Request
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            
            // Check if Error took place
            guard let data = data else {
                completion(nil)
                return
                
            }
                
            // Using parseJSON() function to convert data to Swift struct
            let teamsItem = self.parseJSON(data: data)
                completion(teamsItem)
                   
        }
        task.resume()
 
    }
    
    func getJasonDataOfMediaUrlFromTBA(teamField: String, teamName: String, mediaField: String, year: String,  completion: @escaping ([MediaList]?) -> Void){
        // Create URL
        let s = "https://www.thebluealliance.com/api/v3/" + teamField + "/frc" + teamName + "/" + mediaField + "/" + year
        let url = URL(string: s)
        guard let requestUrl = url else { fatalError() }
        // Create URL Request
        var request = URLRequest(url: requestUrl)
        // Specify HTTP Method to use
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("XTaqp0VqsYCDQbYetQWxJfQ9DMjeHItHlBdkQ4UZ5iXCwZkXnETz5NysIAC4gZhi", forHTTPHeaderField: "X-TBA-Auth-Key")
        // Send HTTP Request
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            
            // Check if Error took place
            guard let data = data else {
                completion(nil)
                return
                
            }
                
                   // Using parseJSON() function to convert data to Swift struct
            let teamsItem = self.parseJSONofMediaList(data: data)
                completion(teamsItem)
                   
        }
        task.resume()
 
    }
    
    //convert Data into TeamsResponseModel struct
    func parseJSON(data: Data) -> TeamsResponseModel? {
        
        var returnValue: TeamsResponseModel?
        do {
            returnValue = try JSONDecoder().decode(TeamsResponseModel.self, from: data)
        } catch {
            //print("Error took place\(error.localizedDescription).")
            print(String(describing: error))
        }
        
        return returnValue
    }
    
    //convert Data into MediaList struct
    func parseJSONofMediaList(data: Data) -> [MediaList]? {
        
        var returnValue: [MediaList]?
        do {
            returnValue = try JSONDecoder().decode([MediaList].self, from: data)
        } catch {
            //print("Error took place\(error.localizedDescription).")
            print(String(describing: error))
        }
        
        return returnValue
    }
    
    //MARK: - Data Manipulation Methods
    
    func saveTeams(){
        
        do {
            context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
            try context.save()
            
            
        } catch {
            print("Error saving context \(error)")
        }
    }
    
    
    
    func loadTeams() {
        let request: NSFetchRequest<Teams> = Teams.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "team_no", ascending: true)]
        do {
            arrTeams = try context.fetch(request)
        } catch {
            print("Error fetching data from context \(error)")
        }
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    
    
    //MARK: - TableView dataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrTeams.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "teamsCell", for: indexPath) as! CustomTableViewCell
        
        //show image logo
        let mediaUrl: String = arrTeams[indexPath.row].mediaUrl ?? ""
        if mediaUrl != "" {
            let url = URL(string: mediaUrl)
            DispatchQueue.main.async {
                if let data = try? Data(contentsOf: url!){
                    cell.imgView.image = UIImage(data: data)
                    cell.imgView.layer.cornerRadius = 38
                    cell.imgView.layer.masksToBounds = true
                    cell.imgView.layer.borderColor = UIColor.lightGray.cgColor
                    cell.imgView.layer.borderWidth = 2
                    cell.imgView.contentMode = .scaleToFill
                } else {
                    let img = UIImage(named: "placeholder-img")
                    cell.imgView.image = img
                    cell.imgView.layer.cornerRadius = 38
                    cell.imgView.layer.masksToBounds = true
                    cell.imgView.layer.borderColor = UIColor.lightGray.cgColor
                    cell.imgView.layer.borderWidth = 2
                    cell.imgView.contentMode = .scaleToFill
                    
                }
            }
        } else {
            DispatchQueue.main.async {
                let img = UIImage(named: "placeholder-img")
                cell.imgView.image = img
                cell.imgView.layer.cornerRadius = 38
                cell.imgView.layer.masksToBounds = true
                cell.imgView.layer.borderColor = UIColor.lightGray.cgColor
                cell.imgView.layer.borderWidth = 2
                cell.imgView.contentMode = .scaleToFill
            }
        }
        cell.lblTeamNo.text = String(arrTeams[indexPath.row].team_no)
        cell.lblTeamName?.text = arrTeams[indexPath.row].nickname
        cell.lblTeamName.widthAnchor.constraint(equalToConstant: 250.0).isActive = true
        //cell.lblTeamName.translatesAutoresizingMaskIntoConstraints = false
        cell.addPress.titleLabel?.font = UIFont(name: "HelveticaNeue-Bold", size: 46)
        cell.delPressed.titleLabel?.font = UIFont(name: "HelveticaNeue-Bold", size: 30)
        cell.delPressed.tag = indexPath.row
        cell.delPressed.addTarget(self, action: #selector(deleteTeam), for: .touchUpInside)
        cell.addPress.tag = indexPath.row
        cell.addPress.addTarget(self, action:#selector(addTeamDetail), for: .touchUpInside)
        return cell
    }
    
    func convertBase64StringToImage (imageBase64String:String) -> UIImage {
        let imageData = Data.init(base64Encoded: imageBase64String, options: .init(rawValue: 0))
        let image = UIImage(data: imageData!)
        return image!
    }
    
    @objc func deleteTeam(sender: UIButton){
        let nickname = arrTeams[sender.tag].nickname ?? ""
        let alert = UIAlertController(title: "Delete Teams", message: "Are you sure to delete team: \(nickname)", preferredStyle: .alert)
        let action = UIAlertAction(title: "Delete", style: .default) { (action) in
            self.context.delete(self.arrTeams[sender.tag])
            self.arrTeams.remove(at: sender.tag)
            self.saveTeams()
            self.loadTeams()
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    @objc func addTeamDetail(sender: UIButton){
        
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let VC = storyBoard.instantiateViewController(withIdentifier: "SubMain") as! TeamDetailViewController
        VC.selectedTeam = arrTeams[sender.tag]
        navigationController?.pushViewController(VC, animated: true)
         
        //self.performSegue(withIdentifier: "goTeamDetail", sender: nil)
         
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 96.0
    }

}


//MARK: - Menu List

@available(iOS 13.0, *)
class MenuListController: UITableViewController {
    var items = ["Export all teams", "Trash", "Support development", "Settings"]
    let darkColor = UIColor(red: 33/255.0,
                            green: 33/255.0,
                            blue: 33/255.0,
                            alpha: 1)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.backgroundColor = darkColor
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = items[indexPath.row]
        cell.textLabel?.textColor = .white
        cell.backgroundColor = darkColor
        return cell
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
       // tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.row == 3 {
            let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
            let VC = storyBoard.instantiateViewController(withIdentifier: "SettingVC") as! SettingViewController
            navigationController?.pushViewController(VC, animated: true)
        }
    }
}
