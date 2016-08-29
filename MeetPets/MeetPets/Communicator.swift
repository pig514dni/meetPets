//
//  Communicator.swift
//  MeetPets
//
//  Created by 張峻綸 on 2016/8/10.
//  Copyright © 2016年 張峻綸. All rights reserved.
//

import UIKit
import Alamofire
let BASE_URL = "填入 Server Domain Name"

let GET_PETSINFO_URL = BASE_URL + "get_PetInfo.php"
typealias Completion = (result:AnyObject?,error:NSError?) -> Void
private let Json = [String:String]()

class Communicator: NSObject {
    

    
    //singleton宣告
    static let sharedInstance = Communicator()
    private var temp:[PetInfo] = []
    func getPetsInfo(Json:[String:AnyObject]?,completion:Completion) -> NSArray {
        self.temp.removeAll()
        Alamofire.request(.GET,GET_PETSINFO_URL,parameters:Json).responseJSON{ response in
            switch response.result {
            case .Success:
                if response.result.value != nil {
//                    print("GetPetInfo::::\(response.result.value)")
//                    print("GetPetsInfo成功!\(response.result.value?.count)")
                    if let jsonObj = response.result.value as? NSArray {
//                        print("JSON:\(jsonObj)")
                        for dic in jsonObj {
                            //有幾筆資料就創造幾個自定義的寵物類別
                            let pet = PetInfo()
//                            print("DIC:\(dic)")
                            //將需要的資料分別解析出來，並存入相對應變數
                            pet.animal_id = dic["animal_id"] as! String
                            pet.animal_place = dic["shelter_address"] as! String
                            pet.animal_kind = dic["animal_kind"] as! String
                            pet.album_file = dic["album_file"] as! String
                            pet.shelter_address = dic["shelter_address"] as! String
                            pet.shelter_tel = dic["shelter_tel"] as! String
                            pet.animal_bacterin = dic["animal_bacterin"] as! String
                            pet.animal_color = dic["animal_color"] as! String
                            pet.animal_age = dic["animal_age"] as! String
                            pet.animal_bodytype = dic["animal_bodytype"] as! String
                            pet.animal_foundplace = dic["animal_foundplace"] as! String
                            pet.animal_sex = dic["animal_sex"] as! String
                            pet.animal_shelter_pkid = dic["animal_shelter_pkid"] as! String
                            pet.animal_sterilization = dic["animal_sterilization"] as! String
                            pet.animal_remark = dic["animal_remark"] as! String
                            pet.shelter_name = dic["shelter_name"] as! String
//                            let urlString:String = dic["album_file"] as! String
//                            imageURLArray.append(urlString)
                         
                            //將存好的每筆資料依序存入暫存陣列
                            self.temp.append(pet)
                        }
                        //將存好的暫存陣列放入反向傳值的closure
                        completion(result: self.temp,error: nil)
                    }
                }
            case .Failure(let error):
                print("upLoadError:\(error)")
            }
            //                                PetInfoArray.append(dic)
        }
        return  self.temp
    }
    
    
    
//    func getPetsInfo(completion:Completion) -> NSArray {
//        Alamofire.request(.POST,GET_PETSINFO_URL,parameters: nil).responseJSON{ response in
//            switch response.result {
//            case .Success:
//                if response.result.value != nil {
//                    //                    print("GetPetsInfo成功!\(response.result.value)")
//                    if let jsonObj = response.result.value as? NSArray {
//                        //                        print("JSON:\(jsonObj)")
//                        for dic in jsonObj {
//                            //有幾筆資料就創造幾個自定義的寵物類別
//                            let pet = PetInfo()
//                            //                            print("DIC:\(dic)")
//                            //將需要的資料分別解析出來，並存入相對應變數
//                            pet.animal_id = dic["animal_id"] as! String
//                            pet.animal_place = dic["shelter_address"] as! String
//                            pet.animal_kind = dic["shelter_tel"] as! String
//                            pet.album_file = dic["album_file"] as! String
//                            
//                            //                            let urlString:String = dic["album_file"] as! String
//                            //                            imageURLArray.append(urlString)
//                            
//                            //將存好的每筆資料依序存入暫存陣列
//                            self.temp.append(pet)
//                        }
//                        //將存好的暫存陣列放入反向傳值的closure
//                        completion(result: self.temp,error: nil)
//                    }
//                }
//            case .Failure(let error):
//                print(error)
//            }
//            //                                PetInfoArray.append(dic)
//        }
//        return  self.temp
//    }

    
    
    
    
    
}