ARG TAIGA_BACK_TAG

FROM taigaio/taiga-back:${TAIGA_BACK_TAG}

ARG BUILD_GITHUB_REPO

RUN apt-get update && apt-get install git -y
RUN git clone ${BUILD_GITHUB_REPO} as taiga-contrib-openid-auth && cd taiga-contrib-openid-auth && git checkout master
RUN cd taiga-contrib-openid-auth/back; pip install -e .

COPY config.py /taiga-back/settings/config.py
