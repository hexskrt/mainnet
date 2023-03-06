#
# // Copyright (C) 2023 Salman Wahib Recoded By Hexnodes
#

echo -e "\033[0;32m"
echo "    ██   ██ ███████ ██   ██ ███    ██  ██████  ██████  ███████ ███████";
echo "    ██   ██ ██       ██ ██  ████   ██ ██    ██ ██   ██ ██      ██     "; 
echo "    ███████ █████     ███   ██ ██  ██ ██    ██ ██   ██ █████   ███████"; 
echo "    ██   ██ ██       ██ ██  ██  ██ ██ ██    ██ ██   ██ ██           ██"; 
echo "    ██   ██ ███████ ██   ██ ██   ████  ██████  ██████  ███████ ███████";
echo "              Automatic Installer for LumenX Network v1.3.3 ";
echo -e "\e[0m"

sleep 1

# Variable
LMX_WALLET=wallet
LMX=lumenxd
LMX_ID=LumenX
LMX_FOLDER=.lumenx
LMX_VER=v1.3.3
LMX_REPO=https://github.com/cryptonetD/lumenx.git
LMX_GENESIS=https://raw.githubusercontent.com/sxlzptprjkt/resource/master/mainnet/lumenx/genesis.json
LMX_ADDRBOOK=https://raw.githubusercontent.com/sxlzptprjkt/resource/master/mainnet/lumenx/addrbook.json
LMX_DENOM=ulumen
LMX_PORT=27

echo "export LMX_WALLET=${LMX_WALLET}" >> $HOME/.bash_profile
echo "export LMX=${LMX}" >> $HOME/.bash_profile
echo "export LMX_ID=${LMX_ID}" >> $HOME/.bash_profile
echo "export LMX_FOLDER=${LMX_FOLDER}" >> $HOME/.bash_profile
echo "export LMX_VER=${LMX_VER}" >> $HOME/.bash_profile
echo "export LMX_REPO=${LMX_REPO}" >> $HOME/.bash_profile
echo "export LMX_GENESIS=${LMX_GENESIS}" >> $HOME/.bash_profile
echo "export LMX_ADDRBOOK=${LMX_ADDRBOOK}" >> $HOME/.bash_profile
echo "export LMX_DENOM=${LMX_DENOM}" >> $HOME/.bash_profile
echo "export LMX_PORT=${LMX_PORT}" >> $HOME/.bash_profile
source $HOME/.bash_profile

# Set Vars
if [ ! $LMX_NODENAME ]; then
        read -p "hexskrt@hexnodes:~# [ENTER YOUR NODE] > " LMX_NODENAME
        echo 'export LMX_NODENAME='$LMX_NODENAME >> $HOME/.bash_profile
fi
echo ""
echo -e "YOUR NODE NAME : \e[1m\e[31m$LMX_NODENAME\e[0m"
echo -e "NODE CHAIN ID  : \e[1m\e[31m$LMX_ID\e[0m"
echo -e "NODE PORT      : \e[1m\e[31m$LMX_PORT\e[0m"
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

# Get mainnet version of LMXelon
cd $HOME
rm -rf $LMX
git clone $LMX_REPO
cd $LMX_FOLDER
git checkout $LMX_VER
make install
sudo mv ~/go/bin/$LMX /usr/local/bin/$LMX

# Init generation
$LMX config chain-id $LMX_ID
$LMX config keyring-backend test
$LMX config node tcp://localhost:${LMX_PORT}657
$LMX init $LMX_NODENAME --chain-id $LMX_ID

# Set peers and seeds
PEERS="39674b41ec5ffaf275977a147163c544e3fda03a@peers-lumenx.sxlzptprjkt.xyz:26656"
SEEDS="ff14d88ffa802336e37632f4deac3eac638a4e95@seeds-lumenx.sxlzptprjkt.xyz:26656"
sed -i -e "s|^seeds *=.*|seeds = \"$SEEDS\"|" $HOME/$LMX_FOLDER/config/config.toml

