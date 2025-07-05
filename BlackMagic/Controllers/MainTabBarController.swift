import UIKit

class MainTabBarController: UITabBarController {
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabs()
        tabBar.tintColor = .systemBlue
        tabBar.barStyle = .black
        tabBar.isTranslucent = true
    }
    
    // MARK: - Setup Tabs
    
    private func setupTabs() {
        let mainVC = MainViewController()
        let boostersVC = UIViewController()
        boostersVC.view.backgroundColor = .black
        let collectionVC = UIViewController()
        collectionVC.view.backgroundColor = .black
        
        mainVC.tabBarItem = UITabBarItem(title: "Buy boosters", image: UIImage(systemName: "cart.fill"), tag: 0)
        boostersVC.tabBarItem = UITabBarItem(title: "Open boosters", image: UIImage(systemName: "gift.fill"), tag: 1)
        collectionVC.tabBarItem = UITabBarItem(title: "My collection", image: UIImage(systemName: "book.fill"), tag: 2)
        
        viewControllers = [
            UINavigationController(rootViewController: mainVC),
            UINavigationController(rootViewController: boostersVC),
            UINavigationController(rootViewController: collectionVC)
        ]
    }
}
