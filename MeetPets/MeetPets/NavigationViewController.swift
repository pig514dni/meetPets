//
//  NavigationViewController.swift
//  MeetPets
//
//  Created by 張峻綸 on 2016/8/26.
//  Copyright © 2016年 張峻綸. All rights reserved.
//
import UIKit

class NavigationViewController: UIViewController,UIScrollViewDelegate {
    
    
    @IBOutlet weak var pageController: UIPageControl!
    
    @IBOutlet weak var guideScrollView: UIScrollView!
    
    //創造一個按鈕
    var goButton = UIButton()
    
    //取得當前螢幕的寬、高
    let width = UIScreen.mainScreen().bounds.size.width
    let height = UIScreen.mainScreen().bounds.size.height
    
    //MARK: viewDidLoad
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.guideScrollView.delegate = self
        
        self.setGuideScrollView()
        self.setGoButton()
    }
    
    //MARK: Set scrollview Info
    
    func setGuideScrollView(){
        
        //設定scrollView的contentSize的範圍是螢幕高 三倍螢幕寬
        self.guideScrollView.contentSize = CGSizeMake(width*3, height)
        
        for i in 1...3 {
            
            //依序設定圖片的大小以及在scrollView上的位置
            let imageView = UIImageView(frame: CGRectMake((width * CGFloat(i-1)), 0, width, height))
            
            imageView.image = UIImage(named:"page\(i).jpg")
            
            self.guideScrollView.addSubview(imageView)
        }
        
    }
    
    //MARK: Set button Info
    
    func setGoButton(){
        
        //按鈕要顯示在最後一張，所以x座標是在0＋兩倍寬的x距離
        goButton = UIButton(frame: CGRectMake(width * 2.0, height - 100.0, 100, 35))
        
        //讓按鈕垂直置中在頁面
        goButton.center.x = self.view.center.x + 2*width
        
        goButton.setBackgroundImage(UIImage(named: "bg"), forState: UIControlState.Normal)
        
        goButton.setTitle("開始體驗", forState: UIControlState.Normal)
        
        //forState: UIControlState.Normal (Normal代表控制元件狀態為尚未被使用)
        goButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        
        //forState: UIControlState.Highlighted (Highlighted代表控制元件狀態為正在被點選或使用中)
        goButton.setTitleColor(UIColor.redColor(), forState: UIControlState.Highlighted)
        
        //增加按鈕功能
        goButton.addTarget(self, action: #selector(goMainPage), forControlEvents: .TouchUpInside)
        
        
        
        self.guideScrollView.addSubview(goButton)
    }
    
    //MARK: Jump to main page
    
    func goMainPage(){
        let vc = storyboard?.instantiateViewControllerWithIdentifier("MainPage")
        
        self.presentViewController(vc!, animated: true, completion: nil)
    }
    
    //MARK: Use scrollview Delegate
    
    //當scrollView停止滑動時會觸發此方法
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        
        //scrollView的位移量除以螢幕寬就是目前在第幾頁
        let currentPage = Int(self.guideScrollView.contentOffset.x/width)
        
        pageController.currentPage = currentPage
    }
    
    
    //MARK: didReceiveMemoryWarning
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}
