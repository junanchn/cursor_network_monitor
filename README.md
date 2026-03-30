# cursor-network-monitor

Cursor API 实时网络监测工具，使用 HTTP/2 双向流式端点持续测量请求往返延迟。

## 安装

```bash
pip install httpx[http2]
```

## 使用

```bash
cursor_network_monitor
```

## 参数

| 参数 | 说明 |
|------|------|
| `-q` | 安静模式，只显示超时和错误 |
| `-v` | 详细模式，逐行显示延迟时间 |
| `-n N` | 测试 N 次后停止 |
| `-t MS` | 延迟超过 MS 毫秒时警告 |

## 示例

```bash
# 持续监测，实时显示
cursor_network_monitor

# 持续监测，超过 500ms 警告
cursor_network_monitor -t 500
```

## 输出

```
Cursor 网络监测
目标: https://api2.cursor.sh/aiserver.v1.HealthService/StreamBidi
Ctrl+C 停止

[12:00:00.000] 连接中...
[12:00:00.500] 已连接
[12:00:00.850] 350ms
```

## 参考

- [Cursor 网络配置文档](https://cursor.com/cn/docs/enterprise/network-configuration)
