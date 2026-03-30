@start "" /b python -x "%~f0" %* & exit /b
"""Cursor 网络监测"""

import httpx
import time
import argparse
from datetime import datetime

URL = "https://api2.cursor.sh/aiserver.v1.HealthService/StreamBidi"
TIMEOUT = 5
RECONNECT_INTERVAL = 240


def timestamp():
    return datetime.now().strftime("%H:%M:%S.%f")[:-3]


def build_frame(payload: str) -> bytes:
    data = payload.encode('utf-8')
    return bytes([0, 0, 0, 0, len(data)]) + data


def main():
    parser = argparse.ArgumentParser(description="Cursor 网络监测")
    parser.add_argument("-q", "--quiet", action="store_true", help="安静模式，只显示超时和错误")
    parser.add_argument("-v", "--verbose", action="store_true", help="详细模式，逐行显示延迟时间")
    parser.add_argument("-n", "--count", type=int, default=0, help="次数(0=无限)")
    parser.add_argument("-t", "--threshold", type=int, default=1000, help="延迟阈值(默认1000ms)")
    args = parser.parse_args()

    print("Cursor 网络监测")
    print(f"目标: {URL}")
    print("Ctrl+C 停止")

    client = None
    success = 0
    fails = 0
    connect_time = 0
    first_connect = True

    frame = build_frame('{"payload":"ping"}')

    print(f"\n[{timestamp()}] 连接中...")

    try:
        while args.count == 0 or success < args.count:
            # 定期重连
            if client and time.time() - connect_time >= RECONNECT_INTERVAL:
                try:
                    client.close()
                except Exception:
                    pass
                client = None

            # 需要连接
            if not client:
                try:
                    client = httpx.Client(http2=True)
                    client.post(URL, content=frame, headers={"Content-Type": "application/connect+json"}, timeout=TIMEOUT)
                    connect_time = time.time()
                    if first_connect:
                        print(f"[{timestamp()}] 已连接")
                        first_connect = False
                except Exception as e:
                    fails += 1
                    print(f"[{timestamp()}] 连接失败: {e}")
                    time.sleep(1)
                    continue

            # 发送ping
            try:
                start = time.time()
                response = client.post(URL, content=frame, headers={"Content-Type": "application/connect+json"}, timeout=TIMEOUT)
                latency = int((time.time() - start) * 1000)

                if response.status_code == 200:
                    success += 1
                    if args.threshold and latency > args.threshold:
                        print(f"\r[{timestamp()}] {latency}ms (>{args.threshold}ms)")
                    elif args.quiet:
                        pass
                    elif args.verbose:
                        print(f"[{timestamp()}] {latency}ms")
                    else:
                        print(f"\r[{timestamp()}] {latency}ms", end="", flush=True)
                else:
                    fails += 1
                    print(f"\n[{timestamp()}] HTTP {response.status_code}")

            except Exception as e:
                fails += 1
                print(f"\n[{timestamp()}] 连接断开: {e}")
                try:
                    client.close()
                except Exception:
                    pass
                client = None
                first_connect = True

    except KeyboardInterrupt:
        if client:
            try:
                client.close()
            except Exception:
                pass
        print(f"\n停止 | 成功: {success} | 失败: {fails}")


if __name__ == "__main__":
    main()
