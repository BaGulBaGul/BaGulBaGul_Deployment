sudo yum update -y
sudo yum install gcc make -y
cd /mnt/redis_home
sudo curl -O http://download.redis.io/releases/redis-6.0.9.tar.gz
sudo tar xzvf redis-6.0.9.tar.gz
cd redis-6.0.9
sudo make
#저장 경로 설정
sudo mkdir /mnt/redis_home/data
sudo sed -i 's|^dir .*|dir /mnt/redis_home/data|' redis.conf
#bind 설정. 외부 접속 허용
sudo sed -i 's|^bind 127.0.0.1|bind 0.0.0.0|' redis.conf
#vpc 내부에서만 사용하므로 protected-mode를 no로 설정
sudo sed -i 's|^protected-mode yes|protected-mode no|' redis.conf
#로그 설정
sudo sed -i 's|^logfile ""|logfile /mnt/redis_home/log|' redis.conf
