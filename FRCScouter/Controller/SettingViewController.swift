//
//  SettingViewController.swift
//  FRCScouter
//
//  Created by Jin Lin on 2021-12-23.
//

import UIKit

class SettingViewController: UIViewController {
    @IBOutlet weak var textViewAboutUs: UITextView!
    
    @IBOutlet weak var textViewMEP: UITextView!
    @IBOutlet weak var textViewP: UITextView!
    @IBOutlet weak var textViewPTL: UITextView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        textViewAboutUs.adjustUITextViewHeight()
        textViewPTL.adjustUITextViewHeight()
        textViewP.adjustUITextViewHeight()
        textViewMEP.adjustUITextViewHeight()
        // Do any additional setup after loading the view.

    }
    

    @IBAction func buttonPresses(_ sender: UIButton) {
        
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

extension UITextView {
    func adjustUITextViewHeight() {
        self.translatesAutoresizingMaskIntoConstraints = true
        self.sizeToFit()
        self.isScrollEnabled = false
    }
}
