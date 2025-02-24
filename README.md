polyv-ios-media-player-sdk-demo
===
[![build passing](https://img.shields.io/badge/build-passing-brightgreen.svg)](#)
[![GitHub release](https://img.shields.io/badge/release-v2.0.0-blue.svg)](https://github.com/polyv/polyv-ios-media-player-sdk-demo/releases/tag/v2.2.0)

- [polyv-ios-media-player-sdk-demo](#)
	- [1 简介](#1-简介)
	- [2 文档](#2-%E6%96%87%E6%A1%A3)
  		- [2.1 集成文档](#21-%E9%9B%86%E6%88%90%E6%96%87%E6%A1%A3)
  		- [2.2 接口文档](#22-%E6%8E%A5%E5%8F%A3%E6%96%87%E6%A1%A3)
  		- [2.3 版本更新记录](#23-%E7%89%88%E6%9C%AC%E6%9B%B4%E6%96%B0%E8%AE%B0%E5%BD%95)

### 1 简介
此项目是保利威 iOS 播放器 SDK Demo。

此项目只支持最基础的播放功能，如果您有额外的业务功能需求，应根据需要选择对应的 SDK：
1. 如果您需要直播相关的连麦、互动、聊天室等功能，您应当接入 [多场景SDK](https://github.com/polyv/polyv-ios-livescenes-sdk-demo)
2. 如果您需要点播相关的下载、上传等功能，您应当接入 [点播SDK](https://github.com/polyv/polyv-ios-vod-sdk)

播放器项目的文件目录结构如下：

```
| -- PolyvVodScenes
	| -- Common（通用工具类、UI组件）
	| -- Modules （播放器皮肤UI组件、画中画控制)
	| -- Resource  (播放器皮肤资源)
	| -- Scenes
		| -- VodSence （长视频场景）
		| -- FeedScene  (Feed 流场景)
		
```

### 2 文档
#### 2.1 集成文档
[集成文档](./docs/public)

#### 2.2 接口文档
[v2.4.1 接口文档](https://repo.polyv.net/ios/documents/mediaplayersdk/2.4.1-250224/index.html)

#### 2.3 版本更新记录
[全版本更新记录](./CHANGELOG.md)


