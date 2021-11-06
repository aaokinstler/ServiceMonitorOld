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


    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.

        // Save changes in the application's managed object context when the application transitions to the background.
        dataManager.dataController.saveViewContext()
    }
}

