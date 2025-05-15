FROM ubuntu:24.04
LABEL author="liaokangning <lkangn.collin@gmail.com>"
LABEL describe="openvpn test env"

# 设置时区
ENV TZ=Asia/Shanghai
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# sh 修改为 bash, 默认为 dash
RUN rm /bin/sh && ln -s /bin/bash /bin/sh

# 修改下载源
RUN sed -i 's@//.*archive.ubuntu.com@//mirrors.ustc.edu.cn@g' /etc/apt/sources.list.d/ubuntu.sources; \
	sed -i 's/security.ubuntu.com/mirrors.ustc.edu.cn/g' /etc/apt/sources.list.d/ubuntu.sources;

RUN apt-get update && apt-get install ca-certificates --reinstall -y

# 使用 HTTPS 可以有效避免国内运营商的缓存劫持
RUN sed -i 's/http:/https:/g' /etc/apt/sources.list.d/ubuntu.sources

RUN apt-get update && apt-get install -y \
	openvpn \
	easy-rsa

# 证书生成
# 参考: https://blog.csdn.net/wfjdemmye/article/details/131486127
RUN mkdir /etc/openvpn/easy-rsa && \
	cd /etc/openvpn/easy-rsa && \
	cp -r /usr/share/easy-rsa/* /etc/openvpn/easy-rsa/ && \
	cp vars.example vars && \
	sed -i 'a export KEY_NAME="openvpn_server"' vars && \
	./easyrsa init-pki && \
	EASYRSA_BATCH=1 ./easyrsa build-ca nopass && \
	EASYRSA_BATCH=1 ./easyrsa build-server-full openvpn_server nopass && \
	EASYRSA_BATCH=1 ./easyrsa build-client-full openvpn_client nopass && \
	./easyrsa gen-dh
