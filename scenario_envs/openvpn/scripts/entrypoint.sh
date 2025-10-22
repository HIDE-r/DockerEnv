#!/usr/bin/env bash

cp 	/etc/openvpn/easy-rsa/pki/ca.crt \
	/etc/openvpn/easy-rsa/pki/issued/openvpn_client.crt \
	/etc/openvpn/easy-rsa/pki/private/openvpn_client.key \
	/var/env_data/

cp /etc/openvpn/client.ovpn /var/env_data/client.ovpn

chown 1000:1000 /var/env_data/*

sed -i '/<ca>/r /var/env_data/ca.crt' /var/env_data/client.ovpn
awk '/-----BEGIN CERTIFICATE-----/,/-----END CERTIFICATE-----/' /var/env_data/openvpn_client.crt | sed -i '/<cert>/r /dev/stdin' /var/env_data/client.ovpn
sed -i '/<key>/r /var/env_data/openvpn_client.key' /var/env_data/client.ovpn

/usr/sbin/openvpn --config /etc/openvpn/server.conf

