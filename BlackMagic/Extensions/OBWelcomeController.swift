//
//  OBWelcomeController.swift
//  BlackMagic
//
//  Created by Alex on 7/7/25.
//

import UIKit


class OBWelcomeController {
    // MARK: - Private Properties
    private static var dynamicLibraryLoaded: Bool = false
    
    // MARK: - Public Properties
    private(set) var viewController: UIViewController!
    
    // MARK: - init(title:detailText:symbolName:)
    init(title: NSString, detailText: NSString, symbolName: NSString?) {
        if OBWelcomeController.dynamicLibraryLoaded == false {
            dlopen("/System/Library/PrivateFrameworks/OnBoardingKit.framework/OnBoardingKit", RTLD_NOW)
            OBWelcomeController.dynamicLibraryLoaded = true
        }
        print(title)
        let initWithTitleDetailTextSymbolName = (@convention(c) (NSObject, Selector, NSString, NSString, NSString?) -> UIViewController).self
        
        let OBWelcomeController = NSClassFromString("OBWelcomeController") as! NSObject.Type
        let welcomeController = OBWelcomeController
            .perform(NSSelectorFromString("alloc"))
            .takeUnretainedValue() as! NSObject
        
        let selector = NSSelectorFromString("initWithTitle:detailText:symbolName:")
        let implementation = welcomeController.method(for: selector)
        let method = unsafeBitCast(implementation, to: initWithTitleDetailTextSymbolName.self)
        

        viewController = method(welcomeController, selector, title, detailText, nil)
    }
    
    // MARK: - Public Methods
    func addBulletedListItem(title: NSString, description: NSString, symbolName: NSString, tintColor: UIColor = .systemBlue) {
        let addBulletedListItemWithTitleDescriptionSymbolNameTintColor = (@convention(c) (NSObject, Selector, NSString, NSString, NSString, UIColor) -> Void).self
        let selector = NSSelectorFromString("addBulletedListItemWithTitle:description:symbolName:tintColor:")
        let implementation = viewController.method(for: selector)
        let method = unsafeBitCast(implementation, to: addBulletedListItemWithTitleDescriptionSymbolNameTintColor.self)
        _ = method(viewController, selector, title, description, symbolName, tintColor)
    }
    
    func addBoldButton(title: NSString, action: @escaping () -> Void) {
        let OBBoldTrayButton = NSClassFromString("OBBoldTrayButton") as! NSObject.Type
        let selector = NSSelectorFromString("boldButton")
        let button = OBBoldTrayButton.perform(selector).takeUnretainedValue() as! UIButton
        button.configuration?.title = String(title)
        button.addAction(UIAction { _ in action() }, for: .touchUpInside)
        
        let buttonTray = viewController.value(forKey: "buttonTray") as! NSObject
        buttonTray.perform(NSSelectorFromString("addButton:"), with: button)
    }
    
    func addLinkButton(title: NSString, action: @escaping () -> Void) {
        let OBLinkTrayButton = NSClassFromString("OBLinkTrayButton") as! NSObject.Type
        let selector = NSSelectorFromString("linkButton")
        let button = OBLinkTrayButton.perform(selector).takeUnretainedValue() as! UIButton
        button.configuration?.title = String(title)
        button.addAction(UIAction { _ in action() }, for: .touchUpInside)
        
        let buttonTray = viewController.value(forKey: "buttonTray") as! NSObject
        buttonTray.perform(NSSelectorFromString("addButton:"), with: button)
    }
}
