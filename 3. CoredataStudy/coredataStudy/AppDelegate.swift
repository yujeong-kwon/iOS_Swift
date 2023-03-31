//
//  AppDelegate.swift
//  coredataStudy
//
//  Created by Mac on 2023/03/28.
//

import UIKit
import CoreData

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        //추가된 xcdatamodeld파일을 코어 데이터 시스템에 등록하고 이를 이용하여 NSPersistentContainer 객체 생성하는 역할
        //NSPersistentContainer -> 앱의 코어 데이터 스택을 캡슐화 하는 컨테이너
        let container = NSPersistentContainer(name: "coredataStudy")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        //컨텍스트 객체(데이터를 읽고 쓸때 필요한 객체)를 참조하는 부분
        //-> NSManagedObjectContext 객체가 반환 (관리 객체 컨텍스트)
        //코어데이터에서 데이터를 읽고 쓰기위해서는 매번 컨텍스트 객체가 필요, 그때마다 직접 생성하는 것이 아니라 persistentContainer 객체의 viewContext 속성을 통해 참조한다 (정확히는 앱델리게이트객체->persistent~ -> viewContext 순서로 참조)
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

