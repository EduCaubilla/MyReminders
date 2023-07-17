//
//  ViewController.swift
//  MyRemiders
//
//  Created by Edu Caubilla on 17/07/2023.
//

import UserNotifications
import UIKit

class ViewController: UIViewController {

    @IBOutlet var table : UITableView!
    
    var models = [MyReminder]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        table.delegate = self
        table.dataSource = self
    }
    
    @IBAction func didTapAdd(){
        // Show add vc
        guard let vc = storyboard?.instantiateViewController(identifier: "add") as? AddViewController else{
            return
        }
        
        vc.title = "New Reminder"
        vc.navigationItem.largeTitleDisplayMode = .never
        vc.completion = {title,body,date in
            DispatchQueue.main.async {
                self.navigationController?.popToRootViewController(animated: true)
                let newReminder = MyReminder(title: title, date: date, identifier: "id_\(title)")
                self.models.append(newReminder)
                self.table.reloadData()
                
                // Set push notification
                self.schedulePush(title: title, body: body, date: date)
            }
        }
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func didTapPush(){
        //Request permission
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound], completionHandler: {success, error in
            if success{
                //Schedule push
                self.schedulePush(title: "Hello World", body: "This is the content of the reminder. Oh yeah.", date: Date().addingTimeInterval(10))
            }
            else if let error = error {
                print("An error happened on requesting notifications.")
                print(error)
            }
        })
    }
    
    func schedulePush(title:String, body:String, date:Date){
        let content = UNMutableNotificationContent()
        content.title = title
        content.sound = .default
        content.body = body
        
        let targetDate = date
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: targetDate), repeats: false)
        
        let request = UNNotificationRequest(identifier: "push_id", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request, withCompletionHandler: {error in
            if error != nil{
                print("Push request went wrong.")
                print(error!)
            }
        })
    }
}

extension ViewController: UITableViewDelegate{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension ViewController:UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return models.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = models[indexPath.row].title
        
        let date = models[indexPath.row].date
        let formatter = DateFormatter()
        formatter.dateFormat = "hh:mm E, d MM Y"
        
        cell.detailTextLabel?.text = formatter.string(from: date)
        return cell
    }
}

struct MyReminder {
    let title: String
    let date: Date
    let identifier: String
}
