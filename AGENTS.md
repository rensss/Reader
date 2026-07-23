# AGENTS.md

本文件是本仓库所有 AI agent(Claude Code、Codex、Cursor 等)的统一工作指南(单一事实来源)。CLAUDE.md 通过 `@AGENTS.md` 导入本文件,修改 agent 指南只改这里,不要两处分别维护。

## PROJECT_MEMORY(项目记忆体系)

跨会话的项目知识记录在 `PROJECT_MEMORY/` 目录,由 git 跟踪,所有 agent 共用。

| 文件 | 内容 | 何时写 |
| --- | --- | --- |
| `PROJECT_MEMORY/INDEX.md` | 索引 | 新增/删除记忆文件时同步 |
| `PROJECT_MEMORY/decisions.md` | 技术/架构决策及原因 | 做出影响后续开发的决策时 |
| `PROJECT_MEMORY/conventions.md` | 项目约定、勿改项 | 发现或确立新约定时 |
| `PROJECT_MEMORY/known-issues.md` | 已知问题、构建坑 | 踩坑并确认原因后 |
| `PROJECT_MEMORY/progress.md` | 进行中工作与待办 | 每次任务开始/结束时 |

使用规则:

1. **会话开始**:先读 `PROJECT_MEMORY/INDEX.md`,再按任务读相关主题文件。
2. **会话结束**:把本次产生的决策、新坑、进度回写到对应文件。
3. **条目格式**:`## YYYY-MM-DD 标题`,新条目放文件最上方,一条一事,写清"是什么 + 为什么"。
4. **不记**:git log、代码本身能直接回答的内容;过时条目直接删除或就地修正,不留废话。

## 项目概览

Reader 是一个纯 Objective-C 编写的 iOS 本地 TXT 小说阅读器,使用 CocoaPods 管理依赖。包含两个 target:

- **Reader** — 主应用
- **ReaderShare** — Share Extension,用于从其他应用接收 TXT 文件,通过 App Group(`group.smart.test`)与主应用共享数据

代码注释与 UI 文案均为中文。无测试 target,无 lint 配置。

## 常用命令

```bash
# 安装依赖(Pods/ 目录已提交入库,通常无需重装)
pod install

# 必须打开 workspace,而不是 xcodeproj
open Reader.xcworkspace

# 命令行构建(模拟器)
xcodebuild -workspace Reader.xcworkspace -scheme Reader -sdk iphonesimulator build
```

注意:`Reader/ThirdParty/iflyMSC.framework`(科大讯飞语音 SDK)为手动集成的二进制 framework,可能不支持部分模拟器架构;构建问题优先在真机 scheme 上验证。

## 架构

### 全局 PCH(关键)

`Reader/Supporting Files/PrefixHeader.pch` 全局导入所有 Pod 头文件、核心单例、Model 与基类,并定义:

- 屏幕/安全区宏(`kWindowWidth`、`kIS_IPHONEX`、`kStatusHight` 等)
- 通知名(`RKAutoReadNotification`、`RKHomeListRefresh`、3D Touch shortcut type)
- 持久化路径宏:`kBookSavePath`(Documents/Books,原始 TXT)、`kBookAnalysisPath`(Documents/BookAnalysis,解析后的章节 plist)、`kHomeBookListsPath`(Documents/BookLists.plist,首页书籍列表)

因此源文件里大多没有显式 import——新增全局可见的类或宏应加到 PCH。

### 数据层(无数据库,纯 plist 文件)

- **RKFileManager**(单例,注意:头文件叫 `RKFileManager.h`,实现文件叫 `RKFileManage.m`)— 书籍全生命周期:导入、编码识别(`encodeWithFilePath:`)、按正则拆章(`separateChapter:content:`)、增删改查,全部以 plist 写入 Documents
- **RKUserConfig**(单例)— 所有阅读设置(字号、边距、翻页模式、TTS 参数、密码等),每个属性直接读写 NSUserDefaults
- **Model**:`RKBook` / `RKChapter` 继承 `RKModel`(基于 MJExtension 做字典与模型互转);`RKBook` 同时承载阅读进度状态(currentChapterNum / currentPage)
- MMKV 虽在 Podfile 与 PCH 中,但业务代码实际持久化用的是 plist + NSUserDefaults

### 阅读流程(核心链路)

```
RKHomeListViewController(首页书架)
  └─ RKReadPageViewController(UIPageViewController 容器,持有 RKBook,管理翻页与菜单)
       └─ RKReadViewController(单页内容,持有 RKChapter + 页内容)
            └─ RKReadView(文字排版渲染)
```

- 菜单/目录以 View 形式叠加:`RKReadMenuView`(阅读菜单)、`RKTTSMenuView`(语音菜单)、`RKChaptersListView`(章节目录)
- 阅读设置页:`RKReadSettingViewController`、`RKFontSetttingViewController`(类名中 "Settting" 三个 t 为既有拼写,勿改)
- 分页依赖 `RKUserConfig` 中的屏幕尺寸与边距配置计算,改动排版参数需同步考虑重新分页

### 书籍导入的三条路径

1. **局域网导入**:`RKBookImprotViewController`(注意 "Improt" 为既有拼写)内置 GCDWebUploader,手机开 HTTP 服务供浏览器上传
2. **Share Extension**:`ReaderShare/ShareViewController` 把文件写入 App Group 容器,主应用在启动/回前台时经 `[RKFileManager checkShareImportBook]` 取回
3. **3D Touch / Quick Action**:AppDelegate 中注册 shortcut,经 NSNotificationCenter 分发

### TTS 双引擎

- `RKTTSManager` — 系统 AVSpeechSynthesizer
- `RKIFLYTTSManager` — 科大讯飞(iflyMSC.framework,appid 硬编码在 AppDelegate `initIFlySpeech`;离线资源在 `Reader/resource/aisound`)

### 加密书籍

`RKBook.isSecret` 标记加密书;`RKSecretViewController` 展示私密书架,解锁走 `RKTouchFaceIDUtil`(Face ID / Touch ID)或 `Utils/PinView/` 下的自绘数字密码键盘,密码明文存于 `RKUserConfig.pinString`。

### 页面间通信

大量使用 NSNotificationCenter(通知名集中定义在 PCH),修改跨页面行为时先搜通知名找到所有收发点。

## Git 约定

- 日常开发在 `dev` 分支,`master` 为主分支(PR 目标)
- `Pods/` 目录已提交;`Podfile.lock` 在 .gitignore 中(非常规做法,保持现状)
