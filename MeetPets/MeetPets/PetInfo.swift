//
//  PetInfo.swift
//  MeetPets
//
//  Created by 張峻綸 on 2016/8/10.
//  Copyright © 2016年 張峻綸. All rights reserved.
//

import UIKit

class PetInfo: NSObject {
    //寵物認養ID
    var animal_id:String = ""
    //目前所在位置
    var animal_place:String = ""
    //動物尋獲地
    var animal_foundplace:String = ""
    //寵物種類 狗 OR 貓
    var animal_kind:String = ""
    //寵物URL
    var album_file:String = ""
    //寵物圖片
    var petsImage:UIImage?
    //動物性別
    var animal_sex:String = ""
    //動物體型
    var animal_bodytype:String = ""
    //動物毛色 
    var animal_color:String = ""
    //動物年齡
    var animal_age:String = ""
    //是否結紮
    var animal_sterilization:String = ""
    //是否施打疫苗
    var animal_bacterin:String = ""
   //備註
    var animal_remark:String = ""
    
    //收容所名稱
    var shelter_name:String = ""
    //收容所地址
    var shelter_address:String = ""
    //收容所電話
    var shelter_tel:String = ""
    //收容所代碼
    var animal_shelter_pkid:String = ""
    
}
