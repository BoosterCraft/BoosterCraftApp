import UIKit

// Кнопка для отображения баланса пользователя (многоразовая)
class BalanceButton: UIButton {
    // Инициализация кнопки
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupAppearance()
        updateBalance()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupAppearance()
        updateBalance()
    }
    
    // Настройка внешнего вида кнопки
    private func setupAppearance() {
        setTitleColor(.systemBlue, for: .normal)
        titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        setImage(UIImage(systemName: "creditcard.fill"), for: .normal)
        tintColor = .systemBlue
        imageEdgeInsets = UIEdgeInsets(top: 0, left: -5, bottom: 0, right: 0)
        addTarget(self, action: #selector(setDebugBalance), for: .touchUpInside)
    }
    
    // Обновить баланс на кнопке
    func updateBalance() {
        let balance = UserDataManager.shared.loadBalance()
        // Округляем баланс до двух знаков после запятой для красивого отображения
        let rounded = String(format: "%.2f", balance.coins)
        let balanceString = "$\(rounded)"
        setTitle(balanceString, for: .normal)
    }
    @objc func setDebugBalance() {
        #if DEBUG
        let balance = UserDataManager.shared.loadBalance()
        UserDataManager.shared.saveBalance(UserBalance(coins: balance.coins + 1000))
        updateBalance()
        #endif
    }
}
// другой вариант
// import UIKit

// // Кнопка для отображения баланса пользователя (многоразовая)
// class BalanceButton: UIButton {
//     // Инициализация кнопки
//     override init(frame: CGRect) {
//         super.init(frame: frame)
//         setupAppearance()
//         updateBalance()
//     }
    
//     required init?(coder: NSCoder) {
//         super.init(coder: coder)
//         setupAppearance()
//         updateBalance()
//     }
    
//     // Настройка внешнего вида кнопки
//     private func setupAppearance() {
//         setTitleColor(.systemBlue, for: .normal)
//         titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
//         let config = UIImage.SymbolConfiguration(pointSize: 22) // Увеличиваем размер иконки
//         setImage(UIImage(systemName: "creditcard.fill", withConfiguration: config), for: .normal)
//         tintColor = .systemBlue
//         imageEdgeInsets = UIEdgeInsets(top: 0, left: -5, bottom: 0, right: 0)
//     }
    
//     // Обновить баланс на кнопке
//     func updateBalance() {
//         let balance = UserDataManager.shared.loadBalance()
//         let balanceString = "$\(balance.coins)"
//         setTitle(balanceString, for: .normal)
//     }
// } 
