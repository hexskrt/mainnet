#
# // Copyright (C) 2023 Salman Wahib Recoded By Hexnodes
#

echo -e "\033[0;32m"
echo "    ██   ██ ███████ ██   ██ ███    ██  ██████  ██████  ███████ ███████";
echo "    ██   ██ ██       ██ ██  ████   ██ ██    ██ ██   ██ ██      ██     "; 
echo "    ███████ █████     ███   ██ ██  ██ ██    ██ ██   ██ █████   ███████"; 
echo "    ██   ██ ██       ██ ██  ██  ██ ██ ██    ██ ██   ██ ██           ██"; 
echo "    ██   ██ ███████ ██   ██ ██   ████  ██████  ██████  ███████ ███████";
echo "        Automatic Installer for TERPM Network | Chain ID : morocco-1 ";
echo -e "\e[0m"
sleep 1

# Variable
TERPM_WALLET=wallet
TERPM=TERPMd
TERPM_ID=morocco-1
TERPM_FOLDER=.TERPM
TERPM_VERSION=v1.0.0-stable
TERPM_REPO=https://github.com/TERPMnetwork/TERPM-core.git
TERPM_ADDRBOOK=https://snapshots.nodestake.top/TERPM/addrbook.json
TERPM_GENESIS=https://snapshots.nodestake.top/TERPM/genesis.json
TERPM_DENOM=upersyx
TERPM_PORT=14

echo "export TERPM_WALLET=${TERPM_WALLET}" >> $HOME/.bash_profile
echo "export TERPM=${TERPM}" >> $HOME/.bash_profile
echo "export TERPM_ID=${TERPM_ID}" >> $HOME/.bash_profile
echo "export TERPM_FOLDER=${TERPM_FOLDER}" >> $HOME/.bash_profile
echo "export TERPM_VER=${TERPM_VER}" >> $HOME/.bash_profile
echo "export TERPM_REPO=${TERPM_REPO}" >> $HOME/.bash_profile
echo "export TERPM_DENOM=${TERPM_DENOM}" >> $HOME/.bash_profile
echo "export TERPM_PORT=${TERPM_PORT}" >> $HOME/.bash_profile
source $HOME/.bash_profile

# Set Vars
if [ ! $TERPM_NODENAME ]; then
        read -p "hexskrt@hexnodes:~# [ENTER YOUR NODE] > " TERPM_NODENAME
        echo 'export TERPM_NODENAME='$TERPM_NODENAME >> $HOME/.bash_profile
fi
echo ""
echo -e "YOUR NODE NAME : \e[1m\e[31m$TERPM_NODENAME\e[0m"
echo -e "NODE CHAIN ID  : \e[1m\e[31m$TERPM_ID\e[0m"
echo -e "NODE PORT      : \e[1m\e[31m$TERPM_PORT\e[0m"
echo ""

# Install GO
ver="1.19.2"
cd $HOME
wget "https://golang.org/dl/go$ver.linux-amd64.tar.gz"
sudo rm -rf /usr/local/go
sudo tar -C /usr/local -xzf "go$ver.linux-amd64.tar.gz"
rm "go$ver.linux-amd64.tar.gz"
echo "export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin" >> ~/.bash_profile
source ~/.bash_profile
go version

# Get version of TERP Network
cd $HOME
rm -rf terp-core
cd $HOME
git clone $TERPM_REPO
cd terp-core
git checkout $TERPM_VERSION
make install

$TERPM config chain-id $TERPM_ID
$TERPM config keyring-backend file
$TERPM config node tcp://localhost:${TERPM_PORT}657
$TERPM init $TERPM_NODENAME --chain-id $TERPM_ID

# Set peers and seeds
SEEDS="c71e63b5da517984d55d36d00dc0dc2413d0ce03@seed.terp.network:26656"
PEERS=""
sed -i -e "s/^seeds *=.*/seeds = \"$SEEDS\"/; s/^persistent_peers *=.*/persistent_peers = \"$PEERS\"/" $HOME/$TERPM_FOLDER/config/config.toml

# Download Genesis & Addrbook
curl -Ls $TERPM_GENESIS > $HOME/$TERPM_FOLDER/config/genesis.json
curl -Ls $TERPM_ADDRBOOK > $HOME/$TERPM_FOLDER/config/addrbook.json

