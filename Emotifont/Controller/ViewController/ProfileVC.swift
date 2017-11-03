//
//  ProfileVC.swift
//  Emotifont
//
//  Created by Buzz on 1/28/17.
//  Copyright © 2017 Emotifont. All rights reserved.
//
//


import UIKit
import Firebase

@objc class ProfileVC: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    @IBOutlet var genderPicker: UIPickerView!
  
    @IBOutlet var offerSwitch: UISwitch!
    
    @IBOutlet var usernameTxt: UITextField!
    
    @IBOutlet var emailTxt: UITextField!
    
    @IBOutlet var dobTxt: UITextField!
    
    // Profile Labels
    @IBOutlet var userNamelbl: UILabel!
    @IBOutlet var emailLbl: UILabel!
    @IBOutlet var dobLbl: UILabel!
    @IBOutlet var genderLbl: UILabel!
    
    @IBOutlet var saveButtonOutlet: UIButton!
    
    //Has Profile Labels
    @IBOutlet var hasProfileUser: UILabel!
    @IBOutlet var hasProfileEmail: UILabel!
    @IBOutlet var hasProfileDob: UILabel!
    @IBOutlet var hasProfileGender: UILabel!
    
    
    
    var pickerData: [String] = [String]()
    
    var ref: DatabaseReference!
    
    var pickerValue = "Select"
    
    var defaults : UserDefaults! = UserDefaults.init(suiteName: "group.directvc")

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    self.navigationController?.navigationBar.tintColor = UIColor.white
        
       // self.navigationController?.navigationBar.topItem?.title = "Profile";
        
        genderPicker.delegate = self
        genderPicker.dataSource = self
        
        //Looks for single or multiple taps.
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ProfileVC.dismissKeyboard))
        
        view.addGestureRecognizer(tap)
        
    //Check Incentive Switch
    offerSwitch.isOn = defaults.bool(forKey: "switchState")
   
    // Check for User Details
    hasProfileEmail.text = defaults.string(forKey: "email")
        
    hasProfileUser.text = defaults.string(forKey: "username")
        
    hasProfileDob.text = defaults.string(forKey: "dob")
        
    hasProfileGender.text = defaults.string(forKey: "gender")
        
        // Input data into the Array:
        pickerData = ["Select", "Male", "Female", "Other"]
        
        if !offerSwitch.isOn {
            
            hideIncentiveView()
            
        } else {
            
            if hasProfileUser.text != "" {
                
               showIncentiveView()
               hasProfile()
            } else {
                
                offerSwitch.setOn(false, animated: false)
                hideIncentiveView()
            }
        }


    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()

    }
    
    // ********* PICKER VIEW ***********
    // The number of columns of data
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    // The number of rows of data
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }
    
    // The data to return for the row and component (column) that's being passed in
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerData[row]
    }
    
    //?? Remove
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        let valueSelected = pickerData[row] as String
        
        pickerValue = valueSelected
        
        print(pickerValue)
        
    }
    
    
    
    func hideIncentiveView() {
        
        usernameTxt.isHidden = true
        userNamelbl.isHidden = true
        
        emailTxt.isHidden = true
        emailLbl.isHidden = true
        
        dobTxt.isHidden = true
        dobLbl.isHidden = true
        
        genderPicker.isHidden = true
        genderLbl.isHidden = true
        
        saveButtonOutlet.isHidden = true
        
        hasProfileUser.isHidden = true
        hasProfileEmail.isHidden = true
        hasProfileDob.isHidden = true
        hasProfileGender.isHidden = true
        
        
    }
    
    func showIncentiveView() {
        
        usernameTxt.isHidden = false
        userNamelbl.isHidden = false
        
        emailTxt.isHidden = false
        emailLbl.isHidden = false
        
        dobTxt.isHidden = false
        dobLbl.isHidden = false
        
        genderPicker.isHidden = false
        genderLbl.isHidden = false
        
        saveButtonOutlet.isHidden = false
        
        hasProfileUser.isHidden = false
        hasProfileEmail.isHidden = false
        hasProfileDob.isHidden = false
        hasProfileGender.isHidden = false
        
    }
    

    @IBAction func submitButton(_ sender: Any) {
        
        if usernameTxt.text == "" || emailTxt.text == "" || dobTxt.text == "" || pickerValue == "Select" {
          
            
            // UI Alert
            
            let alertController = UIAlertController(title: "Emotifont", message:
                "Please complete all values", preferredStyle: UIAlertControllerStyle.alert)
            alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default,handler: nil))
            
            self.present(alertController, animated: true, completion: nil)
            

            
        } else {
            
            // Save and Post
            defaults.set(usernameTxt.text, forKey: "username")
            
            defaults.set(emailTxt.text,forKey: "email")
            
            defaults.set(dobTxt.text, forKey: "dob")
            
            defaults.set(pickerValue, forKey: "gender")
            
            
            postProfile()
            resetFields()
            hideIncentiveView()
            hasProfile()
            
            _ = navigationController?.popViewController(animated: true)
            
            
        }
    
        
        
    }
    
    
    @IBAction func switchChanged(_ sender: Any) {
        
        // Save Switch State to Device
        defaults.set(offerSwitch.isOn, forKey: "switchState")
        
        if offerSwitch.isOn {
            
            showIncentiveView()
            
        } else {
            
            hideIncentiveView()
            optOut()
            
        }
        
    }
    
    
    func postProfile() {
        
        let userName = usernameTxt.text
        let emailAddress = emailTxt.text
        let dob = dobTxt.text
        let gender = pickerValue
        
        

        let post : [String : String] = ["UserID" : userName!, "Email" : emailAddress!, "DOB" : dob!, "Gender" : gender]
        
        ref = Database.database().reference()
        ref.child("Users").childByAutoId().setValue(post)
        
//        ref.child("Users").observeSingleEvent(of: .value, with: { (snapshot) in
//            // Get user value
//            let value = snapshot.value as? NSDictionary
//
//            print(value ?? "")
//
//            // ...
//        }) { (error) in
//            print(error.localizedDescription)
//
//        }
        
        
    }
    
    func resetFields() {
        usernameTxt.text = ""
        emailTxt.text = ""
        dobTxt.text = ""
        genderPicker.reloadAllComponents()
        
    }
    
    func hasProfile() {
        
        usernameTxt.isHidden = true
        emailTxt.isHidden = true
        dobTxt.isHidden = true
        genderPicker.isHidden = true
        saveButtonOutlet.isHidden = true
        
        hasProfileUser.alpha = 1
        hasProfileEmail.alpha = 1
        hasProfileDob.alpha = 1
        hasProfileGender.alpha = 1
        
        
    }
    
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    
    func optOut() {
        
        usernameTxt.text = ""
        emailTxt.text = ""
        dobTxt.text = ""
        genderPicker.reloadAllComponents()
        pickerValue = "Select"
        
        hasProfileUser.text = ""
        hasProfileEmail.text = ""
        hasProfileDob.text = ""
        hasProfileGender.text = ""
        
        hasProfileUser.alpha = 0
        hasProfileEmail.alpha = 0
        hasProfileDob.alpha = 0
        hasProfileGender.alpha = 0
        
        defaults.set(usernameTxt.text, forKey: "username")
        
        defaults.set(emailTxt.text,forKey: "email")
        
        defaults.set(dobTxt.text, forKey: "dob")
        
        defaults.set(pickerValue, forKey: "gender")
        
        
    }
    
}
