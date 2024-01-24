//
//  AppDelegate.swift
//  BillManager
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        let center = UNUserNotificationCenter.current()
        
        let remindInAnHourAction = UNNotificationAction(identifier: Bill.remindActionID, title: "Reminder to Pay Bills In 1 Hour", options: [])
        let markBillAsPaidAction = UNNotificationAction(identifier: Bill.markBillAsPaidActionID, title: "Bills have been Paid", options: [.authenticationRequired])
        
        let billNotificationCategory = UNNotificationCategory(identifier: Bill.notificationCategoryID, actions: [remindInAnHourAction, markBillAsPaidAction], intentIdentifiers: [], options: [])
        
        
        center.setNotificationCategories([billNotificationCategory])
        center.delegate = self
        // Override point for customization after application launch.
        
        return true
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        let forNotificationID = response.notification.request.identifier
        
        let bill = Database.shared.getBills(forNotificationID: forNotificationID)
        
        if var bill = bill {
            switch response.actionIdentifier {
            case Bill.remindActionID:
                let remindDate = Date().addingTimeInterval(3600)
                bill.schedulingReminders(dateOfReminderSet: remindDate, completion: { (updatedBill) in
                    Database.shared.updateAndSave(updatedBill)
                completionHandler()}
                )
            case Bill.markBillAsPaidActionID:
                bill.paidDate = Date()
                Database.shared.updateAndSave(bill)
                completionHandler()
            default:
                break
            }
        }
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound])
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

