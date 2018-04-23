//
//  PhotoDetailViewController.swift
//  VirtualTourist
//
//  Created by Guneet Garg on 21/04/18.
//  Copyright © 2018 Guneet Garg. All rights reserved.
//

import Foundation
import UIKit

class PhotoDetailViewController:UIViewController {
    
    @IBOutlet weak var detailedImage: UIImageView!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
    }
    
    func initWithPhoto(recievedPhotoInstance : Photo){
            let imageURL = URL(string: recievedPhotoInstance.url!)
            URLSession.shared.dataTask(with: imageURL!){data,response,error in
            if error==nil{
                self.detailedImage.image = UIImage(data: data! as Data)
            }
        }
    }
}
