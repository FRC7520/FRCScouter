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
class MatchScoutTemplate: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var labTotal: UILabel!
    
    @IBOutlet weak var view1: UIView!
    
    @IBOutlet weak var view2: UIView!
    @IBOutlet weak var view3: UIView!
    @IBOutlet weak var view4: UIView!
    @IBOutlet weak var view5: UIView!
    
    @IBOutlet weak var view6: UIView!
    @IBOutlet weak var chk_auto_taxi: CheckBox!
    
    @IBOutlet weak var chk_rankingPoints_cargoBonus: CheckBox!
    
    @IBOutlet weak var chk_rankingPoints_hangarBonus: CheckBox!
    @IBOutlet weak var rad_teleop_hangar_low: UIButton!
    @IBOutlet weak var rad_teleop_hangar_mid: UIButton!
    @IBOutlet weak var rad_teleop_hangar_high: UIButton!
    @IBOutlet weak var rad_teleop_hangar_traversal: UIButton!
    
    @IBOutlet weak var rad_rankingPoints_tie: UIButton!
    
    @IBOutlet weak var rad_rankingPoints_win: UIButton!
    
    @IBOutlet weak var rad_rankingPoints_lost: UIButton!
    
    
    @IBOutlet weak var txt_scoutInfo: TJTextField!
    
    @IBOutlet weak var txt_name: TJTextField!
    
    @IBOutlet weak var txt_text: TJTextField!
    
    @IBOutlet weak var txt_auto_cargo_lower: UITextField!
    
    @IBOutlet weak var txt_auto_cargo_upper: UITextField!
    
    @IBOutlet weak var txt_teleop_cargo_lower: UITextField!
    
    @IBOutlet weak var txt_teleop_cargo_upper: UITextField!
    
    let radioController: RadioButtonController = RadioButtonController()
    let radioController1: RadioButtonController = RadioButtonController()
    
    var arrMatchScout = [MatchScout]()
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var currentMatchScout: MatchScout? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        //get Value
        getValue()
        // scoutInfoTextField.text = self.currentMatchScout?.scoutInfo ?? "Scout Info"
        // view1.layer.borderWidth = 1
        // view1.layer.borderColor = UIColor.lightGray.cgColor
        
        // Set Radion button and Check box's value to empty
        setTitleEmpty()
       
        //add border to all view
        addBorder()
        
        //caculate the score
        sumScore()
        
        // Set textField's to UITextViewDelegate
        setTextFieldDelegate()
        // Do any additional setup after loading the view.
        
    }
    
    func setTextFieldDelegate(){
        txt_auto_cargo_lower.delegate = self
        txt_auto_cargo_upper.delegate = self
        txt_teleop_cargo_lower.delegate = self
        txt_teleop_cargo_upper.delegate = self
    }
    
    @IBAction func chkAutoTaxiPressed(_ sender: Any) {
        chk_auto_taxi.isChecked = !chk_auto_taxi.isChecked
        sumScore()
    }
    
    @IBAction func chkRankingPointsCargoBonusPressed(_ sender: Any) {
        chk_rankingPoints_cargoBonus.isChecked = !chk_rankingPoints_cargoBonus.isChecked
        sumScore()
    }
    
    @IBAction func chkRankingPointsHangarBonusPressed(_ sender: Any) {
        chk_rankingPoints_hangarBonus.isChecked = !chk_rankingPoints_hangarBonus.isChecked
        sumScore()
    }
    @IBAction func txtEditngDidEnd(_ sender: Any) {
        sumScore()
    }
    
    func sumScore(){
        var total = 0
        //Auto
        
        if (chk_auto_taxi.isChecked) {
            total = 2
        } else {
            total = 0
        }
        if let auto_cargo_lower = Int(txt_auto_cargo_lower.text ?? "0") {
            total = total + auto_cargo_lower * 2
        }
        
        if let auto_cargo_upper = Int(txt_auto_cargo_upper.text ?? "0") {
            total = total + auto_cargo_upper * 4
        }
        
        //teleop
        if let teleop_cargo_lower = Int(txt_teleop_cargo_lower.text ?? "0") {
            total =  total + teleop_cargo_lower * 1
        }
        
        if let teleop_cargo_upper = Int(txt_teleop_cargo_upper.text ?? "0") {
            total =  total + teleop_cargo_upper * 2
        }
        
        
        if  rad_teleop_hangar_low.isSelected {
            total = total + 4
        } else if rad_teleop_hangar_mid.isSelected {
            total = total + 6
        } else if rad_teleop_hangar_high.isSelected {
            total = total + 10
        } else {
            total = total + 15
        }
        
        //ranking points
        if chk_rankingPoints_cargoBonus.isChecked {
            total = total + 1
        }
        
        if chk_rankingPoints_hangarBonus.isChecked {
            total = total + 1
        }
        
        if rad_rankingPoints_tie.isSelected {
            total = total + 1
            
        } else if rad_rankingPoints_win.isSelected {
            total = total + 2
        } else {
            total = total + 0
        }
        labTotal.text = String(total)
        
    }
    func getValue(){
        txt_scoutInfo.text = currentMatchScout?.scoutInfo
        txt_name.text = currentMatchScout?.name
        txt_text.text = currentMatchScout?.text
        
        //auto
        
        if let auto_taxi = currentMatchScout?.auto_taxi {
            chk_auto_taxi.isChecked = auto_taxi
        } else {
            chk_auto_taxi.isChecked = false
        }
        if let auto_cargo_lower = currentMatchScout?.auto_cargo_lower {
            txt_auto_cargo_lower.text = String(auto_cargo_lower)
        }
        
        if let auto_cargo_upper = currentMatchScout?.auto_cargo_upper {
            txt_auto_cargo_upper.text = String(auto_cargo_upper)
        }
        
        //teleop
        if let teleop_cargo_lower = currentMatchScout?.teleop_cargo_lower {
            txt_teleop_cargo_lower.text = String(teleop_cargo_lower)
        }
        if let teleop_cargo_upper = currentMatchScout?.teleop_cargo_upper {
            txt_teleop_cargo_upper.text = String(teleop_cargo_upper)
        }
        
        if let teleop_hangar_low = currentMatchScout?.teleop_hangar_low {
            rad_teleop_hangar_low.isSelected = teleop_hangar_low
        } else {
            rad_teleop_hangar_low.isSelected = false
        }
        
        if let teleop_hangar_mid = currentMatchScout?.teleop_hangar_mid {
            rad_teleop_hangar_mid.isSelected = teleop_hangar_mid
        } else {
            rad_teleop_hangar_mid.isSelected = false
        }
        
        if let teleop_hangar_high = currentMatchScout?.teleop_hangar_high {
            rad_teleop_hangar_high.isSelected = teleop_hangar_high
        } else {
            rad_teleop_hangar_high.isSelected = false
        }
       
        if let teleop_hangar_traversal = currentMatchScout?.teleop_hangar_traversal {
            rad_teleop_hangar_traversal.isSelected = teleop_hangar_traversal
        } else {
            rad_teleop_hangar_traversal.isSelected = false
        }
        radioController.buttonsArray = [rad_teleop_hangar_low,rad_teleop_hangar_mid,rad_teleop_hangar_high,rad_teleop_hangar_traversal]
        if  rad_teleop_hangar_low.isSelected {
            radioController.defaultButton = rad_teleop_hangar_low
        } else if rad_teleop_hangar_mid.isSelected {
            radioController.defaultButton = rad_teleop_hangar_mid
        } else if rad_teleop_hangar_high.isSelected {
            radioController.defaultButton = rad_teleop_hangar_high
        } else {
            radioController.defaultButton = rad_teleop_hangar_traversal
        }
        
        //ranking points
        if let rankingPoints_cargoBonus = currentMatchScout?.rankingPoints_cargoBonus {
            chk_rankingPoints_cargoBonus.isChecked = rankingPoints_cargoBonus
        } else {
            chk_rankingPoints_cargoBonus.isChecked = false
        }
        
        if let rankingPoints_hangarBonus = currentMatchScout?.rankingPoints_hangarBonus {
            chk_rankingPoints_hangarBonus.isChecked = rankingPoints_hangarBonus
        } else {
            chk_rankingPoints_hangarBonus.isChecked = false
        }
        
        if let rankingPoints_tie = currentMatchScout?.rankingPoints_tie {
            rad_rankingPoints_tie.isSelected = rankingPoints_tie
        } else {
            rad_rankingPoints_tie.isSelected = false
        }
        
        if let rankingPoints_win = currentMatchScout?.rankingPoints_win {
            rad_rankingPoints_win.isSelected = rankingPoints_win
        } else {
            rad_rankingPoints_win.isSelected = false
        }
        
        if let rankingPoints_lost = currentMatchScout?.rankingPoints_lost {
            rad_rankingPoints_lost.isSelected = rankingPoints_lost
        } else {
            rad_rankingPoints_lost.isSelected = false
        }
        
        radioController1.buttonsArray = [rad_rankingPoints_tie,rad_rankingPoints_win,rad_rankingPoints_lost]
        if rad_rankingPoints_tie.isSelected {
            radioController1.defaultButton = rad_rankingPoints_tie
            
        } else if rad_rankingPoints_win.isSelected {
            radioController1.defaultButton = rad_rankingPoints_win
        } else {
            radioController1.defaultButton = rad_rankingPoints_lost
        }
    }
    
    func save(){
        currentMatchScout?.setValue(txt_scoutInfo.text, forKey: "scoutInfo")
        currentMatchScout?.setValue(txt_name.text, forKey: "name")
        currentMatchScout?.setValue(txt_text.text, forKey: "text")
        
        //auto
        currentMatchScout?.setValue(chk_auto_taxi.isChecked, forKey: "auto_taxi")
        currentMatchScout?.setValue(Int(txt_auto_cargo_lower.text ?? "0"), forKey:"auto_cargo_lower")
        currentMatchScout?.setValue(Int(txt_auto_cargo_upper.text ?? "0"), forKey:"auto_cargo_upper")
        
        //teleop
        currentMatchScout?.setValue(Int(txt_teleop_cargo_lower.text ?? "0"), forKey: "teleop_cargo_lower")
        currentMatchScout?.setValue(Int(txt_teleop_cargo_upper.text ?? "0"), forKey: "teleop_cargo_upper")
        currentMatchScout?.setValue(rad_teleop_hangar_low.isSelected, forKey: "teleop_hangar_low")
        currentMatchScout?.setValue(rad_teleop_hangar_mid.isSelected, forKey: "teleop_hangar_mid")
        currentMatchScout?.setValue(rad_teleop_hangar_high.isSelected, forKey: "teleop_hangar_high")
        currentMatchScout?.setValue(rad_teleop_hangar_traversal.isSelected, forKey: "teleop_hangar_traversal")
        
        //ranking points
        currentMatchScout?.setValue(chk_rankingPoints_cargoBonus.isChecked, forKey: "rankingPoints_cargoBonus")
        currentMatchScout?.setValue(chk_rankingPoints_hangarBonus.isChecked, forKey: "rankingPoints_hangarBonus")
        currentMatchScout?.setValue(rad_rankingPoints_tie.isSelected, forKey: "rankingPoints_tie")
        currentMatchScout?.setValue(rad_rankingPoints_win.isSelected, forKey: "rankingPoints_win")
        currentMatchScout?.setValue(rad_rankingPoints_lost.isSelected, forKey: "rankingPoints_lost")
        
        saveMatchScout()
        
    }

    func setTitleEmpty(){
        chk_auto_taxi.setTitle("", for: .normal)
        chk_rankingPoints_cargoBonus.setTitle("", for: .normal)
        chk_rankingPoints_hangarBonus.setTitle("", for: .normal)
        
        rad_teleop_hangar_low.setTitle("", for: .normal)
        rad_teleop_hangar_mid.setTitle("", for: .normal)
        rad_teleop_hangar_high.setTitle("", for: .normal)
        rad_teleop_hangar_traversal.setTitle("", for: .normal)
        
        rad_rankingPoints_win.setTitle("", for: .normal)
        rad_rankingPoints_tie.setTitle("", for: .normal)
        rad_rankingPoints_lost.setTitle("", for: .normal)
        
    }
    @IBAction func btn_teleop_hangar_low(_ sender: UIButton) {
        radioController.buttonArrayUpdated(buttonSelected: sender)
        sumScore()
    }
    
    @IBAction func btn_teleop_hangar_mid(_ sender: UIButton) {
        radioController.buttonArrayUpdated(buttonSelected: sender)
        sumScore()
    }
    
    @IBAction func btn_teleop_hangar_high(_ sender: UIButton) {
        radioController.buttonArrayUpdated(buttonSelected: sender)
        sumScore()
    }
    
   
    @IBAction func btn_teleop_hangar_traversal(_ sender: UIButton) {
        radioController.buttonArrayUpdated(buttonSelected: sender)
        sumScore()
    }
    
    @IBAction func btn_rankingPoints_tie(_ sender: UIButton) {
        radioController1.buttonArrayUpdated(buttonSelected: sender)
        sumScore()
    }
    
    @IBAction func btn_rankingPoints_win(_ sender: UIButton) {
        radioController1.buttonArrayUpdated(buttonSelected: sender)
        sumScore()
    }
    
    @IBAction func btn_rankingPoints_lost(_ sender: UIButton) {
        radioController1.buttonArrayUpdated(buttonSelected: sender)
        sumScore()
    }
    
    func addBorder(){
        //view1
        view1.addBorder(.bottom, color: .lightGray, thickness: 0.5)
        view1.addBorder(.top, color: .lightGray, thickness: 0.5)
        view1.addBorder(.left, color: .lightGray, thickness: 0.5)
        view1.addBorder(.right, color: .lightGray, thickness: 0.5)
        
        //view2
        view2.addBorder(.bottom, color: .lightGray, thickness: 0.5)
        view2.addBorder(.top, color: .lightGray, thickness: 0.5)
        view2.addBorder(.left, color: .lightGray, thickness: 0.5)
        view2.addBorder(.right, color: .lightGray, thickness: 0.5)
        
        //view3
        view3.addBorder(.bottom, color: .lightGray, thickness: 0.5)
        view3.addBorder(.top, color: .lightGray, thickness: 0.5)
        view3.addBorder(.left, color: .lightGray, thickness: 0.5)
        view3.addBorder(.right, color: .lightGray, thickness: 0.5)
        
        //view4
        view4.addBorder(.bottom, color: .lightGray, thickness: 0.5)
        view4.addBorder(.top, color: .lightGray, thickness: 0.5)
        view4.addBorder(.left, color: .lightGray, thickness: 0.5)
        view4.addBorder(.right, color: .lightGray, thickness: 0.5)
        
        
        //view5
        view5.addBorder(.bottom, color: .lightGray, thickness: 0.5)
        view5.addBorder(.top, color: .lightGray, thickness: 0.5)
        view5.addBorder(.left, color: .lightGray, thickness: 0.5)
        view5.addBorder(.right, color: .lightGray, thickness: 0.5)
        
        //view6
        view6.addBorder(.bottom, color: .lightGray, thickness: 0.5)
        view6.addBorder(.top, color: .lightGray, thickness: 0.5)
        view6.addBorder(.left, color: .lightGray, thickness: 0.5)
        view6.addBorder(.right, color: .lightGray, thickness: 0.5)
    }
    
    //MARK: - UITextFieldDelegate Methods
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        //For mobile numer validation
       // if textField == txt_auto_cargo_lower {
            let allowedCharacters = CharacterSet(charactersIn:"+0123456789 ")//Here change this characters based on your requirement
            let characterSet = CharacterSet(charactersIn: string)
            return allowedCharacters.isSuperset(of: characterSet)
        //}
        //return true
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
extension UIView {
    func addBorder(_ edge: UIRectEdge, color: UIColor, thickness: CGFloat) {
        let subview = UIView()
        subview.translatesAutoresizingMaskIntoConstraints = false
        subview.backgroundColor = color
        self.addSubview(subview)
        switch edge {
        case .top, .bottom:
            subview.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 0).isActive = true
            subview.rightAnchor.constraint(equalTo: self.rightAnchor, constant: 0).isActive = true
            subview.heightAnchor.constraint(equalToConstant: thickness).isActive = true
            if edge == .top {
                subview.topAnchor.constraint(equalTo: self.topAnchor, constant: 0).isActive = true
            } else {
                subview.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0).isActive = true
            }
        case .left, .right:
            subview.topAnchor.constraint(equalTo: self.topAnchor, constant: 0).isActive = true
            subview.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0).isActive = true
            subview.widthAnchor.constraint(equalToConstant: thickness).isActive = true
            if edge == .left {
                subview.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 0).isActive = true
            } else {
                subview.rightAnchor.constraint(equalTo: self.rightAnchor, constant: 0).isActive = true
            }
        default:
            break
        }
    }
}

