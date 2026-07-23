# 技术决策

条目格式:`## YYYY-MM-DD 标题`,新条目放最上,写清决策 + 原因。

## 2026-07-23 文档体系:AGENTS.md 为单一事实来源
CLAUDE.md 仅保留 `@AGENTS.md` 导入指针,避免两份指南漂移。改 agent 指南只改 AGENTS.md;项目记忆写 PROJECT_MEMORY/,不写进指南正文。

## 历史决策(从既有代码归纳,时间为 2019–2023)
- 持久化选 plist + NSUserDefaults,不用数据库;MMKV 已引入(Podfile + PCH)但业务代码未实际使用
- TTS 双引擎并存:系统 AVSpeechSynthesizer(RKTTSManager)+ 科大讯飞 iflyMSC 手动集成(RKIFLYTTSManager),由 RKUserConfig.engineType 切换
- 公共依赖与宏全部走 PrefixHeader.pch 全局导入,源文件不写显式 import
- Pods/ 目录提交入库,Podfile.lock 被 .gitignore 忽略(非常规组合,维持现状,不要"修复")
