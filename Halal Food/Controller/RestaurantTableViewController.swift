//
//  RestaurantTableViewController.swift
//  Halal Food
//
//  Created by Sorfian on 22/02/23.
//

import UIKit
import CoreData
import UserNotifications

class RestaurantTableViewController: UITableViewController {
    
    @IBOutlet var emptyRestaurantView: UIView!
    
    var restaurants: [Restaurant] = []
    
    var fetchResultController: NSFetchedResultsController<Restaurant>!
    
    lazy var dataSource = configureDataSource()
    
    var restaurantIsFavourites = Array(repeating: false, count: 21)
    
    var searchController: UISearchController!
    
    
    // MARK: - View controller life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.backButtonTitle = ""
        
        
        if let appearance = navigationController?.navigationBar.standardAppearance {
            appearance.configureWithTransparentBackground()
            
            if let customFont = UIFont(name: "Nunito-Bold", size: 45) {
                appearance.titleTextAttributes = [.foregroundColor: UIColor(named: "NavigationBarTitle")!]
                appearance.largeTitleTextAttributes = [.foregroundColor: UIColor(named: "NavigationBarTitle")!, .font: customFont]
            }
            
            navigationController?.navigationBar.standardAppearance = appearance
            navigationController?.navigationBar.compactAppearance = appearance
            navigationController?.navigationBar.scrollEdgeAppearance = appearance
            
        }
        
        tableView.dataSource = dataSource
//        tableView.delegate = self
        tableView.separatorStyle = .none
        
        tableView.cellLayoutMarginsFollowReadableWidth = true
        
//        Set empty background if no record
        tableView.backgroundView = emptyRestaurantView
        tableView.backgroundView?.isHidden = restaurants.count == 0 ? false : true
        
        fetchRestaurantData()
        
//        Search feature
        
        searchController = UISearchController(searchResultsController: nil)
        
//        Search bar in the top of tableview body
//        self.navigationItem.searchController = searchController
        
//        Search bar in the tableview header
        tableView.tableHeaderView = searchController.searchBar
        
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = NSLocalizedString("Search restaurants...", comment: "Search restaurants...")
        searchController.searchBar.backgroundImage = UIImage()
        searchController.searchBar.tintColor = UIColor(named: "NavigationBarTitle")
        searchController.searchBar.searchBarStyle = .prominent
        
        prepareNotification()
    }
    
//    MARK: - UIViewController View States
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.hidesBarsOnSwipe = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        if UserDefaults.standard.bool(forKey: "hasViewedWalkthrough") {
            return
        }
        
        let storyboard = UIStoryboard(name: "Onboarding", bundle: nil)
        if let walkthroughViewController = storyboard.instantiateViewController(withIdentifier: String(describing: WalkthroughViewController.self)) as? WalkthroughViewController {
            present(walkthroughViewController, animated: true, completion: nil)
        }
    }
    
//    MARK: - UITableView Diffable Data Source
    
    func configureDataSource() -> RestaurantDiffableDataSource {
        let cellIdentifier = "datacell"
        
        let dataSource = RestaurantDiffableDataSource(tableView: tableView, cellProvider: { tableView, indexPath, restaurant in
            let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! RestaurantTableViewCell
//            var content = cell.defaultContentConfiguration()
//            content.text = restaurantName
//            content.image = UIImage(named: self.restaurantImages[indexPath.row])
//            content.imageProperties.maximumSize = CGSize(width: 30, height: 30)
//
//            cell.contentConfiguration = content
            cell.nameLabel.text = restaurant.name
            cell.locationLabel.text = restaurant.location
            cell.typeLabel.text = restaurant.type
            cell.thumbnailImageView.image = UIImage(data: restaurant.image)
            cell.favouriteImageView.isHidden = restaurant.isFavorite ? false : true
            
            return cell
        }
        )
        
        return dataSource
    }
    
//    MARK: - UITableViewDelegate Protocol
    