@available(iOS 13.0, *)
class CheckBox: UIButton {
    // Images
    let checkedImage = UIImage(named: "ic_check_box")! as UIImage
    let uncheckedImage = UIImage(named: "ic_check_box_blank")! as UIImage
    
    // Bool property
    var isChecked: Bool = false {
        didSet {
            if isChecked == true {
                self.setImage(checkedImage, for: UIControl.State.normal)
            } else {
                self.setImage(uncheckedImage, for: UIControl.State.normal)
            }
        }
    }
        
    override func awakeFromNib() {
       /* self.addTarget(self, action:#selector(buttonClicked(sender:)), for: UIControl.Event.touchUpInside)*/
        self.isChecked = false
    }
        
    @available(iOS 13.0, *)
    @objc func buttonClicked(sender: UIButton) {
        if sender == self {
            isChecked = !isChecked
        }
    }
}



@available(iOS 13.0, *)
class RadioButtonController: NSObject {
    var buttonsArray: [UIButton]! {
        didSet {
            for b in buttonsArray {
                b.setImage(UIImage(named: "radioButtonUnchecked"), for: .normal)
                b.setImage(UIImage(named: "radioButtonChecked"), for: .selected)
            }
        }
    }
    var selectedButton: UIButton?
    var defaultButton: UIButton = UIButton() {
        didSet {
            buttonArrayUpdated(buttonSelected: self.defaultButton)
        }
    }

    func buttonArrayUpdated(buttonSelected: UIButton) {
        for b in buttonsArray {
            if b == buttonSelected {
                selectedButton = b
                b.isSelected = true
            } else {
                b.isSelected = false
            }
        }
       // MatchScoutTemplate().sumScore()
        
    }
}


