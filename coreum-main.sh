#
# // Copyright (C) 2023 Salman Wahib Recoded By Hexnodes
#

echo -e "\033[0;32m"
echo "    ██   ██ ███████ ██   ██ ███    ██  ██████  ██████  ███████ ███████";
echo "    ██   ██ ██       ██ ██  ████   ██ ██    ██ ██   ██ ██      ██     "; 
echo "    ███████ █████     ███   ██ ██  ██ ██    ██ ██   ██ █████   ███████"; 
echo "    ██   ██ ██       ██ ██  ██  ██ ██ ██    ██ ██   ██ ██           ██"; 
echo "    ██   ██ ███████ ██   ██ ██   ████  ██████  ██████  ███████ ███████";
echo "      Automatic Installer for Coreum | Chain ID : coreum-mainnet-1 ";
echo -e "\e[0m"
sleep 1

# Variable
CORE_WALLET=wallet
CORE=cored
CORE_ID=coreum-mainnet-1
CORE_FOLDER=.CORE
CORE_VER=v1.0.0
CORE_REPO=https://github.com/CoreumFoundation/coreum
CORE_DENOM=ucoreum
CORE_GENESIS=https://github.com/CoreumFoundation/coreum/blob/master/genesis/coreum-mainnet-1.json
CORE_PORT=30

echo "export CORE_WALLET=${CORE_WALLET}" >> $HOME/.bash_profile
echo "export CORE=${CORE}" >> $HOME/.bash_profile
echo "export CORE_ID=${CORE_ID}" >> $HOME/.bash_profile
echo "export CORE_FOLDER=${CORE_FOLDER}" >> $HOME/.bash_profile
echo "export CORE_VER=${CORE_VER}" >> $HOME/.bash_profile
echo "export CORE_REPO=${CORE_REPO}" >> $HOME/.bash_profile
echo "export CORE_DENOM=${CORE_DENOM}" >> $HOME/.bash_profile
echo "export CORE_PORT=${CORE_PORT}" >> $HOME/.bash_profile
source $HOME/.bash_profile

# Set Vars
if [ ! $CORE_NODENAME ]; then
        read -p "hexskrt@hexnodes:~# [ENTER YOUR NODE] > " CORE_NODENAME
        echo 'export CORE_NODENAME='$CORE_NODENAME >> $HOME/.bash_profile
fi
echo ""
echo -e "YOUR NODE NAME : \e[1m\e[31m$CORE_NODENAME\e[0m"
echo -e "NODE CHAIN ID  : \e[1m\e[31m$CORE_ID\e[0m"
echo -e "NODE PORT      : \e[1m\e[31m$CORE_PORT\e[0m"
echo ""

# Update
sudo apt update && sudo apt upgrade -y

# Package
sudo apt install make build-essential gcc git jq chrony lz4 -y

# Install GO
ver="1.19.5"
cd $HOME
wget "https://golang.org/dl/go$ver.linux-amd64.tar.gz"
sudo rm -rf /usr/local/go
sudo tar -C /usr/local -xzf "go$ver.linux-amd64.tar.gz"
rm "go$ver.linux-amd64.tar.gz"
echo "export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin" >> ~/.bash_profile
source ~/.bash_profile
go version

# Get testnet version of COREmeda
cd $HOME
rm -rf CORE 
cd $HOME
git clone $CORE_REPO
cd coreum
git checkout $CORE_VER
make install
sudo mv build/$CORE /usr/bin/

$CORE config chain-id $CORE_ID
$CORE config keyring-backend file
$CORE config node tcp://localhost:${CORE_PORT}657
$CORE init $CORE_NODENAME --chain-id $CORE_ID

# Set peers and seeds
SEEDS=""
PEERS=""
sed -i -e "s/^seeds *=.*/seeds = \"$SEEDS\"/; s/^persistent_peers *=.*/persistent_peers = \"$PEERS\"/" $HOME/.COREmedad/config/config.toml

# Download genesis and addrbook
curl -Ls $CORE_GENESIS > $HOME/$CORE_FOLDER/config/genesis.json

# Set Port
sed -i.bak -e "s%^proxy_app = \"tcp://127.0.0.1:26658\"%proxy_app = \"tcp://127.0.0.1:${CORE_PORT}658\"%; s%^laddr = \"tcp://127.0.0.1:26657\"%laddr = \"tcp://127.0.0.1:${CORE_PORT}657\"%; s%^pprof_laddr = \"localhost:6060\"%pprof_laddr = \"localhost:${CORE_PORT}060\"%; s%^laddr = \"tcp://0.0.0.0:26656\"%laddr = \"tcp://0.0.0.0:${CORE_PORT}656\"%; s%^prometheus_listen_addr = \":26660\"%prometheus_listen_addr = \":${CORE_PORT}660\"%" $HOME/$CORE_FOLDER/config/config.toml
sed -i.bak -e "s%^address = \"tcp://0.0.0.0:1317\"%address = \"tcp://0.0.0.0:${CORE_PORT}317\"%; s%^address = \":8080\"%address = \":${CORE_PORT}080\"%; s%^address = \"0.0.0.0:9090\"%address = \"0.0.0.0:${CORE_PORT}090\"%; s%^address = \"0.0.0.0:9091\"%address = \"0.0.0.0:${CORE_PORT}091\"%" $HOME/$CORE_FOLDER/config/app.toml

# Set Config Pruning
pruning="custom"
pruning_keep_recent="100"
pruning_keep_every="0"
pruning_interval="19"
sed -i -e "s/^pruning *=.*/pruning = \"$pruning\"/" $HOME/$CORE_FOLDER/config/app.toml
sed -i -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \"$pruning_keep_recent\"/" $HOME/$CORE_FOLDER/config/app.toml
sed -i -e "s/^pruning-keep-every *=.*/pruning-keep-every = \"$pruning_keep_every\"/" $HOME/$CORE_FOLDER/config/app.toml
sed -i -e "s/^pruning-interval *=.*/pruning-interval = \"$pruning_interval\"/" $HOME/$CORE_FOLDER/config/app.toml

# Set minimum gas price
sed -i -e "s/^minimum-gas-prices *=.*/minimum-gas-prices = \"0.001$CORE_DENOM\"/" $HOME/$CORE_FOLDER/config/app.toml

# Set config snapshot
sed -i -e "s/^snapshot-interval *=.*/snapshot-interval = \"2000\"/" $HOME/$CORE_FOLDER/config/app.toml
sed -i -e "s/^snapshot-keep-recent *=.*/snapshot-keep-recent = \"5\"/" $HOME/$CORE_FOLDER/config/app.toml

# Create Service
sudo tee /etc/systemd/system/$CORE.service > /dev/null <<EOF
[Unit]
Description=$CORE
After=network-online.target
[Service]
User=$USER
ExecStart=$(which $CORE) start --home $HOME/$CORE_FOLDER
Restart=on-failure
RestartSec=3
LimitNOFILE=4096
[Install]
WantedBy=multi-user.target
EOF

# Register And Start Service
sudo systemctl daemon-reload
sudo systemctl enable $CORE
sudo systemctl start $CORE

echo -e "\e[1m\e[31mSETUP FINISHED\e[0m"
echo ""
echo -e "CHECK RUNNING LOGS : \e[1m\e[31mjournalctl -fu $CORE -o cat\e[0m"
echo -e "CHECK LOCAL STATUS : \e[1m\e[31mcurl -s localhost:${CORE_PORT}657/status | jq .result.sync_info\e[0m"
echo ""

# End
