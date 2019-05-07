//
//  SettingsTableViewController.swift
//  DungeonSettings
//
//  Created by Jackson on 5/2/19.
//  Copyright © 2019 Jackson. All rights reserved.
//

import UIKit
import RealmSwift
import BLTNBoard

class SettingsTableViewController: UITableViewController {
    
    let options = SettingsOptions()
    // TODO: - set the config in the segue
    var config = DungeonConfiguration()
    var configs = [DungeonConfiguration]()
    lazy var realm: Realm = {
        return try! Realm()
    }()
    
    @IBOutlet weak var iconPreview: UIImageView!
    @IBOutlet weak var iconPicker: UIPickerView!
    @IBOutlet weak var texturePicker: UIPickerView!
    @IBOutlet weak var texturePreview: UIImageView!
    @IBOutlet weak var floorLabel: UILabel!
    @IBOutlet weak var widthLabel: UILabel!
    @IBOutlet weak var heightLabel: UILabel!
    @IBOutlet weak var bagLimitLabel: UILabel!
    @IBOutlet weak var nameLabelField: UITextField!
    @IBOutlet weak var widthSlider: UISlider!
    @IBOutlet weak var floorSlider: UISlider!
    @IBOutlet weak var heightSlider: UISlider!
    @IBOutlet weak var bagSlider: UISlider!
    
    //MARK: - IB Actions
   
    
    @IBAction func setFloors(_ sender: UISlider) {
        let currentValue = Int(sender.value)
        floorLabel.text = "\(currentValue) Levels"
        do {
            try self.realm.write({
                config.floors = currentValue
            })
        }catch let error {
            print(error)
        }
    }
    @IBAction func setWidth(_ sender: UISlider) {
        let currentValue = Int(sender.value)
        widthLabel.text = "\(currentValue) Units"
        do {
            try self.realm.write({
                config.width = currentValue
            })
        }catch let error {
            print(error)
        }
    }
    @IBAction func setHeight(_ sender: UISlider) {
        let currentValue = Int(sender.value)
        heightLabel.text = "\(currentValue) Units"
        do {
            try self.realm.write({
                config.height = currentValue
            })
        }catch let error {
            print(error)
        }
    }
    @IBAction func setBagLimit(_ sender: UISlider) {
        let currentValue = Int(sender.value)
        bagLimitLabel.text = "\(currentValue) Items"
        do {
            try self.realm.write({
                config.bagLimit = currentValue
            })
        }catch let error {
            print(error)
        }
    }
    @IBAction func saveConfig(_ sender: Any) {
        print("Saving to Realm")
        
        do {
            try self.realm.write({
                self.realm.add(config, update: false)
                print(" Config stored.")
            })
        }catch let error {
            print(error)
        }
        
        let note = bottomBulletin(title: config.name, image: config.icon)
        note.showBulletin(above: self)
    }
    
    // MARK: - View Did Load
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.clearsSelectionOnViewWillAppear = false
        
        configs = Array(realm.objects(DungeonConfiguration.self).sorted(byKeyPath: "name"))
        
        // TODO: - Change nav title to "Edit"
        if (configs.contains(config)) {
            navigationItem.title = "Edit"
        }
                
        var pickedImage = UIImage(named: options.icons[0])
        iconPreview.image = resizeImage(image: pickedImage!, targetSize: CGSize(width: iconPreview.frame.width, height:  iconPreview.frame.height))
        
        pickedImage = UIImage(named: options.textures[0])
        texturePreview.image = resizeImage(image: pickedImage!, targetSize: CGSize(width: iconPreview.frame.width, height:  iconPreview.frame.height))
        
        // Set Slider Default
        floorLabel.text = "\(config.floors) Levels"
        widthLabel.text = "\(config.width) Units"
        heightLabel.text = "\(config.height) Units"
        bagLimitLabel.text = "\(config.bagLimit) Items"
        bagSlider.value = Float(config.bagLimit)
        heightSlider.value = Float(config.height)
        widthSlider.value = Float(config.width)
        floorSlider.value = Float(config.floors)
        
        // Delegate Pickers
        iconPicker.dataSource = self
        iconPicker.delegate = self
        
        texturePicker.dataSource = self
        texturePicker.delegate = self
        
        // Delegate Textfields
        nameLabelField.delegate = self

        
        tableView.allowsSelection = false
        
        print(Realm.Configuration.defaultConfiguration.fileURL!)
    }
    
    func initializeRealm() -> Void {
        let realm = try! Realm()
    }
    

    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return header(options.headers[section], view)
    }
    
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return footer(options.footers[section], view)
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        // this will turn on `masksToBounds` just before showing the cell
        cell.contentView.layer.masksToBounds = true
        
        // if you do not set `shadowPath` you'll notice laggy scrolling
        // add this in `willDisplay` method
        let radius = cell.contentView.layer.cornerRadius
        cell.layer.shadowPath = UIBezierPath(roundedRect: cell.bounds, cornerRadius: radius).cgPath
    }

}

// MARK: - Pick an Option and take action on it

extension SettingsTableViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    // tag 0 is icons, tag 1 is texture
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if (pickerView.tag == 0) {
            return options.icons.count
        } else {//if (pickerView.tag == 1) (
            return options.textures.count
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if (pickerView.tag == 0) {
            let picked = UIImage(named: options.icons[row])!
            do {
                try self.realm.write({
                    config.icon = options.icons[row]
                })
            }catch let error {
                print(error)
            }

            iconPreview.image = resizeImage(image: picked, targetSize: CGSize(width: iconPreview.frame.width, height:  iconPreview.frame.height))
            
            
        } else if (pickerView.tag == 1) {
            let picked = UIImage(named: options.textures[row])!
            do {
                try self.realm.write({
                    config.texture = options.textures[row]
                })
            }catch let error {
                print(error)
            }

            texturePreview.image = resizeImage(image: picked, targetSize: CGSize(width: texturePreview.frame.width, height:  texturePreview.frame.height))
            
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if (pickerView.tag == 0) {
            return options.icons[row]
        } else {//if (pickerView.tag == 1) {
            return options.textures[row]
        }
    }
}

extension SettingsTableViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {   //delegate method
        textField.resignFirstResponder()

        do {
            try self.realm.write({
                if (textField.tag == 0) {
                    print(textField.text!)
                    config.name = textField.text ?? config.name
                }
            })
        }catch let error {
            print(error)
        }
        view.endEditing(true)
        return false
    }
}

func bottomBulletin (title: String, image: String) -> BLTNItemManager{
    
    let header = "Saved \(title)!"
    let page = BLTNPageItem(title: header)
    let manager = BLTNItemManager(rootItem: page)
    manager.backgroundViewStyle = .blurredDark
    page.isDismissable = true
    page.image = resizeImage(image: UIImage(named: image)!,
                             targetSize: CGSize(width: 500, height: 500))
    
    page.descriptionText = "You have saved a game. Go to explore tab to begin your adventure! Feel free to make any additional modifications, no save required."
    page.actionButtonTitle = "Dismiss"
    page.actionHandler = { (item: BLTNActionItem) in
        print("Action button tapped")
        manager.dismissBulletin()
    }
    
    return manager
}

