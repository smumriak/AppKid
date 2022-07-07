# **AppKid**

**AppKid** is an open-source Application Development Framework heavily inspired by Apple's AppKit and UIKit. It was started as a way to have convenient SDK to build UI applications for X11 enabled GNU/Linux environment. It is written completely in swift, using Vulkan as rendering backend and relies on X11 for window management and user input events.

<p align="center">
	<img src="https://user-images.githubusercontent.com/4306641/177050935-93acbfca-3e1a-4e00-bdf2-fbbac5ad3ed9.png?raw=true" alt="Hello World with AppKid">
</p>

```swift
import AppKid
import Foundation

class RootViewController: ViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        let label = Label(frame: CGRect(x: 0.0, y: 0.0, width: 320.0, height: 44.0))
        label.text = "Hello World"
        view.addSubview(label)
        label.center = CGPoint(x: 160.0, y: 120.0)
    }
}

@main
final class AppDelegate: ApplicationDelegate {
    func application(_: Application, didFinishLaunchingWithOptions _: [Application.LaunchOptionsKey: Any]? = nil) -> Bool {
        let window = Window(contentRect: CGRect(x: 0.0, y: 0.0, width: 320.0, height: 240.0))
        window.title = "Hello World"
        window.rootViewController = RootViewController()
        return true
    }
}
```

## Getting started with **AppKid** in your project
**AppKid** depends on mulitple opensource projects. Below are the instructrions on how to set those up for Debian-based Linux distributions. RPM-Based instructions will be added some time later.

