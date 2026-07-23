# 已知问题与坑

## 2026-07-23 书签在重新解析章节后可能错位
- 书签定位存「章节 index + 章节内字符偏移」;「删除缓存」等触发重新拆章后,章节 index 可能变化,书签指向的章节会漂移
- 首版接受此限制(设计文档 docs/superpowers/specs/2026-07-23-bookmark-design.md 第 5 节),后续可改存全书绝对偏移解决

## 构建
- `iflyMSC.framework` 为手动集成二进制,可能不含部分模拟器架构;模拟器构建失败先换真机 scheme 验证,不要急着改工程配置
- 必须用 `Reader.xcworkspace` 打开/构建;直接用 xcodeproj 会缺 Pods

## 安全现状(历史遗留,改动前先与维护者确认)
- PIN 密码明文存 NSUserDefaults(`RKUserConfig.pinString`)
- 科大讯飞 appid 硬编码在 `AppDelegate initIFlySpeech`
- App Group 名为占位风格 `group.smart.test`

## 其他
- 仓库根目录的 `xiaoshuo.txt` 是测试用书籍样本,勿删
- `DerivedData/` 在 .gitignore 中但本地存在,勿提交
