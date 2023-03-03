#
# // Copyright (C) 2023 Salman Wahib Recoded By Hexnodes
#

echo -e "\033[0;32m"
echo "    ██   ██ ███████ ██   ██ ███    ██  ██████  ██████  ███████ ███████";
echo "    ██   ██ ██       ██ ██  ████   ██ ██    ██ ██   ██ ██      ██     "; 
echo "    ███████ █████     ███   ██ ██  ██ ██    ██ ██   ██ █████   ███████"; 
echo "    ██   ██ ██       ██ ██  ██  ██ ██ ██    ██ ██   ██ ██           ██"; 
echo "    ██   ██ ███████ ██   ██ ██   ████  ██████  ██████  ███████ ███████";
echo "                 Automatic Installer for Echelon Blockchain ";
echo -e "\e[0m"

sleep 1

# Variable
ECH_WALLET=wallet
ECH=echelond
ECH_ID=echelon_3000-3
ECH_FOLDER=.echelond
ECH_VER=v2.0.0
ECH_REPO=https://github.com/echelonfoundation/echelon
ECH_GENESIS=https://gist.githubusercontent.com/echelonfoundation/ee862f58850fc1b5ee6a6fdccc3130d2/raw/55c2c4ea2fee8a9391d0dc55b2c272adb804054a/genesis.json
ECH_ADDRBOOK=https://ech.world/latest/addrbook.json
ECH_DENOM=aechelon
ECH_PORT=101

echo "export ECH_WALLET=${ECH_WALLET}" >> $HOME/.bash_profile
echo "export ECH=${ECH}" >> $HOME/.bash_profile
echo "export ECH_ID=${ECH_ID}" >> $HOME/.bash_profile
echo "export ECH_FOLDER=${ECH_FOLDER}" >> $HOME/.bash_profile
echo "export ECH_VER=${ECH_VER}" >> $HOME/.bash_profile
echo "export ECH_REPO=${ECH_REPO}" >> $HOME/.bash_profile
echo "export ECH_GENESIS=${ECH_GENESIS}" >> $HOME/.bash_profile
echo "export ECH_ADDRBOOK=${ECH_ADDRBOOK}" >> $HOME/.bash_profile
echo "export ECH_DENOM=${ECH_DENOM}" >> $HOME/.bash_profile
echo "export ECH_PORT=${ECH_PORT}" >> $HOME/.bash_profile
source $HOME/.bash_profile

# Set Vars
if [ ! $ECH_NODENAME ]; then
        read -p "hexskrt@hexnodes:~# [ENTER YOUR NODE] > " ECH_NODENAME
        echo 'export ECH_NODENAME='$ECH_NODENAME >> $HOME/.bash_profile
fi
echo ""
echo -e "YOUR NODE NAME : \e[1m\e[31m$ECH_NODENAME\e[0m"
echo -e "NODE CHAIN ID  : \e[1m\e[31m$ECH_ID\e[0m"
echo -e "NODE PORT      : \e[1m\e[31m$ECH_PORT\e[0m"
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

# Get mainnet version of echelon
cd $HOME
rm -rf $ECH
git clone $ECH_REPO
cd echelon
git checkout $ECH_VER
make install
sudo cp ~/go/bin/echelond /usr/local/bin/echelond

# Init generation
$ECH config chain-id $ECH_ID
$ECH config keyring-backend test
$ECH config node tcp://localhost:${ECH_PORT}657
$ECH init $ECH_NODENAME --chain-id $ECH_ID

# Set peers and seeds
PEERS=""
SEEDS="ab8febad726c213fac69361c8fd47adc3f302e64@38.242.143.4:26656,fda4d1c914a667e72181839fcfddb238c7e480c8@85.239.240.101:26656"
sed -i -e "s|^seeds *=.*|seeds = \"$SEEDS\"|" $HOME/$ECH_FOLDER/config/config.toml

# Download genesis and addrbook
curl -Ls $ECH_GENESIS > $HOME/$ECH_FOLDER/config/genesis.json
curl -Ls $ECH_ADDRBOOK > $HOME/$ECH_FOLDER/config/addrbook.json

# Set Port
sed -i.bak -e "s%^proxy_app = \"tcp://127.0.0.1:26658\"%proxy_app = \"tcp://127.0.0.1:${ECH_PORT}658\"%; s%^laddr = \"tcp://127.0.0.1:26657\"%laddr = \"tcp://127.0.0.1:${ECH_PORT}657\"%; s%^pprof_laddr = \"localhost:6060\"%pprof_laddr = \"localhost:${ECH_PORT}060\"%; s%^laddr = \"tcp://0.0.0.0:26656\"%laddr = \"tcp://0.0.0.0:${ECH_PORT}656\"%; s%^prometheus_listen_addr = \":26660\"%prometheus_listen_addr = \":${ECH_PORT}660\"%" $HOME/$ECH_FOLDER/config/config.toml
sed -i.bak -e "s%^address = \"tcp://0.0.0.0:1317\"%address = \"tcp://0.0.0.0:${ECH_PORT}317\"%; s%^address = \":8080\"%address = \":${ECH_PORT}080\"%; s%^address = \"0.0.0.0:9090\"%address = \"0.0.0.0:${ECH_PORT}090\"%; s%^address = \"0.0.0.0:9091\"%address = \"0.0.0.0:${ECH_PORT}091\"%" $HOME/$ECH_FOLDER/config/app.toml

# Set Config Pruning
sed -i -e "s/^pruning *=.*/pruning = \"nothing\"/" $HOME/.echelond/config/app.toml
indexer="null" && \
sed -i -e "s/^indexer *=.*/indexer = \"$indexer\"/" $HOME/.echelond/config/config.toml

# Set minimum gas price
sed -i -e "s/^minimum-gas-prices *=.*/minimum-gas-prices = \"0.0001$ECH_DENOM\"/" $HOME/$ECH_FOLDER/config/app.toml

# Enable snapshots
$ECH tendermint unsafe-reset-all --home $HOME/$ECH_FOLDER --keep-addr-book
curl -L curl -L https://snapshot.echelon.spt-node.my.id/echelon/echelon-snapshot.tar.lz4 | lz4 -c -d - | tar -x -C $HOME/.echelond

# Create Service
sudo tee /etc/systemd/system/$ECH.service > /dev/null <<EOF
[Unit]
Description=$ECH
After=network-online.target

[Service]
User=$USER
ExecStart=$(which $ECH) start --home $HOME/$ECH_FOLDER
Restart=on-failure
RestartSec=3
LimitNOFILE=4096

[Install]
WantedBy=multi-user.target
EOF

# Register And Start Service
sudo systemctl daemon-reload
sudo systemctl enable $ECH
sudo systemctl start $ECH

echo -e "\e[1m\e[31mSETUP FINISHED\e[0m"
echo ""
echo -e "CHECK RUNNING LOGS : \e[1m\e[31mjournalctl -fu $ECH -o cat\e[0m"
echo -e "CHECK LOCAL STATUS : \e[1m\e[31mcurl -s localhost:${ECH_PORT}657/status | jq .result.sync_info\e[0m"
echo ""

# End
