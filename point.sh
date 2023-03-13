#
# // Copyright (C) 2023 Salman Wahib Recoded By Hexnodes
#

echo -e "\033[0;32m"
echo "    ██   ██ ███████ ██   ██ ███    ██  ██████  ██████  ███████ ███████";
echo "    ██   ██ ██       ██ ██  ████   ██ ██    ██ ██   ██ ██      ██     "; 
echo "    ███████ █████     ███   ██ ██  ██ ██    ██ ██   ██ █████   ███████"; 
echo "    ██   ██ ██       ██ ██  ██  ██ ██ ██    ██ ██   ██ ██           ██"; 
echo "    ██   ██ ███████ ██   ██ ██   ████  ██████  ██████  ███████ ███████";
echo "              Automatic Installer for POINT Network v0.0.4 ";
echo -e "\e[0m"

sleep 1

# Variable
POINT_WALLET=wallet
POINT=pointd
POINT_ID=point_10687-1
POINT_FOLDER=.pointd
POINT_VER=v0.0.4
POINT_REPO=https://github.com/pointnetwork/point-chain
POINT_GENESIS=https://raw.githubusercontent.com/pointnetwork/point-chain-config/main/mainnet-1/genesis.json
POINT_ADDRBOOK=https://anode.team/Point/main/addrbook.json
POINT_DENOM=apoint
POINT_PORT=27

echo "export POINT_WALLET=${POINT_WALLET}" >> $HOME/.bash_profile
echo "export POINT=${POINT}" >> $HOME/.bash_profile
echo "export POINT_ID=${POINT_ID}" >> $HOME/.bash_profile
echo "export POINT_FOLDER=${POINT_FOLDER}" >> $HOME/.bash_profile
echo "export POINT_VER=${POINT_VER}" >> $HOME/.bash_profile
echo "export POINT_REPO=${POINT_REPO}" >> $HOME/.bash_profile
echo "export POINT_GENESIS=${POINT_GENESIS}" >> $HOME/.bash_profile
echo "export POINT_ADDRBOOK=${POINT_ADDRBOOK}" >> $HOME/.bash_profile
echo "export POINT_DENOM=${POINT_DENOM}" >> $HOME/.bash_profile
echo "export POINT_PORT=${POINT_PORT}" >> $HOME/.bash_profile
source $HOME/.bash_profile

# Set Vars
if [ ! $POINT_NODENAME ]; then
        read -p "hexskrt@hexnodes:~# [ENTER YOUR NODE] > " POINT_NODENAME
        echo 'export POINT_NODENAME='$POINT_NODENAME >> $HOME/.bash_profile
fi
echo ""
echo -e "YOUR NODE NAME : \e[1m\e[31m$POINT_NODENAME\e[0m"
echo -e "NODE CHAIN ID  : \e[1m\e[31m$POINT_ID\e[0m"
echo -e "NODE PORT      : \e[1m\e[31m$POINT_PORT\e[0m"
echo ""

# Update
sudo apt update && sudo apt upgrade -y

# Package
sudo apt install make build-essential gcc git jq chrony lz4 -y

# Install GO
ver="1.19.6"
cd $HOME
wget "https://golang.org/dl/go$ver.linux-amd64.tar.gz"
sudo rm -rf /usr/local/go
sudo tar -C /usr/local -xzf "go$ver.linux-amd64.tar.gz"
rm "go$ver.linux-amd64.tar.gz"
echo "export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin" >> ~/.bash_profile
source ~/.bash_profile
go version

# Get mainnet version of POINT Network
cd $HOME
rm -rf $POINT
git clone $POINT_REPO
cd POINT
git checkout $POINT_VER
make install
sudo mv ~/go/bin/$POINT /usr/local/bin/$POINT

# Init generation
$POINT config chain-id $POINT_ID
$POINT config keyring-backend file
$POINT config node tcp://localhost:${POINT_PORT}657
$POINT init $POINT_NODENAME --chain-id $POINT_ID

