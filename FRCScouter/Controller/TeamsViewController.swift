//
//  ViewController.swift
//  FRCScouter
//
//  Created by Jin Lin on 2021-11-29.
//

import UIKit
import CoreData

@available(iOS 13.0, *)

class TeamsViewController: UITableViewController {
    
    
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
    
    @objc func keyboardWillShow(sender: NSNotification) {
         self.view.frame.origin.y = -200 // Move view 150 points upward
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
        print("button tapped")
        var team_number: String = ""
        
        var textField = UITextField()
        let alert = UIAlertController(title: "Add Teams", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add", style: .default) { (action) in
            //what will happen once the user clicks the Add button on our UIAlert
            if let s = textField.text {
               team_number = s
                //self.getJasonDataFromTBA()
                self.getJasonDataFromTBA(teamField: "team", teamName: team_number) { result in
                    guard let teamsItemModel = result else { return }
               //print("Team Number = \(String(describing: teamsItemModel.team_number))")
               //print("School Name = \(String(describing: teamsItemModel.school_name))")
                    let newTeams = Teams(context: self.context)
                    newTeams.team_no = Int64(teamsItemModel.team_number!)
                    newTeams.team_name = teamsItemModel.school_name
                    self.arrTeams.append(newTeams)
                    self.saveTeams()
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
    
    //convert Data into TeamsResponseModel struct
    func parseJSON(data: Data) -> TeamsResponseModel? {
        
        var returnValue: TeamsResponseModel?
        do {
            returnValue = try JSONDecoder().decode(TeamsResponseModel.self, from: data)
        } catch {
            print("Error took place\(error.localizedDescription).")
        }
        
        return returnValue
    }
    
    //MARK: - Data Manipulation Methods
    
    func saveTeams(){
        do {
            try context.save()
        } catch {
            print("Error saving context \(error)")
        }
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    func loadTeams() {
        let request: NSFetchRequest<Teams> = Teams.fetchRequest()
        do {
            arrTeams = try context.fetch(request)
        } catch {
            print("Error fetching data from context \(error)")
        }
        
        tableView.reloadData()
        
    }
    
    //MARK: - TableView dataSource
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrTeams.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "teamsCell", for: indexPath) as! CustomTableViewCell
        cell.lblTeamNo.text = String(arrTeams[indexPath.row].team_no)
        cell.lblTeamName?.text = arrTeams[indexPath.row].team_name
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 96.0
    }

}

