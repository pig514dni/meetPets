//
//  PetsTableViewCell.swift
//  MeetPets
//
//  Created by 張峻綸 on 2016/8/4.
//  Copyright © 2016年 張峻綸. All rights reserved.
//

import UIKit

class PetsTableViewCell: UITableViewCell {

 
    @IBOutlet weak var petImage: AdvancedImageView!
    

    var petsInfoArray:PetInfo?
    static let cellIdentifier = "Cell"
    func setmetInfo() {
        
        //指定圖片給image

        if petsInfoArray?.album_file == "" {
            petImage.image = UIImage(named: "noImages.jpg")
        }else{
            let url:NSURL = NSURL(string: (petsInfoArray?.album_file)!)!
            petImage?.loadImageWithURL(url)
        }
        
        
        //指定文字給Label
//        animalPlaceLabel.text = petsInfoArray?.animal_id
        //指定文字給Label
//        shelterName.text = petsInfoArray?.animal_place
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
