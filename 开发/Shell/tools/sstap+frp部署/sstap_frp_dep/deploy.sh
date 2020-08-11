#!/bin/bash
# Date: 2020-8-10
# Auth: Lukas
# Mail: yangyang.huang@cloudfortdata.com
# Func: deploy sstap service & frp
# Ver.: 1.0

#color config
rmsg() { echo -e "\e[1;31m$*\e[0m"; } #red
gmsg() { echo -e "\e[1;32m$*\e[0m"; } #green
bmsg() { echo -e "\033[34;49m$*\033[0m"; } #blue

#WD
WD="$(cd `dirname $0`; pwd)"

init(){
  which docker || apt-get install docker.io -y
}

frp_client_dep(){
  tar -zxvf frpc.tgz
  read -p "请输入frps服务器的ip:" ip
  sed -i "s/server_addr.*=/& $ip /" frpc/frpc.ini

  while ! ./frpc -c frpc.ini
  do
    sleep 5
    ./frpc -c frpc.ini
  done

}

frp_server_dep(){
  tar -zxvf frps.tgz
  cd ./frps && bash frps -c frps.ini
}

remote_dep(){
  frp_server_dep
}

local_dep(){
  frp_client_dep
  bash $WD/shadowsocks_service_dep.sh
}

case "$1" in
  r|R)
    remote_dep
    ;;
  l|L)
    local_dep
    ;;
  *)
    rmsg "Usage: bash ./deploy.sh [r/l]"
    ;;
esac
