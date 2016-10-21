//
//  SearchView.swift
//  MeetPets
//
//  Created by 張峻綸 on 2016/8/18.
//  Copyright © 2016年 張峻綸. All rights reserved.
//

import UIKit
import GoogleMobileAds
class SearchView: UIView,UITextFieldDelegate,UIPickerViewDelegate,UIPickerViewDataSource {
    
    let comm = Communicator.sharedInstance
    
//    private  var sexLabel:UILabel?
//    private  var sexTextField:UITextField?
    private  var selectView:UIView?
    
    private  let viewWidth = UIScreen.mainScreen().bounds.width
    private let viewHeight = UIScreen.mainScreen().bounds.height
    private  var cancelBtn:UIButton?
    private var confirmBtn:UIButton?
    private var searchBtn:UIButton?
    private var buttonIndex:Bool?
    private var textFieldLabel = UILabel?()
    private var pickerView:UIPickerView?
    private var searchInfoArray:[String] = []
    //實際顯示的文字及輸入地方
    private var areaInfo = selectPetInfo()
    private var kindInfo = selectPetInfo()
    private var bodytypeInfo = selectPetInfo()
    private  var ageInfo = selectPetInfo()
    private  var sexInfo = selectPetInfo()
    
    private  var selectString:String = ""
    private  var selectTextField:String = ""
    private var Json = [String:String]()
    private var BannerView = GADBannerView()
    private let GoogleAdsID = "ca-app-pub-8430677780806455/9506452923"
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
        
        addSelectInfo()
        
        //加入一個View 裡面裝著PickerView 取消 完成按鈕
        selectView = UIView(frame: CGRect(x: 0, y: viewHeight, width: 0.86 * viewWidth, height: 0.5 * viewHeight))
        selectView?.backgroundColor = UIColor(red: 112.0/255.0, green: 193.0/255.0, blue: 179.0/255.0, alpha: 1)


        addSubview(selectView!)
        
