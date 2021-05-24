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
    private var locationAccuracyValue = locationFullAccuracyValue
    
    @IBOutlet weak var rightBarButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = titleName
        updateUI()
        tableView.delegate = self
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
            beginCollectingPhotos()
            rightBarButton.title = stopButton
        } else {
            stopLocationService()
            rightBarButton.title = startButton
        }
        isUpdatingLocation = !isUpdatingLocation
    }
    
    // MARK: Other Methods
    func fetchImage(for coordinates: CLLocationCoordinate2D) {
        viewModel.getPhoto(lat: coordinates.latitude, long: coordinates.longitude)
    }
    
    fileprivate func updateUI() {
        viewModel.completionBlock = {
            self.photoItems = self.viewModel.photoItems.array.sorted(by: {$0.date > $1.date})
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
    private func beginCollectingPhotos() {
        if locationManager.accuracyAuthorization == .reducedAccuracy {
            locationManager.requestTemporaryFullAccuracyAuthorization(withPurposeKey: kTempLocationAlertMessage) { (error) in
                if self.locationManager.accuracyAuthorization == .fullAccuracy {
                    self.locationAccuracyValue = locationFullAccuracyValue
                } else {
                    self.locationAccuracyValue = locationReducedAccuracyValue
                }
                self.startLocationService()
            }
        } else {
            self.locationAccuracyValue = locationReducedAccuracyValue
            self.startLocationService()
        }
    }
    
    private func startLocationService() {
        locationManager.delegate = self
        locationManager.activityType = .fitness
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.showsBackgroundLocationIndicator = true
        locationManager.distanceFilter = minDistanceInMeter
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
            self.loadImage(item)
            cell.configCell(with: item)
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

// MARK: UITableView delegate methods
extension WNDisplayListViewController {
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
}

// MARK: Location manager delegate methods
extension WNDisplayListViewController: CLLocationManagerDelegate {
    fileprivate func stopLocationUpdateAfterInterval() {
        // stop location service after 2 hrs
        if let backgroundEnterTime = LocationManager.sharedManager.date {
            if Date().timeIntervalSince(backgroundEnterTime) > locationServiceRunInterval {
                self.stopLocationService()
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        stopLocationUpdateAfterInterval()
        for newLocation in locations {
            let howRecent = newLocation.timestamp.timeIntervalSinceNow
            guard newLocation.horizontalAccuracy < self.locationAccuracyValue && abs(howRecent) < 10 else { continue }
            
            if let lastLocation = locationList.last {
                let delta = newLocation.distance(from: lastLocation)
                if delta >= minDistanceInMeter {
                    // fetch image
                    fetchImage(for: lastLocation.coordinate)
                }
            }
            locationList.append(newLocation)
        }
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedAlways, .authorizedWhenInUse:
            beginCollectingPhotos()
        case .denied, .notDetermined, .restricted:
            stopLocationService()
        default:
            print("Not handled")
        }
        
        switch manager.accuracyAuthorization {
        case .reducedAccuracy:
            self.locationAccuracyValue = locationFullAccuracyValue
            self.startLocationService()
        case .fullAccuracy:
            self.locationAccuracyValue = locationReducedAccuracyValue
            self.startLocationService()
        default:
            print("undefined")
        }
    }
}
