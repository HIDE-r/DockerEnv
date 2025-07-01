# DHCPv6-PD 实验环境

本仓库提供了一个基于 Docker 的 DHCPv6 和 radvd 环境，用于模拟和测试 IPv6 前缀代理（Prefix Delegation, PD）功能。

## 特性

- 使用 `isc-dhcp-server` 提供 DHCPv6 服务。
- 使用 `radvd` 提供路由通告（RA）服务。
- 通过 Docker Compose 方便地启动和管理服务。
- 支持自定义网络接口。

## 先决条件

- [Docker](https://www.docker.com/)
- [Docker Compose](https://docs.docker.com/compose/)

## 配置

在 `.env` 文件中，设置 `IFACE` 变量为您希望服务监听的网络接口。

```env
IFACE=eth0
```

## 使用方法

**启动服务：**

```bash
docker-compose up -d
```

**查看日志：**

```bash
docker-compose logs -f
```

**停止并移除容器：**

```bash
docker-compose down
```

## 服务详情

### `dhcpd6`

- **镜像**: 基于 `Dockerfile` 构建的 `scenario_envs/ipv6`。
- **功能**: 运行 `isc-dhcp-server` 以提供 DHCPv6 服务。
- **网络**: `host` 模式，直接使用主机的网络。
- **配置文件**: `conf/dhcpd6.conf`。
- **启动命令**:
  1. 激活 `$IFACE` 接口。
  2. 清除接口上原有的 IPv6 地址。
  3. 为接口配置 `2024::1/48` 地址作为 DHCPv6 服务器地址。
  4. 创建并准备租约文件。
  5. 启动 `dhcpd` 服务并监听 `$IFACE` 接口。
- **配置详情 (`conf/dhcpd6.conf`)**:
  - **`server-duid`**: 设置 DHCPv6 服务器的 DUID。
  - **`subnet6`**: 定义 `2024::/48` 的子网。
  - **`range6`**: 为客户端提供 `2024::100` 到 `2024::200` 的地址范围。
  - **`prefix6`**: 提供 `2024:0:0:1::` 到 `2024:0:0:f::` 范围内的 `/64` 前缀代理。
  - **`option dhcp6.name-servers`**: 指定 DNS 服务器地址。

### `radvd`

- **镜像**: 基于 `Dockerfile` 构建的 `scenario_envs/ipv6`。
- **功能**: 运行 `radvd` (Router Advertisement Daemon) 来发送 RA 消息，使网络中的客户端能够自动配置 IPv6 地址。
- **网络**: `host` 模式。
- **配置文件**: `conf/radvd.conf` (作为模板)。
- **启动命令**:
  1. 激活 `$IFACE` 接口。
  2. 使用 `m4` 宏处理器将 `conf/radvd.conf` 中的 `__IFACE__` 占位符替换为实际的接口名，并生成最终配置文件。
  3. 启动 `radvd` 服务。
- **配置详情 (`conf/radvd.conf`)**:
  - **`AdvManagedFlag on`**: 指示客户端通过 DHCPv6 获取地址（有状态自动配置）。
  - **`AdvOtherConfigFlag on`**: 指示客户端通过 DHCPv6 获取其他配置信息（如 DNS）。
  - **`prefix 2012::/64`**: 通告 `2012::/64` 前缀，允许客户端进行无状态地址自动配置 (SLAAC)。
