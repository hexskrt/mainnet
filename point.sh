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
PEERS=""
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
