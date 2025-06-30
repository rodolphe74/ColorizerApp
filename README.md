# ColorizerApp

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
