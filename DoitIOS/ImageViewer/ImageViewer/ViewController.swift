//
//  ViewController.swift
//  ImageViewer
//
//  Created by 권유정 on 2022/05/08.
//

import UIKit

class ViewController: UIViewController {
    var numImage = 1
    
    @IBOutlet var imgView: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        imgView.image = UIImage(named: "1.png")
    }

    @IBAction func btnPrev(_ sender: UIButton) {
        numImage -= 1
        if(numImage<1){
            numImage = 6
        }
        let imageNmae = String(numImage) + ".png"
        imgView.image = UIImage(named: imageNmae)
        
    }
    
    @IBAction func btnNext(_ sender: UIButton) {
        numImage += 1
        if(numImage>6){
            numImage = 1
        }
        let imageNmae = String(numImage) + ".png"
        imgView.image = UIImage(named: imageNmae)
        
    }
}

