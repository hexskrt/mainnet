#
# // Copyright (C) 2023 Salman Wahib Recoded By Hexnodes
#

echo -e "\033[0;32m"
echo "    ██   ██ ███████ ██   ██ ███    ██  ██████  ██████  ███████ ███████";
echo "    ██   ██ ██       ██ ██  ████   ██ ██    ██ ██   ██ ██      ██     "; 
echo "    ███████ █████     ███   ██ ██  ██ ██    ██ ██   ██ █████   ███████"; 
echo "    ██   ██ ██       ██ ██  ██  ██ ██ ██    ██ ██   ██ ██           ██"; 
echo "    ██   ██ ███████ ██   ██ ██   ████  ██████  ██████  ███████ ███████";
echo "              Automatic Installer for Lum Network v1.3.1 ";
echo -e "\e[0m"

sleep 1

# Variable
LUM_WALLET=wallet
LUM=lumd
LUM_ID=lum-network-1
LUM_FOLDER=
LUM_VER=v1.3.1
LUM_REPO=https://github.com/lum-network/chain.git
LUM_GENESIS=https://raw.githubusercontent.com/lum-network/mainnet/master/genesis.json
LUM_ADDRBOOK=https://anode.team/Lum/main/addrbook.json
LUM_DENOM=ulumen
LUM_PORT=28

echo "export LUM_WALLET=${LUM_WALLET}" >> $HOME/.bash_profile
echo "export LUM=${LUM}" >> $HOME/.bash_profile
echo "export LUM_ID=${LUM_ID}" >> $HOME/.bash_profile
echo "export LUM_FOLDER=${LUM_FOLDER}" >> $HOME/.bash_profile
echo "export LUM_VER=${LUM_VER}" >> $HOME/.bash_profile
echo "export LUM_REPO=${LUM_REPO}" >> $HOME/.bash_profile
echo "export LUM_GENESIS=${LUM_GENESIS}" >> $HOME/.bash_profile
echo "export LUM_ADDRBOOK=${LUM_ADDRBOOK}" >> $HOME/.bash_profile
echo "export LUM_DENOM=${LUM_DENOM}" >> $HOME/.bash_profile
echo "export LUM_PORT=${LUM_PORT}" >> $HOME/.bash_profile
source $HOME/.bash_profile

# Set Vars
if [ ! $LUM_NODENAME ]; then
        read -p "hexskrt@hexnodes:~# [ENTER YOUR NODE] > " LUM_NODENAME
        echo 'export LUM_NODENAME='$LUM_NODENAME >> $HOME/.bash_profile
fi
echo ""
echo -e "YOUR NODE NAME : \e[1m\e[31m$LUM_NODENAME\e[0m"
echo -e "NODE CHAIN ID  : \e[1m\e[31m$LUM_ID\e[0m"
echo -e "NODE PORT      : \e[1m\e[31m$LUM_PORT\e[0m"
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

# Get mainnet version of LUMelon
cd $HOME
rm -rf $LUM
git clone $LUM_REPO lum
cd lum
git checkout $LUM_VER
make install
sudo mv ~/go/bin/$LUM /usr/local/bin/$LUM

# Init generation
$LUM config chain-id $LUM_ID
$LUM config keyring-backend file
$LUM config node tcp://localhost:${LUM_PORT}657
$LUM init $LUM_NODENAME --chain-id $LUM_ID