        cancelBtn = UIButton(frame: CGRect(x: 10.0, y: 10.0, width: 40.0, height: 21.0))
        cancelBtn?.setTitle("取消", forState: UIControlState.Normal)
        cancelBtn?.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
        cancelBtn?.addTarget(self, action:#selector(SearchView.cancelSelect), forControlEvents: UIControlEvents.TouchUpInside)
        selectView?.addSubview(cancelBtn!)
        
        
        confirmBtn = UIButton(frame: CGRect(x: (0.86 * viewWidth) - 50, y: 10.0, width: 40.0, height: 21.0))
        confirmBtn?.setTitle("完成", forState: UIControlState.Normal)
        confirmBtn?.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
        confirmBtn?.addTarget(self, action:#selector(SearchView.confirmSelect), forControlEvents: UIControlEvents.TouchUpInside)
        selectView?.addSubview(confirmBtn!)
        
        pickerView = UIPickerView(frame:CGRect(x: (0.86 * viewWidth / 2) - (0.35 * viewWidth)  , y: 40, width: 0.7 * viewWidth, height: 150))

                pickerView?.backgroundColor = UIColor(red: 112.0/255.0, green: 193.0/255.0, blue: 179.0/255.0, alpha: 1)
        
        
        pickerView?.dataSource = self
        pickerView?.delegate = self
        
        selectView?.addSubview(pickerView!)
        
        
        searchBtn = UIButton(frame: CGRect(x: (0.5 * 0.86 * viewWidth) - (0.05 * viewHeight) , y: 30 + (0.35 * viewHeight), width: 40, height: 21))
        searchBtn?.setTitle("搜尋", forState: UIControlState.Normal)
        
        searchBtn?.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
        
        
        searchBtn?.addTarget(self, action:#selector(searchFromDB), forControlEvents: UIControlEvents.TouchUpInside)
        
        addSubview(searchBtn!)
        
        //顯示使用者目前選到哪個條件
        textFieldLabel = UILabel(frame: CGRect(x: (0.86 * viewWidth / 2) - 10.5 , y: 10.0, width: 40.0, height: 21.0))
        
        self.selectView?.addSubview(textFieldLabel!)
        
        //加入廣告
        BannerView = GADBannerView(frame: CGRect(x: 0.0, y: viewHeight - 110, width: 0.86 * viewWidth , height: 50))
        BannerView.adUnitID = GoogleAdsID
        BannerView.rootViewController = view1
        BannerView.loadRequest(GADRequest())
        addSubview(BannerView)

        
        buttonIndex = false
    }
    
    func setBannerViewRootViewController(rootView:UIViewController) {
        BannerView.rootViewController = rootView
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    //顯示幾個選項
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int
    {
        return searchInfoArray.count;
    }
    
    //顯示選項名稱
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        return searchInfoArray[row]
    }
    
    //使用者選擇到哪個選項
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int){
        
        
        selectString = searchInfoArray[row]
    }
    
    func searchFromDB() {

        if (areaInfo.selectTextField.text == "" || areaInfo.selectTextField.text == "不限") {
            Json["area"] = ""
        }else{
            Json["area"] = convertAreaString(areaInfo.selectTextField.text!)
           
        }
        
        if (kindInfo.selectTextField.text == "" || kindInfo.selectTextField.text == "不限") {
            Json["kind"] = ""
            
        }else{
            Json["kind"] = kindInfo.selectTextField.text
        }
        
        if (bodytypeInfo.selectTextField.text == "" || bodytypeInfo.selectTextField.text == "不限") {
            Json["bodytype"] = ""
        }else{
            
            Json["bodytype"] = convertBodytypeString(bodytypeInfo.selectTextField.text!)
        }
        
        if (ageInfo.selectTextField.text == "" || ageInfo.selectTextField.text == "不限") {
            Json["age"] = ""
        }else{
            Json["age"] = convertAgeString(ageInfo.selectTextField.text!)
        }
        
        if (sexInfo.selectTextField.text == "" || sexInfo.selectTextField.text == "不限") {
            Json["sex"] = ""
        }else{
            Json["sex"] = convertSexString(sexInfo.selectTextField.text!)
            
        }
//        print("Json:\(Json)")
        
        //將組好的Json格式Post至DB，並接收回來得值
        self.getPetsInfo(Json) { (result, error) in
            let nc = NSNotificationCenter.defaultCenter()
            nc.postNotificationName("reloadTableView", object: nil)
        }
        
    }
    
    func getPetsInfo(Json:[String:AnyObject]?,completion:Completion) {
  
        comm.getPetsInfo(Json,completion: { (result,error) in
            if (error != nil){
                print("getPetsInfo Error")
            }
            if result?.count == 0 {
                petsInfoArray.removeAll()
                petsInfoArray = result as! [PetInfo]
                petsInfoIndex = true
                completion(result: nil,error: nil)
            }else {

                petsInfoArray.removeAll()
                petsInfoArray = result as! [PetInfo]
                petsInfoIndex = false
                completion(result: nil,error: nil)
            }
            
        })
    }
    
    //按下SelectView 確認按鈕所執行
    func confirmSelect() {

        switch selectTextField {
        case let selectTextField where selectTextField == "area":
            if selectString == "" {
                areaInfo.selectTextField.text = "不限"
            }else{
                areaInfo.selectTextField.text = selectString
            }
            selectString = ""
        case let selectTextField where selectTextField == "kind":
            if selectString == "" {
                kindInfo.selectTextField.text = "不限"
            }else{
                kindInfo.selectTextField.text = selectString
            }
            selectString = ""
        case let selectTextField where selectTextField == "body":
            if selectString == "" {
                bodytypeInfo.selectTextField.text = "不限"
            }else{
                bodytypeInfo.selectTextField.text = selectString
            }
            selectString = ""
            
            
        case let selectTextField where selectTextField == "age":
            if selectString == "" {
                ageInfo.selectTextField.text = "不限"
            }else{
                ageInfo.selectTextField.text = selectString
            }
            selectString = ""
            
        case let selectTextField where selectTextField == "sex":
            if selectString == "" {
                sexInfo.selectTextField.text = "不限"
            }else{
                sexInfo.selectTextField.text = selectString            }
            selectString = ""
            
        default: break
            
        }
        self.selectViewMoveOut()
    }
    
     //按下SelectView 取消按鈕所執行
    func cancelSelect() {
        
        self.selectViewMoveOut()
    }
    
    //按下textField所執行的Delegate
    func textFieldDidBeginEditing(textField: UITextField) {
      
        selectString = "不限"
        //將pickerView位置回到(0.0)
        pickerView?.selectRow(0,inComponent:0,animated:true)
        //移除之前的紀錄
        pickerView?.reloadAllComponents()
        //將鍵盤收起來
        petInfoResignFirstResponder()
        if buttonIndex == false {
            self.selectViewMoveIn()
        }
        if textField == areaInfo.selectTextField {
            searchInfoArray = ["不限","臺北市","新北市","基隆市","宜蘭縣","桃園市","新竹縣","新竹市","苗栗縣","臺中市","彰化縣","南投縣","雲林縣","嘉義縣","嘉義市","臺南市","高雄市","屏東縣","花蓮縣","臺東縣","澎湖縣","金門縣","連江縣"]
            pickerView?.reloadAllComponents()
            pickerView?.selectRow(0,inComponent:0,animated:true)
            selectTextField = "area"

            textFieldLabel?.text = "區域"

        }
        if textField == kindInfo.selectTextField {
            searchInfoArray = ["不限","狗","貓"]
            pickerView?.reloadAllComponents()
            pickerView?.selectRow(0,inComponent:0,animated:true)
            selectTextField = "kind"
            textFieldLabel?.text = "種類"
        }
        if textField == bodytypeInfo.selectTextField {
            searchInfoArray = ["不限","迷你","小型","中型","大型"]
            pickerView?.reloadAllComponents()
            pickerView?.selectRow(0,inComponent:0,animated:true)
            selectTextField = "body"
            textFieldLabel?.text = "體型"
        }
        if textField == ageInfo.selectTextField {
            searchInfoArray = ["不限","幼年","成年"]
            pickerView?.reloadAllComponents()
            pickerView?.selectRow(0,inComponent:0,animated:true)
            selectTextField = "age"
            textFieldLabel?.text = "年齡"
        }
        
        if textField == sexInfo.selectTextField {
            searchInfoArray = ["不限","男","女"]
            pickerView?.reloadAllComponents()
            pickerView?.selectRow(0,inComponent:0,animated:true)
            selectTextField = "sex"
            textFieldLabel?.text = "性別"
        }
        pickerView?.reloadAllComponents()
    }
    
    // MARK: selectView 移入畫面
    func selectViewMoveIn(){
        
        UIView.animateWithDuration(0.75) {
            var newFrame:CGRect = self.selectView!.frame
            newFrame.origin.y -= 300
            self.selectView!.frame = newFrame
        }
        buttonIndex = true
        
    }
    
    // MARK: selectView 移出畫面
    func selectViewMoveOut(){
        petInfoResignFirstResponder()
        UIView.animateWithDuration(0.75) {
            var newFrame:CGRect = self.selectView!.frame
            newFrame.origin.y += 300
            self.selectView!.frame = newFrame
        }
        buttonIndex = false
    }
    
    
    
    
    
    // MARK: 將選擇細項加入
    func addSelectInfo() {
        areaInfo.setLabelFrame(10.0, Y: 30.0 , Width: 0.2 * viewWidth, Height: 30.0)
        areaInfo.setLabelText("區域:")
        areaInfo.setTextFieldFrame(56.0, Y: 30.0 , Width: 0.5 * viewWidth, Height: 30.0)
        areaInfo.selectTextField.delegate = self
        
        addSubview(areaInfo.selectLabel)
        addSubview(areaInfo.selectTextField)
        
        kindInfo.setLabelFrame(10.0, Y: 30.0 + (0.07 * viewHeight), Width: 0.2 * viewWidth, Height: 30.0)
        kindInfo.setLabelText("種類:")
        kindInfo.setTextFieldFrame(56.0, Y: 30.0 + (0.07 * viewHeight), Width: 0.5 * viewWidth, Height: 30.0)
        kindInfo.selectTextField.delegate = self
        
        addSubview(kindInfo.selectLabel)
        addSubview(kindInfo.selectTextField)
        
        bodytypeInfo.setLabelFrame(10.0, Y: 30.0 + (0.14 * viewHeight), Width: 0.2 * viewWidth, Height: 30.0)
        bodytypeInfo.setLabelText("體型:")
        bodytypeInfo.setTextFieldFrame(56.0, Y: 30.0 + (0.14 * viewHeight), Width: 0.5 * viewWidth, Height: 30.0)
        bodytypeInfo.selectTextField.delegate = self
        
        addSubview(bodytypeInfo.selectLabel)
        addSubview(bodytypeInfo.selectTextField)
        
        ageInfo.setLabelFrame(10.0, Y: 30.0 + (0.21 * viewHeight), Width: 0.2 * viewWidth, Height: 30.0)
        ageInfo.setLabelText("年齡:")
        ageInfo.setTextFieldFrame(56.0, Y: 30.0 + (0.21 * viewHeight), Width: 0.5 * viewWidth, Height: 30.0)
        ageInfo.selectTextField.delegate = self
        
        addSubview(ageInfo.selectLabel)
        addSubview(ageInfo.selectTextField)
        
        sexInfo.setLabelFrame(10.0, Y: 30.0 + (0.28 * viewHeight), Width: 0.2 * viewWidth, Height: 30.0)
        sexInfo.setLabelText("性別:")
        sexInfo.setTextFieldFrame(56.0, Y: 30.0 + (0.28 * viewHeight), Width: 0.5 * viewWidth, Height: 30.0)
        sexInfo.selectTextField.delegate = self
        
        addSubview(sexInfo.selectLabel)
        addSubview(sexInfo.selectTextField)
    }
    
    // MARK: 將textField 鍵盤取消
    func petInfoResignFirstResponder() {
        areaInfo.selectTextField.resignFirstResponder()
        kindInfo.selectTextField.resignFirstResponder()
        bodytypeInfo.selectTextField.resignFirstResponder()
        ageInfo.selectTextField.resignFirstResponder()
        sexInfo.selectTextField.resignFirstResponder()
    }
    
    
    func convertAreaString(string:String) -> String {
        if string == "臺北市" {
            return "2"
        }else if string == "新北市"{
            return "3"
        }else if string == "基隆市"{
            return "4"
        }else if string == "宜蘭縣"{
            return "5"
        }else if string == "桃園市"{
            return "6"
        }else if string == "新竹縣"{
            return "7"
        }else if string == "新竹市"{
            return "8"
        }else if string == "苗栗縣"{
            return "9"
        }else if string == "臺中市"{
            return "10"
        }else if string == "彰化縣"{
            return "11"
        }else if string == "南投縣"{
            return "12"
        }else if string == "雲林縣"{
            return "13"
        }else if string == "嘉義縣"{
            return "14"
        }else if string == "嘉義市"{
            return "15"
        }else if string == "臺南市"{
            return "16"
        }else if string == "高雄市"{
            return "17"
        }else if string == "屏東縣"{
            return "18"
        }else if string == "花蓮縣"{
            return "19"
        }else if string == "臺東縣"{
            return "20"
        }else if string == "澎湖縣"{
            return "21"
        }else if string == "金門縣"{
            return "22"
        }else{
            return "23"
        }
        
    }
    
    func convertBodytypeString(string:String) -> String {
        if string == "迷你" {
            return "MINI"
        }else if string == "小型" {
            return "SMALL"
        }else if string == "中型" {
            return "MEDIUM"
        }else {
            return "BIG"
        }
    }
    
    func convertAgeString(string:String) -> String {
        if string == "幼年" {
            return "CHILD"
        }else {
            return "ADULT"
        }
    }
    
    func convertSexString(string:String) -> String {
        if string == "男" {
            return "M"
        }else {
            return "F"
        }
    }
    
}

//自定義Class
class selectPetInfo {
    
