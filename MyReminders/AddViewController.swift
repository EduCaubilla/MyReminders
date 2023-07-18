//
//  AddViewController.swift
//  MyRemiders
//
//  Created by Edu Caubilla on 17/07/2023.
//

import UIKit

class AddViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet var titleField: UITextField!
    @IBOutlet var bodyField: UITextField!
    @IBOutlet var datePicker: UIDatePicker!

    public var completion: ((String,String,Date)-> Void)?
    
    var detailReminder: MyReminder = MyReminder(title: "", date: Date(), identifier: "", body: "")
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .done, target: self, action: #selector(didTapSaveButton))
        
        navigationItem.titleView?.tintColor = UIColor.red
        navigationItem.backBarButtonItem?.tintColor = UIColor.systemGray
        navigationItem.rightBarButtonItem?.tintColor = UIColor.systemGray
        
        titleField.delegate = self
        bodyField.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if !detailReminder.title.isEmpty {
            loadDetailReminder()
        }
    }
    
    func loadDetailReminder(){
        titleField.text = detailReminder.title
        bodyField.text = detailReminder.body
        datePicker.date = detailReminder.date
    }

    @objc func didTapSaveButton(){
        if let titleText = titleField.text, !titleText.isEmpty,
           let bodyText = bodyField.text, !bodyText.isEmpty{
            
            let targetDate = datePicker.date
            
            print("Date saved for a reminder -> \(targetDate) ")
            
            completion?(titleText, bodyText, targetDate)
        }
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