- <details>
	<summary>Swift language</summary>
	
	- Get tarball package from [swift.org](https://swift.org/getting-started/#installing-swift), unpack it to some system directory like `/opt/swift` and update global `$PATH` variable
		```bash
		sudo nano /etc/profile.d/10swift_path.sh
		```
		paste this
		```bash
		export PATH=/opt/swift/usr/bin:"${PATH}"`
		```
		where `/opt/swift` is a path to your swift toolchain
	
	- Alternatively install swiftlang package via [swiftlang builds](https://www.swiftlang.xyz/) (does not require extenting `$PATH` variable)
		```bash
		wget -qO - https://archive.swiftlang.xyz/install.sh | sudo bash
		sudo apt install swiftlang -y
		```
  </details>
- <details>
    <summary>Vulkan SDK</summary>

	LunarG is using deprecated apt-key to verify signature so this repo provides more modern and safe configuration via `SupportingFiles`
	```bash
    wget -qO - https://packages.lunarg.com/lunarg-signing-key-pub.asc | gpg --dearmor | sudo tee -a /usr/share/keyrings/lunarg-archive-keyring.gpg
	sudo wget -q https://raw.githubusercontent.com/smumriak/AppKid/main/SupportingFiles/lunarg-vulkan-focal.list -O /etc/apt/sources.list.d/lunarg-vulkan-focal.list
	sudo apt update
	sudo apt install vulkan-sdk -y
	```
  </details>
- <details>
	<summary>System libraries</summary>

	```bash
	sudo apt install -y \
		libx11-dev \
		libxi-dev \
		libwayland-dev \
		libcairo2-dev \
		libpango1.0-dev \
		libglib2.0-dev
	```
  </details>
- <details>
	<summary>libpython3.8 for debugger support</summary>

	> **NOTE:** If you have no intention of debugging Swift code you skip this step

	Swifts LLDB is built using libpython3.8. On modern system you will probably meet libpython3.9 or higher. Just make a symbolic link from new version to old version. Tho this is not ideal and will break with every major distribution update for you
	```bash
	cd /usr/lib/x86_64-linux-gnu
	sudo ln -sf libpython3.10.so libpython3.8.so.1.0
	```
	where `libpython3.10.so` is currently installed version and libpython3.8.so.1.0 is filename against which Swifts LLDB was built.
  </details>
After the necessary dependencies were set up just add this package in your SwiftPM manifest file as a dependency and add **AppKid** product as a dependency to your target:
```swift
// swift-tools-version: 5.5
import PackageDescription

let package = Package(
  name: "MyApp",
  dependencies: [
    .package(
	  url: "https://github.com/smumriak/AppKid", 
	  branch: "main"
	),
  ],
  targets: [
    .executableTarget(
      name: "MyApp",
      dependencies: [
        .product(name: "AppKid", package: "AppKid")
      ])
  ]
)
```

## **Contributing**
Contributions are very welcome. Before you dive in it is recommended to [setup your local development environment](#development).

You can use provided sample applicatio called **AppKidDemo**, it is located in this repository and is one of the products. **AppKidDemo** is written in swift and provides a sample environment for **AppKid** development. 

https://user-images.githubusercontent.com/4306641/177026612-370dbd73-b414-4551-9341-9bd580389d53.mp4

https://user-images.githubusercontent.com/4306641/177026512-4524bd22-895b-4205-ad9c-5b29251fdfa0.mp4

## Development
Before jumping straight into writing code there is some development setup required. Below are instructions on how to setup development environment for Debian-based Linux or for macOS
#### Debian-based Linux
- Follow steps from [Getting started with **AppKid** in your project](#getting-started-with-appkid-in-your-project) to get the dependencies installed
- <details>
	<summary>libclang for shaders preprocessing</summary>

	> **NOTE:** If you have no intention to modify internal **AppKid** shaders you can skip this step

	AppKid is using its own GLSL dialect for internal shaders. It is preprocessed via custom tool that is build on top of libclang.
	
	Install libclang itself
	```bash
	sudo apt install -y \
		libclang-12-dev 
	```
	Install provided package config file for libclang because llvm does not provide one:
	```bash
	sudo mkdir -p /usr/local/lib/pkgconfig
	sudo wget -q https://raw.githubusercontent.com/smumriak/AppKid/main/SupportingFiles/clang.pc -O /usr/local/lib/pkgconfig/clang.pc
	```
  </details>

#### **macOS**
- Xcode via [AppStore](https://apps.apple.com/us/app/xcode/id497799835) or [developer.apple.com](https://developer.apple.com/download/more/)
- <details>
    <summary>XQuartz</summary>
	
    ```bash
    brew install xquartz
    ```
	</details>
- Vulkan SDK via [lunarg.com](https://vulkan.lunarg.com/sdk/home#mac)
- <details>
    <summary>PKG_CONFIG_PATH global variable</summary>

	Update global `PKG_CONFIG_PATH` variable so command line tools would have proper pkg-config search path:
	```bash
	sudo nano /etc/profile
	````
	paste this:
	```bash
	export PKG_CONFIG_PATH="/opt/X11/lib/pkgconfig:/usr/local/lib/pkgconfig:/usr/local/lib:$PKG_CONFIG_PATH"
	```
    Add a launchctl agent that will update environment variables per user session so Xcode could find all the pkg-config files needed to properly build projects:
	```bash
	mkdir -p ~/Library/LaunchAgents
	curl -s https://raw.githubusercontent.com/smumriak/AppKid/main/SupportingFiles/environment.plist -o ~/Library/LaunchAgents/environment.plist
	launchctl load -w ~/Library/LaunchAgents/environment.plist
	```
	> **NOTE:** This file is not backed up by TimeMachine, so you probably want to extend this environment variable for command line tools in some other way

	</details>
- <details>
    <summary>Install other project dependencies:</summary>
	```bash
	brew install \
		pkg-config \
		cairo \
		glib \
		pango
	```
	</details>

~~I recommend generating the Xcode project via `swift package generate-xcodeproj` and opening it because indexing and build target generation is just faster this way, but you can also open `Packge.swift` in Xcode and it will be pretty much the same user experience.~~

The generate-xcodeproj from swift package manager is [deprecated](https://forums.swift.org/t/rfc-deprecating-generate-xcodeproj/42159). It does not receive updates anymore and is throwing a fatal error when it meets a plugin definition in `Package.swift` file. Opening `Package.swift` itself does not work really well anymore either as it's just not showing any of the local submodules in Xcode sources tree. 

For everyone's convenience there is a VSCode configuration provided. Just load the repo directory in VSCode (or VSCodium if you don't like the telemetry thing). You can install following plugins to improve development experience: 
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