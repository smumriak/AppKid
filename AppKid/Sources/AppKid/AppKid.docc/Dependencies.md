## Installing Swift
### Official Swift binaries
Get tarball package from [swift.org](https://swift.org/getting-started/#installing-swift), unpack it to some system directory like `/opt/swift` and update global `$PATH` variable
```bash
sudo nano /etc/profile.d/10swift_path.sh
```
paste this
```bash
export PATH=/opt/swift/usr/bin:"${PATH}"`
```
where `/opt/swift` is a path to your swift toolchain. Don't forget to install all the Swift dependencies listed on that page.

### Unofficial repository
Alternatively you can install swiftlang package via [swiftlang builds](https://www.swiftlang.xyz/) (does not require extenting `$PATH` variable)
```bash
wget -qO - https://archive.swiftlang.xyz/install.sh | sudo bash
sudo apt install swiftlang -y
```

## Vulkan SDK
### Official deb repository
LunarG is using deprecated apt-key to verify signature so this repo provides more modern and safe configuration via `SupportingFiles`
```bash
wget -qO - https://packages.lunarg.com/lunarg-signing-key-pub.asc | gpg --dearmor | sudo tee -a /usr/share/keyrings/lunarg-archive-keyring.gpg
sudo wget -q https://raw.githubusercontent.com/smumriak/AppKid/main/SupportingFiles/lunarg-vulkan-jammy.list -O /etc/apt/sources.list.d/lunarg-vulkan-jammy.list
sudo apt update
sudo apt install -y vulkan-sdk
```

### Official binaries
LunarG provides tarballs containing all necessary binaries. Follow [this official guide](https://vulkan.lunarg.com/doc/view/latest/linux/getting_started.html) to install those manually

### Distribution-provided packages
Debian starting from version 12 and Ubuntu starting from 22.04 provide packages that are suitable substitutions for the Vulkan SDK. They will be older version than the official binaries.
```
sudo apt install -y \
    libvulkan-dev \
    vulkan-validationlayers \
    glslc
```

## System Libraries
AppKid requires some system dependencies from your distribution of choice. For Debian-based distribution you can install them like this:
```bash
sudo apt install -y \
    libx11-dev \
    libxi-dev \
    libwayland-dev \
    libcairo2-dev \
    libpango1.0-dev \
    libglib2.0-dev
```

## libclang for shaders processing
AppKid is using its own GLSL dialect for internal shaders. It is preprocessed via custom tool that is build on top of libclang.

Install libclang itself
```bash
sudo apt install -y \
    libclang-15-dev 
```
Install provided package config file for libclang because llvm does not provide one:
```bash
sudo mkdir -p /usr/local/lib/pkgconfig
sudo wget -q https://raw.githubusercontent.com/smumriak/AppKid/main/SupportingFiles/clang.pc -O /usr/local/lib/pkgconfig/clang.pc
```
If you are going to install different version of libclang - adjust clang.pc accordingly.

## libpython3.8 for debugger support
> **NOTE:** If you have no intention of debugging Swift code you skip this step

Swifts LLDB is built using libpython3.8. On modern system you will probably see libpython3.9 or higher. Just make a symbolic link from new version to old version. Tho this is not ideal and will break with every major distribution update for you
```bash
cd /usr/lib/x86_64-linux-gnu
sudo ln -sf libpython3.10.so libpython3.8.so.1.0
```
where `libpython3.10.so` is currently installed version, libpython3.8.so.1.0 is filename against which Swifts LLDB was built and `x86_64-linux-gnu` is architecture of your system.