//    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        let optionMenu = UIAlertController(title: nil, message: "What do you want to do?", preferredStyle: .actionSheet)
//        
//        if let popoverController = optionMenu.popoverPresentationController {
//            if let cell = tableView.cellForRow(at: indexPath) {
//                popoverController.sourceView = cell
//                popoverController.sourceRect = cell.bounds
//            }
//        }
//        
//        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
//        optionMenu.addAction(cancelAction)
//        
//        let reserveActionHandler = { (action: UIAlertAction!) -> Void in
//            let alertMessage = UIAlertController(title: "Not available yet", message: "Sorry, this feature is not available yet. Please retry later.", preferredStyle: .alert)
//            
//            alertMessage.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
//            self.present(alertMessage, animated: true, completion: nil)
//            
//        }
//        
//        let reserveAction = UIAlertAction(title: "Reserve a table", style: .default, handler: reserveActionHandler)
//        optionMenu.addAction(reserveAction)
//        
//        let favouriteActionTitle = self.restaurants[indexPath.row].isFavorite ? "Remove from favourites" : "Mark as favourite"
//        let favouriteAction = UIAlertAction(title: favouriteActionTitle, style: .default) { action in
//            let cell = tableView.cellForRow(at: indexPath) as! RestaurantTableViewCell
//            cell.favouriteImageView.isHidden = self.restaurants[indexPath.row].isFavorite
//            
//            
//            
//            self.restaurants[indexPath.row].isFavorite = self.restaurants[indexPath.row].isFavorite ? false : true
//        }
//        optionMenu.addAction(favouriteAction)
//        
//        present(optionMenu, animated: true, completion: nil)
//        
//        tableView.deselectRow(at: indexPath, animated: false)
//    }
    
    
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
//        Get the selected restaurant
        guard let restaurant = self.dataSource.itemIdentifier(for: indexPath)
        else {
            return UISwipeActionsConfiguration()
        }
        
        if searchController.isActive {
            return UISwipeActionsConfiguration()
        }
        
        
//        Delete action
        let deleteAction = UIContextualAction(style: .destructive, title: NSLocalizedString("Delete", comment: "Delete")) { action, sourceView, completionHandler in
//            var snapshot = self.dataSource.snapshot()
//            snapshot.deleteItems([restaurant])
//            self.dataSource.apply(snapshot, animatingDifferences: true)
            
            if let appDelegate = (UIApplication.shared.delegate as? AppDelegate) {
                let context = appDelegate.persistentContainer.viewContext
                
                context.delete(restaurant)
                appDelegate.saveContext()
                
                self.updateSnapshot(animatingChange: true)
            }
            
//            Call completion handler to dismiss the action button
            completionHandler(true)
        }
        
//        Share action
        let shareAction = UIContextualAction(style: .normal, title: NSLocalizedString("Share", comment: "Share")) { action, sourceView, completionHandler in
            let defaultText = NSLocalizedString("Just checking in at ", comment: "Just checking in at ") + restaurant.name
            let activityController: UIActivityViewController
            
            if let imageToShare = UIImage(data: restaurant.image) {
                activityController = UIActivityViewController(activityItems: [defaultText, imageToShare], applicationActivities: nil)
            } else {
                activityController = UIActivityViewController(activityItems: [defaultText], applicationActivities: nil)
            }
            
            if let popoverPresentationController = activityController.popoverPresentationController {
                if let cell = tableView.cellForRow(at: indexPath) {
                    popoverPresentationController.sourceView = cell
                    popoverPresentationController.sourceRect = cell.bounds
                }
            }
            
            self.present(activityController, animated: true, completion: nil)
            
            completionHandler(true)
        }
        
        deleteAction.backgroundColor = .systemRed
        deleteAction.image = UIImage(systemName: "trash")
        
        shareAction.backgroundColor = .systemOrange
        shareAction.image = UIImage(systemName: "square.and.arrow.up")
        
