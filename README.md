<div align="center">
 
# CodeBuddy IDE CN for Linux (Unofficial)
 
</div>
 
<div align="center">
 
Codebuddy IDE CN（国内版）的非官方 Linux 自动化包装与安装构建脚本工具
 
</div>
<p align="center">
  <img src="https://img.shields.io/badge/deb-Ubuntu_%7C_Debian-A81D33?style=flat&logo=debian&logoColor=white" alt="Debian Ubuntu Support">
  <img src="https://img.shields.io/badge/arch-ArchLinux_%7C_CachyOS-1793D1?style=flat&logo=arch-linux&logoColor=white" alt="AUR Package">
  <img src="https://img.shields.io/badge/rpm-Fedora_%7C_RHEL-006699?style=flat&logo=fedora&logoColor=white" alt="Fedora RHEL Support">
  <img src="https://img.shields.io/badge/AppImage-All_Distros-007ACC?style=flat&logo=appimage&logoColor=white" alt="AppImage Support">
  <br>
  <img src="https://img.shields.io/badge/版本适配-v4.10.1-0052D9?style=flat&logo=probot&logoColor=white" alt="Supported Version">
  <img src="https://img.shields.io/badge/Electron-v37.7.0-47307B?style=flat&logo=electron&logoColor=white" alt="Electron Version">
  <img src="https://img.shields.io/badge/状态-Unofficial-d73a49?style=flat" alt="Status Unofficial">
  <img src="https://img.shields.io/badge/License-MIT-yellow?style=flat" alt="License MIT">
  <br>
  <a href="https://aur.archlinux.org/packages/codebuddy-ide-cn" target="_blank">
  <img src="https://img.shields.io/badge/AUR-codebuddy--ide--cn-333333?style=flat&logo=arch-linux&logoColor=white" alt="AUR Package"></a>
</p>
 
<div align="center">
 
