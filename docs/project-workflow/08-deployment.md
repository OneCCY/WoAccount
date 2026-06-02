# 08 - 部署与发布文档 (Technical Specification)

> **版本**: v3.0 | **更新日期**: 2026-06-02 | **状态**: 已更新为本地优先方案

---

## 8.1 构建流程

### 8.1.1 流程图

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                              构建流程                                         │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  代码提交 ──▶ GitHub ──▶ GitHub Actions                                     │
│                              │                                              │
│                    ┌─────────┼─────────┐                                    │
│                    ▼         ▼         ▼                                    │
│               ┌────────┐ ┌────────┐ ┌────────┐                             │
│               │  Lint  │ │  Test  │ │ Build  │                             │
│               │  检查  │ │  测试  │ │  构建  │                             │
│               └────┬───┘ └────┬───┘ └────┬───┘                             │
│                    │         │         │                                    │
│                    ▼         ▼         ▼                                    │
│               ┌─────────────────────────────────────┐                      │
│               │           产物                       │                      │
│               │  ├─ Android APK (直接安装)           │                      │
│               │  └─ iOS IPA (TestFlight/自签)        │                      │
│               └─────────────────────────────────────┘                      │
│                                                                             │
│  当前阶段为个人自用，暂不提交应用商店                                         │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 8.1.2 GitHub Actions 配置

```yaml
# .github/workflows/ci.yml

name: CI Pipeline

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

env:
  FLUTTER_VERSION: '3.19.0'

jobs:
  # 代码检查
  lint:
    name: Lint & Analyze
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: ${{ env.FLUTTER_VERSION }}
          cache: true

      - name: Install dependencies
        run: flutter pub get

      - name: Analyze code
        run: flutter analyze --fatal-infos

      - name: Check formatting
        run: dart format --set-exit-if-changed .

  # 单元测试
  test:
    name: Unit Tests
    runs-on: ubuntu-latest
    needs: lint
    steps:
      - uses: actions/checkout@v4

      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: ${{ env.FLUTTER_VERSION }}
          cache: true

      - name: Install dependencies
        run: flutter pub get

      - name: Run tests
        run: flutter test --coverage

  # 构建Android
  build-android:
    name: Build Android
    runs-on: ubuntu-latest
    needs: test
    if: github.ref == 'refs/heads/main'
    steps:
      - uses: actions/checkout@v4

      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: ${{ env.FLUTTER_VERSION }}
          cache: true

      - name: Setup Java
        uses: actions/setup-java@v4
        with:
          distribution: 'zulu'
          java-version: '17'

      - name: Install dependencies
        run: flutter pub get

      - name: Build APK
        run: flutter build apk --release --dart-define=AI_API_KEY=${{ secrets.AI_API_KEY }}

      - name: Upload artifact
        uses: actions/upload-artifact@v4
        with:
          name: android-release
          path: build/app/outputs/flutter-apk/app-release.apk
```

---

## 8.2 应用签名配置

### 8.2.1 Android 签名

```bash
# 生成密钥库
keytool -genkey -v \
  -keystore ~/wo-account-key.jks \
  -keyalg RSA \
  -keysize 2048 \
  -validity 10000 \
  -alias wo-account

# 配置 key.properties
# android/key.properties
storePassword=<password>
keyPassword=<password>
keyAlias=wo-account
storeFile=<path>/wo-account-key.jks
```

```groovy
// android/app/build.gradle

def keystoreProperties = new Properties()
def keystorePropertiesFile = rootProject.file('key.properties')
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
}

android {
    compileSdkVersion 34
    
    defaultConfig {
        applicationId "com.woaccount.app"
        minSdkVersion 21
        targetSdkVersion 34
        versionCode 1
        versionName "1.0.0"
    }
    
    signingConfigs {
        release {
            keyAlias keystoreProperties['keyAlias']
            keyPassword keystoreProperties['keyPassword']
            storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
            storePassword keystoreProperties['storePassword']
        }
    }
    
    buildTypes {
        release {
            signingConfig signingConfigs.release
            minifyEnabled true
            shrinkResources true
            proguardFiles getDefaultProguardFile('proguard-android-optimize.txt'), 'proguard-rules.pro'
        }
    }
}
```

