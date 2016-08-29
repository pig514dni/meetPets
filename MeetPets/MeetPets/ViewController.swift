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

var petsInfoArray:[PetInfo] = []
var petsInfoIndex = false
var view1 = UIViewController()

let comm = Communicator.sharedInstance
extension NSLayoutConstraint {
    
    override public var description: String {
        let id = identifier ?? ""
        return "id: \(id), constant: \(constant)" //you may print whatever you want here
    }
}
class ViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {

    
    @IBOutlet weak var petsTableview: UITableView!
    
    @IBOutlet weak var searchBtn: UINavigationItem!
    var cell:PetsTableViewCell?
    let comm = Communicator.sharedInstance
    private let URLString:String = "http://data.coa.gov.tw/Service/OpenData/AnimalOpenData.aspx"
    private var viewCheck:Bool?
    var searchView = SearchView()
    var clearView:UIView?
    var viewWidth = UIScreen.mainScreen().bounds.width
    var viewHeight = UIScreen.mainScreen().bounds.height
    private var Json = [String:AnyObject]()
    private let nc = NSNotificationCenter.defaultCenter()
    var reachability : Reachability!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        
        
        
        searchBtn.title = "MeetPets"
        searchBtn.leftBarButtonItem?.title = "搜尋"
        nc.addObserver(self, selector:#selector(reloadPetsTableview) , name: "reloadTableView", object: nil)
        
        viewCheck = false
 
//        print("viewWidth:\(viewWidth),viewHeight:\(viewHeight)")
       
        searchView.frame = CGRect(x: -viewWidth, y: 60.0, width:0.86 * viewWidth, height: viewHeight
        )
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
       
       petsTableview.separatorStyle = UITableViewCellSeparatorStyle.None
       self.checkNetWork()
        
    }
    
    
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
        if petsInfoIndex == true{

            cell?.petImage.image = UIImage(named: "noResult.jpg")
        }else {
            cell?.petsInfoArray = petsInfoArray[indexPath.row]
            
            cell?.setmetInfo()
        }

        cell!.backgroundColor = UIColor.whiteColor()
        return cell!
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
       
        if petsInfoIndex == true {
            let alert = UIAlertController(title: "無法到下一頁", message: "請重新設定搜索條件", preferredStyle: .Alert)
            let ok = UIAlertAction(title: "了解", style: .Default, handler: nil)
            alert.addAction(ok)
             presentViewController(alert, animated: true, completion: nil)
        }else {
            let detailVc:DetailPetInfoViewController = (self.storyboard?.instantiateViewControllerWithIdentifier("DetailPetInfoViewController") as? DetailPetInfoViewController)!
            
            detailVc.detailInfo = petsInfoArray[indexPath.row]
            
            self.showViewController(detailVc, sender: nil)

        }
        
    }
    

    
    @IBAction func leftVC(sender: UIBarButtonItem) {
        if (viewCheck == false ) {
            searchViewMoveIn()
        }else{
            searchViewMoveOut()
        }
    }
    
    func searchViewMoveIn(){
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

