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
        
        loadSavedData()
        
        navigationItem.titleView?.tintColor = UIColor.red
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
                let newReminder = MyReminder(title: title, date: date, identifier: "id_\(title)", body: body)
                self.models.append(newReminder)
                self.table.reloadData()
                
                // Set push notification
                self.schedulePush(title: title, body: body, date: date)
                
                print("Reminder to save -->")
                print(newReminder)
                
                //Save new reminder
                dataCoded.manageDataCoded.encodeData(data: newReminder)
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
    
    func loadSavedData(){
        let savedData = UDM.udm.getAllData()
        
        if !savedData.isEmpty{
            models = savedData
        }
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

struct MyReminder: Codable {
    let title: String
    let date: Date
    let identifier: String
    let body: String
}

class UDM{
    
    static let udm = UDM()
        
    let defaults = UserDefaults(suiteName: "com.ecqdigital.saved.data")!
        
    //pasar a esta función el objeto codificado y el string del id
    func setData(id: String, reminderData: Data){
        defaults.set(reminderData, forKey: id)
    }
    
    func getData(reminderId: String) -> Data{
        return defaults.object(forKey: reminderId) as! Data
    }
    
    func getAllData() -> [MyReminder]{
        var responseData : [String:Any]
        var arrRes = [MyReminder]()
        
        if self.defaults.persistentDomain(forName: "com.ecqdigital.saved.data") != nil {
            responseData = (self.defaults.persistentDomain(forName: "com.ecqdigital.saved.data"))!
            
            for item in responseData {
                
                let itemData = dataCoded.manageDataCoded.decodeData(id: item.key)
                arrRes.append(itemData)
            }
            
            print("Listado de elementos guardados -> ")
            print(arrRes)
        }
        
        return arrRes
    }
}

class dataCoded{
    
    static let manageDataCoded = dataCoded()
    
    func encodeData(data: MyReminder){
        let encoder = JSONEncoder()
        if let encodedData = try? encoder.encode(data) {
            UDM.udm.setData(id:data.identifier, reminderData: encodedData)
        }
    }
    
    func decodeData(id: String) -> MyReminder{
        
        let savedReminder = UDM.udm.getData(reminderId: id)
        let decoder = JSONDecoder()
        if let decodedReminder = try? decoder.decode(MyReminder.self, from: savedReminder){
            return decodedReminder
        }
        
        return MyReminder(title: "Error", date: Date(), identifier: "", body: "")
    }
    
}