    var selectLabel = UILabel()
    var selectTextField = UITextField()
    
    
    
    func setLabelFrame(X: CGFloat, Y: CGFloat ,Width: CGFloat, Height: CGFloat){
        selectLabel = UILabel(frame: CGRect(x: X, y: Y, width: Width, height: Height))
    }
    
    func setTextFieldFrame(X: CGFloat, Y: CGFloat ,Width: CGFloat, Height: CGFloat){
        selectTextField = UITextField(frame: CGRect(x: X, y: Y, width: Width, height: Height))
        selectTextField.borderStyle = .RoundedRect
    }
    
    func setLabelText(string: String) {
        selectLabel.text = string
        selectLabel.font.fontWithSize(24.0)
    }
    
}

//class selectBtn:UIButton {
//    var selectBtn:UIButton?
//
////    cancelBtn = UIButton(frame: CGRect(x: 10.0, y: 10.0, width: 40.0, height: 21.0))
////    cancelBtn?.setTitle("取消", forState: UIControlState.Normal)
////    cancelBtn?.addTarget(self, action:#selector(SearchView.cancelSelect), forControlEvents: UIControlEvents.TouchUpInside)
//    func setBtnFrame(X: CGFloat, Y: CGFloat ,Width: CGFloat, Height: CGFloat){
//        selectBtn = UIButton(frame: CGRect(x: X, y: Y, width: Width, height: Height))
//    }
//    func setBtnTitle(string: String) {
//        selectBtn?.setTitle(string, forState: UIControlState.Normal)
//    }
//}
