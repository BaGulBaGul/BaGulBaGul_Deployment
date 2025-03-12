#!/bin/bash

###볼륨 연결
# IMDSv2로 바뀌면서 토큰이 있어야 접근 가능하다고 함. 3분짜리 토큰을 발급
TOKEN=$(curl -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 270")
# 자기 자신의 인스턴스 ID 조회
INSTANCE_ID=$(curl -H "X-aws-ec2-metadata-token: $TOKEN" -v http://169.254.169.254/latest/meta-data/instance-id)
echo "현재 인스턴스의 id = $INSTANCE_ID"

# redis_home 볼륨 ID 조회
VOLUME_ID=$(aws ec2 describe-volumes --filters "Name=tag:Name,Values=redis_home" --query "Volumes[*].VolumeId" --output text)
echo "redis_home ebs volume의 id = $VOLUME_ID"

# 볼륨 ID가 조회되지 않으면 스크립트 종료
if [ -z "$VOLUME_ID" ]; then
  echo "redis_home EBS 볼륨을 찾을 수 없습니다. 스크립트를 종료합니다."
  exit 1
fi

#redis_home 볼륨을 자신과 연결, 장치 이름은 /dev/sdb, ec2 리눅스에는 /dev/xvdb로 인식됨
aws ec2 attach-volume --volume-id $VOLUME_ID --instance-id $INSTANCE_ID --device /dev/sdb
echo "$INSTANCE_ID에 ebs 볼륨 $VOLUME_ID를 연결. 장치 이름은 /dev/sdb. 리눅스에서는 /dev/xvdb로 인식."

# 볼륨이 연결될 때까지 대기
while ! lsblk | grep -q xvdb; do
  echo "볼륨이 아직 연결되지 않았습니다. 5초 후 다시 확인합니다."
  sleep 5
done

#redis_home 마운트
mkdir /mnt/redis_home
mount /dev/xvdb /mnt/redis_home
#재부팅 시에 자동으로 마운트
echo "/dev/xvdb /mnt/redis_home ext4 defaults,nofail 0 2" | sudo tee -a /etc/fstab
echo "/dev/xvdb를 /mnt/redis_home에 마운트"

#gcc 확인
sudo yum update -y
sudo yum install gcc make -y

#redis 설치
cd /mnt/redis_home/redis-6.0.9
sudo make install

# Redis 서비스 파일 생성
cat <<EOL | sudo tee /etc/systemd/system/redis.service
[Unit]
Description=Redis In-Memory Data Store
After=network.target mnt-redis_home.mount
Requires=mnt-redis_home.mount

[Service]
ExecStart=/usr/local/bin/redis-server /mnt/redis_home/redis-6.0.9/redis.conf
ExecStop=/usr/local/bin/redis-cli shutdown
Restart=always
User=redis
Group=redis
PrivateTmp=true

[Install]
WantedBy=multi-user.target
EOL

# systemd 데몬 리로드
sudo systemctl daemon-reload

# Redis 사용자 생성
sudo adduser --system --no-create-home -U redis
sudo chown -R redis:redis /mnt/redis_home
sudo chmod -R 777 /mnt/redis_home

# 서비스 시작 및 활성화
sudo systemctl start redis
sudo systemctl enable redis