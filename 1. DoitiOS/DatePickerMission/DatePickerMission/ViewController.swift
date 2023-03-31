//
//  ViewController.swift
//  DatePickerMission
//
//  Created by 권유정 on 2022/05/09.
//

import UIKit

class ViewController: UIViewController {
    let timeSelector: Selector = #selector(ViewController.updateTime)
    let interval = 1.0
    @IBOutlet var lblCurrentTime: UILabel!
    @IBOutlet var lblPickerTime: UILabel!
    var alarmTime: String?
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        Timer.scheduledTimer(timeInterval: interval, target: self, selector: timeSelector, userInfo: nil, repeats: true)
    }
    @IBAction func changeDatePicker(_ sender: UIDatePicker) {
        let datePickerView = sender
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm aaa"
        alarmTime = formatter.string(from: datePickerView.date)
        lblPickerTime.text = "선택시간: " + formatter.string(from: datePickerView.date)
    }
    @objc func updateTime(){
        let date = NSDate()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm aaa"
        let currentTime = formatter.string(from: date as Date)
        lblCurrentTime.text = "현재시간: " + currentTime
        
        if(alarmTime == currentTime){
            view.backgroundColor = UIColor.red
        }
        else{
            view.backgroundColor = UIColor.white
        }
    }

}

