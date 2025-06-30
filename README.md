# ColorizerApp
MacOs project aim to color black and white pictures using a neural network.

## project creation
⚠ Need to adapt -DCMAKE_TOOLCHAIN_FILE=/Users/rodoc/develop/vcpkg/scripts/buildsystems/vcpkg.cmake to your real vcpkg.cmake path in proj.sh file. Depends where vcpkg is installed.

```shell
cd ~
git clone https://github.com/microsoft/vcpkg.git
cd vcpkg
vcpkg install opencv4
cd ~
git clone https://github.com/rodolphe74/ColorizerApp.git
cd ColorizerApp
cd neural
7zz x model.7z.001
cd ..
./proj.sh
cd debug
make
open Colorizer.app
```

## Xcode project creation
use ./xcode.sh instead of ./proj.sh

<img src="sample.png">
