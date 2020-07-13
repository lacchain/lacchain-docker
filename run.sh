#!/bin/bash -u

# Copyright 2018 ConsenSys AG.
#
# Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with
# the License. You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on
# an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the
# specific language governing permissions and limitations under the License.

set -e
NO_LOCK_REQUIRED=true

. ./.env
#. ./.common.sh

hash jq 2>/dev/null || {
  echo >&2 "This script requires jq but it's not installed."
  echo >&2 "Refer to documentation to fulfill requirements."
  exit 1
}

hash yarn 2>/dev/null || {
  echo >&2 "This script requires yarn but it's not installed."
  echo >&2 "Refer to documentation to fulfill requirements."
  exit 1
}

PARAMS=""

displayUsage()
{
  echo "This script creates and start a local private Besu network using Docker."
  echo "You can select the consensus mechanism to use.\n"
  echo "Usage: ${me} [OPTIONS]"
  echo "    -e                       : setup ELK with the network."
  exit 0
}

composeFile="-f docker-compose.yml"

# Build and run containers and network
echo "${composeFile}" > ${LOCK_FILE}
echo "${SAMPLE_VERSION}" >> ${LOCK_FILE}

echo "*************************************"
echo "Sample Network for Besu at ${SAMPLE_VERSION}"
echo "*************************************"
echo "Start network"
echo "--------------------"

if [ -f 'docker-compose.yml' ] ; then
rm docker-compose.yml
fi
touch docker-compose.yml

echo "Generating docker-compose.yml ..."

VALIDATORS=1
WRITERS=1

while getopts v:w: option
do
case "${option}"
in
v) VALIDATORS=${OPTARG};;
w) WRITERS=${OPTARG};;
esac
done

cat >> docker-compose.yml <<EOF
version: '3.4'

services:
  generator:
    build:
      context: generator/.
    environment:
      - WRITERS=$WRITERS
      - VALIDATORS=$VALIDATORS
    volumes:
      - ./volumes/validators:/validators
      - ./volumes/writers:/writers

  bootnode:
    build:
      context: besu/.
      args:
        BESU_VERSION: ${BESU_VERSION}
    image: lacchain-network/besu:${BESU_VERSION}
    environment:
      - BESU_PUBLIC_KEY_DIRECTORY=${BESU_PUBLIC_KEY_DIRECTORY}
    entrypoint: /opt/besu/bootnode_start.sh
    command: &base_options [
      "--config-file=/config/config.toml",
      "--genesis-file=/config/genesis.json",
      "--node-private-key-file=/opt/besu/keys/key",
      "--rpc-http-api=WEB3,ETH,NET,IBFT,ADMIN",
      "--rpc-ws-api=WEB3,ETH,NET,IBFT,ADMIN",
    ]
    volumes:
      - ./:${BESU_PUBLIC_KEY_DIRECTORY}
      - ./config/besu/config.toml:/config/config.toml
      - ./config/besu/genesis.json:/config/genesis.json
      - ./volumes/bootnode/keys:/opt/besu/keys
      - ./volumes/bootnode/data:/opt/besu/data
    depends_on:
      - generator
    networks:
      lacchain:
        ipv4_address: 172.24.2.2
EOF

for (( v = 1; v <= $VALIDATORS; v++ ))
do
cat >> docker-compose.yml <<EOF

  validator$v:
    image: lacchain-network/besu:${BESU_VERSION}
    environment:
      - BESU_PUBLIC_KEY_DIRECTORY=${BESU_PUBLIC_KEY_DIRECTORY}
    command: *base_options
    volumes:
      - ./:${BESU_PUBLIC_KEY_DIRECTORY}
      - ./config/besu/config.toml:/config/config.toml
      - ./config/besu/genesis.json:/config/genesis.json
      - ./volumes/validators/$v/keys:/opt/besu/keys
      - ./volumes/validators/$v/data:/opt/besu/data
    depends_on:
      - bootnode
    networks:
      lacchain:
        ipv4_address: 172.24.2.$((10+v))
EOF
done

for (( w = 1; w <= $WRITERS; w++ ))
do
cat >> docker-compose.yml <<EOF

  writer$w:
    image: lacchain-network/besu:${BESU_VERSION}
    environment:
      - BESU_PUBLIC_KEY_DIRECTORY=${BESU_PUBLIC_KEY_DIRECTORY}
    command: *base_options
    volumes:
      - ./:${BESU_PUBLIC_KEY_DIRECTORY}
      - ./config/besu/config.toml:/config/config.toml
      - ./config/besu/genesis.json:/config/genesis.json
      - ./volumes/writers/$w/keys:/opt/besu/keys
      - ./volumes/writers/$w/data:/opt/besu/data
    depends_on:
      - bootnode
EOF
if [ $w -eq 1 ]; then
cat >> docker-compose.yml <<EOF
    ports:
      - 8545:8545/tcp
EOF
fi
cat >> docker-compose.yml <<EOF
    networks:
      lacchain:
        ipv4_address: 172.24.2.$((50+w))
EOF
done

cat >> docker-compose.yml <<EOF

  explorer:
    build: explorer/.
    image: lacchain-network/block-explorer-light:${BESU_VERSION}
    depends_on:
      - writer1
    ports:
      - 25000:80/tcp
    networks:
      lacchain:
        ipv4_address: 172.24.2.254
EOF

cat >> docker-compose.yml <<EOF

networks:
  lacchain:
    driver: bridge
    ipam:
      config:
        - subnet: 172.24.2.0/24
EOF

echo "Starting network..."
docker-compose -f docker-compose.yml build --pull
docker-compose -f docker-compose.yml up --detach

#list services and endpoints
./list.sh
