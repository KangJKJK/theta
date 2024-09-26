#!/bin/bash

# 색상 코드 선언
RED="\e[31m"
YELLOW="\e[33m"
BLUE="\e[34m"
CYAN="\e[36m"
GREEN="\e[32m"
MAGENTA="\e[35m"
RESET="\e[0m"

echo -e "${GREEN}Theta edge node 설치를 시작합니다.${NC}"

# Docker가 설치되어 있지 않으면 설치
if ! command -v docker &> /dev/null; then
    echo -e "${BLUE}Docker를 설치 중...${RESET}"
    curl -fsSL https://get.docker.com -o get-docker.sh
    sh get-docker.sh
fi

# 최신 Theta Edge Node Docker 이미지를 가져오기
echo -e "${CYAN}최신 Theta Edge Node Docker 이미지를 가져오는 중...${RESET}"
docker pull thetalabsorg/edgelauncher_mainnet:latest

# 기존의 Theta Edge Node 컨테이너 중지 및 제거
echo -e "${MAGENTA}기존 Theta Edge Node 컨테이너 중지 및 제거 중...${RESET}"
docker rm -f edgelauncher &> /dev/null

# Theta Edge Node Docker 컨테이너 시작
echo -e "${GREEN}Theta Edge Node Docker 컨테이너 시작 중...${RESET}"
echo -ne "${YELLOW}Edge Node를 위한 보안 비밀번호를 입력하세요: ${RESET}"
read -s PASSWORD
echo
docker run -d --restart=always -e EDGELAUNCHER_CONFIG_PATH=/edgelauncher/data/mainnet -e PASSWORD="$PASSWORD" -v ~/.edgelauncher:/edgelauncher/data/mainnet -p 127.0.0.1:15888:15888 -p 127.0.0.1:17888:17888 -p 127.0.0.1:17935:17935 --name edgelauncher thetalabsorg/edgelauncher_mainnet:latest

# Theta Edge Node에 대한 systemd 서비스 생성
echo -e "${CYAN}Theta Edge Node에 대한 systemd 서비스를 생성하는 중...${RESET}"
sudo tee /etc/systemd/system/theta_edge_node.service << EOF
[Unit]
Description=Theta Edge Node
Requires=docker.service
After=docker.service

[Service]
Restart=always
RestartSec=30
ExecStart=/usr/bin/docker start -a edgelauncher
ExecStop=/usr/bin/docker stop -t 2 edgelauncher

[Install]
WantedBy=multi-user.target
EOF

# systemd를 다시 로드하여 변경 사항 적용
echo -e "${BLUE}systemd를 다시 로드하는 중...${RESET}"
sudo systemctl daemon-reload

# 부팅 시 자동으로 시작되도록 systemd 서비스 활성화
echo -e "${GREEN}systemd 서비스를 활성화하는 중...${RESET}"
sudo systemctl enable theta_edge_node.service

echo -e "${GREEN}모든 작업이 완료되었습니다. 컨트롤+A+D로 스크린을 종료해주세요.${NC}"
echo -e "${GREEN}스크립트 작성자: https://t.me/kjkresearch${NC}"
