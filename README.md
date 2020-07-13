# LACChain Network Docker

## Prerequisites

To run these tutorials, you must have the following installed:

- [Docker and Docker-compose](https://docs.docker.com/compose/install/)

| ⚠️ **Note**: If on MacOS or Windows, please ensure that you allow docker to use upto 4G of memory or 6G if running Privacy examples under the _Resources_ section. The [Docker for Mac](https://docs.docker.com/docker-for-mac/) and [Docker Desktop](https://docs.docker.com/docker-for-windows/) sites have details on how to do this at the "Resources" heading       |
| ---                                                                                                                                                                                                                                                                                                                                                                                |


| ⚠️ **Note**: This has only been tested on Windows 10 Build 18362 and Docker >= 17.12.2                                                                                                                                                                                                                                                                                              |
| ---                                                                                                                                                                                                                                                                                                                                                                                |

- On Windows ensure that the drive that this repo is cloned onto is a "Shared Drive" with Docker Desktop
- On Windows we recommend running all commands from GitBash
- [Nodejs](https://nodejs.org/en/download/) and [Truffle](https://www.trufflesuite.com/truffle) if using the DApp


## Description

There are multiple examples in this repo, and each has a POA example. You can choose the default setup which comprises a 4 node network with the Block Explorer and our Prometheus & Grafana dashboard to track the progress of the chain; or the whole setup with logging via ELK.   
Please use the following use cases personas as guidelines only: 

All the architecture diagrams below generally use the POA (IBFT2) setup, to view the architecture diagrams for the POW (ethash) setup please see the `images` folder, where the files share the same name but have different suffixes. 

### Start Services and Network
`./run.sh` starts all the docker containers in POA mode

`./run.sh -c ibft2` starts all the docker containers in POA mode using the IBFT2 Consensus algorithm

There is an optional `-e` parameter which provides centralised logging functionality via ELK 


#### Basic 4 Node Network with Block Explorer and Prometheus & Grafana to track the progress of your chain

Use this scenario:
 - if you are a DApp Developer looking for a robust, simple network to use as an experimental testing ground for POCs 
 
![Image basic](./images/sampleNetworks-poa.png)

Where the node details are as follows:

Name  | Besu Node address                      | Orion node key | Node URL
----- | ---- | ---- | ---- |
node1 | 0x866b0df7138daf807300ed9204de733c1eb6d600 | 9QHwUJ6uK+FuQMzFSXIo7wOLCGFZa0PiF771OLX5c1o= | http://localhost:20000
node2 | 0xa46f0935de4176ffeccdeecaf3c6e3ca03e31b22 | qVDsbJh2UluZOePxbXAL49g0S0s2gGlJ3ftQceMlchU= | http://localhost:20002
node3 | 0x998c8bc11c28b667e4b1930c3fe3c9ab1cde3c52 | T1ItOQxwgY1pTW6YXb2EbKXYkK4saBEys3CfJ2OIKHs= | http://localhost:20004


###### Testing Privacy between Orion nodes

###### Prerequisites
 - [Nodejs](https://nodejs.org/en/download/)
 
Follow the [eeajs-multinode-example](https://besu.hyperledger.org/en/stable/Tutorials/Privacy/eeajs-Multinode-example/) which deploys 
an `EventEmitter` contract and then sends a couple of Private Transaction from Node1 -> Node2 (& vice versa) with an arbitrary value (1000). 

At the end of both transactions, it then reads all three Orion nodes to check the value at an address, and you should observe 
that only Node1 & Node2 have this information becuase they were involved in the transaction and that Orion3 responds with a `0x` 
value for reads at those addresses

There is an additional erc20 token example that you can also test with: executing `node example/erc20.js` deploys a `HumanStandardToken` contract and transfers 1 token to node2.

This can be verified from the `data` field of the `logs` which is `1`.

###### Prerequisites
 - [Nodejs](https://nodejs.org/en/download/)
 - [Yarn](https://www.npmjs.com/package/yarn)
 - [JQ](https://stedolan.github.io/jq/)
 - Install [metamask](https://metamask.io/) as an extension in your browser
 - Once you have setup your own private account, select 'My Accounts' by clicking on the avatar pic and then 'Import Account' for the following private keys:
    - `0x8f2a55949038a9610f50fb23b5883af3b4ecb3c3bb792cbcefbd1542c692be63`
    - `0xc87509a1c067bbde78beb793e6fa76530b6382a4c0241e5e4a9ec0a0f44dc0d3`
    - `0xae6ae8e5ccbfb04590405997ee2d52d2b330726137b875053c36d94e974d162f`

![Image basic_permissioning](./images/sampleNetworks-poa-permissioning.png)

### Stop Services and Network
`./stop.sh` stops all the docker containers created.

### Remove stopped containers and volumes
`./remove.sh` stops and removes all the containers and volumes.
