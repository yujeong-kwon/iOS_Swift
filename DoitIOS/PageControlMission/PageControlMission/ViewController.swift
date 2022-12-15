//
//  ViewController.swift
//  PageControlMission
//
//  Created by 권유정 on 2022/05/17.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet var lblPage: UILabel!
    @IBOutlet var pageControl: UIPageControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        pageControl.numberOfPages = 10
        pageControl.currentPage = 0
        pageControl.pageIndicatorTintColor = UIColor.blue
        pageControl.currentPageIndicatorTintColor = UIColor.green
        lblPage.text = String(1)
    }
    @IBAction func pageChange(_ sender: UIPageControl) {
        lblPage.text = String(pageControl.currentPage + 1)
    }
    

}

