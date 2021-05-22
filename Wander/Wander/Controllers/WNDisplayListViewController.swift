//
//  WNDisplayListViewController.swift
//  Wander
//
//  Created by Ankita on 21.05.21.
//

import UIKit



class WNDisplayListViewController: UITableViewController {

    var viewModel = WNPhotoViewModel()
    var observation: NSKeyValueObservation?
    
    let reuseIdentifier = "WNDisplayViewCell"
    
    var photoItems = [PhotoItem]()
    
    var dataSource: DataSource! = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(WNDisplayViewCell.self, forCellReuseIdentifier: reuseIdentifier)
        
        viewModel.completionBlock = { 
            self.photoItems = self.viewModel.photoItems
            DispatchQueue.main.async {
                var updatedSnapshot = self.dataSource.snapshot()
                updatedSnapshot.appendItems(self.photoItems)
                self.dataSource.apply(updatedSnapshot, animatingDifferences: true)
            }
        }
        
        self.configureDataSource()
        
        loadPhotoUrl()
        
    }
    
    
    
    func loadPhotoUrl() {
        viewModel.getPhoto(lat: 49.902550, long: 10.884520, accuracy: 16, radius: 0.2)
    }
    
    
    /*
     dataSource = UITableViewDiffableDataSource<Section, Item>(tableView: tableView) {
         (tableView: UITableView, indexPath: IndexPath, item: Item) -> UITableViewCell? in
         let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
         /// - Tag: update
         var content = cell.defaultContentConfiguration()
         content.image = item.image
         ImageCache.publicCache.load(url: item.url as NSURL, item: item) { (fetchedItem, image) in
             if let img = image, img != fetchedItem.image {
                 var updatedSnapshot = self.dataSource.snapshot()
                 if let datasourceIndex = updatedSnapshot.indexOfItem(fetchedItem) {
                     let item = self.imageObjects[datasourceIndex]
                     item.image = img
                     updatedSnapshot.reloadItems([item])
                     self.dataSource.apply(updatedSnapshot, animatingDifferences: true)
                 }
             }
         }
         cell.contentConfiguration = content
         return cell
     }
     */
    func configureDataSource() {
        dataSource = DataSource(tableView: tableView) {
            (tableView: UITableView, indexPath: IndexPath, item: PhotoItem) -> UITableViewCell? in
            guard let cell = tableView.dequeueReusableCell(withIdentifier: self.reuseIdentifier, for: indexPath) as? WNDisplayViewCell else { return nil }
            var content = cell.defaultContentConfiguration()
            content.image = item.image
            cell.contentConfiguration = content
            return cell
        }
        
        dataSource.defaultRowAnimation = .fade
        
        initialSnapshot()
    }
    
    func initialSnapshot() {
        var snapshot = NSDiffableDataSourceSnapshot<Section, PhotoItem>()
        snapshot.appendSections([.main])
        snapshot.appendItems(photoItems)
        self.dataSource.apply(snapshot, animatingDifferences: true)
    }

    
    class DataSource: UITableViewDiffableDataSource<Section, PhotoItem> {
//        var items = [PhotoItem]()
    }
}
