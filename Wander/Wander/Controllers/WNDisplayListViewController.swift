//
//  WNDisplayListViewController.swift
//  Wander
//
//  Created by Ankita on 21.05.21.
//

import UIKit
import CoreLocation

class WNDisplayListViewController: UITableViewController {

    private var viewModel = WNPhotoViewModel()
    private let reuseIdentifier = "WNDisplayViewCell"
    private var photoItems = [PhotoItem]()
    private var dataSource: DataSource! = nil
    
    private var isUpdatingLocation = false
    private let locationManager = LocationManager.shared
    private var distance = Measurement(value: 0, unit: UnitLength.meters)
    private var locationList = [CLLocation]()
    
    @IBOutlet weak var rightBarButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Wander"
        
//        loadPhotoUrl()
        updateUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        registerCells()
        configureDataSource()
    }
    
    func registerCells() {
        tableView.register(WNDisplayViewCell.self)
    }
    
    @IBAction func startStopLocationService(_ sender: Any) {
        if !isUpdatingLocation {
            startLocationService()
            rightBarButton.title = "Stop"
        } else {
            stopLocationService()
            rightBarButton.title = "Start"
        }
        isUpdatingLocation = !isUpdatingLocation
    }
    
    
//    func loadPhotoUrl() {
//        viewModel.getPhoto(lat: 49.902550, long: 10.884520, accuracy: 16, radius: 0.2)
//        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 5.0) {
//            self.viewModel.getPhoto(lat: 49.901620, long: 10.885090, accuracy: 16, radius: 0.2)
//        }
//    }
    
    // MARK: Other Methods
    func fetchImage(for coordinates: CLLocationCoordinate2D) {
        viewModel.getPhoto(lat: coordinates.latitude, long: coordinates.longitude, accuracy: 16, radius: 0.2)
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
    
    // MARK: Location methods
    private func startLocationService() {
        locationManager.delegate = self
        locationManager.activityType = .fitness
        locationManager.distanceFilter = 100
        locationManager.startUpdatingLocation()
    }
    
    private func stopLocationService() {
        locationManager.stopUpdatingLocation()
    }
    
    // MARK: TableView Methods
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


extension WNDisplayListViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
      for newLocation in locations {
        let howRecent = newLocation.timestamp.timeIntervalSinceNow
        guard newLocation.horizontalAccuracy < 20 && abs(howRecent) < 10 else { continue }
        
        if let lastLocation = locationList.last {
            let delta = newLocation.distance(from: lastLocation)
            if delta >= 100 {
                // fetch image
                fetchImage(for: lastLocation.coordinate)
                locationList.append(newLocation)
            }
        }
        
      }
    }
}
