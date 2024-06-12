<p align="center">
  <img height="100" height="auto" src="https://github.com/hexskrt/logos/blob/main/cheqd.png?raw=true">
</p>

# Cheqd Mainnet | Chain ID : cheqd-mainnet-1

### Custom Explorer:
>-  https://explorer.hexnodes.co/CHEQD

### Public Endpoint

>- API : https://lcd.cheqd.hexnodes.co
>- RPC : https://rpc.cheqd.hexnodes.co
>- gRPC : https://grpc.cheqd.hexnodes.co

### Auto Installation
```
curl -sL https://raw.githubusercontent.com/hexskrt/mainnet/main/Cheqd/cheqd.sh > cheqd.sh && chmod +x cheqd.sh && ./cheqd.sh
```

### Snapshot ( Update Every 5 Hours )
```
sudo systemctl stop cheqd-noded
cp $HOME/.cheqdnode/data/priv_validator_state.json $HOME/.cheqdnode/priv_validator_state.json.backup
rm -rf $HOME/.cheqdnode/data

curl -L https://snap.hexnodes.co/ixo/ixo.latest.tar.lz4 | tar -Ilz4 -xf - -C $HOME/.cheqdnode/
mv $HOME/.cheqdnode/priv_validator_state.json.backup $HOME/.cheqdnode/data/priv_validator_state.json

sudo systemctl start cheqd-noded && sudo journalctl -fu cheqd-noded -o cat
```

### State Sync
```
sudo systemctl stop cheqd-noded
cp $HOME/.cheqdnode/data/priv_validator_state.json $HOME/.cheqdnode/priv_validator_state.json.backup
cheqd-noded tendermint unsafe-reset-all --home $HOME/.cheqdnode

STATE_SYNC_RPC=https://rpc.cheqd.hexnodes.co:443
LATEST_HEIGHT=$(curl -s $STATE_SYNC_RPC/block | jq -r .result.block.header.height)
SYNC_BLOCK_HEIGHT=$(($LATEST_HEIGHT - 2000))
SYNC_BLOCK_HASH=$(curl -s "$STATE_SYNC_RPC/block?height=$SYNC_BLOCK_HEIGHT" | jq -r .result.block_id.hash)

sed -i \
  -e "s|^enable *=.*|enable = true|" \
  -e "s|^rpc_servers *=.*|rpc_servers = \"$STATE_SYNC_RPC,$STATE_SYNC_RPC\"|" \
  -e "s|^trust_height *=.*|trust_height = $SYNC_BLOCK_HEIGHT|" \
  -e "s|^trust_hash *=.*|trust_hash = \"$SYNC_BLOCK_HASH\"|" \
  $HOME/.cheqdnode/config/config.toml

mv $HOME/.cheqdnode/priv_validator_state.json.backup $HOME/.cheqdnode/data/priv_validator_state.json

sudo systemctl start cheqd-noded && sudo journalctl -u cheqd-noded -f --no-hostname -o cat
```

### Live Peers
```
PEERS="9201b408d24941fd342e739f0814aa3eb8ab7577@178.128.20.15:26656,c7b1c178adaf364917caaac67687051d1ed5bf53@78.46.83.78:26656,468092cfb222e07d365dd69d73541e6ed5dc87d8@57.128.20.163:16156,cd490e23a84015ff2478f181a79a5d53ed17aefe@206.189.137.229:26656,a7fee20e59b68e9c707b54af51462450cf2e18f6@65.21.254.210:26656,3c1732a5fac42f436631289200e0625156d5acdb@65.108.132.107:3000,0bb8a1db87e2bb8e0204ca1c078b8ab4aa43d7c4@134.209.190.126:26656,930067f48301adccaa9f7e28424fa6da3a023de4@116.203.250.20:26656,0e7a55c5f5fb4e9a7d2baa8a2b7dbe143b0a9f77@137.74.4.20:3000,d290b179ebe7703bb4429ac508fe104c527e49a5@143.110.218.56:26656,9b30307a2a2819790d68c04bb62f5cf4028f447e@139.59.121.243:26656"
sed -i -e "s|^persistent_peers *=.*|persistent_peers = \"$PEERS\"|" $HOME/.cheqdnode/config/config.toml
```
### Addrbook
```
curl -Ls https://ss.hexnodes.co/cheqd/addrbook.json > $HOME/.cheqdnode/config/addrbook.json
```
### Genesis
```
curl -Ls https://ss.hexnodes.co/cheqd/genesis.json > $HOME/.cheqdnode/config/genesis.json
```

### Cheqd CLI Cheatsheet

- Always be careful with the capitalized words
- Specify `--chain-id`

### Wallet Management

Add Wallet
Specify the value `wallet` with your own wallet name

```
cheqd-noded keys add wallet
```

Recover Wallet
```
cheqd-noded keys add wallet --recover
```

List Wallet
```
cheqd-noded keys list
```

Delete Wallet
```
cheqd-noded keys delete wallet
```

Check Wallet Balance
```
cheqd-noded q bank balances $(cheqd-noded keys show wallet -a)
```

### Validator Management

Please adjust `wallet` , `MONIKER` , `YOUR_KEYBASE_ID` , `YOUR_DETAILS` , `YOUUR_WEBSITE_URL`

