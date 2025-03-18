#!/bin/sh
#호스트의 결과물 생성 폴더와 컨테이너의 /home을 볼륨 마운트
#환경변수 필요
#$CONFIG_REPOSITORY_GITCRYPT_GPG_PRIVATEKEY
#$CONFIG_REPOSITORY_ADDRESS
#$CONFIG_REPOSITORY_NAME
cd /home

#GPG key를 gpg key ring에 등록
echo "============== GPG key를 gpg key ring에 등록 =============="
eval $(gpg-agent --daemon)
echo "$CONFIG_REPOSITORY_GITCRYPT_GPG_PRIVATEKEY" | gpg --import

#Clone Config Repository
echo "============== clone  config repository =============="
git clone $CONFIG_REPOSITORY_ADDRESS
cd $CONFIG_REPOSITORY_NAME
#git-crypt로 Config 레포지토리를 복호화
echo "============== config 레포지토리 복호화 =============="
git-crypt unlock