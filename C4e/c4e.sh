#
# // Copyright (C) 2023 Salman Wahib Recoded By Hexnodes
#

echo -e "\033[0;32m"
echo "    ██   ██ ███████ ██   ██ ███    ██  ██████  ██████  ███████ ███████";
echo "    ██   ██ ██       ██ ██  ████   ██ ██    ██ ██   ██ ██      ██     "; 
echo "    ███████ █████     ███   ██ ██  ██ ██    ██ ██   ██ █████   ███████"; 
echo "    ██   ██ ██       ██ ██  ██  ██ ██ ██    ██ ██   ██ ██           ██"; 
echo "    ██   ██ ███████ ██   ██ ██   ████  ██████  ██████  ███████ ███████";
echo "              Automatic Installer for C4E Network v1.1.0 ";
echo -e "\e[0m"

sleep 1

# Variable
C4E_WALLET=wallet
C4E=c4ed
C4E_ID=perun-1
C4E_FOLDER=.c4e-chain
C4E_VER=v1.1.0
C4E_REPO=https://github.com/chain4energy/c4e-chain.git
C4E_GENESIS=https://raw.githubusercontent.com/chain4energy/c4e-chains/main/perun-1/genesis.json
C4E_ADDRBOOK=https://raw.githubusercontent.com/BccNodes/Testnet-Guides/main/Chain4Energy%20Mainnet/addrbook.json
C4E_DENOM=uc4e
C4E_PORT=27

echo "export C4E_WALLET=${C4E_WALLET}" >> $HOME/.bash_profile
echo "export C4E=${C4E}" >> $HOME/.bash_profile
echo "export C4E_ID=${C4E_ID}" >> $HOME/.bash_profile
echo "export C4E_FOLDER=${C4E_FOLDER}" >> $HOME/.bash_profile
echo "export C4E_VER=${C4E_VER}" >> $HOME/.bash_profile
echo "export C4E_REPO=${C4E_REPO}" >> $HOME/.bash_profile
echo "export C4E_GENESIS=${C4E_GENESIS}" >> $HOME/.bash_profile
echo "export C4E_ADDRBOOK=${C4E_ADDRBOOK}" >> $HOME/.bash_profile
echo "export C4E_DENOM=${C4E_DENOM}" >> $HOME/.bash_profile
echo "export C4E_PORT=${C4E_PORT}" >> $HOME/.bash_profile
source $HOME/.bash_profile

# Set Vars
if [ ! $C4E_NODENAME ]; then
        read -p "hexskrt@hexnodes:~# [ENTER YOUR NODE] > " C4E_NODENAME
        echo 'export C4E_NODENAME='$C4E_NODENAME >> $HOME/.bash_profile
fi
echo ""
echo -e "YOUR NODE NAME : \e[1m\e[31m$C4E_NODENAME\e[0m"
echo -e "NODE CHAIN ID  : \e[1m\e[31m$C4E_ID\e[0m"
echo -e "NODE PORT      : \e[1m\e[31m$C4E_PORT\e[0m"
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

# Get mainnet version of C4Eelon
cd $HOME
rm -rf $C4E
git clone $C4E_REPO
cd c4e-chain
git checkout $C4E_VER
make install
sudo mv ~/go/bin/$C4E /usr/local/bin/$C4E

# Init generation
$C4E config chain-id $C4E_ID
$C4E config keyring-backend file
$C4E config node tcp://localhost:${C4E_PORT}657
$C4E init $C4E_NODENAME --chain-id $C4E_ID

# Set peers and seeds
PEERS="96b621f209eb2244e6b0976a8918e1f6536d9a3d@34.208.153.193:26656,c1bfac5b59966c2fc97d48540b9614f34785fbf3@57.128.144.137:26656,f5d50df79f2aa5a9d18576147f59b8807347b6f9@66.70.178.78:26656,85acd1e5580c950f5ede07c3da4bd814d42cf323@95.179.190.59:26656,fe9a629d1bb3e1e958b2013b6747e3dbbd7ba8d3@149.102.130.176:26656,37f3f290c59dcce9109ac828e9839dc9c22be718@188.34.134.24:26656,bb9cbee9c391f5b0744d5da0ea1abc17ed0ca1b2@159.69.56.25:26656,2f6141859c28c088514b46f7783509aeeb87553f@141.94.193.12:11656"
SEEDS=""
sed -i -e "s|^seeds *=.*|seeds = \"$SEEDS\"|" $HOME/$C4E_FOLDER/config/config.toml
sed -i -e "s|^persistent_peers *=.*|persistent_peers = \"$PEERS\"|" $HOME/$C4E_FOLDER/config/config.toml

