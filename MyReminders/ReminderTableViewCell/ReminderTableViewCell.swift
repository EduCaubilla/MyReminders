//
//  ReminderTableViewCell.swift
//  MyReminders
//
//  Created by Edu Caubilla on 18/07/2023.
//

import UIKit

class ReminderTableViewCell: UITableViewCell {

    @IBOutlet var title: UILabel!
    @IBOutlet var date: UILabel!
    @IBOutlet var body: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    static let identifier = "ReminderTableViewCell"
    
    static func nib() -> UINib{
        return UINib(nibName: "ReminderTableViewCell", bundle: nil)
    }
    
    func configure(with model: MyReminder){
        self.title.text = model.title
        self.title.font = UIFont.systemFont(ofSize: 18, weight: UIFont.Weight.light)
        self.title.textColor = UIColor.init(red: 26/255, green: 26/255, blue: 26/255, alpha: 1)
        
        self.body.text = model.body
        self.body.font = UIFont.systemFont(ofSize: 13, weight: UIFont.Weight.regular)
        self.body.textColor = UIColor.init(red: 128/255, green: 128/255, blue: 128/255, alpha: 1)
        
        let formatter = DateFormatter()
        formatter.dateFormat = "hh:mm E, d MM Y"

        self.date.text = formatter.string(from: model.date)
        self.date.font = UIFont.systemFont(ofSize: 14, weight: UIFont.Weight.medium)
        
        self.date.textColor = UIColor.init(red: 89/255, green: 89/255, blue: 89/255, alpha: 1)
        markOutdated(with: model)
    }
    
    func markOutdated(with model:MyReminder){
        if(model.date < Date()){
            self.date.textColor = UIColor.init(red: 255/255, green: 0/255, blue: 0/255, alpha: 0.8)
            self.date.text?.append(" - Outdated")
        }
    }
}
