//
//  ViewController.swift
//  MeetPets
//
//  Created by 張峻綸 on 2016/8/3.
//  Copyright © 2016年 張峻綸. All rights reserved.
//

import UIKit
import Alamofire
import ReachabilitySwift
//typealias completion = (youWantToSave:NSArray) -> Void

//產生一個只能包著PetInfo類別的Array
var petsInfoArray:[PetInfo] = []
//判斷從DB拿不拿得到資料，拿不到資料則為True，有符合則維持False
var petsInfoIndex = false
//Google Admob須使用
var view1 = UIViewController()

//let comm = Communicator.sharedInstance

//解決Autolayout 錯誤
//每一個constraint都要設定一個identifier
extension NSLayoutConstraint {
    
    override public var description: String {
        let id = identifier ?? ""
        return "id: \(id), constant: \(constant)" //you may print whatever you want here
    }
}
class ViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {

    
    @IBOutlet weak var petsTableview: UITableView!
    
    @IBOutlet weak var searchBtn: UINavigationItem!
    //創照一個PetsTableViewCell 物件
    var cell:PetsTableViewCell?
    //創造一個Communicator.sharedInstance 確保都使用到同一個
    let comm = Communicator.sharedInstance
    
    //確認目前搜尋頁面的狀態 True為目前搜尋頁面在前面 False為目前隱藏
    private var viewCheck:Bool?
    //創照一個SearchView物件
    var searchView = SearchView()
    //因搜尋頁面出來，使用者點選TableView會進入詳細頁面，所以創造一個透明View擋住
    var clearView:UIView?
    //使用者手機目前螢幕寬
    var viewWidth = UIScreen.mainScreen().bounds.width
    //使用者手機目前螢幕高
    var viewHeight = UIScreen.mainScreen().bounds.height
    //創造一個字典[String:AnyObject]
    private var Json = [String:AnyObject]()
    //創造一個監聽NotificationCenter的物件
    private let nc = NSNotificationCenter.defaultCenter()
    //創造一個第三方套件Reachability物件
    var reachability : Reachability!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        searchBtn.title = "MeetPets"
        searchBtn.leftBarButtonItem?.title = "搜尋"
        //當接收到字串reloadTableView時，執行reloadPetsTableview函式
        nc.addObserver(self, selector:#selector(reloadPetsTableview) , name: "reloadTableView", object: nil)
        
        //將viewCheck設為False，表示目前searchView隱藏中
        viewCheck = false
 
//        print("viewWidth:\(viewWidth),viewHeight:\(viewHeight)")
       
        //將創出來得searchView位置預設為x: -viewWidth, y: 60.0
        searchView.frame = CGRect(x: -viewWidth, y: 60.0, width:0.86 * viewWidth, height: viewHeight
        )
        //將創出來得searchView顏色設定
        searchView.backgroundColor = UIColor(red: 112.0/255.0, green: 193.0/255.0, blue: 179.0/255.0, alpha: 1)

        
        self.view.addSubview(searchView)
        
        clearView = UIView(frame: CGRect(x:  viewWidth, y: 60.0, width:0.14 * viewWidth, height: viewHeight))
        
        self.view.addSubview(clearView!)
        

//        Connection(URLString) { (youWantToSave) in
//            petsInfoArray = youWantToSave as! [PetInfo]
                self.getPetsInfo(Json) { (result, error) in
//                 dispatch_async(dispatch_get_main_queue(), {
                        self.petsTableview.reloadData()
//                    })
                    
                   
        }
       //將自定義的TableViewCell 分割線設定成None
       petsTableview.separatorStyle = UITableViewCellSeparatorStyle.None
        
        //執行檢查網路狀態
       self.checkNetWork()
        
    }
    
