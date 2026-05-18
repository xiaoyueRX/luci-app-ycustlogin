# luci-app-ycustlogin

银川科技学院（YCUST）校园网 Dr.COM 自动认证插件，适用于 OpenWrt / ImmortalWrt。

## 支持的系统

- **认证系统**: Dr.COM 宽带认证（ePortal 4.x / 6.x）
- **认证方式**: HTTP GET 明文协议（非 802.1X，非 WebVPN）
- **通用性**: 理论上支持所有使用相同 Dr.COM HTTP 协议的高校，只需修改认证服务器 IP 和登录参数

### 已知适用高校

| 学校 | 认证服务器 | 备注 |
|------|-----------|------|
| 银川科技学院 | `10.10.10.3` | 已测试 |

> 如果你的学校也使用 Dr.COM HTTP 明文认证，修改 `/usr/bin/ycust_autologin.sh` 中的 `LOGIN_URL` 即可适配。

## 安装

### 方式一：ipk 安装包

在 OpenWrt SDK 中编译：

```bash
# 将 luci-app-ycustlogin 放入 package/ 目录
make package/luci-app-ycustlogin/compile V=s
```

生成的 ipk 位于 `bin/packages/`，上传到路由器后：

```bash
opkg install luci-app-ycustlogin_*.ipk
```

### 方式二：手动安装

```bash
# 复制文件到对应路径
cp ycust_autologin.sh /usr/bin/
cp ycustlogin.lua /usr/lib/lua/luci/model/cbi/
cp luci-app-ycustlogin.json /usr/share/luci/menu.d/
cp ycustlogin /etc/init.d/
cp ycustlogin /etc/config/
chmod +x /usr/bin/ycust_autologin.sh /etc/init.d/ycustlogin
```

## 使用方法

1. 浏览器打开路由器后台 → **服务 → 校园网认证**
2. 填入认证账号和密码
3. 启用并保存
4. 插件会自动检测校园网状态，掉线后 30 秒内自动重连

## 工作原理

每 30 秒向 Dr.COM 认证服务器发送登录请求：

- `error5` → 已在线，静默
- `result:1` → 登录成功
- `result:0` → 认证失败
- 超时/无响应 → Portal 不可达，记录警告

## 目录结构

```
luci-app-ycustlogin/
├── Makefile                          # OpenWrt 编译文件
├── luasrc/model/cbi/ycustlogin.lua   # LuCI 设置页面
└── root/
    ├── etc/
    │   ├── config/ycustlogin          # 默认配置模板
    │   └── init.d/ycustlogin          # procd 启动脚本
    └── usr/
        ├── bin/ycust_autologin.sh     # 核心认证守护脚本
        └── share/luci/menu.d/         # 菜单注册
            luci-app-ycustlogin.json
```