//        Configure both actions as swipe action
        let swipeConfiguration = UISwipeActionsConfiguration(actions: [deleteAction, shareAction])
        
        return swipeConfiguration
    }
    
    override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        guard let cell = tableView.cellForRow(at: indexPath) as? RestaurantTableViewCell
        else {
            return UISwipeActionsConfiguration()
        }
        
        let favouriteAction = UIContextualAction(style: .destructive, title: "") { action, sourceView, completionHandler in
            cell.favouriteImageView.isHidden = self.restaurants[indexPath.row].isFavorite
            self.restaurants[indexPath.row].isFavorite = self.restaurants[indexPath.row].isFavorite ? false : true
            
            completionHandler(true)
        }
        
        favouriteAction.backgroundColor = .systemYellow
        favouriteAction.image = UIImage(systemName: self.restaurants[indexPath.row].isFavorite ? "heart.slash.fill" : "heart.fill")
        let swipeConfiguration = UISwipeActionsConfiguration(actions: [favouriteAction])
        return swipeConfiguration
    }
    
//    MARK: - Navigation controller and Segue
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showRestaurantDetail" {
            if let indexPath = tableView.indexPathForSelectedRow {
                let destinationController = segue.destination as! RestaurantDetailViewController
                destinationController.restaurant = self.restaurants[indexPath.row]
                destinationController.hidesBottomBarWhenPushed = true
            }
        }
    }
    
    @IBAction func unwindToHome(segue: UIStoryboardSegue) {
        dismiss(animated: true, completion: nil)
    }
    
//    MARK: - Context Menu
    
    override func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
//        Get the selected restaurant
        guard let restaurant = self.dataSource.itemIdentifier(for: indexPath) else {
            return nil
        }
        
        let configuration = UIContextMenuConfiguration(identifier: indexPath.row as NSCopying, previewProvider: {
            guard let restaurantDetailViewController = self.storyboard?.instantiateViewController(withIdentifier: String(describing: RestaurantDetailViewController.self)) as? RestaurantDetailViewController else {
                return UIViewController()
            }
            restaurantDetailViewController.restaurant = restaurant
            return restaurantDetailViewController
        }, actionProvider: { action in
            let favoriteAction = UIAction(title: "Save as favorite", image: UIImage(systemName: "heart")) { action in
                let cell = tableView.cellForRow(at: indexPath) as! RestaurantTableViewCell
                self.restaurants[indexPath.row].isFavorite.toggle()
                cell.favouriteImageView.isHidden = !self.restaurants[indexPath.row].isFavorite
            }
            
            let shareAction = UIAction(title: "Share", image: UIImage(systemName: "square.and.up.arrow")) { action in
                let defaultText = NSLocalizedString("Just checking in at ", comment: "Just checking in at ") + self.restaurants[indexPath.row].name
                
                let activityController: UIActivityViewController
                
                if let imageToShare = UIImage(data: restaurant.image as Data) {
                    activityController = UIActivityViewController(activityItems: [defaultText, imageToShare], applicationActivities: nil)
                } else {
                    activityController = UIActivityViewController(activityItems: [defaultText], applicationActivities: nil)
                }
                self.present(activityController, animated: true, completion: nil)
            }
            
            let deleteAction = UIAction(title: "Delete", image: UIImage(systemName: "trash"), attributes: .destructive) { action in
                // Delete the row from the data store
                if let appDelegate = (UIApplication.shared.delegate as? AppDelegate) {
                    let context = appDelegate.persistentContainer.viewContext
                    let restaurantToDelete = self.fetchResultController.object(at: indexPath)
                    context.delete(restaurantToDelete)
                    appDelegate.saveContext()
                }
            }
            // Create and return a UIMenu with the share action
            return UIMenu(title: "", children: [favoriteAction, shareAction, deleteAction])
        })
        
        return configuration
    }
    
    override func tableView(_ tableView: UITableView, willPerformPreviewActionForMenuWith configuration: UIContextMenuConfiguration, animator: UIContextMenuInteractionCommitAnimating) {
        guard let selectedRow = configuration.identifier as? Int else {
            print("Failed to retrieve the row number")
            return
        }
        
        guard let restaurantDetailViewController = self.storyboard?.instantiateViewController(withIdentifier: String(describing: RestaurantDetailViewController.self)) as? RestaurantDetailViewController else {
            return
        }
        
        restaurantDetailViewController.restaurant = self.restaurants[selectedRow]
        animator.preferredCommitStyle = .pop
        animator.addCompletion {
            self.show(restaurantDetailViewController, sender: self)
        }
    }
    
