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
        
        registerCells()
        configureDataSource()
        
        // todo on location
        loadPhotoUrl()
        updateUI()
    }
    
    func registerCells() {
        tableView.register(WNDisplayViewCell.self)
    }
    
    func loadPhotoUrl() {
        viewModel.getPhoto(lat: 49.902550, long: 10.884520, accuracy: 16, radius: 0.2)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 5.0) {
            self.viewModel.getPhoto(lat: 49.901620, long: 10.885090, accuracy: 16, radius: 0.2)
        }
    }
    
    fileprivate func updateUI() {
        viewModel.completionBlock = {
            self.photoItems = self.viewModel.photoItems
            DispatchQueue.main.async {
                self.applySnanpshot(for: self.photoItems)
            }
        }
    }
    
    fileprivate func loadImage(_ item: PhotoItem) {
        ImageCache.imageCache.load(url: item.url, item: item) { (fetchedItem, image) in
            if let img = image, img != fetchedItem.image {
                var updatedSnapshot = self.dataSource.snapshot()
                if let datasourceIndex = updatedSnapshot.indexOfItem(fetchedItem) {
                    let item = self.photoItems[datasourceIndex]
                    item.image = img
                    updatedSnapshot.reloadItems([item])
                    DispatchQueue.main.async {
                        self.dataSource.apply(updatedSnapshot, animatingDifferences: true)
                    }
                }
            }
        }
    }
    
    // MARK: TableView
    func configureDataSource() {
        dataSource = DataSource(tableView: tableView) {
            (tableView: UITableView, indexPath: IndexPath, item: PhotoItem) -> UITableViewCell? in
            guard let cell = tableView.dequeueReusableCell(withIdentifier: self.reuseIdentifier, for: indexPath) as? WNDisplayViewCell else { return nil }
            var content = cell.defaultContentConfiguration()
            content.image = item.image
            self.loadImage(item)
            cell.contentConfiguration = content
            return cell
        }
        
        dataSource.defaultRowAnimation = .fade
        applySnanpshot(for: photoItems)
    }
    
    func applySnanpshot(for items: [PhotoItem]) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, PhotoItem>()
        snapshot.appendSections([.main])
        snapshot.appendItems(items)
        self.dataSource.apply(snapshot, animatingDifferences: true)
    }

    // for more custom UI if needed
    class DataSource: UITableViewDiffableDataSource<Section, PhotoItem> {
        
    }
}
