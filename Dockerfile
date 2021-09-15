FROM ubuntu:latest as builder

RUN apt update \
    && apt install -y --no-install-recommends \
        ca-certificates \
        wget \
        gnupg \
    && apt clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

WORKDIR /tmp

ARG VERSION=22.0
ARG ARCH=x86_64
ARG BITCOIN_CORE_SIGNATURE=01EA5486DE18A882D4C2684590C8019E36C2E964

RUN cd /tmp \
    && wget https://bitcoincore.org/bin/bitcoin-core-${VERSION}/SHA256SUMS.asc \
    && wget https://bitcoincore.org/bin/bitcoin-core-${VERSION}/SHA256SUMS \
    && gpg --keyserver hkp://keyserver.ubuntu.com --recv-keys ${BITCOIN_CORE_SIGNATURE} \
    && gpg --keyserver hkp://keyserver.ubuntu.com --recv-keys 0CCBAAFD76A2ECE2CCD3141DE2FFD5B1D88CA97D \
    && gpg --keyserver hkp://keyserver.ubuntu.com --recv-keys 152812300785C96444D3334D17565732E08E5E41 \
    && gpg --keyserver hkp://keyserver.ubuntu.com --recv-keys 0AD83877C1F0CD1EE9BD660AD7CC770B81FD22A8 \
    && gpg --keyserver hkp://keyserver.ubuntu.com --recv-keys 590B7292695AFFA5B672CBB2E13FC145CD3F4304 \
    && gpg --keyserver hkp://keyserver.ubuntu.com --recv-keys 28F5900B1BB5D1A4B6B6D1A9ED357015286A333D \
    && gpg --keyserver hkp://keyserver.ubuntu.com --recv-keys 637DB1E23370F84AFF88CCE03152347D07DA627C \
    && gpg --keyserver hkp://keyserver.ubuntu.com --recv-keys CFB16E21C950F67FA95E558F2EEB9F5CC09526C1 \
    && gpg --keyserver hkp://keyserver.ubuntu.com --recv-keys 6E01EEC9656903B0542B8F1003DB6322267C373B \
    && gpg --keyserver hkp://keyserver.ubuntu.com --recv-keys D1DBF2C4B96F2DEBF4C16654410108112E7EA81F \
    && gpg --keyserver hkp://keyserver.ubuntu.com --recv-keys 82921A4B88FD454B7EB8CE3C796C4109063D4EAF \
    && gpg --keyserver hkp://keyserver.ubuntu.com --recv-keys 9DEAE0DC7063249FB05474681E4AED62986CD25D \
    && gpg --keyserver hkp://keyserver.ubuntu.com --recv-keys 9D3CC86A72F8494342EA5FD10A41BDC3F4FAFF1C \
    && gpg --keyserver hkp://keyserver.ubuntu.com --recv-keys 74E2DEF5D77260B98BC19438099BAD163C70FBFA \
    && gpg --verify SHA256SUMS.asc SHA256SUMS\
    && grep bitcoin-${VERSION}-${ARCH}-linux-gnu.tar.gz SHA256SUMS.asc > SHA25SUM \
    && wget https://bitcoincore.org/bin/bitcoin-core-${VERSION}/bitcoin-${VERSION}-${ARCH}-linux-gnu.tar.gz \
    && sha256sum -c SHA25SUM \
    && tar -xzvf bitcoin-${VERSION}-${ARCH}-linux-gnu.tar.gz -C /opt \
    && ln -sv bitcoin-${VERSION} /opt/bitcoin \
    && /opt/bitcoin/bin/test_bitcoin --show_progress \
    && rm -v /opt/bitcoin/bin/test_bitcoin /opt/bitcoin/bin/bitcoin-qt



FROM quay.io/sinq/nodejs:lts
LABEL maintainer="SINQ inc."


ENV HOME /bitcoin
EXPOSE 8332 8333
VOLUME ["/bitcoin/.bitcoin"]
WORKDIR /bitcoin

ARG GROUP_ID=1001
ARG USER_ID=1001
RUN groupadd -g ${GROUP_ID} bitcoin \
    && useradd -u ${USER_ID} -g bitcoin -d /bitcoin bitcoin

COPY --from=builder /opt/ /opt/

RUN apt update \
    && apt install -y --no-install-recommends gosu \
    && apt clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
    && ln -sv /opt/bitcoin/bin/* /usr/local/bin

COPY bin/  /usr/local/bin/
COPY docker-entrypoint.sh /docker-entrypoint.sh


RUN chmod 755 /docker-entrypoint.sh \
    && chmod 755 /usr/local/bin/btc_oneshot \
    && chmod 755 /usr/local/bin/btc_init

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["btc_oneshot"]