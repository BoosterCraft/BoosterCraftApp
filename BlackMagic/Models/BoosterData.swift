import Foundation
import UIKit

struct BoosterData {
    let setCode: String
    let setName: String
    let description: String
    let price: String
    let cardRange: ClosedRange<Int>
    let titleColor: UIColor
    let titleBackgroundColor: UIColor
    let buttonTextColor: UIColor
    let imageName: String
    let setIconURL: String?
    
    // Predefined boosters based on the requirements
    static let predefinedBoosters: [BoosterData] = [
        BoosterData(
            setCode: "tdm",
            setName: "TARKIR: DRAGONSTORM",
            description: "Cinematic action, dynamic clan gameplay, and powerful new dragons.",
            price: "$26.28",
            cardRange: 1...286,
            titleColor: UIColor(red: 34, green: 45, blue: 87),
            titleBackgroundColor: UIColor(red: 219, green: 240, blue: 252),
            buttonTextColor: UIColor(red: 34, green: 45, blue: 87),
            imageName: "cardImage",
            setIconURL: "https://svgs.scryfall.io/sets/tdm.svg?1727064000"
        ),
        BoosterData(
            setCode: "otj",
            setName: "OUTLAWS OF THUNDER JUNCTION",
            description: "Dark gothic horror, werewolves, and vampires — lead your clan to power.",
            price: "$19.80",
            cardRange: 1...286,
            titleColor: UIColor(red: 255, green: 255, blue: 255),
            titleBackgroundColor: UIColor(red: 236, green: 90, blue: 43),
            buttonTextColor: UIColor(red: 236, green: 90, blue: 43),
            imageName: "cardImage",
            setIconURL: "https://svgs.scryfall.io/sets/otj.svg?1727064000"
        ),
        BoosterData(
            setCode: "woe",
            setName: "WILD OF ELDRAINE",
            description: "Fairy tale adventures in a magical realm of knights and monsters.",
            price: "$24.50",
            cardRange: 1...276,
            titleColor: UIColor(red: 255, green: 255, blue: 255),
            titleBackgroundColor: UIColor(red: 138, green: 43, blue: 226),
            buttonTextColor: UIColor(red: 138, green: 43, blue: 226),
            imageName: "cardImage",
            setIconURL: "https://svgs.scryfall.io/sets/woe.svg?1727064000"
        ),
        BoosterData(
            setCode: "neo",
            setName: "KAMIGAWA: NEON DYNASTY",
            description: "Cyberpunk meets traditional Japanese mythology in this futuristic world.",
            price: "$28.75",
            cardRange: 1...302,
            titleColor: UIColor(red: 255, green: 255, blue: 255),
            titleBackgroundColor: UIColor(red: 255, green: 20, blue: 147),
            buttonTextColor: UIColor(red: 255, green: 20, blue: 147),
            imageName: "cardImage",
            setIconURL: "https://svgs.scryfall.io/sets/neo.svg?1727064000"
        ),
        BoosterData(
            setCode: "mkm",
            setName: "MURDERS AT KARLOV MANOR",
            description: "Solve mysteries in a gothic detective story setting.",
            price: "$22.50",
            cardRange: 1...250,
            titleColor: UIColor(red: 255, green: 255, blue: 255),
            titleBackgroundColor: UIColor(red: 139, green: 69, blue: 19),
            buttonTextColor: UIColor(red: 139, green: 69, blue: 19),
            imageName: "cardImage",
            setIconURL: "https://svgs.scryfall.io/sets/mkm.svg?1727064000"
        ),
        BoosterData(
            setCode: "lci",
            setName: "LOST CAVERNS OF IXALAN",
            description: "Explore ancient ruins and discover lost treasures.",
            price: "$25.00",
            cardRange: 1...280,
            titleColor: UIColor(red: 255, green: 255, blue: 255),
            titleBackgroundColor: UIColor(red: 255, green: 165, blue: 0),
            buttonTextColor: UIColor(red: 255, green: 165, blue: 0),
            imageName: "cardImage",
            setIconURL: "https://svgs.scryfall.io/sets/lci.svg?1727064000"
        ),
        BoosterData(
            setCode: "snc",
            setName: "STREETS OF NEW CAPENNA",
            description: "Art deco cityscape with crime families and powerful artifacts.",
            price: "$23.75",
            cardRange: 1...281,
            titleColor: UIColor(red: 255, green: 255, blue: 255),
            titleBackgroundColor: UIColor(red: 75, green: 0, blue: 130),
            buttonTextColor: UIColor(red: 75, green: 0, blue: 130),
            imageName: "cardImage",
            setIconURL: "https://svgs.scryfall.io/sets/snc.svg?1727064000"
        ),
        BoosterData(
            setCode: "vow",
            setName: "INNISTRAD: CRIMSON VOW",
            description: "Gothic horror wedding with vampires and dark magic.",
            price: "$21.50",
            cardRange: 1...277,
            titleColor: UIColor(red: 255, green: 255, blue: 255),
            titleBackgroundColor: UIColor(red: 139, green: 0, blue: 0),
            buttonTextColor: UIColor(red: 139, green: 0, blue: 0),
            imageName: "cardImage",
            setIconURL: "https://svgs.scryfall.io/sets/vow.svg?1727064000"
        )
    ]
} 