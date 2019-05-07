////
////  ShadowTableCell.swift
////  DungeonSettings
////
////  Created by Jackson on 4/22/19.
////  Copyright © 2019 Jackson. All rights reserved.
////
//
//import UIKit
//
//class ShadowTableCell: UITableViewCell {
//
//    var background: UIView
//    var shadowLayer: ShadowView
//    
//    init() {
////        super.init(frame: let cellFrame = CGRect(x: 0, y: , width: self.frame.width - 10, height: self.frame.height * 0.85))
////        super.init(style: ., reuseIdentifier: "shadowView")
//    }
//
//    required init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//
//    override func awakeFromNib() {
//        super.awakeFromNib()
//        // Initialization code
//    }
//
//    // run in @code{cellForRowAt}
//    func setupCell() {
//
//        let cellFrame = CGRect(x: 10, y: 5, width: self.frame.width - 10, height: self.frame.height * 0.85)
//
//        background = UIView(frame: cellFrame)
//        shadowLayer = ShadowView(frame: cellFrame)
//        self.addSubview(background)
//        self.addSubview(shadowLayer)
//
//        // ShadowView Constraints
//        let shadowTop = NSLayoutConstraint(item: shadowLayer, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 13)
//        let shadowTrail = NSLayoutConstraint(item: shadowLayer, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1, constant: -26)
//        let shadowLead = NSLayoutConstraint(item: shadowLayer, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1, constant: 10)
//        let shadowBot = NSLayoutConstraint(item: shadowLayer, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: 11)
//        let shadowHeight = NSLayoutConstraint(item: shadowLayer, attribute: .height, relatedBy: .equal, toItem: self, attribute: .height, multiplier: 0.8, constant: 0)
//        let shadowCenterX = NSLayoutConstraint(item: shadowLayer, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: 0)
//
//        NSLayoutConstraint.activate([shadowBot, shadowTop, shadowLead, shadowTrail, shadowHeight, shadowCenterX])
//
//        // BackgroundView Constraints
//        let backgroundTop = NSLayoutConstraint(item: background, attribute: .top, relatedBy: .equal, toItem: shadowLayer, attribute: .top, multiplier: 1, constant: 0)
//        let backgroundTrail = NSLayoutConstraint(item: background, attribute: .trailing, relatedBy: .equal, toItem: shadowLayer, attribute: .trailing, multiplier: 1, constant: 0)
//        let backgroundLead = NSLayoutConstraint(item: background, attribute: .leading, relatedBy: .equal, toItem: shadowLayer, attribute: .leading, multiplier: 1, constant: 0)
//        let backgroundBot = NSLayoutConstraint(item: background, attribute: .bottom, relatedBy: .equal, toItem: shadowLayer, attribute: .bottom, multiplier: 1, constant: 0)
//        let backgroundHeight = NSLayoutConstraint(item: background, attribute: .height, relatedBy: .equal, toItem: shadowLayer, attribute: .height, multiplier: 1, constant: 0)
//        let backgroundWidth = NSLayoutConstraint(item: background, attribute: .width, relatedBy: .equal, toItem: shadowLayer, attribute: .width, multiplier: 1, constant: 0)
//        let backgroundCenterX = NSLayoutConstraint(item: background, attribute: .centerX, relatedBy: .equal, toItem: shadowLayer, attribute: .centerX, multiplier: 1, constant: 0)
//
//
//        NSLayoutConstraint.activate([backgroundTop, backgroundWidth, backgroundBot, backgroundTrail, backgroundLead, backgroundBot, backgroundHeight, backgroundCenterX])
//
//        // Setup the shadow
//        self.layer.shadowPath = UIBezierPath(rect: self.backgroundView!.bounds).cgPath
//        shadowLayer.setupShadow()
//    }
//
//    override func setSelected(_ selected: Bool, animated: Bool) {
//        super.setSelected(selected, animated: animated)
//
//        // Configure the view for the selected state
//    }
//}
//
//class ShadowView: UIView {
//    override var bounds: CGRect {
//        didSet {
//            setupShadow()
//            print("didSet shadowView's width to: \(self.bounds.width)\n")
//        }
//    }
//
//    public func setupShadow() {
//        self.layer.masksToBounds = false
//        self.layer.cornerRadius = 8
//        self.layer.shadowOffset = .zero
//        self.layer.shadowColor = UIColor.black.cgColor
//        self.layer.shadowRadius = 3
//        self.layer.shadowOpacity = 0.3
//        self.layer.shadowPath = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: .allCorners, cornerRadii: CGSize(width: 8, height: 8)).cgPath
//        self.layer.shouldRasterize = true
//        self.layer.rasterizationScale = UIScreen.main.scale
//    }
//}
