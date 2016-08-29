//
//  ViewController.swift
//  UploadPetInfo
//
//  Created by 張峻綸 on 2016/8/14.
//  Copyright © 2016年 張峻綸. All rights reserved.
//

import UIKit
import Alamofire
let BASE_URL = "填入 Server DomainName"
//let BASE_URL = "http://localhost:8888/"
let upload_PetInfo_URL = BASE_URL + "upload_petInfo.php"
let clearPetInfoTableURL = BASE_URL + "clearPetInfoTable.php"
let URLString:String = "http://data.coa.gov.tw/Service/OpenData/AnimalOpenData.aspx"

var petsArray:NSMutableArray = []
class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        clearPetInfoTable()
        Alamofire.request(.GET,URLString).responseJSON { response in
            
                                if  let  JSON = response.result.value {
                                    //將抓到的JSON存入陣列
                                    petsArray = (JSON as? NSMutableArray)!
                                    
                                    self.upoladPetInfo(petsArray)
//                                    print ( "self.petsArray: \(petsArray) " )
                                }
                            }
        
        
    }
    
    func upoladPetInfo(jsonObject:NSMutableArray){
        for i in 0..<jsonObject.count{
            
            let dic:NSDictionary = jsonObject[i] as! NSDictionary
            
            Alamofire.request(.GET, upload_PetInfo_URL, parameters: dic as? [String : AnyObject])
                //                .validate()
                .responseJSON { response in
                    switch response.result {
                    case .Success:
                        print("上傳成功!\(response.result.value)")
                    case .Failure(let error):
                        print(error)
                    }
                    //                                PetInfoArray.append(dic)
            }
            
        }
    }
    func clearPetInfoTable(){
        Alamofire.request(.GET, clearPetInfoTableURL, parameters: nil).responseJSON { response in
            switch response.result {
            case .Success:
                print("CLEAR成功!\(response.result.value)")
            case .Failure(let error):
                print(error)
            }
            //                                PetInfoArray.append(dic)
        }
    }

    
//    func upoladAllPetInfo(jsonObject:NSArray){
//        let dic:NSDictionary = ["json":jsonObject]
//        Alamofire.request(.POST, upload_PetInfo_URL, parameters: dic as? [String : NSArray])
//            //                .validate()
//            .responseJSON { response in
//                switch response.result {
//                case .Success:
//                    print("上傳成功!\(response.result.value)")
//                //                          print("上傳成功!")
//                case .Failure(let error):
//                    print("failError\(error)")
//                }
//                //                                PetInfoArray.append(dic)
//                
//        }
//        
//    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

