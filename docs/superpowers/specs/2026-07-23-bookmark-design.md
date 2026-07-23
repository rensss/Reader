# 书签功能设计(2026-07-23)

## 需求

阅读页下拉手势添加/移除书签(仿微信读书 toggle);章节目录侧滑视图内加「目录 / 书签」分段,书签列表支持跳转与左滑删除。

决策记录:

- 交互:下拉超过阈值松手 toggle(无书签则加、已有则移除),页面右上角角标标记当前页已收藏
- 入口:书签列表放 `RKChaptersListView` 分段,不加独立菜单按钮
- 定位:存「章节 index + 章节内字符偏移」,跳转时按当前分页换算页码,改字号/行距不漂移
- 上下翻页模式(`navigationOrientation` 为 Vertical):不注册下拉手势,书签仍可在列表查看/跳转/删除

## 1. 数据模型与持久化

- 新建 `Models/RKBookmark.h/m`,继承 `RKModel`:
  - `chapterNum`(NSInteger,章节 index)
  - `location`(NSInteger,章节内字符偏移,取当页起始偏移 `pageArray[page]`)
  - `summary`(NSString,当页开头约 40 字,去换行,列表展示)
  - `createDate`(NSTimeInterval)
- `RKBook` 加 `NSMutableArray *bookmarks`;`RKBook.m` 加 `mj_objectClassInArray` 返回 `@{@"bookmarks": @"RKBookmark"}`(plist 字典读回转模型必需)
- `RKBookmark.h` 加入 `PrefixHeader.pch`(项目惯例:Model 全局导入)
- 落盘:`getAllBookList` → 按 bookID 找到书 → 赋 `bookmarks` → `saveBookList`;与 `updateLocalBookData` 同构。BookLists.plist 已剔除 content/chapters,书签字典体积小,直接随存

## 2. 下拉手势 + 角标(RKReadPageViewController)

- 仅 `[RKUserConfig sharedInstance].navigationOrientation == UIPageViewControllerNavigationOrientationHorizontal` 时给 `self.view` 加 `UIPanGestureRecognizer`
- 手势仲裁:delegate 判定起始位移竖直分量占优才 begin;横向翻页不受影响;`isShowMenu` / `isShowList` 时不响应
- 交互:下拉时 `pageViewController.view` 跟随下移(阻尼,上限约 120pt),顶部露出提示条:
  - 未过阈值(60pt):「下拉添加书签」;过阈值:「松手添加书签」;当前页已有书签则文案换为移除
  - 松手过阈值执行 toggle,回弹动画复位
- 角标:当前页已有书签 → 页面右上角书签 ribbon(CAShapeLayer 贝塞尔绘制,不加图片资源)
  - `RKReadViewController` 加 `isBookmarked` 属性,容器 `viewControllerChapter:andPage:` 计算后传入,翻页自然带出;toggle 后就地更新当前页角标
- 「当前页已有书签」判定:存在 bookmark 满足 `chapterNum == 当前章` 且 `location ∈ [pageArray[page], 下页起始偏移)`;添加限一条(该页已有即视为已收藏);移除删该页区间内全部书签

## 3. 书签列表(RKChaptersListView 改造)

- tableView 上方加「目录 / 书签」分段控件,切换刷新数据源
- 书签行:章节名 + 摘要 + 日期,新建 `RKBookmarkListCell`;左滑删除,删除即落盘;若删的是当前页书签,目录关闭后容器刷新角标
- 新增回调 `didSelectBookmark:`(回传选中 RKBookmark);现有 `didSelectChapter:` 不动
- 书签为空:占位文案「暂无书签,阅读页下拉即可添加」

## 4. 跳转

- `RKChapter` 加 `- (NSInteger)pageOfLocation:(NSInteger)location`:pageArray 中最后一个 `offset <= location` 的 index
- 容器收到 `didSelectBookmark:`:先 `getPageContentWithChapter:` 该章(触发 setContent → 分页),再 `pageOfLocation:` 换算页码,`setViewControllers` 跳转 + `updateLocalBookData`

## 5. 边界与验证

- 上下翻页模式:无手势,列表照常
- 「删除缓存」重新解析章节后章节 index 可能变化,书签或错位——首版接受,记入 known-issues
- 落盘沿用现有 fetch-modify-write 模式(并发窗口与 `updateLocalBookData` 现状一致,不另起炉灶)
- 无测试 target,人工验证清单:
  - [ ] 下拉添加书签,角标出现
  - [ ] 已有书签页下拉移除,角标消失
  - [ ] 翻页后角标随页正确显隐
  - [ ] 目录书签 tab 列表展示、点击跳转
  - [ ] 左滑删除书签,当前页书签删除后角标刷新
  - [ ] 改字号/行距后书签跳转仍指向原文位置
  - [ ] 上下翻页模式无下拉手势,列表功能正常
  - [ ] 杀 app 重进,书签仍在
