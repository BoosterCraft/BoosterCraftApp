import UIKit
import CoreGraphics

class SVGConverter {
    static func convertSVGToImage(svgData: Data, size: CGSize = CGSize(width: 100, height: 100)) -> UIImage? {
        guard let svgString = String(data: svgData, encoding: .utf8) else {
            return nil
        }
        
        // Create a simple SVG renderer using Core Graphics
        let renderer = UIGraphicsImageRenderer(size: size)
        
        return renderer.image { context in
            // Set background color
            UIColor.clear.setFill()
            context.fill(CGRect(origin: .zero, size: size))
            
            // For now, we'll create a simple placeholder since full SVG parsing is complex
            // This is a simplified approach - in production you might want to use a library like SwiftSVG
            
            // Create a simple icon representation
            let path = UIBezierPath()
            let center = CGPoint(x: size.width / 2, y: size.height / 2)
            let radius = min(size.width, size.height) / 3
            
            // Draw a simple circle as placeholder
            path.addArc(withCenter: center, radius: radius, startAngle: 0, endAngle: 2 * .pi, clockwise: true)
            
            UIColor.white.setFill()
            path.fill()
            
            // Add some simple decoration
            let innerPath = UIBezierPath()
            innerPath.addArc(withCenter: center, radius: radius * 0.6, startAngle: 0, endAngle: 2 * .pi, clockwise: true)
            
            UIColor(red: 37/255, green: 37/255, blue: 37/255).setFill()
            innerPath.fill()
        }
    }
    
    // Create a set-specific icon based on set code
    static func createSetIcon(for setCode: String, size: CGSize = CGSize(width: 100, height: 100)) -> UIImage? {
        let renderer = UIGraphicsImageRenderer(size: size)
        
        return renderer.image { context in
            // Set background color
            UIColor.clear.setFill()
            context.fill(CGRect(origin: .zero, size: size))
            
            let center = CGPoint(x: size.width / 2, y: size.height / 2)
            let radius = min(size.width, size.height) / 3
            
            // Create a unique icon based on set code
            let setCodeUpper = setCode.uppercased()
            
            // Draw background circle
            let backgroundPath = UIBezierPath()
            backgroundPath.addArc(withCenter: center, radius: radius, startAngle: 0, endAngle: 2 * .pi, clockwise: true)
            
            // Use different colors based on set code
            let backgroundColor: UIColor
            switch setCode {
            case "tdm":
                backgroundColor = UIColor(red: 34/255, green: 45/255, blue: 87/255)
            case "otj":
                backgroundColor = UIColor(red: 236/255, green: 90/255, blue: 43/255)
            case "woe":
                backgroundColor = UIColor(red: 138/255, green: 43/255, blue: 226/255)
            case "neo":
                backgroundColor = UIColor(red: 255/255, green: 20/255, blue: 147/255)
            case "mkm":
                backgroundColor = UIColor(red: 139/255, green: 69/255, blue: 19/255)
            case "lci":
                backgroundColor = UIColor(red: 255/255, green: 165/255, blue: 0/255)
            case "snc":
                backgroundColor = UIColor(red: 75/255, green: 0/255, blue: 130/255)
            case "vow":
                backgroundColor = UIColor(red: 139/255, green: 0/255, blue: 0/255)
            default:
                backgroundColor = UIColor(red: 37/255, green: 37/255, blue: 37/255)
            }
            
            backgroundColor.setFill()
            backgroundPath.fill()
            
            // Draw set code text
            let attributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.boldSystemFont(ofSize: radius * 0.8),
                .foregroundColor: UIColor.white
            ]
            
            let textSize = setCodeUpper.size(withAttributes: attributes)
            let textRect = CGRect(
                x: center.x - textSize.width / 2,
                y: center.y - textSize.height / 2,
                width: textSize.width,
                height: textSize.height
            )
            
            setCodeUpper.draw(in: textRect, withAttributes: attributes)
        }
    }
} 