Create Validator
```
cheqd-noded tx staking create-validator \
  --chain-id cheqd-mainnet-1 \
  --pubkey="$(cheqd-noded tendermint show-validator)" \
  --moniker="YOUR_MONIKER" \
  --amount 1000000ncheqd \
  --identity "YOUR_KEYBASE_ID" \
  --website "YOUR_WEBSITE_URL" \
  --details "YOUR_DETAILS" \
  --from wallet \
  --commission-rate=0.05 \
  --commission-max-rate=0.20 \
  --commission-max-change-rate=0.01 \
  --min-self-delegation 1 \
  --gas auto \
  --fees=5000000ncheq \
  -y
```

Edit Validator
```
cheqd-noded tx staking edit-validator \
--new-moniker "YOUR_MONIKER " \
--identity "YOUR_KEYBASE_ID" \
--website "YOUR_WEBSITE_URL" \
--details "YOUR_DETAILS" \
--chain-id cheqd-mainnet-1 \
--commission-rate=0.01 \
--min-self-delegation=1 \
--from=wallet \
--gas auto \
-y
```


Unjail Validator
```
cheqd-noded tx slashing unjail --from wallet --chain-id cheqd-mainnet-1 --gas auto -y
```

Check Jailed Reason
```
cheqd-noded query slashing signing-info $(cheqd-noded tendermint show-validator)
```

### Token Management

Withdraw Rewards
```
cheqd-noded tx distribution withdraw-all-rewards --from wallet --chain-id cheqd-mainnet-1 --gas-adjustment 1.4 --gas auto --gas-prices="0.025ncheqd" -y
```

Withdraw Rewards with Comission
```
cheqd-noded tx distribution withdraw-rewards $(cheqd-noded keys show wallet --bech val -a) --commission --from wallet --chain-id cheqd-mainnet-1 --gas-adjustment 1.4 --gas auto --gas-prices="0.025ncheqd" -y
```

Delegate Token to your own validator
```
cheqd-noded tx staking delegate $(cheqd-noded keys show wallet --bech val -a) 100000000ncheqd --from wallet --chain-id cheqd-mainnet-1 --gas-adjustment 1.4 --gas auto --gas-prices="0.025ncheqd" -y
```

Delegate Token to other validator
```
cheqd-noded tx staking redelegate $(cheqd-noded keys show wallet --bech val -a) <TO_VALOPER_ADDRESS> 100000000ncheqd --from wallet --chain-id cheqd-mainnet-1 --gas-adjustment 1.4 --gas auto --gas-prices="0.025ncheqd" -y
```

Unbond Token from your validator
```
cheqd-noded tx staking unbond $(cheqd-noded keys show wallet --bech val -a) 100000000ncheqd --from wallet --chain-id cheqd-mainnet-1 --gas-adjustment 1.4 --gas auto --gas-prices="0.025ncheqd" -y
```

Send Token to another wallet
```
cheqd-noded tx bank send wallet <TO_WALLET_ADDRESS> 100000000ncheqd --from wallet --chain-id cheqd-mainnet-1
```

### Governance 

Vote
You can change the value of `yes` to `no`,`abstain`,`nowithveto`

```
cheqd-noded tx gov vote 1 yes --from wallet --chain-id cheqd-mainnet-1 --gas-adjustment 1.4 --gas auto --gas-prices="0.025ncheqd" -y
```

### Other

Set Your own Custom Ports
You can change value `CUSTOM_PORT=102` To any other ports
```
CUSTOM_PORT=102
sed -i -e "s%^proxy_app = \"tcp://127.0.0.1:26658\"%proxy_app = \"tcp://127.0.0.1:${CUSTOM_PORT}58\"%; s%^laddr = \"tcp://127.0.0.1:26657\"%laddr = \"tcp://127.0.0.1:${CUSTOM_PORT}57\"%; s%^pprof_laddr = \"localhost:6060\"%pprof_laddr = \"localhost:${CUSTOM_PORT}60\"%; s%^laddr = \"tcp://0.0.0.0:26656\"%laddr = \"tcp://0.0.0.0:${CUSTOM_PORT}56\"%; s%^prometheus_listen_addr = \":26660\"%prometheus_listen_addr = \":${CUSTOM_PORT}60\"%" $HOME/.cheqdnode/config/config.toml
sed -i -e "s%^address = \"tcp://0.0.0.0:1317\"%address = \"tcp://0.0.0.0:${CUSTOM_PORT}17\"%; s%^address = \":8080\"%address = \":${CUSTOM_PORT}80\"%; s%^address = \"0.0.0.0:9090\"%address = \"0.0.0.0:${CUSTOM_PORT}90\"%; s%^address = \"0.0.0.0:9091\"%address = \"0.0.0.0:${CUSTOM_PORT}91\"%" $HOME/.cheqdnode/config/app.toml
```

Enable Indexing usually enabled by default
```
sed -i -e 's|^indexer *=.*|indexer = "kv"|' $HOME/.cheqdnode/config/config.toml
```

Disable Indexing
```
sed -i -e 's|^indexer *=.*|indexer = "null"|' $HOME/.cheqdnode/config/config.toml
```

Reset Chain Data
```
cheqd-noded tendermint unsafe-reset-all --home $HOME/.cheqdnode --keep-addr-book
```

### Delete Node

WARNING! Use this command wisely 
Backup your key first it will remove Cheqd

```
sudo systemctl stop cheqd-noded && \
sudo systemctl disable cheqd-noded && \
rm /etc/systemd/system/cheqd-noded.service && \
sudo systemctl daemon-reload && \
cd $HOME && \
rm -rf .cheqdnode && \
rm -rf $(which cheqd-noded)
```
