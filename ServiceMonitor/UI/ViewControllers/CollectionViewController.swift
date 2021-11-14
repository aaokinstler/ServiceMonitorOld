//
//  ViewController.swift
//  ServiceMonitor
//
//  Created by Anton Kinstler on 30.08.2021.
//

import UIKit
import CoreData

class CollectionViewController: UICollectionViewController, UIGestureRecognizerDelegate {
    
    
    var dataManager: DataManager!
    var parentGroup: Group!
    var fetchedResultController: NSFetchedResultsController<MonitorObject>!
    var datasource: UICollectionViewDiffableDataSource<Int, NSManagedObjectID>!
    var lgpr: UILongPressGestureRecognizer!
    var refreshControl: UIRefreshControl!
    
    @IBOutlet weak var addButton: UIBarButtonItem!
    
    // MARK: Lifecycle methods
    fileprivate func setFetchedResultController() {
        let fetchRequest: NSFetchRequest<MonitorObject> = MonitorObject.fetchRequest()
        var predicate:NSPredicate
        
        if parentGroup == nil {
            predicate = NSPredicate(format: "group == nil")
        } else {
            predicate = NSPredicate(format: "group == %@", parentGroup)
        }
        
        fetchRequest.predicate = predicate
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        fetchedResultController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataManager.dataController.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultController.delegate = self
        do {
            try fetchedResultController.performFetch()
        } catch {
            fatalError("The fetch could note be performed:  \(error.localizedDescription)")
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureDatasource()
        setFetchedResultController()
        setLayout()
        setAddButton()
        setRefreshControl()
        NotificationCenter.default.addObserver(self, selector: #selector(onDidReceiveData(_:)), name: .didUpdateGroup , object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        dataManager.object = parentGroup
        dataManager.startAutoupdate()
        setTitle()
    }
    
    func configureDatasource() {
        datasource = UICollectionViewDiffableDataSource(collectionView: collectionView, cellProvider: configureCell(_:indexPath:identifier:))
        collectionView.dataSource = datasource
    }
    
    func setLayout() {
        let albumFlowLayout = UICollectionViewFlowLayout()
        let cellWidthHeight = view.frame.width / 2 - 3
        albumFlowLayout.itemSize = CGSize(width: cellWidthHeight, height: 125)
        albumFlowLayout.minimumInteritemSpacing = 0
        albumFlowLayout.minimumLineSpacing = 2
        albumFlowLayout.sectionInset = UIEdgeInsets(top:2, left: 2, bottom: 2, right: 2)
        collectionView.collectionViewLayout = albumFlowLayout
    }
    
    // set button to add group or service
    func setAddButton() {
        var actions:[UIAction] = []
        let groupAction = UIAction(title: "Group") { (action) in
            self.pushGroupObjectVC(monitorObject: nil)
        }
        actions.append(groupAction)
        
        if parentGroup != nil {
            let serviceAction = UIAction(title: "Service") { (action) in
                self.pushServiceVC(monitorObject: nil)
            }
            actions.append(serviceAction)
        }
        
        let menu = UIMenu(title: "Add", options: .displayInline, children: actions)
        addButton.menu = menu
    }
    
    // set refresh control for manual updating.
    func setRefreshControl() {
        self.refreshControl = UIRefreshControl()
        self.collectionView!.alwaysBounceVertical = true
        self.refreshControl.tintColor = UIColor.gray
        self.refreshControl.addTarget(self, action: #selector(loadData), for: .valueChanged)
        self.collectionView!.addSubview(refreshControl)
    }
    
    func setTitle() {
        if parentGroup == nil {
            self.title = "Service Monitor"
        } else {
            self.title = parentGroup.name
        }
    }
    
    // MARK: configuring cells
    @objc func configureCell(_ collectionView: UICollectionView,  indexPath: IndexPath, identifier: Any) -> UICollectionViewCell {
 
        let monitorObject = fetchedResultController.object(at: indexPath)
        var cell:UICollectionViewCell
        
        if monitorObject.entity.name == "Group" {
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GroupCell", for: indexPath)
            fillGroupCell(cell: cell, data: monitorObject, indexPath: indexPath)
        } else {
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ServiceCell", for: indexPath)
            fillServiceCell(cell: cell, data: monitorObject)
        }
    
        return cell
    }
    
    func fillServiceCell(cell: UICollectionViewCell, data: MonitorObject) {
        let serviceData = data as! Service
        let serviceCell = cell as! ServiceCell
        
        serviceCell.serviceNameLabel.text = serviceData.name
        serviceCell.idLabel.text = "ID: " + String(serviceData.monitorId)
        serviceCell.statusNameLabel.text = serviceData.status?.name ?? ""
        serviceCell.lastUpdated.text = serviceData.getTimeFromLastExecution()
        serviceCell.backgroundColor = serviceData.status?.getStatusColor()
    
    }
    
    func fillGroupCell(cell: UICollectionViewCell, data: MonitorObject, indexPath: IndexPath) {
        let groupData = data as! Group
        let groupCell = cell as! GroupCell
        
        groupCell.groupNameLabel.text = groupData.name
        groupCell.idLabel.text = "ID: " + String(groupData.monitorId)
        groupCell.editButton.tag = indexPath.row
        groupCell.editButton.titleLabel?.text = ""
        
        let servicesAll = groupData.services?.count ?? 0
        let servicesOk = groupData.getServicesOk()
        
        groupCell.servicesInfoLabel.text = "\(servicesOk)/\(servicesAll)"
        
        if servicesAll == 0 {
            groupCell.backgroundColor = .gray
        } else {
            switch servicesOk  {
            case ..<servicesAll:
                groupCell.backgroundColor = .customYellow
            case servicesAll:
                groupCell.backgroundColor = .customGreen
            default:
                groupCell.backgroundColor = .gray
            }
        }
    }
    
    // MARK: Handling cell selection
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let monitorObject = fetchedResultController.object(at: indexPath)
        
        if monitorObject.entity.name == "Group" {
            pushGroupVC(monitorObject: monitorObject)
        } else {
            pushServiceVC(monitorObject: monitorObject)
        }
    }
    
    @IBAction func groupEditButtonTapped(_ sender: UIButton) {
        let ip = IndexPath(item: sender.tag, section: 0)
        pushGroupObjectVC(monitorObject: fetchedResultController.object(at: ip))
    }
    
    func pushGroupVC(monitorObject: MonitorObject) {
        let groupObject = monitorObject as! Group
        let controller = self.storyboard?.instantiateViewController(identifier: "GroupNode") as! CollectionViewController
        controller.dataManager = dataManager
        controller.parentGroup = groupObject
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    func pushServiceVC(monitorObject: MonitorObject!) {
        
        let controller = self.storyboard?.instantiateViewController(identifier: "ServiceVC") as! ServiceViewController
        controller.dataManager = dataManager
        controller.parentGroup = parentGroup
        if let monitorObject = monitorObject {
            let serviceObject = monitorObject as! Service
            controller.object = serviceObject
        }
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    func pushGroupObjectVC(monitorObject: MonitorObject!) {
        let controller = self.storyboard?.instantiateViewController(identifier: "GroupVC") as! GroupViewController
        controller.dataManager = dataManager
        controller.parentGroup = parentGroup
        if let monitorObject = monitorObject {
            controller.object = monitorObject
        } else {
            controller.object = nil
        }
        
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    // MARK: Manual update information.
    @objc func loadData() {
        
        refreshControl.beginRefreshing()
        if let parentGroup = parentGroup {
            dataManager.updateGroupData(id: Int(parentGroup.monitorId))
        } else {
            dataManager.updateMonitorData()
        }
     }
    
    @objc func onDidReceiveData(_ notification: Notification) {
        if refreshControl.isRefreshing {
            refreshControl.endRefreshing()
        }
    }
}


extension CollectionViewController: NSFetchedResultsControllerDelegate {
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChangeContentWith snapshot: NSDiffableDataSourceSnapshotReference) {
        datasource.apply(snapshot as NSDiffableDataSourceSnapshot<Int, NSManagedObjectID>, animatingDifferences: false)
    }
}


