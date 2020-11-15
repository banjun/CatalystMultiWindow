import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard case let windowScene as UIWindowScene = scene else { return }

        #if targetEnvironment(macCatalyst)
        let minSize = CGSize(width: 375, height: 667) // iPhone 6s
        let maxSize = CGSize(width: 428, height: 926) // iPhone 12 Pro Max
        if #available(macCatalyst 14, *) {
            windowScene.sizeRestrictions!.minimumSize = minSize
            windowScene.sizeRestrictions!.maximumSize = maxSize
        } else {
            guard let window = windowScene.windows.first else { return }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0) {
                // make some adjustments for 374,667 ~ 429,926
                windowScene.sizeRestrictions!.minimumSize = CGSize(width: minSize.width - 2, height: minSize.height - 29)
                windowScene.sizeRestrictions!.maximumSize = CGSize(width: maxSize.width, height: maxSize.height - 28)
                let nsWindow = NSWindowProxy(window)
                nsWindow.setMinSize(minSize)
                nsWindow.setMaxSize(maxSize)
                nsWindow.setFrame(CGRect(origin: .zero, size: maxSize))
                nsWindow.center()
            }
        }
        #endif
    }
}

// magic numbers might be specific to Catalina Catalyst

#if targetEnvironment(macCatalyst)
private struct NSApplicationProxy {
    private let app = NSClassFromString("NSApplication") as AnyObject
    var sharedApplication: NSObject? { app.value(forKey: "sharedApplication") as? NSObject }
    var delegate: NSObject? { sharedApplication?.value(forKey: "delegate") as? NSObject }
    func hostWindowForUIWindow(_ window: UIWindow) -> NSObject? { delegate?.perform(Selector(("hostWindowForUIWindow:")), with: window)?.takeUnretainedValue() as? NSObject }
}
private struct NSWindowProxy {
    private let nsWindow: NSObject?
    init(_ window: UIWindow) {
        self.nsWindow = NSApplicationProxy().hostWindowForUIWindow(window)
    }
    func setMinSize(_ minSize: CGSize) {
        nsWindow?.setValue(NSValue(size: CGSize(width: minSize.width - 88, height: minSize.height - 154)), forKey: "minSize")
    }
    func setMaxSize(_ maxSize: CGSize) {
        nsWindow?.setValue(NSValue(size: CGSize(width: maxSize.width, height: maxSize.height - 28)), forKey: "maxSize")
    }
    func setFrame(_ frame: CGRect) {
        nsWindow?.setValue(NSValue(rect: CGRect(x: frame.origin.x, y: frame.origin.y, width: frame.size.width, height: frame.size.height - 28)), forKey: "frame")
    }
    func center() {
        _ = nsWindow?.value(forKey: "center")
    }
}
#endif
