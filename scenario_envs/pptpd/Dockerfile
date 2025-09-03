FROM ubuntu:22.04
LABEL author="liaokangning <lkangn.collin@gmail.com>"

# 设置时区
ENV TZ=Asia/Shanghai
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# sh 修改为 bash, 默认为 dash
RUN rm /bin/sh && ln -s /bin/bash /bin/sh

# 修改下载源
RUN sed -i 's@//.*archive.ubuntu.com@//mirrors.ustc.edu.cn@g' /etc/apt/sources.list; \
	sed -i 's/security.ubuntu.com/mirrors.ustc.edu.cn/g' /etc/apt/sources.list

RUN apt-get update && apt-get install ca-certificates --reinstall -y

# 使用 HTTPS 可以有效避免国内运营商的缓存劫持
RUN sed -i 's/http:/https:/g' /etc/apt/sources.list

RUN apt-get update && apt-get install -y \
	pptpd \
	vim \
	iproute2 \
	iputils-ping