# Set Port
sed -i.bak -e "s%^proxy_app = \"tcp://127.0.0.1:26658\"%proxy_app = \"tcp://127.0.0.1:${TERPM_PORT}658\"%; s%^laddr = \"tcp://127.0.0.1:26657\"%laddr = \"tcp://127.0.0.1:${TERPM_PORT}657\"%; s%^pprof_laddr = \"localhost:6060\"%pprof_laddr = \"localhost:${TERPM_PORT}060\"%; s%^laddr = \"tcp://0.0.0.0:26656\"%laddr = \"tcp://0.0.0.0:${TERPM_PORT}656\"%; s%^prometheus_listen_addr = \":26660\"%prometheus_listen_addr = \":${TERPM_PORT}660\"%" $HOME/$TERPM_FOLDER/config/config.toml
sed -i.bak -e "s%^address = \"tcp://0.0.0.0:1317\"%address = \"tcp://0.0.0.0:${TERPM_PORT}317\"%; s%^address = \":8080\"%address = \":${TERPM_PORT}080\"%; s%^address = \"0.0.0.0:9090\"%address = \"0.0.0.0:${TERPM_PORT}090\"%; s%^address = \"0.0.0.0:9091\"%address = \"0.0.0.0:${TERPM_PORT}091\"%" $HOME/$TERPM_FOLDER/config/app.toml

# Set Config Pruning
pruning="custom"
pruning_keep_recent="100"
pruning_keep_every="0"
pruning_interval="19"
sed -i -e "s/^pruning *=.*/pruning = \"$pruning\"/" $HOME/$TERPM_FOLDER/config/app.toml
sed -i -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \"$pruning_keep_recent\"/" $HOME/$TERPM_FOLDER/config/app.toml
sed -i -e "s/^pruning-keep-every *=.*/pruning-keep-every = \"$pruning_keep_every\"/" $HOME/$TERPM_FOLDER/config/app.toml
sed -i -e "s/^pruning-interval *=.*/pruning-interval = \"$pruning_interval\"/" $HOME/$TERPM_FOLDER/config/app.toml

# Set minimum gas price
sed -i -e "s/^minimum-gas-prices *=.*/minimum-gas-prices = \"0.001$TERPM_DENOM\"/" $HOME/$TERPM_FOLDER/config/app.toml

# Set config snapshot
sed -i -e "s/^snapshot-interval *=.*/snapshot-interval = \"2000\"/" $HOME/$TERPM_FOLDER/config/app.toml
sed -i -e "s/^snapshot-keep-recent *=.*/snapshot-keep-recent = \"5\"/" $HOME/$TERPM_FOLDER/config/app.toml

# Enable Snapshot
$TERPM tendermint unsafe-reset-all --home $HOME/$TERPM_FOLDER --keep-addr-book
SNAP_NAME=$(curl -s https://snapshots.nodestake.top/TERPM/ | egrep -o ">20.*\.tar.lz4" | tr -d ">")
curl -o - -L https://snapshots.nodestake.top/TERPM/${SNAP_NAME}  | lz4 -c -d - | tar -x -C $HOME/.TERPM

# Create Service
sudo tee /etc/systemd/system/$TERPM.service > /dev/null <<EOF
[Unit]
Description=$TERPM
After=network-online.target
[Service]
User=$USER
ExecStart=$(which $TERPM) start --home $HOME/$TERPM_FOLDER
Restart=on-failure
RestartSec=3
LimitNOFILE=4096
[Install]
WantedBy=multi-user.target
EOF

# Register And Start Service
sudo systemctl daemon-reload
sudo systemctl enable $TERPM
sudo systemctl start $TERPM

echo -e "\e[1m\e[31mSETUP FINISHED\e[0m"
echo ""
echo -e "CHECK RUNNING LOGS : \e[1m\e[31mjournalctl -fu $TERPM -o cat\e[0m"
echo -e "CHECK LOCAL STATUS : \e[1m\e[31mcurl -s localhost:${TERPM_PORT}657/status | jq .result.sync_info\e[0m"
echo ""

# End