### 8.2.2 iOS 签名

```xml
<!-- ios/Runner/Info.plist -->
<key>CFBundleDisplayName</key>
<string>WoAccount</string>
<key>CFBundleIdentifier</key>
<string>com.woaccount.app</string>
<key>CFBundleVersion</key>
<string>1</string>
<key>CFBundleShortVersionString</key>
<string>1.0.0</string>
```

---

## 8.3 应用商店发布

### 8.3.1 Google Play 发布

**准备清单**:

| 项目 | 规格 | 状态 |
|------|------|------|
| 应用图标 | 512x512 PNG | 待准备 |
| 功能图片 | 1024x500 PNG | 待准备 |
| 截图 | 至少2张，手机+平板 | 待准备 |
| 简短描述 | 80字符以内 | 待准备 |
| 完整描述 | 4000字符以内 | 待准备 |
| 隐私政策URL | 有效链接 | 待准备 |
| 内容分级 | 填写问卷 | 待准备 |
| 目标受众 | 设置年龄范围 | 待准备 |

**发布流程**:

```bash
# 1. 构建AAB
flutter build appbundle --release

# 2. 上传到Google Play Console
# https://play.google.com/console

# 3. 填写应用信息
# 4. 提交审核
# 5. 等待审核通过 (通常1-3天)
```

### 8.3.2 App Store 发布

**准备清单**:

| 项目 | 规格 | 状态 |
|------|------|------|
| App图标 | 1024x1024 PNG | 待准备 |
| 截图 | 6.5寸、5.5寸、iPad | 待准备 |
| App预览视频 | 可选 | 待准备 |
| 描述 | 4000字符以内 | 待准备 |
| 关键词 | 100字符以内 | 待准备 |
| 隐私政策URL | 有效链接 | 待准备 |
| 年龄分级 | 填写问卷 | 待准备 |

**发布流程**:

```bash
# 1. 构建iOS
flutter build ios --release

# 2. 在Xcode中Archive
# Xcode → Product → Archive

# 3. 上传到App Store Connect
# Window → Organizer → Upload to App Store

# 4. 填写应用信息
# https://appstoreconnect.apple.com

# 5. 提交审核
# 6. 等待审核通过 (通常1-3天)
```

---

## 8.4 应用商店优化 (ASO)

### 8.4.1 关键词策略

| 类型 | 关键词 | 搜索量 | 竞争度 |
|------|--------|--------|--------|
| 核心词 | 记账 | 高 | 高 |
| 核心词 | 记账本 | 高 | 高 |
| 长尾词 | 智能记账 | 中 | 低 |
| 长尾词 | AI记账 | 低 | 低 |
| 长尾词 | 自动分类记账 | 低 | 低 |
| 场景词 | 日常记账 | 中 | 中 |
| 场景词 | 生活记账 | 中 | 中 |
| 场景词 | 花钱记账 | 中 | 低 |

### 8.4.2 应用描述模板

