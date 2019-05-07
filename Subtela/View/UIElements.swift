//
//  HeaderFooter.swift
//  DungeonSettings
//
//  Created by Jackson on 5/2/19.
//  Copyright © 2019 Jackson. All rights reserved.
//
//  Containers a Header and Footer Class

import UIKit

// Header and footer UI Elements

func header(_ title: String, _ parent: UIView) -> UIView? {
    // var headerView: UIView = UIView.init(frame: CGRect(x: 1, y: 50, width: 276, height: 100))
    let headerView: UIView = UIView.init()
    headerView.backgroundColor = UIColor.white
    
    let labelView: UILabel = UILabel.init(frame: CGRect(x: 18, y: 5, width: parent.frame.width - 18, height: 24))
    labelView.text = "\(title)"
    labelView.font = UIFont(name: "Helvetica Bold", size: 18)
    headerView.addSubview(labelView)
    return headerView
}

func footer(_ description: String, _ parent: UIView) -> UIView {
    // var headerView: UIView = UIView.init(frame: CGRect(x: 1, y: 50, width: 276, height: 100))
    let footerView: UIView = UIView.init()
    footerView.backgroundColor = UIColor.white
    
    let label: UILabel = UILabel.init(frame: CGRect(x: 18, y: 5, width: parent.frame.width - 23, height: 60))
    label.text = "\(description)"
    label.textColor = .lightGray
    label.lineBreakMode = NSLineBreakMode.byWordWrapping
    label.numberOfLines = 0
    label.font = UIFont(name: "Helvetica", size: 12)
    footerView.addSubview(label)
    
    return footerView
}

/** Resize Image */
func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
    let size = image.size
    
    let widthRatio  = targetSize.width  / size.width
    let heightRatio = targetSize.height / size.height
    
    // Figure out what our orientation is, and use that to form the rectangle
    var newSize: CGSize
    if(widthRatio > heightRatio) {
        newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
    } else {
        newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
    }
    
    // This is the rect that we've calculated out and this is what is actually used below
    let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
    
//    // Actually do the resizing to the rect using the ImageContext stuff
    UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
    image.draw(in: rect)
    let newImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    
//    let view = UIImageView(frame: rect)
//    view.image = image
//    view.layer.cornerRadius = view.frame.size.width / 2
//    view.clipsToBounds = true
//    view.layer.masksToBounds = false
//    view.layer.shadowOffset = .zero
//    view.layer.shadowRadius = 5
//    view.layer.shadowOpacity = 0.5

    return newImage!// ?? image
}


