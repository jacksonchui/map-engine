//
//  HomeTableTableViewController.swift
//  DungeonSettings
//
//  Created by Jackson on 4/22/19.
//  Copyright © 2019 Jackson. All rights reserved.
//

import UIKit
import Timepiece
import BLTNBoard
import RealmSwift


class ExploreTableViewController: UITableViewController, UISearchResultsUpdating, UISearchBarDelegate {
    
    lazy var realm:Realm = {
        return try! Realm()
    }()

    var gamesUnfiltered = [GameState]()
    var gamesFiltered = [GameState]()
    // Section 1
    var dungeonsFiltered = [DungeonConfiguration]()
    var dungeonsUnfiltered = [DungeonConfiguration]()

    @IBOutlet weak var feedView: UITableView!
    //TODO: Create an array of High Scores

    let sections: [String] = ["Recent Plays", "Choose a Dungeon"]
//    let names: [String] = ["Tiny Woods", "Mt. Freeze", "Magma Cavern",
//                                "Sky Tower", "Uproar Forest"]
    var filteredNames = [String]()
    var isSearching = false

    let searchController = UISearchController(searchResultsController: nil)

    override func viewDidLoad() {
        super.viewDidLoad()

        let db1 = Array(realm.objects(DungeonConfiguration.self))
        let db2 = Array(realm.objects(GameState.self))

        // add dungeons to the filtered list
        for dungeon in db1 {
            dungeonsUnfiltered.append(dungeon)
        }
        for dungeon in db2 {
            gamesUnfiltered.append(dungeon)
        }

        setupView()

        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action:  #selector(refresh), for: .valueChanged)
        self.refreshControl = refreshControl
    }
    