# Download genesis and addrbook
curl -Ls $LMX_GENESIS > $HOME/$LMX_FOLDER/config/genesis.json
curl -Ls $LMX_ADDRBOOK > $HOME/$LMX_FOLDER/config/addrbook.json

# Set Port
sed -i.bak -e "s%^proxy_app = \"tcp://127.0.0.1:26658\"%proxy_app = \"tcp://127.0.0.1:${LMX_PORT}658\"%; s%^laddr = \"tcp://127.0.0.1:26657\"%laddr = \"tcp://127.0.0.1:${LMX_PORT}657\"%; s%^pprof_laddr = \"localhost:6060\"%pprof_laddr = \"localhost:${LMX_PORT}060\"%; s%^laddr = \"tcp://0.0.0.0:26656\"%laddr = \"tcp://0.0.0.0:${LMX_PORT}656\"%; s%^prometheus_listen_addr = \":26660\"%prometheus_listen_addr = \":${LMX_PORT}660\"%" $HOME/$LMX_FOLDER/config/config.toml
sed -i.bak -e "s%^address = \"tcp://0.0.0.0:1317\"%address = \"tcp://0.0.0.0:${LMX_PORT}317\"%; s%^address = \":8080\"%address = \":${LMX_PORT}080\"%; s%^address = \"0.0.0.0:9090\"%address = \"0.0.0.0:${LMX_PORT}090\"%; s%^address = \"0.0.0.0:9091\"%address = \"0.0.0.0:${LMX_PORT}091\"%" $HOME/$LMX_FOLDER/config/app.toml

# Set Config Pruning
pruning="custom"
pruning_keep_recent="100"
pruning_keep_every="0"
pruning_interval="19"
sed -i -e "s/^pruning *=.*/pruning = \"$pruning\"/" $HOME/$LMX_FOLDER/config/app.toml
sed -i -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \"$pruning_keep_recent\"/" $HOME/$LMX_FOLDER/config/app.toml
sed -i -e "s/^pruning-keep-every *=.*/pruning-keep-every = \"$pruning_keep_every\"/" $HOME/$LMX_FOLDER/config/app.toml
sed -i -e "s/^pruning-interval *=.*/pruning-interval = \"$pruning_interval\"/" $HOME/$LMX_FOLDER/config/app.toml

# Set minimum gas price
sed -i -e "s/^minimum-gas-prices *=.*/minimum-gas-prices = \"0.0025$LMX_DENOM\"/" $HOME/$LMX_FOLDER/config/app.toml

# Enable snapshots
sed -i -e "s/^snapshot-interval *=.*/snapshot-interval = \"2000\"/" $HOME/$LMX_FOLDER/config/app.toml
sed -i -e "s/^snapshot-keep-recent *=.*/snapshot-keep-recent = \"5\"/" $HOME/$LMX_FOLDER/config/app.toml
$LMX tendermint unsafe-reset-all --home $HOME/$LMX_FOLDER
curl -L https://lumenx.service.indonode.net/lumenx-snapshot.tar.lz4 | lz4 -dc - | tar -xf - -C $HOME/$LMX_FOLDER

# Create Service
sudo tee /etc/systemd/system/$LMX.service > /dev/null <<EOF
[Unit]
Description=$LMX
After=network-online.target
[Service]
User=$USER
ExecStart=$(which $LMX) start --home $HOME/$LMX_FOLDER
Restart=on-failure
RestartSec=3
LimitNOFILE=4096
[Install]
WantedBy=multi-user.target
EOF

# Register And Start Service
sudo systemctl daemon-reload
sudo systemctl enable $LMX
sudo systemctl start $LMX

echo -e "\e[1m\e[31mSETUP FINISHED\e[0m"
echo ""
echo -e "CHECK RUNNING LOGS : \e[1m\e[31mjournalctl -fu $LMX -o cat\e[0m"
echo -e "CHECK LOCAL STATUS : \e[1m\e[31mcurl -s localhost:${LMX_PORT}657/status | jq .result.sync_info\e[0m"
echo ""

# End