# Set peers and seeds
PEERS="c55775cdfa05454327bd2561c1cb46268193a0f6@72.167.53.129:26656,67e0c78dfa41a2cef663984f57db1c766066b6ed@89.58.45.204:56656,7f08ea75175f07c5461e7294c23c0d77ff3c0189@85.215.119.162:26656,980caabf57654ee2321c9948b0c95855b052cb5d@51.38.53.101:26621,c234ab00b8a7ddd0b4067379116aeaa189fb55e7@65.108.69.17:26256,ea46930c7993dac01c317f07d5e016e6d8414a8e@162.55.2.6:26656,9597b6d25f6b3f9efd33d3a542713cc190959040@65.21.238.147:16656,c6feeac736ce8a9f450104bbe8cc2d6d7ccdc9bc@164.92.91.127:26656,fb2dc6d9e73be8891f9730144f95b39697528a16@51.158.111.136:26656,9f0ef2a0669c1eeb71fb8df92d2b9fb8bf355cf6@167.235.108.189:27009,c7a568d0d212c93a2832abff450a00756eebc650@66.206.6.82:26656,089092ca29b535f5e5199b5c697708a3f1b7bb8e@146.59.231.57:26656,a7f8832cb8842f9fb118122354fff22d3051fb83@3.36.179.104:26656,74c8a45201d9fbc674bd9989478c8fdc2dc46398@5.9.100.51:24656,2cda4d97de0449878da10e456b176dd0720fbcec@62.171.129.174:26656,4785e4f62d788482a7d80ddc30fb566210670209@85.237.193.100:26656,97091ac28da1be46a00a146d4812ccacc393e171@89.149.218.102:26656,8fafab32895a31a0d7f17de58eddb492c6ced6d1@185.194.219.83:36656,024b9450c03c522452cdfd480dddb2c1824148ef@51.158.102.167:26656,bccc65e8cb75d9ed9f3e07ace8991199aa3a0bce@91.134.147.1:26656,433c60a5bc0a693484b7af26208922b84773117e@34.209.132.0:26656,fbaeeff89ec94a4f6c4a2a61e24af7d06b3be0c8@46.166.140.180:26656,84d3babfae6fb96a87e4f0baf1846599e4ca8960@34.159.186.30:26656,aadaac366d66b1786f2c9ca9d423b5a813130d9a@15.235.42.151:26656,7b7d44f8494f78ba924db3fa2046f15c08208614@164.90.181.78:22056,9738aeab89fc497858c468b48597d4f9a05dd07d@185.252.233.216:36656,19ad16527c98b782ee35df56b65a3a251bd99971@51.15.142.113:26656,95832f68f7ce42cd52dfb8477c2160f1fcb3645e@185.163.64.143:26656,19987c2a634bd1106fa10d51390ac31c640237e7@185.16.38.165:16756,ea25a36162ddb85e097a65a241af47e81625af6b@65.109.43.75:27009,e15978aecedcbe1a54d36788f91475669fb7811c@116.202.96.76:27009,c552b839a578d3df0d98714e4895279388a1bed3@146.19.24.151:26656,2672931de194a1edf1d044cef04c5bcd03b66e44@65.108.71.225:28364,02d34d0d9b66be609e90d71c43c06e439357898b@51.250.24.4:26656,ea6f4af6c8001517b30f404dbf950885c6ecd4f9@65.108.141.57:22656,8a3019b7f1130ebd2f47fd9c161a0bb7659aba02@65.108.106.135:26676,3f0adc05cc80af0103492ec1f7b61797a405d8d9@15.235.115.154:10003,9e8944d2ce256a772588b16927113b0b8956be2f@95.217.85.254:15608,d8a2ec5b5005af3769925b8fb9e6b46df060bf0c@138.201.197.188:3000,6f498cf5c7500a60928d868f61568c5ee769d7aa@185.197.249.177:56656,300035004a3e7ca5dbb9826d4b5740d54012fe99@95.216.242.158:26806,68b3fb209692cc96617b5daa3da076a4dc5aebad@185.119.118.116:3000,b44c52cb06dcef87c45b7ea7d8a5cab0e0928ed5@95.70.184.178:36656,b3cb06a21815a1d72180eda95051c10db4d1c948@45.33.51.248:26656,4e8c6ece96a2a3b776014075d670f03849e1d72c@65.21.204.171:59656,60c64519ca3689262d74044a5d0fd1db6018894c@118.70.186.130:34656,432e74d93be800b26c63a8a899128c11c354d018@65.108.11.6:26656,eec92a206c48cf295340d451303eaab4bc8d0f59@51.89.7.179:26621,1cb7c751fc5c624f5aae024e1fe6cb4bfad6c4a8@209.145.60.19:26656,61439c74ced725e1b6590ed4457afc924f1941a2@142.132.158.93:16756,1c9ee150e41a803f3fe6eca2f3dff703023e386d@212.47.250.217:26656,ad7e30afa40c6a5c25a75d5b42f04d2401d43017@65.108.121.190:12140,56d8dbfb66503e69af0248a317651d8c5e99fb9f@141.95.34.193:60656,95f4033ddb777611c4a906e09c1b0132de3b2bb6@94.79.54.137:33656,1920e5154367b89228278c492bdeea1cd6312a15@176.191.97.120:27656,4bb2c34952304ae4355ef259555e1b78d3cef14a@176.57.150.227:26656,1ac22ec657a6a090f113b2831e4ebd15375c2f7e@80.64.208.79:26656,a38cecac16f118d59994fbc692c847b65186f0d1@38.242.250.7:26626,bcee3e8539e20e0ac208251b1619450c74d625c3@161.97.64.178:16656,dfded2660d683d764f8acc4ca54f86a93f5dfd7b@135.181.250.53:26656,9604e1b29ed45c24b1e62bd308ba58c4d17a37d5@5.189.128.119:53656"
SEEDS="19ad16527c98b782ee35df56b65a3a251bd99971@peer-1.mainnet.lum.network:26656"
sed -i.bak -e "s/^seeds *=.*/seeds = \"$SEEDS\"/; s/^persistent_peers *=.*/persistent_peers = \"$PEERS\"/" $HOME/$LUM_FOLDER/config/config.toml