# Set peers and seeds
PEERS="57497b1ecdfd1c1566cbbf19f52673c404f72300@65.108.50.106:26656,2894ad67ded3715c591949a50a86eca287227f8d@65.109.122.105:61656,9c90759b21db896b3a88aa53a2b2fb4eddc21fac@95.216.175.68:26656,bd3dfbaa59111acbeafc35bfed283c7a55f31606@54.39.129.4:26656,a98ce5206930c7f78b54005097b261904541af8c@159.223.234.196:26656,57b4e8246e748e6fed2d7585426e9cbdb96fc5cb@65.109.48.11:26656,cfc8566d7989a08156ce7775c7ba06910a8305f9@161.97.166.6:26656,7d04addcf070dac5c6fa1d3d588ad833dbf7ae30@88.99.100.39:26656,99dbdf9f6736ae822ae0abe43503f9e037f678d9@144.126.139.109:26656,a520fffe8b889b9c38a140fd6a5ae5edba264cab@104.248.194.148:26656,319e0ad92761d08b8af26157609aa76dd7cf5de5@65.21.91.160:26989,7d4424db82cbf73d3b8a47b6430b2afaf2873b2b@167.235.229.236:26656,61c55bf88dcda516876baaf29a778c07b6dd73eb@180.178.72.254:26656,fffbb069e5563a0fb2366818d076c62dfac193db@64.226.88.168:26656,4896c8b474560ff359edd9e2a1e705b0513180e2@144.76.97.251:34656,d8161e37cdc3ca7dbe1379a054f8f6072147ac76@65.108.44.100:28656,c2ad2b84e9747c71a269284414b1532db37f8acd@217.182.199.219:26656,f90323d7323b9e709f2a179430b39593cd7a2ab0@5.161.122.253:26656,3bcccc00199c8b8e082e55910d3e5e3320134fd6@154.26.136.203:26656,bb81447d12aad20721ea38a008cd5815e3758dee@204.236.207.177:26656,a15ca4998882b74ed8311dd0f473381b4dcd3a79@88.99.161.162:21656,a8bd036af7908c5752896441e1612d3073cc9da5@54.64.157.114:26656,488259415221639f5c082695cffd4c81d299b662@65.108.232.168:14656,af45621cef733795d1a5bd5316e15639bc8d83aa@65.21.90.141:12143,5d2dfcc98233973f74280528a2fcba6707035a1d@45.90.92.185:26656,0742dfb487761f92287028aff129c88b643aa10d@65.21.204.46:55656,6994b66f2fd1abe76787c1218f9eb18a7ebbe063@185.227.135.88:26656,e5880e61180a13614d11ae70ef7847598f00cf0a@23.175.146.228:26656,99e8db87fc091249a74b9bd851c6d71efc101842@141.95.100.185:26656,0764cc1fa52a5da1f8f5c0eb92574c737541ff14@145.239.7.44:26656,a6f631098d18e474a48012fa395962795109b71c@192.99.4.20:28656,76af8650397fb49bbe6f68023a8eb9efb61ef7f4@52.14.238.202:26656,acf109a7c590f8121dda230af6feb176d9b31452@65.109.81.119:34656,6c28a94445bd95750baf137aebdc8a48829493df@65.108.123.119:26656"
SEEDS="8673c1f04c29c464189e8bf29e51fb0b38da2f19@rpc-mainnet-1.point.space:26656"
sed -i.bak -e "s/^seeds *=.*/seeds = \"$SEEDS\"/; s/^persistent_peers *=.*/persistent_peers = \"$PEERS\"/" $HOME/$POINT_FOLDER/config/config.toml

# Download genesis and addrbook
curl -Ls $POINT_GENESIS > $HOME/$POINT_FOLDER/config/genesis.json
curl -Ls $POINT_ADDRBOOK > $HOME/$POINT_FOLDER/config/addrbook.json

