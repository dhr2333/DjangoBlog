FROM python:alpine as builder 

RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.ustc.edu.cn/g' /etc/apk/repositories

RUN apk add --update libxml2-dev libxslt-dev gcc musl-dev g++
RUN pip config set global.index-url http://mirrors.aliyun.com/pypi/simple
RUN pip config set install.trusted-host mirrors.aliyun.com
RUN pip install --prefix="/install" fava 

FROM harbor.wlhiot.com:8080/library/python:3
LABEL maintainer="daihaorui <Dai_Haorui@163.com>"
COPY --from=builder /install /usr/local
ENV FAVA_HOST "0.0.0.0"
EXPOSE 5000

ENV PYTHONUNBUFFERED 1
WORKDIR /code/djangoblog/

RUN sed -i "s/archive.ubuntu./mirrors.aliyun./g" /etc/apt/sources.list
RUN sed -i "s/deb.debian.org/mirrors.aliyun.com/g" /etc/apt/sources.list
RUN sed -i "s/security.debian.org/mirrors.aliyun.com\/debian-security/g" /etc/apt/sources.list
RUN sed -i "s/httpredir.debian.org/mirrors.aliyun.com\/debian-security/g" /etc/apt/sources.list
RUN pip install -U pip
RUN pip config set global.index-url http://mirrors.aliyun.com/pypi/simple
RUN pip config set install.trusted-host mirrors.aliyun.com

RUN  apt-get install  default-libmysqlclient-dev -y && \
    ln -sf /usr/share/zoneinfo/Asia/Shanghai  /etc/localtime
ADD requirements.txt requirements.txt
RUN pip install --upgrade pip && \
        pip install -Ur requirements.txt && \
        pip install gunicorn[gevent] && \
        pip cache purge
        
ADD . .
RUN chmod +x /code/djangoblog/bin/docker_start.sh
ENTRYPOINT ["/code/djangoblog/bin/docker_start.sh"]
