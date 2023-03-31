//
//  ViewController.swift
//  AlertMission
//
//  Created by 권유정 on 2022/05/12.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet var lblCurrentTime: UILabel!
    @IBOutlet var lblSelectedTime: UILabel!
    let timeSelector: Selector = #selector(ViewController.updateTime)
    let interval = 1.0
    var count = 0
    var alarmTime: String?
    //1분안에 계속 반복되지 않게 해주기 위함 
    var alertFlag = false
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        Timer.scheduledTimer(timeInterval: interval, target: self, selector: timeSelector, userInfo: nil, repeats: true)
    }

    @IBAction func changeDatePicker(_ sender: UIDatePicker) {
        let datePickerView = sender
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm EEE"
        
        lblSelectedTime.text = "선택시간: " + formatter.string(from: datePickerView.date)
        formatter.dateFormat = "hh:mm aaa"
        alarmTime = formatter.string(from: datePickerView.date)
    }
    @objc func updateTime(){
        //현재 시간
        let date = NSDate()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm EEE"
        lblCurrentTime.text = "현재시간: " + formatter.string(from: date as Date)
        formatter.dateFormat = "hh:mm aaa"
        let currentTime = formatter.string(from: date as Date)
        if(alarmTime == currentTime){
            if !alertFlag{
                let alarmAlert = UIAlertController(title: "알림", message: "설정된 시간입니다!!", preferredStyle: UIAlertController.Style.alert)
                let onAction = UIAlertAction(title: "확인", style: UIAlertAction.Style.default, handler: nil)
                alarmAlert.addAction(onAction)
                present(alarmAlert, animated: true, completion: nil)
                alertFlag = true
            }
        }else{
            alertFlag = false
        }
    }
    
}

