# 进行中与待办

## 2026-07-23 书签功能完成(2026-07-24 真机人工验证通过)
- 阅读页下拉超 60pt 松手 toggle 书签(仅左右翻页模式),右上角红 ribbon 角标;目录侧滑加「目录/书签」分段,支持跳转与左滑删除
- 定位存「章节 index + 章节内字符偏移」,改字号/行距不漂移;持久化挂 `RKBook.bookmarks` 随 BookLists.plist
- commits bb9ef9a / 73571ae / 5993b5b / 8e37dc2;设计 docs/superpowers/specs/2026-07-23-bookmark-design.md,计划 docs/superpowers/plans/2026-07-23-bookmark.md(含人工验证清单,Task 5)
- 已知限制:重新解析章节后书签可能错位,见 known-issues.md

## 2026-07-23 建立 agent 文档与项目记忆体系
- 新增 AGENTS.md(单一事实来源)+ PROJECT_MEMORY/ 体系;CLAUDE.md 改为 `@AGENTS.md` 导入指针
- 当前分支 dev,工作树此前干净;最近功能 commit:300eb59「update 详情页面章节列表逻辑」

## 待办(源自 README)
- [x] 书签(2026-07-23 完成)
- [ ] 搜索查找功能
- [ ] Home Screen Quick Actions 快捷进入
- [ ] 复制
- [ ] 收藏
- [ ] 标注
- [ ] 日志
- [ ] widget(待定)
