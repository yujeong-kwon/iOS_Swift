//
//  ViewController.swift
//  PinchGesture
//
//  Created by 권유정 on 2022/06/14.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet var txtPinch: UILabel!
    @IBOutlet var imgPinch: UIImageView!
    
    var initalFontSize: CGFloat!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        let pinch = UIPinchGestureRecognizer(target: self, action: #selector(ViewController.doPinch(_:)))
        self.view.addGestureRecognizer(pinch)
    }
    @objc func doPinch(_ pinch: UIPinchGestureRecognizer){
        //if (pinch.state == UIGestureRecognizer.State.began){
        //    initalFontSize = txtPinch.font.pointSize
        //}else{
        //    txtPinch.font = txtPinch.font.withSize(initalFontSize * pinch.scale)
        //}
        imgPinch.transform = imgPinch.transform.scaledBy(x: pinch.scale, y: pinch.scale)
        pinch.scale = 1
    }

}

