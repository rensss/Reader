# 已知问题与坑

## 2026-07-23 书签在重新解析章节后可能错位
- 书签定位存「章节 index + 章节内字符偏移」;「删除缓存」等触发重新拆章后,章节 index 可能变化,书签指向的章节会漂移
- 首版接受此限制(设计文档 docs/superpowers/specs/2026-07-23-bookmark-design.md 第 5 节),后续可改存全书绝对偏移解决

## 构建
- `iflyMSC.framework` 为手动集成二进制(fat: i386/armv7/x86_64/arm64,arm64 为真机切片);arm64 模拟器链接必失败(`building for 'iOS-simulator', but linking in object file ... built for 'iOS'`)
- 模拟器可跑:加 `ARCHS=x86_64 ONLY_ACTIVE_ARCH=NO` 走 Rosetta,如 `xcodebuild -workspace Reader.xcworkspace -scheme Reader -sdk iphonesimulator -destination 'platform=iOS Simulator,id=<UDID>' ARCHS=x86_64 ONLY_ACTIVE_ARCH=NO build`,再 `simctl install/launch`(2026-07-24 在 iPhone Xs Max iOS 16.0 模拟器验证通过)
- 必须用 `Reader.xcworkspace` 打开/构建;直接用 xcodeproj 会缺 Pods

## 安全现状(历史遗留,改动前先与维护者确认)
- PIN 密码明文存 NSUserDefaults(`RKUserConfig.pinString`)
- 科大讯飞 appid 硬编码在 `AppDelegate initIFlySpeech`
- App Group 名为占位风格 `group.smart.test`

## 其他
- 仓库根目录的 `xiaoshuo.txt` 是测试用书籍样本,勿删
- `DerivedData/` 在 .gitignore 中但本地存在,勿提交
