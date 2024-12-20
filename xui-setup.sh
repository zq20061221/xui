#!/bin/bash

set -e

# 更新系统并安装必要组件
echo "更新系统并安装必要组件..."
apt update && apt install -y nginx curl jq

# 停止 Apache（如果存在）以避免端口冲突
if systemctl is-active --quiet apache2; then
  echo "检测到 Apache，停止并禁用 Apache 服务..."
  systemctl stop apache2
  systemctl disable apache2
fi

# 设置站点目录
WEB_DIR="/var/www/xui-query"
mkdir -p "$WEB_DIR"

# 部署 XUI 前端页面
echo "部署前端页面..."
cat > "$WEB_DIR/index.html" <<EOF
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>XUI 流量查询</title>
  <style>
    body { font-family: Arial, sans-serif; text-align: center; margin: 20px; }
    h1 { color: #007bff; }
  </style>
</head>
<body>
  <h1>隐姓埋名 流量查询页面</h1>
  <p>欢迎访问流量查询系统，请配置后使用。</p>
</body>
</html>
EOF

# 配置 Nginx
echo "配置 Nginx..."
cat > /etc/nginx/sites-available/xui-query <<EOF
server {
    listen 80;
    server_name 103.30.79.49;

    root $WEB_DIR;
    index index.html;

    location / {
        try_files \$uri \$uri/ =404;
    }
}
EOF

ln -sf /etc/nginx/sites-available/xui-query /etc/nginx/sites-enabled/
systemctl restart nginx

# 启动 Nginx
echo "重启 Nginx 服务..."
systemctl enable nginx
systemctl restart nginx

echo "部署完成！请访问 http://103.30.79.49 查看 XUI 查询页面。"
