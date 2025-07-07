import UIKit

class ImageLoadingService {
    static let shared = ImageLoadingService()
    
    private let imageCache = NSCache<NSString, UIImage>()
    private let session = URLSession.shared
    
    private init() {
        imageCache.countLimit = 100 // Limit cache to 100 images
    }
    
    func loadImage(from urlString: String, completion: @escaping (UIImage?) -> Void) {
        // Check cache first
        if let cachedImage = imageCache.object(forKey: urlString as NSString) {
            completion(cachedImage)
            return
        }
        
        guard let url = URL(string: urlString) else {
            completion(nil)
            return
        }
        
        let task = session.dataTask(with: url) { [weak self] data, response, error in
            DispatchQueue.main.async {
                if let data = data {
                    var image: UIImage?
                    
                    // Check if it's an SVG file
                    if urlString.lowercased().contains(".svg") {
                        image = SVGConverter.convertSVGToImage(svgData: data, size: CGSize(width: 120, height: 120))
                    } else {
                        image = UIImage(data: data)
                    }
                    
                    if let image = image {
                        // Cache the image
                        self?.imageCache.setObject(image, forKey: urlString as NSString)
                        completion(image)
                    } else {
                        completion(nil)
                    }
                } else {
                    completion(nil)
                }
            }
        }
        task.resume()
    }
    
    func clearCache() {
        imageCache.removeAllObjects()
    }
} 