[English](#english) | [简体中文](#简体中文) | [繁體中文](#繁體中文)
 
</div>
 
---
 
# 简体中文
 
## 项目简介
 
> ⚠️ **重要提示**：腾讯 CodeBuddy 团队已正式推出官方 Linux x86_64 Debian 分支（`.deb`）安装包。如果您使用的是 Ubuntu、Debian、Linux Mint 或其他 Debian 系发行版，**请直接前往 [CodeBuddy 官网](https://www.codebuddy.cn/ide/) 下载官方 `.deb` 包直接安装，无需使用本项目进行转换。** 本项目主要用于为 Arch Linux、Fedora/RedHat 用户提供打包转换支持，或生成通用的 AppImage 独立包。
> 
> *(注：原基于 macOS DMG 提取的旧版移植工作流已安全归档至 [legacy-dmg](https://github.com/JipZeonGit/codebuddy-ide-cn-linux/tree/legacy-dmg) 分支。)*
 
这是一款非官方社区工具，核心作用是将官方 CodeBuddy IDE CN **Linux x86_64 Debian 分支 .deb 安装包**，重新封装与加工，转换为适用于 Arch Linux (AUR)、RedHat/Fedora (RPM) 以及通用 AppImage 格式的本地 Linux 软件包。
 
本仓库**仅作为重新打包和适配工具**，绝不充当软件分发渠道。所有官方安装包由用户机器自行从腾讯官方 CDN 下载，所有生成的应用目录、安装包产物均仅保留在本地，已加入 Git 忽略规则，不会被提交至仓库。
 
遇到任何 Bug 请在此仓库提 Issue，严禁向腾讯官方客服反馈在 Linux 移植适配后使用的相关问题。请勿在腾讯 CodeBuddy 官方用户群、社交媒体讨论本项目，本项目应保持低调维护。
 
## 版本适配说明
 
当前转换流程基于官方 CodeBuddy IDE CN **4.10.1**（构建号 `33158423-3ad58bcb-cn`）验证通过。更高版本的 DEB 安装包可能因为上游代码结构变化导致流程失败。如遇到构建失败或运行异常，请在本仓库提 Issue 并附上所使用的安装包版本号。
 
各版本间的 Electron 升级、Node 模块变更与移植处理详情，请查阅 [版本变更记录](docs/changelog/)。
 
## 快速安装
 
### Arch Linux / CachyOS / Manjaro 等 Arch 系发行版
 
直接通过 AUR 安装，无需 clone 本仓库：
 
```bash
yay -S codebuddy-ide-cn
# 或者
paru -S codebuddy-ide-cn
```
 
也可以手动构建：
 
```bash
git clone https://aur.archlinux.org/codebuddy-ide-cn.git
cd codebuddy-ide-cn
makepkg -si
```
 
AUR 包页面：<https://aur.archlinux.org/packages/codebuddy-ide-cn>
 
> 构建过程会自动从腾讯官方 CDN 下载官方 DEB 安装包，请保持网络畅通。本仓库与 AUR 包均不重新分发任何腾讯软件二进制。
 
### 其他 Linux 发行版（Debian / Ubuntu / Linux Mint / Fedora / openSUSE 等）
 
1. 克隆本项目至本地 Linux 机器；
2. 依次执行：
 
```bash
make deps
make download
make build-app
make package    # 或 make appimage
make install
```
 
`make download` 会自动从腾讯官方 CDN 下载 x86_64 架构的 DEB 安装包到 `downloads/` 目录。如已有旧版 DEB 包，会自动移至 `downloads/backups/` 备份。你也可以手动从官方网站下载 DEB 包放入 `downloads/` 目录替代此步骤。
 
`make deps` 会自动识别当前系统的包管理器（支持 `apt`、`dnf5`、`dnf`、`pacman`、`zypper`），一键安装包解包、开发工具链及依赖重构所需的全部依赖。
 
## 项目状态
 
目前项目已完整实现 Linux 端的转换与打包核心流程，具体功能如下：
 
- 自动提取 `downloads/` 目录下的官方 DEB 安装包 Payload；
- 从解包的 `package.json` 中，自动识别上游 Electron 版本号（4.10.1 对应 Electron `37.7.0`）；
- 直接复用 DEB 内部自带的原生 Linux `buddycn` 运行时，最大程度保持与官方构建的一致性；
- **原生模块按需本地补译**：官方 DEB 安装包缺失了部分关键原生模块（如 `node-pty`）的 Linux 预编译二进制文件。本工具会智能识别并仅对这些缺失的模块从 npm 获取完整源码，针对 Electron 37.7.0 本地重新编译并塞回安装目录，而对已正常打包的模块（如 `sqlite3`, `spdlog`）则直接复用；
- 自动生成 Linux 系统启动器与桌面入口文件，并使用 ImageMagick 自动生成标准 `256x256` 高清图标；
- 根据当前 Linux 发行版，一键生成适配的 `.deb`、`.rpm` 或 `.pkg.tar.zst` 格式安装包；
- 支持生成跨发行版通用的 AppImage 格式（`make appimage`），无需安装即可运行；
- 通过 AUR 上架 `codebuddy-ide-cn`，Arch 系用户可一键安装。
 
> 测试范围：已在 Debian 系（Linux Mint 22.3）、Arch 系（CachyOS）和 Fedora 系（Fedora 44）完成完整打包部署实测，运行稳定。
> 项目**未集成自动更新功能**。如需更新软件，只需执行 `make download` 下载新版官方 DEB 后重新执行构建流程即可覆盖本地旧版本；AUR 用户等包升级 push 后正常 `yay -Syu` 或 `paru -Syu` 即可。
 
## 构建与运行
 
### 下载官方 DEB 包
 
自动从腾讯官方 CDN 下载 x86_64 架构的 DEB 安装包到 `downloads/` 目录：
 
```bash
make download
```
 
如 `downloads/` 中已有旧版 DEB，会自动移至 `downloads/backups/` 备份后再下载新版。你也可以跳过此步骤，手动从官方网站下载 DEB 包放入 `downloads/` 目录。
 
### 推荐构建方式
 
将官方 DEB 文件放入 `downloads/` 目录后，直接执行：
 
```bash
make build-app
```
 
### 自定义 DEB 路径
 
也可手动指定官方 DEB 文件路径：
 
```bash
make build-app DEB=/path/to/CodeBuddy-linux-x64-VERSION.deb
```
 
### 运行生成的应用
 
```bash
make run-app
```
 
### 打包并安装
 
自动生成适配当前发行版的安装包，并完成本地安装：
 
```bash
make package
make install
```
 
### 构建 AppImage
 
生成跨发行版通用的 AppImage 格式，无需安装即可运行（会自动触发 `build-app`）：
 
```bash
make appimage
```
 
生成的 AppImage 位于 `dist/codebuddy-ide-cn-x86_64.AppImage`。首次构建会自动下载并缓存 `linuxdeploy` 及 AppImage 运行时文件到 `build/tools/` 目录，以加速后续的离线打包。
 
### 清理构建产物
 
清除所有构建生成的临时文件与应用目录：
 
```bash
make clean
```
 
## 实现原理
 
本项目参考了 `codex-desktop-linux` 的本地转换与打包逻辑，但**未移植其自动更新模块**，核心流程如下：
 
1. 以用户自行提供（或通过 `make download` / AUR 包自动从腾讯官方 CDN 下载）的官方 Linux x86_64 Debian 分支 .deb 安装包作为输入源；
2. 提取 DEB 应用核心程序，不对外分发任何官方软件内容；
3. 直接复用 DEB 内部自带的原生 Linux `buddycn` 运行时以保证稳定性；
4. **原生模块本地补译**：官方 DEB 安装包缺失了部分关键原生模块（如 `node-pty`）的 Linux 预编译二进制文件。本工具会智能识别并仅对这些缺失的模块从 npm 获取完整源码，针对 Electron 37.7.0 本地重新编译并塞回安装目录，而对已正常打包的模块则直接复用；
5. 本地生成 Linux 系统启动配置与安装包元数据；
6. 编译生成对应发行版的原生安装包，通过 `make install` 或 AUR helper 完成安装。
 
CodeBuddy IDE CN 基于 VS Code/Electron 开发，官方 DEB 包含跨平台 JavaScript 核心代码，重新打包适配仅需要完成少部分缺失原生模块的本地编译，即可达到完美的系统兼容性。
 
## 常用自定义配置
 
如需自定义安装路径、切换 Electron 镜像，可通过以下环境变量配合 `make build-app` 执行：
 
```bash
# 自定义安装目录
CODEBUDDY_INSTALL_DIR=/opt/tmp/codebuddycn-app make build-app
# 切换 Electron 镜像源
ELECTRON_MIRROR=https://npmmirror.com/mirrors/electron/ make build-app
# 自定义 Electron 头文件下载地址
ELECTRON_HEADERS_URL=https://artifacts.electronjs.org/headers/dist make build-app
```
 
## 迁移说明
 
如果您之前安装过旧版 `codebuddycn-ide`，请参考 [迁移指南](docs/migration.md) 迁移到新版 `codebuddy-ide-cn`。
 
## 仓库维护规范
 
以下目录因会存放上游软件、生成类安装包文件，已被 Git 忽略，**切勿手动提交**：
 
- `downloads/`
- `build/`
- `codebuddycn-app/`
- `dist/`
- `reference/`
 
禁止提交 DEB 安装包、生成的 Linux 应用目录及各类原生安装包产物。
 
## 免责声明
 
本项目为**非官方社区开源工具**，与腾讯官方无任何关联。CodeBuddy IDE CN 是腾讯旗下产品（版权 © 2026 腾讯云计算（北京）有限责任公司丨腾讯科技（深圳）有限公司 版权所有），详细版权信息请参阅官方网站。本工具不分发任何 CodeBuddy IDE CN 官方软件，仅自动化实现用户对正版安装包的格式转换与打包流程。
 
使用本工具产生的 CodeBuddy 应用受腾讯官方协议约束：
 
- CodeBuddy 服务条款：<https://cloud.tencent.com/document/product/301/106125>
- CodeBuddy 用户隐私协议：<https://privacy.qq.com/document/preview/284d799a07164d09bfc7cedd0ec3e089>
 
使用本工具即表示您已知悉并同意以下内容：
 
1. **用户责任**：您有责任确保自行获取的 DEB 安装包来源合法，并遵守 CodeBuddy 的最终用户许可协议（EULA）及相关服务条款。
2. **无担保**：本工具按"现状"提供，不提供任何形式的明示或暗示担保，包括但不限于对适销性、特定用途适用性和非侵权性的担保。
3. **无官方支持**：本项目是独立社区项目，腾讯官方不对本工具提供任何技术支持。在 Linux 移植环境下遇到的问题，请在本仓库提 Issue，**严禁向官方客服反馈**。
4. **风险自担**：使用本工具进行重新打包和运行所产生的一切后果，由用户自行承担。
5. **商标声明**：CodeBuddy 相关标识是腾讯公司的商标或注册商标。本项目使用这些名称仅用于描述性目的，不暗示任何官方认可或授权。
6. **下架预案**：如腾讯或任何相关权利方对本项目存在异议，请通过本仓库 Issue 或邮件联系维护者。维护者承诺在收到合理异议后立即停止维护、下架 AUR 包，并按权利方要求处理 GitHub 仓库。
7. **项目定位**： 本项目（包括本 GitHub 仓库及相关的 AUR/PKGBUILD 自动化脚本）仅用于技术研究与概念验证。原作者从未、亦绝不分发任何官方二进制软件。
8. **AUR 机制说明**： 相关的 AUR 软件包仅提供文本形式的构建“配方”（Script/PKGBUILD）。用户通过该脚本进行的任何下载、解包、重新打包等行为，均在用户本地计算机上独立发生，下载源均指向官方或合法的公开地址，本项目不托管任何受版权保护的二进制文件。
9. **第三方责任**： 任何第三方因 Fork、修改本项目，或自行分发移植二进制安装包（Releases）而产生的版权争议与法律责任，均由该第三方独立承担，与本项目原作者无关。
 
## 开源许可证
 
本项目（PKGBUILD、重新打包脚本及相关 recipe）采用 MIT 开源许可证，详见 [LICENSE](LICENSE)。MIT 许可仅覆盖本仓库中的适配工具，**不延伸到通过本工具安装的腾讯 CodeBuddy IDE 二进制文件**——后者仍受腾讯官方私有协议约束。
 
---
 
# 繁體中文
 
## 專案簡介
 
> ⚠️ **重要提示**：騰訊 CodeBuddy 團隊已正式推出官方 Linux x86_64 Debian 分支（`.deb`）安裝包。如果您使用的是 Ubuntu、Debian、Linux Mint 或其他 Debian 系發行版，**請直接前往 [CodeBuddy 官網](https://www.codebuddy.cn/ide/) 下載官方 `.deb` 包直接安裝，無需使用本專案進行轉換。** 本專案主要用於為 Arch Linux、Fedora/RedHat 使用者提供打包轉換支援，或生成通用的 AppImage 獨立包。
> 
> *(註：原基於 macOS DMG 提取的舊版移植工作流已安全歸檔至 [legacy-dmg](https://github.com/JipZeonGit/codebuddy-ide-cn-linux/tree/legacy-dmg) 分支。)*
 
這是一款非官方社群工具，核心作用是將官方 CodeBuddy IDE CN **Linux x86_64 Debian 分支 .deb 安裝包**，重新封裝與加工，轉換為適用於 Arch Linux (AUR)、RedHat/Fedora (RPM) 以及通用 AppImage 格式的本地 Linux 軟體包。
 
本儲存庫**僅作為重新打包和適配工具**，絕不充當軟體分發管道。所有官方安裝包由使用者機器自行從騰訊官方 CDN 下載，所有生成的應用程式目錄、安裝包產物均僅保留在本地，已加入 Git 忽略規則，不會被提交至儲存庫。
 
遇到任何 Bug 請在此儲存庫提 Issue，嚴禁向騰訊官方客服回報在 Linux 移植適配後使用的相關問題。請勿在騰訊 CodeBuddy 官方使用者群組、社群媒體討論本專案，本專案應保持低調維護。
 
## 版本適配說明
 
當前轉換流程基於官方 CodeBuddy IDE CN **4.10.1**（構建號 `33158423-3ad58bcb-cn`）驗證通過。更高版本的 DEB 安裝包可能因為上遊程式碼結構變化導致流程失敗。如遇到構建失敗或執行異常，請在本儲存庫提 Issue 並附上所使用的安裝包版本號。
 
各版本間的 Electron 升級、Node 模組變更與移植處理詳情，請查閱 [版本變更記錄](docs/changelog/)。
 
## 快速安裝
 
### Arch Linux / CachyOS / Manjaro 等 Arch 系發行版
 
直接透過 AUR 安裝，無需 clone 本儲存庫：
 
```bash
yay -S codebuddy-ide-cn
# 或者
paru -S codebuddy-ide-cn
```
 
也可以手動構建：
 
```bash
git clone https://aur.archlinux.org/codebuddy-ide-cn.git
cd codebuddy-ide-cn
makepkg -si
```
 
AUR 套件頁面：<https://aur.archlinux.org/packages/codebuddy-ide-cn>
 
> 構建過程會自動從騰訊官方 CDN 下載官方 DEB 安裝包，請保持網路暢通。本儲存庫與 AUR 套件均不重新分發任何騰訊軟體二進位檔案。
 
### 其他 Linux 發行版（Debian / Ubuntu / Linux Mint / Fedora / openSUSE 等）
 
1. 複製本專案至本地 Linux 機器；
2. 依次執行：
 
```bash
make deps
make download
make build-app
make package    # 或 make appimage
make install
```
 
`make download` 會自動從騰訊官方 CDN 下載 x86_64 架構的 DEB 安裝包到 `downloads/` 目錄。如已有舊版 DEB 包，會自動移至 `downloads/backups/` 備份。你也可以手動從官方網站下載 DEB 包放入 `downloads/` 目錄替代此步驟。
 
`make deps` 會自動辨識當前系統的套件管理器（支援 `apt`、`dnf5`、`dnf`、`pacman`、`zypper`），一鍵安裝包解包、開發工具鏈及相依性重構所需的全部相依性。
 
## 專案狀態
 
目前專案已完整實現 Linux 端的轉換與打包核心流程，具體功能如下：
 
- 自動提取 `downloads/` 目錄下的官方 DEB 安裝包 Payload；
- 從解包的 `package.json` 中，自動識別上游 Electron 版本號（4.10.1 對應 Electron `37.7.0`）；
- 直接復用 DEB 內部自帶的原生 Linux `buddycn` 執行時，最大程度保持與官方構建的一致性；
- **原生模組按需本地補譯**：官方 DEB 安裝包缺失了部分關鍵原生模組（如 `node-pty`）的 Linux 預編譯二進位檔案。本工具會智能識別並僅對這些缺失的模組從 npm 獲取完整原始碼，針對 Electron 37.7.0 本地重新編譯並塞回安裝目錄，而對已正常打包的模組（如 `sqlite3`, `spdlog`）則直接復用；
- 自動生成 Linux 系統啟動器與桌面入口檔案，並使用 ImageMagick 自動生成標準 `256x256` 高清圖標；
- 根據當前 Linux 發行版，一鍵生成適配的 `.deb`、`.rpm` 或 `.pkg.tar.zst` 格式安裝包；
- 支援生成跨發行版通用的 AppImage 格式（`make appimage`），無需安裝即可執行；
- 透過 AUR 上架 `codebuddy-ide-cn`，Arch 系使用者可一鍵安裝。
 
> 測試範圍：已在 Debian 系（Linux Mint 22.3）、Arch 系（CachyOS）和 Fedora 系（Fedora 44）完成完整打包部署實測，執行穩定。
> 專案**未整合自動更新功能**。如需更新軟體，只需執行 `make download` 下載新版官方 DEB 後重新執行構建流程即可覆蓋本地舊版本；AUR 使用者等套件升級 push 後正常 `yay -Syu` 或 `paru -Syu` 即可。
 
## 構建與執行
 
### 下載官方 DEB 包
 
自動從騰訊官方 CDN 下載 x86_64 架構的 DEB 安裝包到 `downloads/` 目錄：
 
```bash
make download
```
 
如 `downloads/` 中已有舊版 DEB，會自動移至 `downloads/backups/` 備份後再下載新版。你也可以跳過此步驟，手動從官方網站下載 DEB 包放入 `downloads/` 目錄。
 
### 推薦構建方式
 
將官方 DEB 檔案放入 `downloads/` 目錄後，直接執行：
 
```bash
make build-app
```
 
### 自訂 DEB 路徑
 
也可手動指定官方 DEB 檔案路徑：
 
```bash
make build-app DEB=/path/to/CodeBuddy-linux-x64-VERSION.deb
```
 
### 執行生成的應用程式
 
```bash
make run-app
```
 
### 打包並安裝
 
自動生成適配當前發行版的安裝包，並完成本地安裝：
 
```bash
make package
make install
```
 
### 構建 AppImage
 
生成跨發行版通用的 AppImage 格式，無需安裝即可執行（會自動觸發 `build-app`）：
 
```bash
make appimage
```
 
生成的 AppImage 位於 `dist/codebuddy-ide-cn-x86_64.AppImage`。首次構建會自動下載並快取 `linuxdeploy` 及 AppImage 執行時檔案到 `build/tools/` 目錄，以加速後續的離線打包。
 
### 清理構建產物
 
清除所有構建生成的暫存檔案與應用程式目錄：
 
```bash
make clean
```
 
## 實現原理
 
本專案參考了 `codex-desktop-linux` 的本地轉換與打包邏輯，但**未移植其自動更新模組**，核心流程如下：
 
1. 以使用者自行提供（或透過 `make download` / AUR 套件自動從騰訊官方 CDN 下載）的官方 Linux x86_64 Debian 分支 .deb 安裝包作為輸入來源；
2. 提取 DEB 應用程式核心程式，不對外分發任何官方軟體內容；
3. 直接復用 DEB 內部自帶的原生 Linux `buddycn` 執行時以保證穩定性；
4. **原生模組本地補譯**：官方 DEB 安裝包缺失了部分關鍵原生模組（如 `node-pty`）的 Linux 預編譯二進位檔案。本工具會智能識別並僅對這些缺失的模組從 npm 獲取完整原始碼，針對 Electron 37.7.0 本地重新編譯並塞回安裝目錄，而對已正常打包的模組則直接復用；
5. 本地生成 Linux 系統啟動設定與安裝包後設資料；
6. 編譯生成對應發行版的原生安裝包，透過 `make install` 或 AUR helper 完成安裝。
 
CodeBuddy IDE CN 基於 VS Code/Electron 開發，官方 DEB 包含跨平台 JavaScript 核心程式碼，重新打包適配僅需要完成少部分缺失原生模組的本地編譯，即可達到完美的系統相容性。
 
## 常用自訂設定
 
如需自訂安裝路徑、切換 Electron 鏡像，可透過以下環境變數搭配 `make build-app` 執行：
 
```bash
# 自訂安裝目錄
CODEBUDDY_INSTALL_DIR=/opt/tmp/codebuddycn-app make build-app
# 切換 Electron 鏡像來源
ELECTRON_MIRROR=https://npmmirror.com/mirrors/electron/ make build-app
# 自訂 Electron 頭檔案下載位址
ELECTRON_HEADERS_URL=https://artifacts.electronjs.org/headers/dist make build-app
```
 
## 遷移說明
 
如果您之前安裝過舊版 `codebuddycn-ide`，請參考 [遷移指南](docs/migration.md) 遷移到新版 `codebuddy-ide-cn`。
 
## 儲存庫維護規範
 
以下目錄因會存放上游軟體、生成類安裝包檔案，已被 Git 忽略，**切勿手動提交**：
 
- `downloads/`
- `build/`
- `codebuddycn-app/`
- `dist/`
- `reference/`
 
禁止提交 DEB 安裝包、生成的 Linux 應用程式目錄及各類原生安裝包產物。
 
## 免責聲明
 
本專案為**非官方社群開源工具**，與騰訊官方無任何關聯。CodeBuddy IDE CN 是騰訊旗下產品（版權 © 2026 騰訊雲端運算（北京）有限責任公司丨騰訊科技（深圳）有限公司 版權所有），詳細版權資訊請參閱官方網站。本工具不分發任何 CodeBuddy IDE CN 官方軟體，僅自動化實現使用者對正版安裝包的格式轉換與打包流程。
 
使用本工具產生的 CodeBuddy 應用程式受騰訊官方協議約束：
 
- CodeBuddy 服務條款：<https://cloud.tencent.com/document/product/301/106125>
- CodeBuddy 使用者隱私協議：<https://privacy.qq.com/document/preview/284d799a07164d09bfc7cedd0ec3e089>
 
使用本工具即表示您已知悉並同意以下內容：
 
1. **使用者責任**：您有責任確保自行取得的 DEB 安裝包來源合法，並遵守 CodeBuddy 的最終使用者授權協議（EULA）及相關服務條款。
2. **無擔保**：本工具按「現狀」提供，不提供任何形式的明示或暗示擔保，包括但不限于對適銷性、特定用途適用性和非侵權性的擔保。
3. **無官方支援**：本專案是獨立社群專案，騰訊官方不對本工具提供任何技術支援。在 Linux 移植環境下遇到的問題，請在本儲存庫提 Issue，**嚴禁向官方客服回報**。
4. **風險自擔**：使用本工具進行重新打包和執行所產生的一切後果，由使用者自行承擔。
5. **商標聲明**：CodeBuddy 相關標識是騰訊公司的商標或註冊商標。本專案使用這些名稱僅用于描述性目的，不暗示任何官方認可或授權。
6. **下架預案**：如騰訊或任何相關權利方對本專案存在異議，請透過本儲存庫 Issue 或電子郵件聯繫維護者。維護者承諾在收到合理異議後立即停止維護、下架 AUR 套件，並按權利方要求處理 GitHub 儲存庫。
7. **專案定位**：本專案（包括本 GitHub 儲存庫及相關的 AUR/PKGBUILD 自動化腳本）僅用于技術研究與概念驗證。原作者從未、亦絕不分發 any 官方二進位軟體。
8. **AUR 機制說明**：相關的 AUR 軟體套件僅提供文本形式的構建「配方」（Script/PKGBUILD）。使用者透過該腳本進行的任何下載、解包、重新打包等行為，均在使用者本地電腦上獨立發生，下載來源均指向官方或合法的公開位址，本專案不託管任何受版權保護的二進位檔案。
9. **第三方責任**：任何第三方因 Fork、修改本專案，或自行分發移植二進位安裝包（Releases）而產生的版權爭議與法律責任，均由該第三方獨立承擔，與本專案原作者無關。
 
## 開源授權條款
 
本專案（PKGBUILD、重新打包腳本及相關 recipe）採用 MIT 開源授權條款，詳見 [LICENSE](LICENSE)。MIT 授權僅覆蓋本儲存庫中的適配工具，**不延伸到透過本工具安裝的騰訊 CodeBuddy IDE 二進位檔案**——後者仍受騰訊官方私有協議約束。
 
---
 
# English
 
## Project Introduction
 
> ⚠️ **IMPORTANT NOTICE**: The Tencent CodeBuddy team has officially released the Linux x86_64 Debian branch (`.deb`) installer package. If you are using Ubuntu, Debian, Linux Mint, or other Debian-based distributions, **please download the official `.deb` package directly from the [CodeBuddy Official Website](https://www.codebuddy.cn/ide/) and install it. There is no need to use this project for repackaging.** This project is primarily intended for Arch Linux (AUR) and Fedora/RedHat (RPM) users who want native integration, or for those who need a standalone AppImage.
> 
> *(Note: The legacy migration workflow based on macOS DMG extraction has been archived to the [legacy-dmg](https://github.com/JipZeonGit/codebuddy-ide-cn-linux/tree/legacy-dmg) branch.)*
 
This is an unofficial community tool designed to repackage and adapt the official CodeBuddy IDE CN **Linux x86_64 Debian branch .deb installer** into various Linux formats, including Arch Linux (AUR), RedHat/Fedora (RPM) packages, and universal AppImages.
 
This repository **serves solely as a repackaging and adaptation tool** and is never a software redistribution channel. The official installer is downloaded by the user's own machine directly from Tencent's official CDN. All generated application directories and package artifacts are stored locally only and are added to Git ignore rules.
 
If you encounter bugs, please submit an Issue here. Do not contact Tencent official customer service to report Linux porting and packaging issues. Please do not promote this project in CodeBuddy official user groups or social media; this project is intended to be maintained quietly.
 
## Version Compatibility
 
The current repackaging workflow has been verified against official CodeBuddy IDE CN **4.10.1** (build `33158423-3ad58bcb-cn`). Higher versions of the DEB installer may have upstream code structure changes that prevent the flow from completing. If you encounter build failures or runtime issues, please file an Issue with the package version number.
 
For details on Electron upgrades, Node module changes and porting notes between versions, see the [Changelog](docs/changelog/).
 
## Quick Install
 
### Arch Linux / CachyOS / Manjaro and other Arch-based distros
 
Install directly from the AUR, no need to clone this repository:
 
```bash
yay -S codebuddy-ide-cn
# or
paru -S codebuddy-ide-cn
```
 
Or build manually:
 
```bash
git clone https://aur.archlinux.org/codebuddy-ide-cn.git
cd codebuddy-ide-cn
makepkg -si
```
 
AUR package page: <https://aur.archlinux.org/packages/codebuddy-ide-cn>
 
> The build process automatically downloads the official DEB package from Tencent's CDN. Neither this repository nor the AUR package re-distributes any Tencent binary.
 
### Other Linux distros (Debian / Ubuntu / Linux Mint / Fedora / openSUSE etc.)
 
1. Clone this repository to your local Linux machine;
2. Run:
 
```bash
make deps
make download
make build-app
make package    # or make appimage
make install
```
 
`make download` automatically downloads the x86_64 DEB installer from Tencent's official CDN to the `downloads/` directory. If an older DEB already exists, it is moved to `downloads/backups/` first. You can also skip this step and manually download the DEB from the official website and place it in `downloads/`.
 
`make deps` automatically detects the package manager (`apt`, `dnf5`, `dnf`, `pacman`, `zypper`) and installs all dependencies needed for package extraction, compilation toolchain setup, and native module rebuilding.
 
## Project Status
 
The project fully implements the core Linux-side repackaging and adaptation workflow:
 
- Auto-extract the official DEB installer payload in `downloads/`;
- Detect the upstream Electron version from the extracted `package.json` metadata (4.10.1 matches Electron `37.7.0`);
- Directly reuse the native Linux `buddycn` runtime bundled in the DEB to ensure maximum stability and official consistency;
- **On-demand Native Module Compilation**: the official DEB installer lacks compiled Linux binaries for several critical native modules (e.g., `node-pty`). This tool automatically downloads the source code from npm for these missing modules and rebuilds them locally against Electron 37.7.0, while keeping and reusing pre-compiled modules (e.g., `sqlite3`, `spdlog`) already present in the DEB;
- Auto-generate Linux desktop entry and launcher configurations, utilizing ImageMagick to produce a standard `256x256` high-resolution icon;
- Generate distro-native `.deb`, `.rpm` or `.pkg.tar.zst` packages;
- Support generating universal AppImage format (`make appimage`) that runs without installation;
- Distributed through AUR as `codebuddy-ide-cn` for one-click installation on Arch-based distros.
 
> Testing scope: fully tested on Debian-based (Linux Mint 22.3), Arch-based (CachyOS), and Fedora-based (Fedora 44) systems.
> No auto-update feature is integrated. To update, run `make download` to fetch the latest official DEB and re-run the build flow; AUR users get updates via standard `yay -Syu` or `paru -Syu` once the AUR package is bumped.
 
## Build & Run
 
### Download Official DEB
 
Automatically download the x86_64 DEB installer from Tencent's official CDN to the `downloads/` directory:
 
```bash
make download
```
 
If an older DEB already exists in `downloads/`, it is moved to `downloads/backups/` before downloading the new one. You can also skip this step and manually download the DEB from the official website and place it in `downloads/`.
 
### Recommended Build Method
 
Place the official DEB in `downloads/` and run:
 
```bash
make build-app
```
 
### Custom DEB Path
 
You can also manually specify the path of the official DEB file:
 
```bash
make build-app DEB=/path/to/CodeBuddy-linux-x64-VERSION.deb
```
 
### Run the Generated Application
 
```bash
make run-app
```
 
### Package & Install
 
Generate a distribution-compatible package and install it locally:
 
```bash
make package
make install
```
 
### Build AppImage
 
Generate a universal AppImage that runs without installation (automatically triggers `build-app`):
 
```bash
make appimage
```
 
The resulting AppImage is located at `dist/codebuddy-ide-cn-x86_64.AppImage`. The first build automatically downloads and caches `linuxdeploy` and the AppImage runtime binaries into the `build/tools/` directory to speed up subsequent offline packaging.
 
### Clean Build Artifacts
 
Remove all generated temporary files and application directories:
 
```bash
make clean
```
 
## How It Works
 
This project references the local conversion and packaging logic of `codex-desktop-linux`, but **does not port its auto-update module**. The core workflow:
 
1. Take the official Linux x86_64 Debian branch .deb installer (provided by the user, or fetched via `make download` / the AUR package from Tencent's official CDN) as the input source;
2. Extract the core application payload without redistributing any official software content;
3. Reuse the bundled Linux Electron runtime `buddycn` to ensure consistency;
4. **On-demand Native Module Compilation**: several critical native modules (e.g., `node-pty`) in the official DEB installer do not contain compiled Linux binaries. This tool dynamically identifies and compiles only these missing modules from source against Electron 37.7.0, and directly keeps the other precompiled native files;
5. Generate Linux system startup configuration and package metadata locally;
6. Compile a native package for the current distribution and install via `make install` or an AUR helper.
 
CodeBuddy IDE CN is built on VS Code/Electron. The official DEB contains the cross-platform JavaScript core code, so repackaging and adaptation only require recompiling a few missing native modules to achieve perfect system compatibility.
 
## Useful Custom Configurations
 
To customize the installation path or switch Electron mirrors, pass environment variables to `make build-app`:
 
```bash
# Custom installation directory
CODEBUDDY_INSTALL_DIR=/opt/tmp/codebuddycn-app make build-app
# Switch Electron mirror source
ELECTRON_MIRROR=https://npmmirror.com/mirrors/electron/ make build-app
# Custom Electron headers download URL
ELECTRON_HEADERS_URL=https://artifacts.electronjs.org/headers/dist make build-app
```
 
## Migration Notes
 
If you previously installed the old `codebuddycn-ide` package, please refer to the [Migration Guide](docs/migration.md) to migrate to the new `codebuddy-ide-cn` package.
 
## Repository Maintenance Rules
 
The following directories are ignored by Git because they hold upstream software and generated package files. **Never commit them manually**:
 
- `downloads/`
- `build/`
- `codebuddycn-app/`
- `dist/`
- `reference/`
 
Committing DEB installers, generated Linux application directories and native package artifacts is prohibited.
 
## Disclaimer
 
This project is an **unofficial community open-source tool** with no affiliation with Tencent. CodeBuddy IDE CN is a product of Tencent (Copyright © 2026 Tencent Cloud Computing (Beijing) Co., Ltd. / Tencent Technology (Shenzhen) Co., Ltd. All rights reserved). See the official site for details. This tool does not redistribute any official CodeBuddy IDE CN software; it only automates the format conversion and packaging process for users' genuine installers.
 
The CodeBuddy application produced by this tool is governed by the official Tencent agreements:
 
- CodeBuddy Terms of Service: <https://cloud.tencent.com/document/product/301/106125>
- CodeBuddy Privacy Policy: <https://privacy.qq.com/document/preview/284d799a07164d09bfc7cedd0ec3e089>
 
By using this tool you acknowledge and agree to the following:
 
1. **User Responsibility**: You are responsible for ensuring that the DEB installer you obtained is from a legitimate source and that your usage complies with CodeBuddy's End User License Agreement (EULA) and related terms of service.
2. **No Warranty**: This tool is provided "AS IS" without any express or implied warranties, including but not limited to warranties of merchantability, fitness for a particular purpose, and non-infringement.
3. **No Official Support**: This project is an independent community project. Tencent does not provide any technical support. For issues encountered in the Linux porting environment, please file an Issue here. **Do not report to official customer service.**
4. **Use at Your Own Risk**: All consequences arising from using this tool for repackaging and running the application are borne solely by the user.
5. **Trademark Notice**: CodeBuddy and related logos are trademarks or registered trademarks of Tencent. Any use of these names in this project is for descriptive purposes only and does not imply any official endorsement or authorization.
6. **Takedown Policy**: If Tencent or any rights holder objects to this project, please contact the maintainer via a GitHub issue or email. The maintainer commits to immediately suspending maintenance, removing the AUR package, and processing the GitHub repository in accordance with the rights holder's reasonable request upon receipt of such objection.
7. **Project Purpose**: This project (including this GitHub repository and any related AUR/PKGBUILD automation scripts) is intended solely for technical research and proof-of-concept purposes. The original author has never distributed, and will never distribute, any official proprietary binary software.
8. **AUR Mechanism Clarification**: The related AUR package contains only text-based build scripts ("recipes"). All download, extraction, and repackaging processes are executed independently on the user's local machine. The build scripts fetch files directly from official or legally public URLs; this project does not host or store any copyrighted binary files.
9. **Third-Party Responsibility**: Any copyright disputes or legal liabilities arising from third-party forks, modifications, or the independent publication of pre-compiled binary installation packages (including GitHub Releases) shall be the sole responsibility of such third parties, and are entirely unrelated to the original author.
 
## License
 
This project (PKGBUILD, repackaging scripts and related recipes) is licensed under the MIT License; see [LICENSE](LICENSE). The MIT grant covers only the adaptation tooling in this repository and **does NOT extend to the Tencent CodeBuddy IDE binaries installed via this tool**, which remain subject to Tencent's proprietary terms.
