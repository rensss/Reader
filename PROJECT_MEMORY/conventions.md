# 约定与勿改项

## 既有拼写(全仓引用一致,勿"修正",改名会破坏引用)
- 实现文件 `RKFileManage.m` 与头文件 `RKFileManager.h` 名字不一致
- 类名 `RKBookImprotViewController`("Improt")
- 类名 `RKFontSetttingViewController`("Settting" 三个 t)

## 代码风格
- 纯 Objective-C;注释、UI 文案、commit message 均为中文
- 属性注释用 `/**< 说明*/` 尾注格式
- 公共类/宏/通知名/路径集中定义在 `Reader/Supporting Files/PrefixHeader.pch`,源文件基本无显式 import;新增全局可见内容加 PCH
- 跨页面通信用 NSNotificationCenter,通知名定义在 PCH;改跨页面行为先全局搜通知名
- UI 布局用 Masonry(mas_makeConstraints),无 storyboard/xib(仅 Launch Screen)

## 工程约定
- App Group 名 `group.smart.test` 在主应用 PCH 与 ReaderShare/ShareViewController.m 两处以宏各自定义,改动需同步两处
- 开发在 dev 分支,master 收 PR
