//
//  DiscoverTableViewController.swift
//  Halal Food
//
//  Created by Sorfian on 08/03/23.
//

import UIKit
import FirebaseCore
import FirebaseFirestore
import FirebaseStorage

class DiscoverTableViewController: UITableViewController {
    
    var discovers: [Discover] = []
    
    lazy var dataSource = configureDataSource()
    
    let db = Firestore.firestore()
    let storage = Storage.storage().reference()
    
    enum Section {
        case all
    }
    
    var spinner = UIActivityIndicatorView()
    private var imageCache = NSCache<NSString, NSData>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.cellLayoutMarginsFollowReadableWidth = true
        navigationController?.navigationBar.prefersLargeTitles = true
        
        if let appearance = navigationController?.navigationBar.standardAppearance {
            appearance.configureWithTransparentBackground()
            
            if let customFont = UIFont(name: "Nunito-Bold", size: 45.0) {
                appearance.titleTextAttributes = [.foregroundColor: UIColor(named: "NavigationBarTitle")!]
                appearance.largeTitleTextAttributes = [.foregroundColor: UIColor(named: "NavigationBarTitle")!, .font: customFont]
            }
            
            navigationController?.navigationBar.standardAppearance = appearance
            navigationController?.navigationBar.compactAppearance = appearance
            navigationController?.navigationBar.scrollEdgeAppearance = appearance
            
        }
        
        fetchRecordsFromCloud()
           
        // Set the data source of the table view for Diffable Data Source
        tableView.dataSource = dataSource
        tableView.separatorStyle = .none
        
//        Spinner configuration
        spinner.style = .large
        spinner.hidesWhenStopped = true
        view.addSubview(spinner)
//        Define layout constraints for the spinner
        spinner.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([spinner.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 150.0), spinner.centerXAnchor.constraint(equalTo: view.centerXAnchor)])
//        Activate the spinner
        spinner.startAnimating()
        
//        Pull to refresh control
        refreshControl = UIRefreshControl()
//        refreshControl?.backgroundColor = .white
        refreshControl?.tintColor = .gray
        refreshControl?.addTarget(self, action: #selector(fetchRecordsFromCloud), for: UIControl.Event.valueChanged)
    }
    
    @objc func fetchRecordsFromCloud() {
//        self.discovers = []
        db.collection("resto").order(by: "created_at", descending: false).getDocuments { querySnapshot, error in
            guard let snapshotDocuments = querySnapshot?.documents else {
                return
            }
            
            for doc in snapshotDocuments {
                let data = doc.data()
                
                if let name = data["name"] as? String, let type = data["type"] as? String, let location = data["location"] as? String, let phone = data["phone"] as? String, let description = data["description"] as? String, let image = data["imageName"] as? String {
                    
                    let existingData = self.discovers.first { discover in
                        discover.image == image
                    }
                    
                    if existingData == nil {
                        
                        let discover = Discover(
                            name: name,
                            type: type,
                            location: location,
                            phone: phone,
                            description: description,
                            image: image
                        )
                                 
                        self.discovers.append(discover)
                        print("Data belum ada...")
                    }
                    
                    if !self.discovers.isEmpty {
                        DispatchQueue.main.async {
                            
                            self.spinner.stopAnimating()
                            
                            if let refreshControl = self.refreshControl {
                                if refreshControl.isRefreshing {
                                    refreshControl.endRefreshing()
                                }
                            }
                        }
                    }
                    
                    
//                    self.updateSnapshot()
                }
            }
            self.updateSnapshot()
        }
    }
    
    func updateSnapshot(animatingChange: Bool = false) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Discover>()
        snapshot.appendSections([.all])
        snapshot.appendItems(discovers, toSection: .all)
        dataSource.apply(snapshot, animatingDifferences: false)
    }

    func configureDataSource() -> UITableViewDiffableDataSource<Section, Discover> {
        let cellIdentifier = "discovercell"
        let dataSource = UITableViewDiffableDataSource<Section, Discover>(tableView: tableView) { (tableView, indexPath, discover) -> UITableViewCell? in
            let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! DiscoverTableViewCell
            cell.nameLabel.text = discover.name
            cell.typeLabel.text = discover.type
            cell.locationLabel.text = discover.location
            cell.descriptionLabel.text = discover.description
            
            cell.thumbnailImageView.image = UIImage(systemName: "photo")
            cell.thumbnailImageView.tintColor = .black
            
            if let imageFileData = self.imageCache.object(forKey: discover.image as NSString) {
                cell.thumbnailImageView.image = UIImage(data: imageFileData as Data)
            } else {
    //            Fetch image from firebase storage in the background
                let restoRef = self.storage.child(discover.image)
                restoRef.downloadURL { url, error in
                    
                    guard let url = url else {
                        return
                    }
                    
                    let session = URLSession(configuration: .default)
                    let task = session.dataTask(with: url) { data, urlResponse, error in
                        if error != nil {
                            return
                        }
                        
                        if let data = data {
                            DispatchQueue.main.async {
                                cell.thumbnailImageView.image = UIImage(data: data)
                                cell.setNeedsLayout()
                            }
                            
                            self.imageCache.setObject(data as NSData, forKey: discover.image as NSString)
                        }
                    }
                    task.resume()
                }
            }
            
            return cell
        }
        return dataSource
    }
    
}

