FROM alpine:latest

###필요 패키지 설치
# gpg 설치
RUN apk add --no-cache gnupg
# 빌드 도구 설치
RUN apk add --no-cache g++ make perl
# git 설치
RUN apk add --no-cache git
#
#RUN apk add --no-cache musl-dev
RUN apk add --no-cache linux-headers


###openssl 1.1.1 빌드 후 설치(git-crypt와 openssl3.0이 호환되지 않음)
#소스 코드를 다운로드
RUN wget https://github.com/openssl/openssl/releases/download/OpenSSL_1_1_1w/openssl-1.1.1w.tar.gz
#압축 해제
RUN tar -zxvf openssl-1.1.1w.tar.gz
#빌드 후 설치
RUN \
    cd openssl-1.1.1w && \
#시스템에 맞춰 컴파일러 옵션이나 Makefile등을 만드는 과정
    ./config && \
#빌드
    make && \
#설치
    make install && \
#설치파일 삭제 \
    cd .. && \
    rm -rf openssl-1.1.1w && \
    rm openssl-1.1.1w.tar.gz

###git-crypt 빌드 후 설치
RUN wget https://github.com/AGWA/git-crypt/archive/refs/tags/0.7.0.tar.gz
RUN tar -zxvf 0.7.0.tar.gz
RUN \
    cd git-crypt-0.7.0 && \
    make && \
    make install && \
    cd .. && \
    rm -rf git-crypt-0.7.0 && \
    rm 0.7.0.tar.gz

#진입점 설정
COPY ./entry.sh ./entry.sh
RUN chmod 777 ./entry.sh
CMD ["./entry.sh"]