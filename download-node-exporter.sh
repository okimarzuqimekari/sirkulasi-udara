VERSION="${1:-1.2.2}"
ARCH="linux-${dpkg --print-architecture}"

wget https://github.com/prometheus/node_exporter/releases/download/v$VERSION/node_exporter-$VERSION.$ARCH.tar.gz -O v$VERSION-$ARCH.tar.gz