```
【WoAccount - AI智能记账】

还在为记账选择分类而烦恼吗？

WoAccount 让记账变得前所未有的简单：
只需输入一句话，AI自动帮你分类！

✨ 核心功能
• 智能记账：输入"午饭拉面25"，AI自动识别金额和分类
• 零分类操作：再也不用手动选择分类
• AI助手：问"我上周花了多少钱"，AI帮你查
• 消费洞察：AI主动发现你的消费规律
• 清晰统计：一目了然的消费图表

📱 适用人群
• 想记账但嫌麻烦的你
• 追求效率的年轻人
• 喜欢简洁工具的用户

🔒 数据安全
• 本地优先存储
• 数据加密保护
• 隐私安全有保障

立即下载，开启智能记账新体验！

---

【English】

Tired of choosing categories when tracking expenses?

WoAccount makes expense tracking incredibly simple:
Just type a sentence, AI categorizes it automatically!

✨ Core Features
• Smart Input: Type "lunch noodles 25", AI detects amount & category
• Zero Classification: No need to select categories manually
• AI Assistant: Ask "how much did I spend last week?"
• Spending Insights: AI discovers your spending patterns
• Clear Statistics: Visual charts at a glance

📱 Perfect For
• People who want to track expenses but find it tedious
• Young professionals who value efficiency
• Users who prefer simple tools

🔒 Data Security
• Local-first storage
• Encrypted data protection
• Privacy guaranteed

Download now and start smart expense tracking!
```

---

## 8.5 质量保障

当前阶段无 Firebase 监控，通过以下方式保障质量：

### 8.5.1 错误处理

```dart
// lib/main.dart

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 全局错误捕获
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    // 本地日志记录
    _logError(details.exception, details.stack);
  };

  runApp(MyApp());
}
```

### 8.5.2 关键指标

| 指标 | 目标 | 验证方式 |
|------|------|----------|
| 崩溃率 | < 1% | 真机手动测试 |
| AI准确率 | > 90% | 内置训练数据表统计 |
| 记账响应时间 | < 2s | 性能测试 |
| 启动时间 | < 2s | 性能测试 |

---

## 8.6 版本管理

### 8.6.1 版本号规范

```
主版本号.次版本号.修订号+构建号
  1.0.0+1

主版本号: 重大功能更新或架构变更
次版本号: 新功能添加
修订号: Bug修复和小优化
构建号: 每次构建递增
```

### 8.6.2 版本发布流程

```
1. 创建release分支
   git checkout -b release/1.0.0

2. 更新版本号
   - pubspec.yaml: version: 1.0.0+1
   - Android: versionCode, versionName
   - iOS: CFBundleVersion, CFBundleShortVersionString

3. 测试验证
   - 运行所有测试
   - 真机测试
   - 性能测试

4. 合并到main
   git checkout main
   git merge release/1.0.0

5. 打Tag
   git tag -a v1.0.0 -m "Release v1.0.0"
   git push origin v1.0.0

6. 构建发布版本
   flutter build appbundle --release
   flutter build ios --release

7. 提交商店审核
   - Google Play Console
   - App Store Connect

8. 合并到develop
   git checkout develop
   git merge release/1.0.0

9. 删除release分支
   git branch -d release/1.0.0
```

---

## 8.7 回滚策略

### 8.7.1 回滚触发条件

| 条件 | 阈值 | 操作 |
|------|------|------|
| 崩溃率 | > 5% | 立即回滚 |
| 严重Bug | P0级别 | 评估后回滚 |
| 用户投诉 | 大量 | 评估后回滚 |
| 数据丢失 | 任何 | 立即回滚 |

### 8.7.2 回滚流程

**Google Play**:
1. 在Google Play Console选择"停止发布"
2. 回退到上一个稳定版本
3. 发布修复版本

**App Store**:
1. 在App Store Connect选择"移除版本"
2. 提交修复版本加急审核
3. 联系Apple支持加急审核

---

## 8.8 发布检查清单

### 8.8.1 发布前检查

- [ ] 所有测试通过
- [ ] 代码审查完成
- [ ] 版本号更新
- [ ] 更新日志编写
- [ ] 截图和描述更新
- [ ] 隐私政策更新
- [ ] 性能测试通过
- [ ] 真机测试通过
- [ ] 安全审计通过
- [ ] 数据库迁移测试

### 8.8.2 发布后检查

- [ ] 商店审核通过
- [ ] 应用可正常下载
- [ ] 崩溃监控正常
- [ ] 用户反馈监控
- [ ] 关键指标正常
- [ ] 服务器负载正常
