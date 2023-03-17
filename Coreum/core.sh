
#
# // Copyright (C) 2022 Salman Wahib (sxlmnwb)
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
BINARY=cosmovisor
CORE_ID=coreum-mainnet-1
CORE_FOLDER=.core
CORE_VER=v1.0.0
CORE_BINARY=https://github.com/CoreumFoundation/coreum/releases/download
CORE_BIN=cored-linux-amd64
CORE_GENESIS=https://raw.githubusercontent.com/CoreumFoundation/coreum/master/genesis/coreum-mainnet-1.json > $HOME/.core/config/genesis.json
CORE_DENOM=ucore
CORE_PORT=30

echo "export CORE_WALLET=${CORE_WALLET}" >> $HOME/.bash_profile
echo "export CORE=${CORE}" >> $HOME/.bash_profile
echo "export BINARY=${BINARY}" >> $HOME/.bash_profile
echo "export CORE_ID=${CORE_ID}" >> $HOME/.bash_profile
echo "export CORE_FOLDER=${CORE_FOLDER}" >> $HOME/.bash_profile
echo "export CORE_VER=${CORE_VER}" >> $HOME/.bash_profile
echo "export CORE_BINARY=${CORE_BINARY}" >> $HOME/.bash_profile
echo "export CORE_BIN=${CORE_BIN}" >> $HOME/.bash_profile
echo "export CORE_GENESIS=${CORE_GENESIS}" >> $HOME/.bash_profile
echo "export CORE_ADDRBOOK=${CORE_ADDRBOOK}" >> $HOME/.bash_profile
echo "export CORE_DENOM=${CORE_DENOM}" >> $HOME/.bash_profile
echo "export CORE_PORT=${CORE_PORT}" >> $HOME/.bash_profile
source $HOME/.bash_profile

# Set Vars
if [ ! $CORE_NODENAME ]; then
        read -p "sxlzptprjkt@w00t666w00t:~# [ENTER YOUR NODE] > " CORE_NODENAME
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
sudo apt install curl build-essential jq chrony lz4 -y

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

# Get mainnet version of coreum
cd $HOME
curl -Ls $CORE_BINARY/$CORE_VER/$CORE_BIN > $CORE
chmod +x $CORE
go install cosmossdk.io/tools/cosmovisor/cmd/cosmovisor@v1.4.0

# Prepare binaries for Cosmovisor
mkdir -p $HOME/$CORE_FOLDER/$CORE_ID/$BINARY/genesis/bin
mv $CORE $HOME/$CORE_FOLDER/$CORE_ID/$BINARY/genesis/bin/

# Create application symlinks
ln -s $HOME/$CORE_FOLDER/$CORE_ID/$BINARY/genesis $HOME/$CORE_FOLDER/$CORE_ID/$BINARY/current
sudo ln -s $HOME/$CORE_FOLDER/$CORE_ID/$BINARY/current/bin/$CORE /usr/bin/$CORE

# Create Service
sudo tee /etc/systemd/system/$CORE.service > /dev/null << EOF
[Unit]
Description=$BINARY
After=network-online.target

[Service]
User=$USER
ExecStart=$(which $BINARY) run start
Restart=on-failure
RestartSec=10
LimitNOFILE=65535
Environment="DAEMON_HOME=$HOME/$CORE_FOLDER/$CORE_ID"
Environment="DAEMON_NAME=$CORE"
Environment="UNSAFE_SKIP_BACKUP=true"

[Install]
WantedBy=multi-user.target
EOF

# Register Service
sudo systemctl daemon-reload
sudo systemctl enable $CORE

# Init generation
$CORE config chain-id $CORE_ID
$CORE config keyring-backend file
$CORE config node tcp://localhost:${CORE_PORT}657
$CORE init $CORE_NODENAME --chain-id $CORE_ID

# Download genesis and addrbook
curl -Ls $CORE_GENESIS > $HOME/$CORE_FOLDER/$CORE_ID/config/genesis.json

# Set Port
sed -i.bak -e "s%^proxy_app = \"tcp://127.0.0.1:26658\"%proxy_app = \"tcp://127.0.0.1:${CORE_PORT}658\"%; s%^laddr = \"tcp://127.0.0.1:26657\"%laddr = \"tcp://127.0.0.1:${CORE_PORT}657\"%; s%^pprof_laddr = \"localhost:6060\"%pprof_laddr = \"localhost:${CORE_PORT}060\"%; s%^laddr = \"tcp://0.0.0.0:26656\"%laddr = \"tcp://0.0.0.0:${CORE_PORT}656\"%; s%^prometheus_listen_addr = \":26660\"%prometheus_listen_addr = \":${CORE_PORT}660\"%" $HOME/$CORE_FOLDER/$CORE_ID/config/config.toml
sed -i.bak -e "s%^address = \"tcp://0.0.0.0:1317\"%address = \"tcp://0.0.0.0:${CORE_PORT}317\"%; s%^address = \":8080\"%address = \":${CORE_PORT}080\"%; s%^address = \"0.0.0.0:9090\"%address = \"0.0.0.0:${CORE_PORT}090\"%; s%^address = \"0.0.0.0:9091\"%address = \"0.0.0.0:${CORE_PORT}091\"%" $HOME/$CORE_FOLDER/$CORE_ID/config/app.toml

# Set Config Pruning
pruning="custom"
pruning_keep_recent="100"
pruning_keep_every="0"
pruning_interval="19"
sed -i -e "s/^pruning *=.*/pruning = \"$pruning\"/" $HOME/$CORE_FOLDER/$CORE_ID/config/app.toml
sed -i -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \"$pruning_keep_recent\"/" $HOME/$CORE_FOLDER/$CORE_ID/config/app.toml
sed -i -e "s/^pruning-keep-every *=.*/pruning-keep-every = \"$pruning_keep_every\"/" $HOME/$CORE_FOLDER/$CORE_ID/config/app.toml
sed -i -e "s/^pruning-interval *=.*/pruning-interval = \"$pruning_interval\"/" $HOME/$CORE_FOLDER/$CORE_ID/config/app.toml

# Set minimum gas price
sed -i -e "s/^minimum-gas-prices *=.*/minimum-gas-prices = \"0$CORE_DENOM\"/" $HOME/$CORE_FOLDER/$CORE_ID/config/app.toml

#Start Service
sudo systemctl start $CORE

echo -e "\e[1m\e[31mSETUP FINISHED\e[0m"
echo ""
echo -e "CHECK STATUS BINARY : \e[1m\e[31msystemctl status $CORE\e[0m"
echo -e "CHECK RUNNING LOGS  : \e[1m\e[31mjournalctl -fu $CORE -o cat\e[0m"
echo -e "CHECK LOCAL STATUS  : \e[1m\e[31mcurl -s localhost:${CORE_PORT}657/status | jq .result.sync_info\e[0m"
echo ""

# End