# Download genesis and addrbook
curl -Ls $LUM_GENESIS > $HOME/$LUM_FOLDER/config/genesis.json
curl -Ls $LUM_ADDRBOOK > $HOME/$LUM_FOLDER/config/addrbook.json

# Set Port
sed -i.bak -e "s%^proxy_app = \"tcp://127.0.0.1:26658\"%proxy_app = \"tcp://127.0.0.1:${LUM_PORT}658\"%; s%^laddr = \"tcp://127.0.0.1:26657\"%laddr = \"tcp://127.0.0.1:${LUM_PORT}657\"%; s%^pprof_laddr = \"localhost:6060\"%pprof_laddr = \"localhost:${LUM_PORT}060\"%; s%^laddr = \"tcp://0.0.0.0:26656\"%laddr = \"tcp://0.0.0.0:${LUM_PORT}656\"%; s%^prometheus_listen_addr = \":26660\"%prometheus_listen_addr = \":${LUM_PORT}660\"%" $HOME/$LUM_FOLDER/config/config.toml
sed -i.bak -e "s%^address = \"tcp://0.0.0.0:1317\"%address = \"tcp://0.0.0.0:${LUM_PORT}317\"%; s%^address = \":8080\"%address = \":${LUM_PORT}080\"%; s%^address = \"0.0.0.0:9090\"%address = \"0.0.0.0:${LUM_PORT}090\"%; s%^address = \"0.0.0.0:9091\"%address = \"0.0.0.0:${LUM_PORT}091\"%" $HOME/$LUM_FOLDER/config/app.toml

# Set Config Pruning
pruning="custom"
pruning_keep_recent="100"
pruning_keep_every="0"
pruning_interval="19"
sed -i -e "s/^pruning *=.*/pruning = \"$pruning\"/" $HOME/$LUM_FOLDER/config/app.toml
sed -i -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \"$pruning_keep_recent\"/" $HOME/$LUM_FOLDER/config/app.toml
sed -i -e "s/^pruning-keep-every *=.*/pruning-keep-every = \"$pruning_keep_every\"/" $HOME/$LUM_FOLDER/config/app.toml
sed -i -e "s/^pruning-interval *=.*/pruning-interval = \"$pruning_interval\"/" $HOME/$LUM_FOLDER/config/app.toml

# Set minimum gas price
sed -i -e "s/^minimum-gas-prices *=.*/minimum-gas-prices = \"0.0025$LUM_DENOM\"/" $HOME/$LUM_FOLDER/config/app.toml
sed -i -e "s/^snapshot-interval *=.*/snapshot-interval = \"2000\"/" $HOME/$LUM_FOLDER/config/app.toml
sed -i -e "s/^snapshot-keep-recent *=.*/snapshot-keep-recent = \"5\"/" $HOME/$LUM_FOLDER/config/app.toml
$LUM tendermint unsafe-reset-all --home $HOME/$LUM_FOLDER

# Create Service
sudo tee /etc/systemd/system/$LUM.service > /dev/null <<EOF
[Unit]
Description=$LUM
After=network-online.target
[Service]
User=$USER
ExecStart=$(which $LUM) start --home $HOME/$LUM_FOLDER
Restart=on-failure
RestartSec=3
LimitNOFILE=4096
[Install]
WantedBy=multi-user.target
EOF

# Register And Start Service
sudo systemctl daemon-reload
sudo systemctl enable $LUM
sudo systemctl start $LUM

echo -e "\e[1m\e[31mSETUP FINISHED\e[0m"
echo ""
echo -e "CHECK RUNNING LOGS : \e[1m\e[31mjournalctl -fu $LUM -o cat\e[0m"
echo -e "CHECK LOCAL STATUS : \e[1m\e[31mcurl -s localhost:${LUM_PORT}657/status | jq .result.sync_info\e[0m"
echo ""

# End