    //確認網路狀態
    func checkNetWork() {
        do{
            reachability = try Reachability.reachabilityForInternetConnection()
            
        }catch{
            
            print("Unable to create Reachability")
            return
        }
        
        
        
        //當網路無法連接時，執行以下
        reachability.whenUnreachable = { reachability in
            
            let alert = UIAlertController(title: "網路連接失敗", message: "請連接網路，否則將無法正常使用", preferredStyle: .Alert)
            
            let ok = UIAlertAction(title: "OK", style: .Default, handler: nil)
            
            alert.addAction(ok)
            
            dispatch_async(dispatch_get_main_queue(), {
                self.presentViewController(alert, animated: true, completion: nil)
            })
            
            
            return
            
        }
        
        do {
            //開始監聽
            try reachability.startNotifier()
            
        }catch{
            
            print("Unable to start notifier")
            
        }
    }
    
    //此函式為至comm拿取寵物資料
    func getPetsInfo(Json:[String:AnyObject]?,completion:Completion) {

         comm.getPetsInfo(Json,completion: { (result,error) in
            petsInfoArray = result as! [PetInfo]
             completion(result: nil,error: nil)
         })
    }

    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1

    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if petsInfoIndex == true {
            return 1
        }else {
            return petsInfoArray.count
        }
    
        
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        
        //重複利用PetsTableViewCell
        cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as? PetsTableViewCell
//        print("cell petInfoArray:\(petsInfoArray)")
       
        cell?.petImage.image = nil
        if petsInfoIndex == true{
            //假如沒有資料，則秀出noResult.jpg 圖片
            cell?.petImage.image = UIImage(named: "noResult.jpg")
        }else {
//            cell?.petsInfoArray = petsInfoArray[indexPath.row]
            
            //假如有資料則當使用者滑到該Cell時，至URL下載並秀到Cell上
            if let url = NSURL(string: petsInfoArray[indexPath.row].album_file){
                cell?.petImage.loadImageWithURL(url)
            }
            
        }

        cell!.backgroundColor = UIColor.whiteColor()
        return cell!
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
       
        if petsInfoIndex == true {
            //當沒有資料時，使用者點選Cell跳出alert告知沒有資料
            let alert = UIAlertController(title: "無法到下一頁", message: "請重新設定搜索條件", preferredStyle: .Alert)
            let ok = UIAlertAction(title: "了解", style: .Default, handler: nil)
            alert.addAction(ok)
             presentViewController(alert, animated: true, completion: nil)
        }else {
            
            let detailVc:DetailPetInfoViewController = (self.storyboard?.instantiateViewControllerWithIdentifier("DetailPetInfoViewController") as? DetailPetInfoViewController)!
            
            //將使用者選到的PetInfo給下一個頁面的detailInfo變數
            detailVc.detailInfo = petsInfoArray[indexPath.row]
            
            self.showViewController(detailVc, sender: nil)

        }
        
    }
    

    //當使用者按下搜尋案件時判斷
    @IBAction func leftVC(sender: UIBarButtonItem) {
        if (viewCheck == false ) {
            searchViewMoveIn()
        }else{
            searchViewMoveOut()
        }
    }
    
    func searchViewMoveIn(){
        //搜尋頁面在0.85秒秀出來，並改變他的Frame
        UIView.animateWithDuration(0.85) {
            var newFrame:CGRect = self.searchView.frame
            newFrame.origin.x += self.viewWidth
            self.searchView.frame = newFrame
            self.viewCheck = true
            
        }
        
        var clearNewFrame:CGRect = self.clearView!.frame
        clearNewFrame.origin.x -= 0.15 * self.viewWidth
        self.clearView?.frame = clearNewFrame
        
    }
    
    func searchViewMoveOut(){
        
        UIView.animateWithDuration(0.85) {
            var newFrame:CGRect = self.searchView.frame
            newFrame.origin.x -= self.viewWidth
            self.searchView.frame = newFrame
            self.viewCheck = false
            
        }
        var clearNewFrame:CGRect = self.clearView!.frame
        clearNewFrame.origin.x += 0.15 * self.viewWidth
        self.clearView?.frame = clearNewFrame
       
        
    }
    
    func reloadPetsTableview() {
        self.petsTableview.reloadData()
        searchViewMoveOut()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

