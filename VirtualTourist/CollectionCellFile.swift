//
//  CollectionCellFile.swift
//  VirtualTourist
//
//  Created by Guneet Garg on 21/04/18.
//  Copyright © 2018 Guneet Garg. All rights reserved.
//

import Foundation
import UIKit

class CollectionCell:UICollectionViewCell{
    
    @IBOutlet weak var imageView: UIImageView!
    
    func initWithPhoto(recievedPhotoInstance : Photo){
        if recievedPhotoInstance.data == nil {
            let imageURL = URL(string: recievedPhotoInstance.url!)
            URLSession.shared.dataTask(with: imageURL!){data,response,error in
                if error==nil{
                    DispatchQueue.main.async {
                        self.imageView.image = UIImage(data: data! as Data)
                    }
                }
                
                }.resume()
        } else {
            imageView.image = UIImage(data: recievedPhotoInstance.data!)
        }
    }
}

