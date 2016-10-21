//
//  DetailPetInfoViewController.swift
//  MeetPets
//
//  Created by 張峻綸 on 2016/8/16.
//  Copyright © 2016年 張峻綸. All rights reserved.
//

import UIKit
import GoogleMaps
import MapKit

class DetailPetInfoViewController: UIViewController,UITableViewDelegate,UITableViewDataSource{
    
    var detailImage = AdvancedImageView()
    var detailInfo:PetInfo?
    var viewWidth = UIScreen.mainScreen().bounds.width
    //因有 NavigationBar 所以高度要剪掉44
    var viewHeight = UIScreen.mainScreen().bounds.height - 44
    var googleView:GMSMapView?
    //打電話按鈕
    var phoneBtn = UIButton()
    //導覽按鈕
    var navigationBtn = UIButton()
    var detailTableView = UITableView()
    var geocoder1 = CLGeocoder()
    //地址轉換經緯度的
    var targetPlacemark:CLPlacemark?

    private let GoogleAdsID = "ca-app-pub-8430677780806455/9506452923"
    override func loadView() {
        super.loadView()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        detailImage = AdvancedImageView(frame: CGRect(x: 0.0, y: 44.0, width: viewWidth, height: 0.3 * viewHeight))
        
        if detailInfo?.album_file == "" {
            self.detailImage.image = UIImage(named: "noImages.jpg")
            detailImage.contentMode = .ScaleAspectFit
            self.view.addSubview(detailImage)
        }else{
            
            let url:NSURL = NSURL(string: (detailInfo?.album_file)!)!
            self.detailImage.loadImageWithURL(url)
            detailImage.contentMode = .ScaleAspectFit
            self.view.addSubview(detailImage)
        }
        
        phoneBtn = UIButton(frame: CGRect(x: 10.0, y: 52 + (0.55 * viewHeight), width: 0.1 * viewWidth, height: 0.05 * viewHeight))
        let callImg = UIImage(named: "telephone.png")
        phoneBtn.setImage(callImg, forState: UIControlState.Normal)
        phoneBtn.addTarget(self, action:#selector(self.callToTarget), forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(phoneBtn)
        
        navigationBtn = UIButton(frame: CGRect(x: viewWidth - 40, y: 52 + (0.55 * viewHeight), width: 0.1 * viewWidth, height: 0.05 * viewHeight))
        let navigationImg = UIImage(named: "navigation.png")
        navigationBtn.setImage(navigationImg, forState: UIControlState.Normal)
        navigationBtn.addTarget(self, action:#selector(self.navigationToTarget), forControlEvents: UIControlEvents.TouchUpInside)
        
        self.view.addSubview(navigationBtn)
        
        detailTableView.scrollEnabled = true
        
        detailTableView = UITableView(frame: CGRect(x: 0.0, y: 52 + (0.6 * viewHeight), width: viewWidth, height: 0.4 * viewHeight))
        detailTableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        detailTableView.delegate = self
        detailTableView.dataSource = self
        detailTableView.rowHeight = UITableViewAutomaticDimension
        detailTableView.estimatedRowHeight = 21
        detailTableView.separatorStyle = UITableViewCellSeparatorStyle.None
        self.view.addSubview(detailTableView)
        
        //將收容所位置轉換為經緯度
        geocoder1.geocodeAddressString((detailInfo?.shelter_address)!) { (let placemarks , let error ) in
            
            if (error != nil) {
                print("Geocode failed with error:\(error)")
                return
            }
            self.targetPlacemark = placemarks![0]
            
            
//            print("targetPlacemark lat:\(self.targetPlacemark!.location?.coordinate.latitude), lon:\(self.targetPlacemark!.location?.coordinate.longitude)")
            let camera = GMSCameraPosition.cameraWithLatitude((self.targetPlacemark!.location?.coordinate.latitude )!,
                longitude:(self.targetPlacemark!.location?.coordinate.longitude)!, zoom:16)
            
            self.googleView = GMSMapView.mapWithFrame(CGRectMake(0.0, 48 + (0.3 * self.viewHeight), self.viewWidth, 0.25 * self.viewHeight), camera: camera)
            
            self.googleView?.myLocationEnabled = true
            
            // GMSMarker https://developers.google.com/maps/documentation/ios-sdk/marker?hl=zh-tw
            //製作標記點
            let marker = GMSMarker()
            marker.position = camera.target
            //
            marker.title = self.detailInfo?.shelter_name
            //新增標記至地圖」動畫化
            marker.appearAnimation = kGMSMarkerAnimationPop
            marker.map = self.googleView
            self.view.addSubview(self.googleView!)
        }
        
    }
    
    //導航按鈕所執行功能
    func navigationToTarget() {
        
        //產生一格Alert
        let alert = UIAlertController(title: detailInfo?.animal_place, message: nil, preferredStyle: .Alert)
        
        //Alert按下後顯示的action
        //產生Apple action
        let appleAction = UIAlertAction(title: "Apple導航", style: .Default) { (let action) in
            self.geocoder1.geocodeAddressString((self.detailInfo?.shelter_address)!) { (let placemarks , let error ) in
                
                if (error != nil) {
                    print("Geocode failed with error:\(error)")
                    let errorAlert = UIAlertController(title: "沒有提供收容所地址", message: "無法導航至目的地", preferredStyle: .Alert)
                    let errorOk = UIAlertAction(title: "了解", style: .Default, handler: nil)
                    errorAlert.addAction(errorOk)
                    self.presentViewController(errorAlert, animated: true, completion: nil)
                    return
                }
                let targetPlacemark = placemarks![0]
                
                let targetPlace = MKPlacemark.init(placemark: targetPlacemark)
                
                let targetMapItem = MKMapItem.init(placemark: targetPlace)
                
                //導航模式為Driving
                let options = [MKLaunchOptionsDirectionsModeKey:MKLaunchOptionsDirectionsModeDriving]
                //開啟導航
                targetMapItem.openInMapsWithLaunchOptions(options)
            }
        }
        //將做好的action加入至alert
        alert.addAction(appleAction)
        
        //產生Google alert
        let googleAction = UIAlertAction(title: "Google導航", style: .Default) { (let action) in
            let googleURL = NSURL(string: "comgooglemaps://")
            //假如收容所位置能轉換成功為經緯度
            if self.targetPlacemark != nil {
                //假如判斷使用者有安裝Google Map
                if (UIApplication.sharedApplication().canOpenURL(googleURL!) ){
                    
                    
                    
                    let stringToAddr = String.init(format: "%f ,%f", (self.targetPlacemark?.location?.coordinate.latitude)!,(self.targetPlacemark?.location?.coordinate.longitude)!)
                    
                    let stringURLContent = String.init(format: "comgooglemaps://?daddr=%@", stringToAddr)
                    
                    //將stringURLContent的字符編碼，已便傳到網路
                    //參考 http://www.jianshu.com/p/21a21866e379
                    let GoogleURL2 = NSURL(string: stringURLContent.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!)
                    
                    dispatch_async(dispatch_get_main_queue(), {
                        UIApplication.sharedApplication().openURL(GoogleURL2!)
                    })
                    
                }
                    //如判斷使用者沒有安裝Google Map則跳至itunes安裝頁面
                else {
                    let itunsURL = NSURL(string: "itms-apps://itunes.apple.com/app/id585027354")
                    dispatch_async(dispatch_get_main_queue(), {
                        UIApplication.sharedApplication().openURL(itunsURL!)
                    })
                    
                    //跳至Google MAP iTuns安裝頁 須在主執行緒並且異步執行,不然會有提示錯誤
                }
            }else{
                print("Geocode failed with error in Google Map")
                  let errorAlert = UIAlertController(title: "沒有提供收容所地址", message: "無法導航至目的地", preferredStyle: .Alert)
                  let errorOk = UIAlertAction(title: "了解", style: .Default, handler: nil)
                                errorAlert.addAction(errorOk)
                  self.presentViewController(errorAlert, animated: true, completion: nil)
                                return
            }
            
            

        }
        alert.addAction(googleAction)
        
        let cancelAction = UIAlertAction(title: "取消", style: .Default, handler: nil)
        alert.addAction(cancelAction)
        presentViewController(alert, animated: true, completion: nil)
    }
    
    //按下打電話按鈕後執行
    func callToTarget() {
        if detailInfo?.shelter_tel == "" {
            print("Call failed with error ")
            let errorAlert = UIAlertController(title: "沒有提供收容所電話", message: "無法撥打電話至收容所", preferredStyle: .Alert)
            let errorOk = UIAlertAction(title: "了解", style: .Default, handler: nil)
            errorAlert.addAction(errorOk)
            self.presentViewController(errorAlert, animated: true, completion: nil)
            return
            
        }else if detailInfo?.shelter_tel.characters.count < 12 {
            if detailInfo?.shelter_tel.rangeOfString(";") == nil || detailInfo?.shelter_tel.rangeOfString(" ") == nil || detailInfo?.shelter_tel != nil{
//                print("tel.Count < 12 :\(detailInfo?.shelter_tel)")
                self.callToShelter((detailInfo?.shelter_tel)!)
                
            }
        }else {
            if detailInfo?.shelter_tel.rangeOfString(";") != nil || detailInfo?.shelter_tel.rangeOfString(" ") != nil {
                
                if ((detailInfo?.shelter_tel.rangeOfString(";") ) != nil) {
                    let someArray = detailInfo?.shelter_tel.characters.split(";")
                    
                    let  tmpTelString = String(someArray![0])
                    
//                    print("tel.Count > 12 :\(tmpTelString)")
                    self.callToShelter(tmpTelString)
                }else if ((detailInfo?.shelter_tel.rangeOfString(" ") ) != nil)
                {
                    let someArray = detailInfo?.shelter_tel.characters.split(" ")
                    
                    let  tmpTelString = String(someArray![0])
                    
//                    print("tel.Count > 12 :\(tmpTelString)")
                    self.callToShelter(tmpTelString)
                }
                
            }else {
                let alert = UIAlertController(title: "電話無法撥通", message: "該收容所電話不符合格式" , preferredStyle: .Alert)
                let ok = UIAlertAction(title: "了解", style: .Default, handler: nil)
                alert.addAction(ok)
                
                presentViewController(alert, animated: true, completion: nil)
            }
            
        }
    }
    
    //開始撥打電話函式
    func callToShelter(telString:String) {
        let tel = telString
        
        //刪除輸入字符串的頭尾的空白符號
        var telephoneString = tel.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        
        var deletePhoneString = telephoneString
        //將"("、")"、_、"" 去掉
        deletePhoneString = deletePhoneString.stringByReplacingOccurrencesOfString("(", withString: "")
        deletePhoneString = deletePhoneString.stringByReplacingOccurrencesOfString(")", withString: "")
        deletePhoneString = deletePhoneString.stringByReplacingOccurrencesOfString("_", withString: "")
        deletePhoneString = deletePhoneString.stringByReplacingOccurrencesOfString(" ", withString: "")
        
        
        telephoneString = "tel://".stringByAppendingString(deletePhoneString)
        dispatch_async(dispatch_get_main_queue(), {
            UIApplication.sharedApplication().openURL(NSURL(string: telephoneString)!)
        })
        
    }
    
    //最面下顯示的tableView
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 15
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        
        //重複利用PetsTableViewCell
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
        
        if indexPath.row == 0 {
            if self.detailInfo?.animal_id == "" {
                cell.textLabel?.text = "動物編號:未提供"
            }else {
                cell.textLabel?.text = String.init(format: "動物編號:%@", (self.detailInfo?.animal_id)!)
            }
            
        }else if indexPath.row == 1 {
            cell.textLabel?.text = "收容所名稱:\(self.detailInfo?.shelter_name)"
            if self.detailInfo?.shelter_name == "" {
                cell.textLabel?.text = "收容所名稱:未提供"
            }else {
                cell.textLabel?.text = String.init(format: "收容所名稱:%@", (self.detailInfo?.shelter_name)!)
            }
        }else if indexPath.row == 2 {
            
            if self.detailInfo?.shelter_address == "" {
                cell.textLabel?.text = "收容所地址:未提供"
            }else {
                cell.textLabel?.text = String.init(format: "收容所地址:%@", (self.detailInfo?.shelter_address)!)
            }
        }else if indexPath.row == 3{
            
            if self.detailInfo?.shelter_tel == "" {
                cell.textLabel?.text = "收容所電話:未提供"
            }else {
                cell.textLabel?.text = String.init(format: "收容所電話:%@", (self.detailInfo?.shelter_tel)!)
            }
        }else if indexPath.row == 4 {
            
            if self.detailInfo?.animal_shelter_pkid == "" {
                cell.textLabel?.text = "收容所代碼:未提供"
            }else {
                cell.textLabel?.text = String.init(format: "收容所代碼:%@", (self.detailInfo?.animal_shelter_pkid)!)
            }
        }else if indexPath.row == 5 {
            
            if self.detailInfo?.animal_foundplace == "" {
                cell.textLabel?.text = "動物尋獲地:未提供"
            }else {
                cell.textLabel?.text = String.init(format: "動物尋獲地:%@", (self.detailInfo?.animal_foundplace)!)
            }
        }else if indexPath.row == 6 {
            
            if self.detailInfo?.animal_place == "" {
                cell.textLabel?.text = "目前所在地:未提供"
            }else {
                cell.textLabel?.text = String.init(format: "目前所在地:%@", (self.detailInfo?.animal_place)!)
            }
        }else if indexPath.row == 7 {
            
            if self.detailInfo?.animal_kind == "" {
                cell.textLabel?.text = "動物類型:未提供"
            }else {
                
                cell.textLabel?.text = String.init(format: "動物類型:%@", (self.detailInfo?.animal_kind)!)
            }
        }else if indexPath.row == 8 {
            
            if self.detailInfo?.animal_sex == "" {
                cell.textLabel?.text = "動物性別:未提供"
            }else {
                if self.detailInfo?.animal_sex == "M" {
                    cell.textLabel?.text = "動物性別:男"
                }else {
                    cell.textLabel?.text = "動物性別:女"
                }

            }
        }else if indexPath.row == 9 {
            
            if self.detailInfo?.animal_bodytype == "" {
                cell.textLabel?.text = "動物體型:未提供"
            }else {
                if self.detailInfo?.animal_bodytype == "MINI" {
                    cell.textLabel?.text = "動物體型:迷你"
                }else if self.detailInfo?.animal_bodytype == "SMALL" {
                    cell.textLabel?.text = "動物體型:小型"
                }else if self.detailInfo?.animal_bodytype == "MEDIUM" {
                    cell.textLabel?.text = "動物體型:中型"
                }else if self.detailInfo?.animal_bodytype == "BIG" {
                    cell.textLabel?.text = "動物體型:大型"
                }

            }
        }else if indexPath.row == 10 {
            
            if self.detailInfo?.animal_color == "" {
                cell.textLabel?.text = "動物毛色:未提供"
            }else {
                cell.textLabel?.text = String.init(format: "動物毛色:%@", (self.detailInfo?.animal_color)!)
            }
        }else if indexPath.row == 11 {
            
            if self.detailInfo?.animal_age == "" {
                cell.textLabel?.text = "動物年紀:未提供"
            }else {
                if self.detailInfo?.animal_age == "CHILD" {
                    cell.textLabel?.text = "動物年紀:幼年"
                }else {
                    cell.textLabel?.text = "動物年紀:成年"
                }

            }
        }else if indexPath.row == 12 {
            
            if self.detailInfo?.animal_sterilization == "" {
                cell.textLabel?.text = "是否結紮:未提供"
            }else {
                if self.detailInfo?.animal_sterilization == "T" {
                    cell.textLabel?.text = "是否結紮:是"
                }else if self.detailInfo?.animal_sterilization == "F" {
                    cell.textLabel?.text = "是否結紮:否"
                }else {
                    cell.textLabel?.text = "是否結紮:未提供"
                }

            }
        }else if indexPath.row == 13 {
            
            if self.detailInfo?.animal_bacterin == "" {
                cell.textLabel?.text = "是否施打疫苗:未提供"
            }else {
                if self.detailInfo?.animal_bacterin == "T" {
                    cell.textLabel?.text = "是否施打疫苗:是"
                }else if self.detailInfo?.animal_bacterin == "F" {
                    cell.textLabel?.text = "是否施打疫苗:否"
                }else {
                    cell.textLabel?.text = "是否施打疫苗:未提供"
                }
   
            }
        }else if indexPath.row == 14 {
            
            if self.detailInfo?.animal_remark == "" {
                cell.textLabel?.text = "備註:未提供"
            }else {
                cell.textLabel?.text = String.init(format: "備註:%@", (self.detailInfo?.animal_remark)!)
            }
        }

        cell.textLabel?.numberOfLines = 0
        cell.textLabel?.sizeToFit()
        return cell
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
