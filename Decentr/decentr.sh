#
# // Copyright (C) 2023 Salman Wahib Recoded By Hexnodes
#

echo -e "\033[0;32m"
echo "    ██   ██ ███████ ██   ██ ███    ██  ██████  ██████  ███████ ███████";
echo "    ██   ██ ██       ██ ██  ████   ██ ██    ██ ██   ██ ██      ██     "; 
echo "    ███████ █████     ███   ██ ██  ██ ██    ██ ██   ██ █████   ███████"; 
echo "    ██   ██ ██       ██ ██  ██  ██ ██ ██    ██ ██   ██ ██           ██"; 
echo "    ██   ██ ███████ ██   ██ ██   ████  ██████  ██████  ███████ ███████";
echo "               Automatic Installer for Decentr v1.6.2 ";
echo -e "\e[0m"

sleep 1

# Variable
DEC_WALLET=wallet
DEC=decentrd
DEC_ID=mainnet-3
DEC_FOLDER=.decentr
DEC_VER=v1.6.2
DEC_REPO=https://github.com/Decentr-net/decentr
DEC_GENESIS=http://snapcrot.hexskrt.net/decentr/genesis.json
DEC_ADDRBOOK=http://snapcrot.hexskrt.net/decentr/addrbook.json
DEC_DENOM=udec
DEC_PORT=29

echo "export DEC_WALLET=${DEC_WALLET}" >> $HOME/.bash_profile
echo "export DEC=${DEC}" >> $HOME/.bash_profile
echo "export DEC_ID=${DEC_ID}" >> $HOME/.bash_profile
echo "export DEC_FOLDER=${DEC_FOLDER}" >> $HOME/.bash_profile
echo "export DEC_VER=${DEC_VER}" >> $HOME/.bash_profile
echo "export DEC_REPO=${DEC_REPO}" >> $HOME/.bash_profile
echo "export DEC_GENESIS=${DEC_GENESIS}" >> $HOME/.bash_profile
echo "export DEC_ADDRBOOK=${DEC_ADDRBOOK}" >> $HOME/.bash_profile
echo "export DEC_DENOM=${DEC_DENOM}" >> $HOME/.bash_profile
echo "export DEC_PORT=${DEC_PORT}" >> $HOME/.bash_profile
source $HOME/.bash_profile

# Set Vars
if [ ! $DEC_NODENAME ]; then
        read -p "hexskrt@hexnodes:~# [ENTER YOUR NODE] > " DEC_NODENAME
        echo 'export DEC_NODENAME='$DEC_NODENAME >> $HOME/.bash_profile
fi
echo ""
echo -e "YOUR NODE NAME : \e[1m\e[31m$DEC_NODENAME\e[0m"
echo -e "NODE CHAIN ID  : \e[1m\e[31m$DEC_ID\e[0m"
echo -e "NODE PORT      : \e[1m\e[31m$DEC_PORT\e[0m"
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

# Get mainnet version of DEC Network
cd $HOME
rm -rf $DEC
git clone $DEC_REPO
cd decentr
git checkout $DEC_VER
make install
sudo mv ~/go/bin/$DEC /usr/local/bin/$DEC

# Init generation
$DEC config chain-id $DEC_ID
$DEC config keyring-backend file
$DEC config node tcp://localhost:${DEC_PORT}657
$DEC init $DEC_NODENAME --chain-id $DEC_ID

# Set Seeds
SEEDS="97b2d394748c8c2bdd8ea1d16902daa1c8db1292@185.188.249.18:26656"
sed -i -e "s|^seeds *=.*|seeds = \"$SEEDS\"|" $HOME/$DEC_FOLDER/config/config.toml

# Download genesis and addrbook
curl -Ls $DEC_GENESIS > $HOME/$DEC_FOLDER/config/genesis.json
curl -Ls $DEC_ADDRBOOK > $HOME/$DEC_FOLDER/config/addrbook.json

# Set Port
sed -i.bak -e "s%^proxy_app = \"tcp://127.0.0.1:26658\"%proxy_app = \"tcp://127.0.0.1:${DEC_PORT}658\"%; s%^laddr = \"tcp://127.0.0.1:26657\"%laddr = \"tcp://127.0.0.1:${DEC_PORT}657\"%; s%^pprof_laddr = \"localhost:6060\"%pprof_laddr = \"localhost:${DEC_PORT}060\"%; s%^laddr = \"tcp://0.0.0.0:26656\"%laddr = \"tcp://0.0.0.0:${DEC_PORT}656\"%; s%^prometheus_listen_addr = \":26660\"%prometheus_listen_addr = \":${DEC_PORT}660\"%" $HOME/$DEC_FOLDER/config/config.toml
sed -i.bak -e "s%^address = \"tcp://0.0.0.0:1317\"%address = \"tcp://0.0.0.0:${DEC_PORT}317\"%; s%^address = \":8080\"%address = \":${DEC_PORT}080\"%; s%^address = \"0.0.0.0:9090\"%address = \"0.0.0.0:${DEC_PORT}090\"%; s%^address = \"0.0.0.0:9091\"%address = \"0.0.0.0:${DEC_PORT}091\"%" $HOME/$DEC_FOLDER/config/app.toml

# Set Config Pruning
pruning="custom"
pruning_keep_recent="100"
pruning_keep_every="0"
pruning_interval="19"
sed -i -e "s/^pruning *=.*/pruning = \"$pruning\"/" $HOME/$DEC_FOLDER/config/app.toml
sed -i -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \"$pruning_keep_recent\"/" $HOME/$DEC_FOLDER/config/app.toml
sed -i -e "s/^pruning-keep-every *=.*/pruning-keep-every = \"$pruning_keep_every\"/" $HOME/$DEC_FOLDER/config/app.toml
sed -i -e "s/^pruning-interval *=.*/pruning-interval = \"$pruning_interval\"/" $HOME/$DEC_FOLDER/config/app.toml

# Set minimum gas price
sed -i -e "s/^minimum-gas-prices *=.*/minimum-gas-prices = \"0.0025$DEC_DENOM\"/" $HOME/$DEC_FOLDER/config/app.toml
sed -i -e "s/^snapshot-interval *=.*/snapshot-interval = \"1000\"/" $HOME/$DEC_FOLDER/config/app.toml
sed -i -e "s/^snapshot-keep-recent *=.*/snapshot-keep-recent = \"2\"/" $HOME/$DEC_FOLDER/config/app.toml

# Enable Snapshot
$DEC tendermint unsafe-reset-all --home $HOME/$DEC_FOLDER
curl -o - -L http://snapcrot.hexskrt.net/decentr/dec.latest.tar.lz4 | lz4 -c -d - | tar -x -C $HOME/.decentr

# Create Service
sudo tee /etc/systemd/system/$DEC.service > /dev/null <<EOF
[Unit]
Description=$DEC
After=network-online.target
[Service]
User=$USER
ExecStart=$(which $DEC) start --home $HOME/$DEC_FOLDER
Restart=on-failure
RestartSec=3
LimitNOFILE=4096
[Install]
WantedBy=multi-user.target
EOF

# Register And Start Service
sudo systemctl daemon-reload
sudo systemctl enable $DEC
sudo systemctl start $DEC

echo -e "\e[1m\e[31mSETUP FINISHED\e[0m"
echo ""
echo -e "CHECK RUNNING LOGS : \e[1m\e[31mjournalctl -fu $DEC -o cat\e[0m"
echo -e "CHECK LOCAL STATUS : \e[1m\e[31mcurl -s localhost:${DEC_PORT}657/status | jq .result.sync_info\e[0m"
echo ""

# End
