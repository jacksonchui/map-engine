//
//  FeedTableViewCell.swift
//  Subtela
//
//  Created by Jackson on 5/5/19.
//  Copyright © 2019 Jackson. All rights reserved.
//

import UIKit

class FeedTableViewCell: UITableViewCell {
    @IBOutlet weak var progressLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var snapshotImage: UIImageView!
    @IBOutlet weak var timestampLabel: UILabel!
    @IBOutlet weak var contentLayer: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        //custom logic goes here
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setupShadow() {

        // add shadow on cell
        backgroundColor = .clear // very important
        layer.masksToBounds = false
        layer.shadowOpacity = 0.23
        layer.shadowRadius = 4
        layer.shadowOffset = CGSize(width: 0, height: 0)
        layer.shadowColor = UIColor.black.cgColor

        // add corner radius on `contentView`
        contentLayer.backgroundColor = .white
        contentLayer.layer.cornerRadius = 8
    }

}
