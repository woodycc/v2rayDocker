#!/bin/bash
# FILE="/etc/Caddy"
domain="$1"
psname="$2"
uuid="51be9a06-299f-43b9-b713-1ec5eb76e3d7"
if  [ ! "$3" ] ;then
    uuid=$(uuidgen)
    echo "uuid 将会系统随机生成"
else
    uuid="$3"
fi
cat > /etc/caddy/Caddyfile <<'EOF'
domain
{
  log {
	output discard 
  }
  @ws {
	header Connection *Upgrade*
	header Upgrade websocket
  }
  reverse_proxy @ws localhost:2333
  root * /srv
  file_server
}

EOF
sed -i "s/domain/${domain}/" /etc/caddy/Caddyfile

# v2ray
cat > /etc/v2ray/config.json <<'EOF'
{
  "inbounds": [
    {
      "port": 2333,
      "protocol": "vmess",
      "settings": {
        "clients": [
          {
            "id": "uuid",
            "alterId": 64
          }
        ]
      },
      "streamSettings": {
        "network": "ws",
        "wsSettings": {
        "path": "/one"
        }
      }
    }
  ],
  "outbounds": [
    {
      "protocol": "freedom",
      "settings": {}
    }
  ]
}

EOF

sed -i "s/uuid/${uuid}/" /etc/v2ray/config.json

cat > /data/sebs.js <<'EOF'
 {
    "add":"domain",
    "aid":"0",
    "host":"",
    "id":"uuid",
    "net":"ws",
    "path":"/one",
    "port":"443",
    "ps":"sebsclub",
    "tls":"tls",
    "type":"none",
    "v":"2"
  }
EOF

if [ "$psname" != "" ] && [ "$psname" != "-c" ]; then
  sed -i "s/sebsclub/${psname}/" /data/sebs.js
  sed -i "s/domain/${domain}/" /data/sebs.js
  sed -i "s/uuid/${uuid}/" /data/sebs.js
else
  $*
fi
pwd
cp /etc/caddy/Caddyfile .
nohup /bin/parent caddy run &
echo "配置 JSON 详情"
echo " "
cat /etc/v2ray/config.json
echo " "
node v2ray.js
/usr/bin/v2ray -config /etc/v2ray/config.json
