<h1 align="center">
  <img src="https://github.com/Dreamacro/clash/raw/master/docs/logo.png" alt="Clash" width="200">
  <br>
  ClashX
  <br>
</h1>


A rule based proxy For Mac base on [Clash](https://github.com/Dreamacro/clash).



## Features

- HTTP/HTTPS and SOCKS protocol
- Surge like configuration
- GeoIP rule support
- Support Vmess/Shadowsocks/Socks5
- Support for Netfilter TCP redirect


## Install

You can download from [release](https://github.com/yichengchen/clashX/releases) page

## Config

**NOTE: clashX current using yaml as configuration file**

The default configuration directory is `$HOME/.config/clash`

The name of the configuration file is `config.yml`,You can use config generator in Status Bar Menu "Config" section.

Below is a simple demo configuration file,Checking [Github for Clash](https://github.com/Dreamacro/clash) or [SS-Rule-Snippet for Clash](https://github.com/Hackl0us/SS-Rule-Snippet/blob/master/LAZY_RULES/clash.yml) for more detail.


```yml
# port of HTTP
port: 7890

# port of SOCKS5
socks-port: 7891

# redir port for Linux and macOS
# redir-port: 7892

allow-lan: false

# Rule / Global/ Direct (default is Rule)
mode: Rule

# set log level to stdout (default is info)
# info / warning / error / debug
log-level: info

# A RESTful API for clash
external-controller: 127.0.0.1:9090

# Secret for RESTful API (Optional)
# secret: ""

Proxy:

# shadowsocks
# The types of cipher are consistent with go-shadowsocks2
# support AEAD_AES_128_GCM AEAD_AES_192_GCM AEAD_AES_256_GCM AEAD_CHACHA20_POLY1305 AES-128-CTR AES-192-CTR AES-256-CTR AES-128-CFB AES-192-CFB AES-256-CFB CHACHA20-IETF XCHACHA20
# In addition to what go-shadowsocks2 supports, it also supports chacha20 rc4-md5 xchacha20-ietf-poly1305
- { name: "ss1", type: ss, server: server, port: 443, cipher: AEAD_CHACHA20_POLY1305, password: "password" }
- { name: "ss2", type: ss, server: server, port: 443, cipher: AEAD_CHACHA20_POLY1305, password: "password", obfs: tls, obfs-host: bing.com }

# vmess
# cipher support auto/aes-128-gcm/chacha20-poly1305/none
- { name: "vmess", type: vmess, server: server, port: 443, uuid: uuid, alterId: 32, cipher: auto }
# with tls
- { name: "vmess", type: vmess, server: server, port: 443, uuid: uuid, alterId: 32, cipher: auto, tls: true }
# with tls and skip-cert-verify
- { name: "vmess", type: vmess, server: server, port: 443, uuid: uuid, alterId: 32, cipher: auto, tls: true, skip-cert-verify: true }
# with ws
- { name: "vmess", type: vmess, server: server, port: 443, uuid: uuid, alterId: 32, cipher: auto, network: ws, ws-path: /path }
# with ws + tls
- { name: "vmess", type: vmess, server: server, port: 443, uuid: uuid, alterId: 32, cipher: auto, network: ws, ws-path: /path, tls: true }

# socks5
- { name: "socks", type: socks5, server: server, port: 443 }
# with tls
- { name: "socks", type: socks5, server: server, port: 443, tls: true }
# with tls and skip-cert-verify
- { name: "socks", type: socks5, server: server, port: 443, tls: true, skip-cert-verify: true }

Proxy Group:
# url-test select which proxy will be used by benchmarking speed to a URL.
- { name: "auto", type: url-test, proxies: ["ss1", "ss2", "vmess1"], url: "http://www.gstatic.com/generate_204", interval: 300 }

# fallback select an available policy by priority. The availability is tested by accessing an URL, just like an auto url-test group.
- { name: "fallback-auto", type: fallback, proxies: ["ss1", "ss2", "vmess1"], url: "http://www.gstatic.com/generate_204", interval: 300 }

# select is used for selecting proxy or proxy group
# you can use RESTful API to switch proxy, is recommended for use in GUI.
- { name: "Proxy", type: select, proxies: ["ss1", "ss2", "vmess1", "auto"] }

Rule:
- DOMAIN-SUFFIX,google.com,Proxy
- DOMAIN-KEYWORD,google,Proxy
- DOMAIN,google.com,Proxy
- DOMAIN-SUFFIX,ad.com,REJECT
- IP-CIDR,127.0.0.0/8,DIRECT
- GEOIP,CN,DIRECT
# note: there is two ","
- MATCH,Proxy
```

