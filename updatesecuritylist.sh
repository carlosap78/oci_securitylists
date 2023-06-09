#!/bin/bash
source /home/user/lib/oracle-cli/bin/activate
server_ip="$(curl checkip.amazonaws.com)"

#check if its the same ip
oci_ip="$(oci network security-list get | grep \"source\" | awk -F'[ ":/]+' '{print $3}')"

echo "server_ip: $server_ip, oci_ip: $oci_ip"



#script
cd /home/user/scripts/ 

echo "[" > ingress.json
  echo " {" >> ingress.json
  echo "  \"source\": \"${server_ip}/32\"," >> ingress.json
  echo "  \"source-type\": \"CIDR_BLOCK\"," >> ingress.json
  echo "  \"protocol\": \"6\"," >> ingress.json
  echo "  \"isStateless\": \"false\"," >> ingress.json
  echo "  \"Description\": \"zvo\"," >> ingress.json
  echo "  \"tcp-options\": {" >> ingress.json
  echo "   \"destination-port-range\": {" >> ingress.json
  echo "      \"max\": 3389," >> ingress.json
  echo "      \"min\": 3389" >> ingress.json
  echo "      }" >> ingress.json
  echo "     }" >> ingress.json
  echo "  }" >> ingress.json

echo "]" >> ingress.json


if [ "$server_ip" != "$oci_ip" ]; then
    echo "update security list"
    oci network security-list update --ingress-security-rules  file://./ingress.json --force
else
    echo "same ip's from oci and server, not updating"

fi