# Set Port
sed -i.bak -e "s%^proxy_app = \"tcp://127.0.0.1:26658\"%proxy_app = \"tcp://127.0.0.1:${POINT_PORT}658\"%; s%^laddr = \"tcp://127.0.0.1:26657\"%laddr = \"tcp://127.0.0.1:${POINT_PORT}657\"%; s%^pprof_laddr = \"localhost:6060\"%pprof_laddr = \"localhost:${POINT_PORT}060\"%; s%^laddr = \"tcp://0.0.0.0:26656\"%laddr = \"tcp://0.0.0.0:${POINT_PORT}656\"%; s%^prometheus_listen_addr = \":26660\"%prometheus_listen_addr = \":${POINT_PORT}660\"%" $HOME/$POINT_FOLDER/config/config.toml
sed -i.bak -e "s%^address = \"tcp://0.0.0.0:1317\"%address = \"tcp://0.0.0.0:${POINT_PORT}317\"%; s%^address = \":8080\"%address = \":${POINT_PORT}080\"%; s%^address = \"0.0.0.0:9090\"%address = \"0.0.0.0:${POINT_PORT}090\"%; s%^address = \"0.0.0.0:9091\"%address = \"0.0.0.0:${POINT_PORT}091\"%" $HOME/$POINT_FOLDER/config/app.toml

# Set Config Pruning
pruning="custom"
pruning_keep_recent="100"
pruning_keep_every="0"
pruning_interval="19"
sed -i -e "s/^pruning *=.*/pruning = \"$pruning\"/" $HOME/$POINT_FOLDER/config/app.toml
sed -i -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \"$pruning_keep_recent\"/" $HOME/$POINT_FOLDER/config/app.toml
sed -i -e "s/^pruning-keep-every *=.*/pruning-keep-every = \"$pruning_keep_every\"/" $HOME/$POINT_FOLDER/config/app.toml
sed -i -e "s/^pruning-interval *=.*/pruning-interval = \"$pruning_interval\"/" $HOME/$POINT_FOLDER/config/app.toml

# Set minimum gas price
sed -i -e "s/^minimum-gas-prices *=.*/minimum-gas-prices = \"0.0025$POINT_DENOM\"/" $HOME/$POINT_FOLDER/config/app.toml
sed -i -e "s/^snapshot-interval *=.*/snapshot-interval = \"2000\"/" $HOME/$POINT_FOLDER/config/app.toml
sed -i -e "s/^snapshot-keep-recent *=.*/snapshot-keep-recent = \"5\"/" $HOME/$POINT_FOLDER/config/app.toml

# Enable Snapshot
$POINT tendermint unsafe-reset-all --home $HOME/$POINT_FOLDER
SNAP_NAME=$(curl -s https://snapshots.nodestake.top/point/ | egrep -o ">20.*\.tar.lz4" | tr -d ">")
curl -o - -L https://snapshots.nodestake.top/point/${SNAP_NAME}  | lz4 -c -d - | tar -x -C $HOME/$POINT_FOLDER

# Create Service
sudo tee /etc/systemd/system/$POINT.service > /dev/null <<EOF
[Unit]
Description=$POINT
After=network-online.target
[Service]
User=$USER
ExecStart=$(which $POINT) start --home $HOME/$POINT_FOLDER
Restart=on-failure
RestartSec=3
LimitNOFILE=4096
[Install]
WantedBy=multi-user.target
EOF

# Register And Start Service
sudo systemctl daemon-reload
sudo systemctl enable $POINT
sudo systemctl start $POINT

echo -e "\e[1m\e[31mSETUP FINISHED\e[0m"
echo ""
echo -e "CHECK RUNNING LOGS : \e[1m\e[31mjournalctl -fu $POINT -o cat\e[0m"
echo -e "CHECK LOCAL STATUS : \e[1m\e[31mcurl -s localhost:${POINT_PORT}657/status | jq .result.sync_info\e[0m"
echo ""

# End
