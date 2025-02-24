### 2.4.1
### Added
- [SDK] 增加跨端续播功能
- [SDK] 增加观看、播放时长等统计功能


# 注意：
## 旧版点播PLVVodSDK，升级到新版本点播PolyvMediaPlayerSDK，必须设置 单例PLVDownloadMediaManager 的 previousDownloadDir 属性，用于缓存视频的迁移
## 新版PolyvMediaPlayerSDK 下载功能的使用，必须调用setAccountID 方法，用于初始化设置
## 下载功能使用，具体参考DEMO中AppDelegate 的配置，和下载中心api 使用


### 2.4.0
### Added
-  [DEMO]  字幕功能 类名优化， 解决集成多场景sdk 的冲突
- [SDK] 下载管理类`PLVDownloadManager ` 更新为`PLVDownloadMediaManager `  解决集成多场景sdk 的冲突

# 注意：
## 旧版点播PLVVodSDK，升级到新版本点播PolyvMediaPlayerSDK，必须设置 单例PLVDownloadMediaManager 的 previousDownloadDir 属性，用于缓存视频的迁移
## 新版PolyvMediaPlayerSDK 下载功能的使用，必须调用setAccountID 方法，用于初始化设置
## 下载功能使用，具体参考DEMO中AppDelegate 的配置，和下载中心api 使用



### 2.3.1
### Added
- [DEMO] 新增防录屏，防截屏功能

# 注意：
## 旧版点播PLVVodSDK，升级到新版本点播PolyvMediaPlayerSDK，必须设置 单例PLVDownloadManager 的 previousDownloadDir 属性，用于缓存视频的迁移
## 新版PolyvMediaPlayerSDK 下载功能的使用，必须调用setAccountID 方法，用于初始化设置
## 下载功能使用，具体参考DEMO中AppDelegate 的配置，和下载中心api 使用

### 2.3.0
### Added
- [DEMO] 新增下载功能
- [SDK] 新增下载功能

# 注意：
## 旧版点播PLVVodSDK，升级到新版本点播PolyvMediaPlayerSDK，必须设置 单例PLVDownloadManager 的 previousDownloadDir 属性，用于缓存视频的迁移
## 新版PolyvMediaPlayerSDK 下载功能的使用，必须调用setAccountID 方法，用于初始化设置
## 下载功能使用，具体参考DEMO中AppDelegate 的配置，和下载中心api 使用

### 2.2.1
### Added
- [DEMO] 新增字幕功能
- [SDK] 新增字幕功能
### Fixed
- [SDK] 暂停状态 API连续截图失败修复


### 2.2.0
### Fixed
- [DEMO] 修复与其他项目集成可能导致的冲突问题
- [SDK] 修复与其他项目集成可能导致的冲突问题

### 2.1.3
### Added
- [DEMO] 新增续播提示

### Changed
- [DEMO] 系统小窗播放，添加自定义占位图
- [SDK] 续播保存逻辑优化（前后三秒删除记录）

### Fixed
- [DEMO] UI交互细节体验优化
- [SDK] Qos 上报优化
- [DEMO] 相关bug修复

### 2.1.2
### Added
- [DEMO] 播放器显示网络加载速度
### Changed
- [DEMO] 清晰度切换交互优化
- [DEMO] 播放器暂停模式时seek 速度慢优化
### Fixed
- [SDK] 小窗快进、快退按钮迅速点击播放暂停修复
- [SDK] 小窗模式返回播放器界面，恢复应用内播放
- [DEMO] 清晰度切换保持原倍速播放
- [DEMO] 已知问题修复

### 2.1.1
### Fixed

- 【SDK】音频、视频切换黑屏问题
- 【SDK】播放器、画中画播放状态同步优化
- 【DEMO】重播UI显示问题修复
- 【DEMO】seek 时，UI进度同步优化
- 其他问题修复

### 2.1.0
### Added 

- 长视频支持片头片尾播放
- 拖拽进度条支持缩略图预览
- 支持防盗录跑马灯
- 小窗支持快进快退
- 小窗支持退到后台自动启动

### Changed
- 相关 demo 代码优化
