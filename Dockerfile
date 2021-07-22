FROM quay.io/sinq/nodejs:lts

WORKDIR /tmp

#https://bitcoincore.org/bin/bitcoin-core-$VER/bitcoin-$VER-x86_64-linux-gnu.tar.gz
COPY bitcoincore/bitcoin-0.21.1-x86_64-linux-gnu.tar.gz /tmp/bitcoin-0.21.1-x86_64-linux-gnu.tar.gz
