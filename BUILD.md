# JSKeyborad iOS 项目

本文档描述如何在 GitHub Actions 上编译 JSKeyborad iOS 项目。

## 前置要求

### GitHub Secrets 配置

在仓库设置中添加以下 Secrets：

- `APPLE_CERTIFICATE`: Base64 编码的 .p12 证书文件
- `APPLE_CERTIFICATE_PASSWORD`: 证书密码
- `APPLE_PROVISION_PROFILE`: Base64 编码的 .mobileprovision 文件
- `APPLE_TEAM_ID`: Apple Developer Team ID
- `KEYCHAIN_PASSWORD`: 临时钥匙串密码（可以随机生成）

### 证书和配置文件准备

```bash
# 1. 导出 .p12 证书
# 在钥匙串访问中选择证书，右键导出

# 2. 编码为 Base64
openssl base64 -in certificate.p12 -out certificate_base64.txt

# 3. 获取 Provisioning Profile
# 从 Apple Developer 下载

# 4. 编码为 Base64
openssl base64 -in profile.mobileprovision -out profile_base64.txt
```

## 构建流程

### 自动构建

推送到 `main` 或 `develop` 分支会自动触发构建。

### 手动构建

```bash
# 1. 触发 workflow
git tag v1.0.0
git push origin v1.0.0
```

## 项目配置

### Bundle Identifier

- 主 App: `com.jskeyborad.app`
- 键盘扩展: `com.jskeyborad.app.keyboard`
- 小组件: `com.jskeyborad.app.widget`

### App Group

所有 target 共享同一个 App Group: `group.com.jskeyboard.app`

## 排查问题

### 构建失败

1. 检查 Xcode 版本是否匹配
2. 确认所有 Secrets 已正确配置
3. 查看 GitHub Actions 日志

### 签名问题

1. 确保证书和配置文件有效
2. 确认 Team ID 正确
3. 检查 Bundle Identifier 是否匹配

## 联系方式

如有问题，请提交 Issue。