# Download genesis and addrbook
curl -Ls $C4E_GENESIS > $HOME/$C4E_FOLDER/config/genesis.json
curl -Ls $C4E_ADDRBOOK > $HOME/$C4E_FOLDER/config/addrbook.json

# Set Port
sed -i.bak -e "s%^proxy_app = \"tcp://127.0.0.1:26658\"%proxy_app = \"tcp://127.0.0.1:${C4E_PORT}658\"%; s%^laddr = \"tcp://127.0.0.1:26657\"%laddr = \"tcp://127.0.0.1:${C4E_PORT}657\"%; s%^pprof_laddr = \"localhost:6060\"%pprof_laddr = \"localhost:${C4E_PORT}060\"%; s%^laddr = \"tcp://0.0.0.0:26656\"%laddr = \"tcp://0.0.0.0:${C4E_PORT}656\"%; s%^prometheus_listen_addr = \":26660\"%prometheus_listen_addr = \":${C4E_PORT}660\"%" $HOME/$C4E_FOLDER/config/config.toml
sed -i.bak -e "s%^address = \"tcp://0.0.0.0:1317\"%address = \"tcp://0.0.0.0:${C4E_PORT}317\"%; s%^address = \":8080\"%address = \":${C4E_PORT}080\"%; s%^address = \"0.0.0.0:9090\"%address = \"0.0.0.0:${C4E_PORT}090\"%; s%^address = \"0.0.0.0:9091\"%address = \"0.0.0.0:${C4E_PORT}091\"%" $HOME/$C4E_FOLDER/config/app.toml

# Set Config Pruning
pruning="custom"
pruning_keep_recent="100"
pruning_keep_every="0"
pruning_interval="19"
sed -i -e "s/^pruning *=.*/pruning = \"$pruning\"/" $HOME/$C4E_FOLDER/config/app.toml
sed -i -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \"$pruning_keep_recent\"/" $HOME/$C4E_FOLDER/config/app.toml
sed -i -e "s/^pruning-keep-every *=.*/pruning-keep-every = \"$pruning_keep_every\"/" $HOME/$C4E_FOLDER/config/app.toml
sed -i -e "s/^pruning-interval *=.*/pruning-interval = \"$pruning_interval\"/" $HOME/$C4E_FOLDER/config/app.toml

# Set minimum gas price
sed -i -e "s/^minimum-gas-prices *=.*/minimum-gas-prices = \"0.0025$C4E_DENOM\"/" $HOME/$C4E_FOLDER/config/app.toml

# Enable snapshots
sed -i -e "s/^snapshot-interval *=.*/snapshot-interval = \"2000\"/" $HOME/$C4E_FOLDER/config/app.toml
sed -i -e "s/^snapshot-keep-recent *=.*/snapshot-keep-recent = \"5\"/" $HOME/$C4E_FOLDER/config/app.toml
$C4E tendermint unsafe-reset-all --home $HOME/$C4E_FOLDER
curl -L http://snap.hexnodes.co/c4e/c4e.latest.tar.lz4 | lz4 -c -d - | tar -x -C $HOME/.c4e-chain

# Create Service
sudo tee /etc/systemd/system/$C4E.service > /dev/null <<EOF
[Unit]
Description=$C4E
After=network-online.target
[Service]
User=$USER
ExecStart=$(which $C4E) start --home $HOME/$C4E_FOLDER
Restart=on-failure
RestartSec=3
LimitNOFILE=4096
[Install]
WantedBy=multi-user.target
EOF

# Register And Start Service
sudo systemctl daemon-reload
sudo systemctl enable $C4E
sudo systemctl start $C4E

echo -e "\e[1m\e[31mSETUP FINISHED\e[0m"
echo ""
echo -e "CHECK RUNNING LOGS : \e[1m\e[31mjournalctl -fu $C4E -o cat\e[0m"
echo -e "CHECK LOCAL STATUS : \e[1m\e[31mcurl -s localhost:${C4E_PORT}657/status | jq .result.sync_info\e[0m"
echo ""

# End