    @objc func refresh() {
        let configs = Array(realm.objects(DungeonConfiguration.self))
        dungeonsUnfiltered = [DungeonConfiguration]()
        for dungeon in configs {
            dungeonsUnfiltered.append(dungeon)
        }
        tableView.reloadData()
        refreshControl?.endRefreshing()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if #available(iOS 11.0, *) {
            navigationItem.hidesSearchBarWhenScrolling = false
        }
        self.hidesBottomBarWhenPushed = false

    }

    override func viewDidAppear(_ animated: Bool) {
        // default row height is now self-sizing
        feedView.estimatedRowHeight = 150
        navigationItem.hidesSearchBarWhenScrolling = true
    }

    // Temp

    func setupView() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Dungeons"
        // setup the scope bar
        searchController.searchBar.scopeButtonTitles = ["All", "Recents", "Dungeons"]
        searchController.searchBar.delegate = self
        navigationItem.searchController = searchController
        definesPresentationContext = true
    }

    // MARK: - Search Bar


    func updateSearchResults(for searchController: UISearchController) {
        // What determins how we get someting out of the text
        let searchBar = searchController.searchBar
        //sends the currently selected scope
        let scope = searchBar.scopeButtonTitles![searchBar.selectedScopeButtonIndex]
        filterContentForSearchText(searchController.searchBar.text!, scope: scope)
    }

    func filterContentForSearchText(_ searchText: String, scope: String = "All") {

        dungeonsFiltered = dungeonsUnfiltered.filter({(dungeon: DungeonConfiguration) -> Bool in
            let doesCategoryMatch = (scope == "All") || (scope == "Dungeons")
            if (searchBarIsEmpty()) {
                return doesCategoryMatch
            } else {
                return doesCategoryMatch && dungeon.name.lowercased().contains(searchText.lowercased())
            }
        })

        gamesFiltered = gamesUnfiltered.filter({(game: GameState) -> Bool in
            let doesCategoryMatch = (scope == "All") || (scope == "Recent")
            if (searchBarIsEmpty()) {
                return doesCategoryMatch
            } else {
                return doesCategoryMatch && (game.config?.name.lowercased().contains(searchText.lowercased()))!
            }
        })

        tableView.reloadData()
    }

    func searchBarIsEmpty() -> Bool {
        return searchController.searchBar.text?.isEmpty ?? true
    }

    func isFiltering() -> Bool {
        let searchBarScopeIsFiltering = searchController.searchBar.selectedScopeButtonIndex != 0
        return searchController.isActive && (!searchBarIsEmpty() || searchBarScopeIsFiltering)
    }

    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        filterContentForSearchText(searchBar.text!, scope: searchBar.scopeButtonTitles![selectedScope])
    }

    // MARK: Data Source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return header(sections[section], view)
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // can customize for a given section
        if (section == 0) {
            return isFiltering() ? gamesFiltered.count : gamesUnfiltered.count
        }
        if section == 1 {
            return isFiltering() ? dungeonsFiltered.count : dungeonsUnfiltered.count
        }
        return 0
    }

    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 20
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        if (indexPath.section == 0) {
            let info = isFiltering() ? gamesFiltered[indexPath.row] : gamesUnfiltered[indexPath.row]
            let cell = tableView.dequeueReusableCell(withIdentifier: "feedTableViewCell", for: indexPath) as! FeedTableViewCell
            let icon = resizeImage(image: UIImage(named: info.config?.icon ?? "Chinese Nightlife")!,
                                   targetSize: CGSize(width: 500.0, height: 500.0))
            cell.titleLabel.text = info.config?.name
            cell.snapshotImage.image = icon
            let percentageComplete = info.currentFloor/(info.config?.floors ?? 9000) * 100
            cell.timestampLabel.text = "\(info.health) health"
            cell.progressLabel.text = "\(info.currentFloor) of \(info.config?.floors ?? 9000) floors, \(percentageComplete)%"
        }

        if (indexPath.section == 1) {

            let info = isFiltering() ? dungeonsFiltered[indexPath.row] : dungeonsUnfiltered[indexPath.row]

            let name = info.name
            let cell = tableView.dequeueReusableCell(withIdentifier: "feedTableViewCell", for: indexPath) as! FeedTableViewCell
            let icon = resizeImage(image: UIImage(named: info.icon)!,
                                   targetSize: CGSize(width: 500.0, height: 500.0))
            cell.titleLabel.text = name
            cell.timestampLabel.text = "\(info.width) x \(info.height)"
            cell.progressLabel.text = "\(info.floors) floors"
            cell.snapshotImage.image = icon

            // Set the shadowing
            cell.setupShadow()
            cell.layer.cornerRadius = 10
            cell.layer.masksToBounds = true

            return cell
        }

        return UITableViewCell(frame: .zero)

    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var bulletin = bottomBulletin(title: "Default", imageNamed: "Chinese Snow",
                                      descriptionText: "Default Text",actionButtonTitle: "Play!", alternativeButtonTitle: "Edit", section: 0, createdByUser: false)
        if (indexPath.section == 0) {
            let info = isFiltering() ? gamesFiltered[indexPath.row] : gamesUnfiltered[indexPath.row]
            let config = info.config
            bulletin = bottomBulletin(title: config!.name, imageNamed: config!.icon,
                                      descriptionText: "\(config!.width) x \(config!.height) and \(config!.floors) floors",
                actionButtonTitle: "Play!", alternativeButtonTitle: "Edit", section: 0, createdByUser: config!.createdByUser)
        }
        if (indexPath.section == 1) {
            let config = isFiltering() ? dungeonsFiltered[indexPath.row] : dungeonsUnfiltered[indexPath.row]
            bulletin = bottomBulletin(title: config.name, imageNamed: config.icon,
                                      descriptionText: "\(config.width) x \(config.height) and \(config.floors) floors",
                actionButtonTitle: "Play!", alternativeButtonTitle: "Edit", section: 1, createdByUser: config.createdByUser)
        }

        bulletin.showBulletin(above: self)

    }
    
    // MARK - UI Elements




    func bottomBulletin (title: String, imageNamed: String, descriptionText: String,
                         actionButtonTitle: String, alternativeButtonTitle: String, section num: Int, createdByUser: Bool) -> BLTNItemManager{


        let page = BLTNPageItem(title: title)
        let bltnManager = BLTNItemManager(rootItem: page)
        page.isDismissable = true
        page.requiresCloseButton = true

        page.image = resizeImage(image: UIImage(named: imageNamed)!,
                                targetSize: CGSize(width: 300, height: 300))

        page.descriptionText = descriptionText
        page.actionButtonTitle = actionButtonTitle
        page.alternativeButtonTitle = (num == 1 && createdByUser) ? alternativeButtonTitle : "Edit" // TODO: Change back
        page.actionHandler = { (item: BLTNActionItem) in
            print("Action button tapped")
            // TODO: Go to the Play Screens
            bltnManager.dismissBulletin(animated: true)
            self.performSegue(withIdentifier: "beginARSegue", sender: nil)
        }
        page.alternativeHandler = { (item: BLTNActionItem) in
            if ((page.alternativeButtonTitle?.contains("Dismiss"))!) {
                bltnManager.dismissBulletin(animated: true)
            } else {
                
//                self.tabBarController?.delegate.
                let config = self.isFiltering() ? self.dungeonsFiltered[self.tableView.indexPathForSelectedRow!.row] : self.dungeonsUnfiltered[self.tableView.indexPathForSelectedRow!.row]
                
                // TODO: Figure out tab controller Editing
//                let tabControllers = self.tabBarController!.viewControllers!
//                print("VCs: \(self.tabBarController!.viewControllers!.description)")
////                    .viewControllers! as! SettingsTableViewController
//                print((tabControllers[1].class as! SettingsTableViewController)
//                (tabControllers[1] as! SettingsTableViewController).config = config
                
                // we want to segue on this
                self.tabBarController?.selectedIndex = 1
                bltnManager.dismissBulletin(animated: true)
            }
        }

        return bltnManager
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Only will segue to edits and new games
        print("Index that we are testing: \(tableView.indexPathForSelectedRow!.row)")
        let config = isFiltering() ? dungeonsFiltered[tableView.indexPathForSelectedRow!.row] : dungeonsUnfiltered[tableView.indexPathForSelectedRow!.row]
        
        let destination = segue.destination as? SettingsTableViewController
        
        if segue.identifier == "dungeonEditSegue"{
            destination?.config = config
        }
    }


}
