//
//  EditViewController.swift
//  Navigation
//
//  Created by 권유정 on 2022/05/23.
//

import UIKit

protocol EditDelegate{
    func didMessageEditDone(_ controller: EditViewController, message: String)
    func didImageOnOffDone(_ controller: EditViewController, isOn: Bool)
    func didImageZoomDone(_ controller: EditViewController, isZoom: Bool)
}

class EditViewController: UIViewController {

    
    var textWayValue: String = ""
    var textMessage: String = ""
    var delegate : EditDelegate?
    var isOn = false
    var isZoom = false
    
    @IBOutlet var txMessage: UITextField!
    @IBOutlet var lblWay: UILabel!
    @IBOutlet var swIsOn: UISwitch!
    @IBOutlet var btnResize: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        lblWay.text = textWayValue
        txMessage.text = textMessage
        swIsOn.isOn = isOn
        if isZoom{
            btnResize.setTitle("확대", for: UIControl.State())
        }else{
            btnResize.setTitle("축소", for: UIControl.State())
        }
        // Do any additional setup after loading the view.
    }
    
    @IBAction func btnDone(_ sender: UIButton) {
        if delegate != nil{
            delegate?.didMessageEditDone(self, message: txMessage.text!)
            delegate?.didImageOnOffDone(self, isOn: isOn)
            delegate?.didImageZoomDone(self, isZoom: isZoom)
        }
        _ = navigationController?.popViewController(animated: true)
    }
    
    @IBAction func swImageOnOff(_ sender: UISwitch) {
        if sender.isOn{
            isOn = true
        }else{
            isOn = false
        }
    }
    
    @IBAction func btnResizeImage(_ sender: UIButton) {
        if isZoom{
            isZoom = false
            btnResize.setTitle("축소", for: UIControl.State())
        }else{
            isZoom = true
            btnResize.setTitle("확대", for: UIControl.State())
        }
    }
}