//    MARK: - User Notifications
    
    func prepareNotification() {
//        Make sure the restaurant is not empty
        if restaurants.count <= 0 {
            return
        }
        
//        Pick a restaurant randomly
        let randomNum = Int.random(in: 0..<restaurants.count)
        let suggestedRestaurant = restaurants[randomNum]
        
//        Create the user notification
        let content = UNMutableNotificationContent()
        content.title = "Restaurant Recommendation"
        content.subtitle = "Try new food today"
        content.body = "I recommend you to check out \(suggestedRestaurant.name). The restaurant is one of your favorites. It is located at \(suggestedRestaurant.location). Would you like to give it a try?"
        content.sound = UNNotificationSound.default
        content.userInfo = ["phone": suggestedRestaurant.phone]
        
//        Add image in notification
        
        let tempDirURL = URL.init(filePath: NSTemporaryDirectory(), directoryHint: .isDirectory)
//        let tempDirURL = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
        let tempFileURL = tempDirURL.appendingPathComponent("suggested-restaurant.jpg")
        if let image = UIImage(data: suggestedRestaurant.image as Data) {
            try? image.jpegData(compressionQuality: 0.7)?.write(to: tempFileURL)
            if let restaurantImage = try? UNNotificationAttachment(identifier: "restaurantImage", url: tempFileURL, options: nil) {
                content.attachments = [restaurantImage]
            }
        }
        
//        Add action in notification
        
        let categoryIdentifer = "halalfood.restaurantaction"
        let makeReservationAction = UNNotificationAction(identifier: "halalfood.makeReservation", title: "Reserve a table", options: [.foreground])
        let cancelAction = UNNotificationAction(identifier: "halalfood.cancel", title: "Later", options: [])
        let category = UNNotificationCategory(identifier: categoryIdentifer, actions: [makeReservationAction, cancelAction], intentIdentifiers: [], options: [])
        UNUserNotificationCenter.current().setNotificationCategories([category])
        content.categoryIdentifier = categoryIdentifer
        
//        Trigger the notification based on countdown timer
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 10, repeats: false)
        let request = UNNotificationRequest(identifier: "halalfood.suggestedRestaurant", content: content, trigger: trigger)
        
//        Schedule the notification
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }

}

extension RestaurantTableViewController: NSFetchedResultsControllerDelegate {
    func fetchRestaurantData(searchText: String = "") {
//        Fetch data from data store
        let fetchRequest: NSFetchRequest<Restaurant> = Restaurant.fetchRequest()
        
        if !searchText.isEmpty {
            fetchRequest.predicate = NSPredicate(format: "name CONTAINS[c] %@ OR location CONTAINS[c] %@ OR type CONTAINS[c] %@", searchText, searchText, searchText)
        }
        
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        if let appDelegate = (UIApplication.shared.delegate as? AppDelegate) {
            let context = appDelegate.persistentContainer.viewContext
            fetchResultController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
            fetchResultController.delegate = self
            
            do {
                try fetchResultController.performFetch()
                updateSnapshot(animatingChange: searchText.isEmpty ? false : true)
            } catch {
                print(error)
            }
        }
    }
    
    func updateSnapshot(animatingChange: Bool = false) {
        if let fetchedObjects = fetchResultController.fetchedObjects {
            restaurants = fetchedObjects
        }
        
//        Create a snapshot and populate the data
        var snapshot = NSDiffableDataSourceSnapshot<Section, Restaurant>()
        snapshot.appendSections([.all])
        snapshot.appendItems(restaurants, toSection: .all)
        
        dataSource.apply(snapshot, animatingDifferences: animatingChange)
        
        tableView.backgroundView?.isHidden = restaurants.count == 0 ? false : true
        
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        updateSnapshot()
    }
}

extension RestaurantTableViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text else {
            return
        }
        fetchRestaurantData(searchText: searchText)
        
    }
    
    
}
