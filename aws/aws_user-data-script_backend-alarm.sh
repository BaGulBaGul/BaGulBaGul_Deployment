#!/bin/bash

###필요한 정보 정의
#AWS Systems Manager Parameter Store에서 shh,gpg key를 가져옴
export CONFIG_REPOSITORY_GITCRYPT_GPG_PRIVATEKEY=$(aws ssm get-parameter --name "/bagulbagul/github/config/git-crypt/gpg/private-key" --with-decryption --query "Parameter.Value" --output text)
export CONFIG_REPOSITORY_ADDRESS="https://github.com/BaGulBaGul/BaGulBaGul_Config.git"
export CONFIG_REPOSITORY_NAME="BaGulBaGul_Config"
export CONFIG_REPOSITORY_ENVFILE_PATH="config/backend-alarm.env"
export DOCKER_IMAGE_PATH="ohretry/bagulbagul-backend-alarm"

#실행권한 부여
chmod +x ./scripts/amazonlinux2023_init_docker.sh ./scripts/amazonlinux2023_init_swapfile_2GB.sh
#docker 설치
echo "================ 도커 설치 ================"
source ./scripts/amazonlinux2023_init_docker.sh
#swapfile 2GB 설정
echo "================ 스왑메모리 2GB 설정 ================"
source ./scripts/amazonlinux2023_init_swapfile_2GB.sh

#config 레포지토리를 clone하고 git-crypt 복호화
echo "================ Config 레포지토리 클론 & 복호화 ================"
docker run \
-v .:/home \
-e CONFIG_REPOSITORY_GITCRYPT_GPG_PRIVATEKEY="$CONFIG_REPOSITORY_GITCRYPT_GPG_PRIVATEKEY" \
-e CONFIG_REPOSITORY_ADDRESS="$CONFIG_REPOSITORY_ADDRESS" \
-e CONFIG_REPOSITORY_NAME="$CONFIG_REPOSITORY_NAME" \
ohretry/clone-decrypt_config-repository

#종료된 컨테이너 삭제
docker container prune -f

###백엔드 서버 실행
echo "================ 백엔드 서버 실행 ================"
docker run --env-file $CONFIG_REPOSITORY_NAME/$CONFIG_REPOSITORY_ENVFILE_PATH -p 8080:8080 $DOCKER_IMAGE_PATH