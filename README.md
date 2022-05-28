# AppKid

AppKid is an implementation of Application Development Framework heavily inspired by Apple's AppKit and UIKit. It was started as a way to have convenient SDK to build UI applications for X11 enabled GNU/Linux environment. It is written completely in swift, using Vulkan as rendering backend and relies on X11 for window management and user input events.

```swift
import Foundation
import AppKid

class RootViewController: ViewController {
	override func viewDidLoad() {
        super.viewDidLoad()
		let label = Label(with: CGRect(x: 0.0, y: 0.0, width: 200.0, height: 200.0))
		label.text = "Hello World"
		label.center = CGPoint(x: 320.0, y: 240.0)
		view.add(subview: label)
	}
}

@main
final class AppDelegate: NSObject, ApplicationDelegate {
    func application(_ application: Application, didFinishLaunchingWithOptions launchOptions: [Application.LaunchOptionsKey: Any]? = nil) -> Bool {
        let window = Window(contentRect: CGRect(x: 0.0, y: 0.0, width: 640.0, height: 480.0))
        window.title = "Hello World"
        window.rootViewController = RootViewController()
        return true
    }
}
```

# AppKidDemo

AppKidDemo is an application written in swift that aims to provide simple and convenient interface to control PWM fans on the given computer.

## Getting Started
#### Dependencies and environment setup
##### Ubuntu
- Install swift via [swift.org](https://swift.org/getting-started/#installing-swift)
- Update your global `$PATH` variable: `sudo nano /etc/profile.d/10swift_path.sh`, paste this:
	```bash
	export PATH=/opt/swift/usr/bin:"${PATH}"` where `/opt/swift` is a path to your swift toolchai
	```
- Install Vulkan SDK via [lunarg.com](https://vulkan.lunarg.com/sdk/home#linux)
	Something like this:
	```bash
	wget -qO - http://packages.lunarg.com/lunarg-signing-key-pub.asc | sudo apt-key add -
	sudo wget -qO /etc/apt/sources.list.d/lunarg-vulkan-bionic.list http://packages.lunarg.com/vulkan/lunarg-vulkan-bionic.list
	sudo apt update
	sudo apt install vulkan-sdk
	```
- Get other project dependencies:
	```bash
	sudo apt install -y \
		libx11-dev \
		libxi-dev \
		libcairo2-dev \
		libpango1.0-dev
	```
##### macOS
- Install Xcode via AppStore or [developer.apple.com](https://developer.apple.com/download/more/)
- Install XQuartz:
	```bash
	brew cask install xquartz
	```
- Install Vulkan SDK via [lunarg.com](https://vulkan.lunarg.com/sdk/home#mac)
Something like this
- Install the Vulkan pkg-config file to your system so build tools could resolve C flags for Vulkan SDK:
	```bash
	sudo cp "Supporting Files/vulkan.pc" /usr/local/lib/pkgconfig/vulkan.pc
	```
- Add a launchctl agent that will update environment variables so Xcode could find all the pkg-config files needed to properly build projects:
	```bash
	cp "Supporting Files/environment.plist" Library/LaunchAgents/environment.plist

	launchctl load -w ~/Library/LaunchAgents/environment.plist
	```
- Update your global `$PKG_CONFIG_PATH` variable so command line tools would have proper pkg-config search path: `sudo nano /etc/profile`, paste this:
	```bash
	export PKG_CONFIG_PATH="/opt/X11/lib/pkgconfig:/usr/local/lib/pkgconfig:/usr/local/lib:$PKG_CONFIG_PATH"
	```
##### Any Other Linux distros
Installation is pretty much the same as on Ubuntu, just using your local package manager. Specific stuff is in swift and Vulkan SDK installation, but if you are running something that is not Debian based - you can probably do the installation yourself.
##### Windows
Well, not there. Sorry about that.
## Development
I recommend generating the Xcode project via `swift package generate-xcodeproj` and opening it because indexing and build target generation is just faster this way, but you can just open `Packge.swift` in Xcode and it will be pretty much the same user experience.
For everyone's convenience (mostly people who are not using mac) there is a vscode configuration file provided. Just load the repo directory in VSCode (or VSCodium if you don't like the telemetry thing). You can install next plugins for best experience: 
- [Swift](https://marketplace.visualstudio.com/items?itemName=sswg.swift-lang)
- [CodeLLDB](https://marketplace.visualstudio.com/items?itemName=vadimcn.vscode-lldb)
- [Camel Case Navigation](https://marketplace.visualstudio.com/items?itemName=maptz.camelcasenavigation)
- [SwiftFormat](https://marketplace.visualstudio.com/items?itemName=vknabel.vscode-swiftformat)
- [Launch Configs](https://marketplace.visualstudio.com/items?itemName=ArturoDent.launch-config)
- [change-case](https://marketplace.visualstudio.com/items?itemName=wmaurer.change-case)
- [Shader languages support](https://marketplace.visualstudio.com/items?itemName=slevesque.shader)

## Building and running
On macOS running from Xcode is not really supported, only building and linking to get copiler checks and all that kind of stuff.
On Linux machine : `swift build` to build, `swift run` to run or use provided VSCode setup.