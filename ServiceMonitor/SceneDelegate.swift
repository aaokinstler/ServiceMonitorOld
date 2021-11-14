//
//  SceneDelegate.swift
//  ServiceMonitor
//
//  Created by Anton Kinstler on 30.08.2021.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    
    lazy var dataManager = DataManager()

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let _ = (scene as? UIWindowScene) else { return }
        let navigationController = window?.rootViewController as! UINavigationController
        let collectionViewController = navigationController.topViewController as! CollectionViewController
        collectionViewController.dataManager = dataManager
    }
}

