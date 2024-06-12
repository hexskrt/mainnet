<p align="center">
  <img height="100" height="auto" src="https://github.com/hexskrt/logos/blob/main/desmos.jpg?raw=true">
</p>

# Desmos Network Mainnet | Chain ID : desmos-mainnet

### Custom Explorer:
>-  https://explorer.hexnodes.one/DESMOS

### Public Endpoint

>- API : https://lcd.desmos.hexnodes.one
>- RPC : https://rpc.desmos.hexnodes.one
>- gRPC : https://grpc.desmos.hexnodes.one

### Auto Installation

```
wget -O desmos.sh https://raw.githubusercontent.com/hexskrt/mainnet/main/Desmos/desmos.sh && chmod +x desmos.sh && ./desmos.sh
```

### Snapshot updated every 5 hours

```
sudo systemctl stop desmos
cp $HOME/.desmos/data/priv_validator_state.json $HOME/.desmos/priv_validator_state.json.backup
rm -rf $HOME/.desmos/data
curl -o - -L http://snapshot.hexnodes.one/desmos/desmos.latest.tar.lz4 | lz4 -c -d - | tar -x -C $HOME/.desmos
mv $HOME/.desmos/priv_validator_state.json.backup $HOME/.desmos/data/priv_validator_state.json
sudo systemctl restart desmos && journalctl -u desmos -f -o cat
```


### State Sync

```
sudo systemctl stop desmos
cp $HOME/.desmos/data/priv_validator_state.json $HOME/.desmos/priv_validator_state.json.backup
desmos tendermint unsafe-reset-all --home $HOME/.desmos

STATE_SYNC_RPC=https://rpc.desmos.hexnodes.one:443
LATEST_HEIGHT=$(curl -s $STATE_SYNC_RPC/block | jq -r .result.block.header.height)
SYNC_BLOCK_HEIGHT=$(($LATEST_HEIGHT - 2000))
SYNC_BLOCK_HASH=$(curl -s "$STATE_SYNC_RPC/block?height=$SYNC_BLOCK_HEIGHT" | jq -r .result.block_id.hash)

sed -i.bak -E "s|^(enable[[:space:]]+=[[:space:]]+).*$|\1true| ; \
s|^(rpc_servers[[:space:]]+=[[:space:]]+).*$|\1\"$STATE_SYNC_RPC,$STATE_SYNC_RPC\"| ; \
s|^(trust_height[[:space:]]+=[[:space:]]+).*$|\1$BLOCK_HEIGHT| ; \
s|^(trust_hash[[:space:]]+=[[:space:]]+).*$|\1\"$TRUST_HASH\"|" $HOME/.desmos/config/config.toml

mv $HOME/.desmos/priv_validator_state.json.backup $HOME/.desmos/data/priv_validator_state.json
sudo systemctl restart desmos && sudo journalctl -u desmos -f -o cat
```

### Desmos CLI Cheatsheet

- Always be careful with the capitalized words
- Specify `--chain-id`

### Wallet Management

Add Wallet
Specify the value `wallet` with your own wallet name

```
desmos keys add wallet
```

Recover Wallet
```
desmos keys add wallet --recover
```

List Wallet
```
desmos keys list
```

Delete Wallet
```
desmos keys delete wallet
```

Check Wallet Balance
```
desmos q bank balances $(desmos keys show wallet -a)
```

### Validator Management

Please adjust `wallet` , `MONIKER` , `YOUR_KEYBASE_ID` , `YOUR_DETAILS` , `YOUUR_WEBSITE_URL`

Create Validator
```
desmos tx staking create-validator \
  --chain-id desmos-mainnet \
  --pubkey="$(desmos tendermint show-validator)" \
  --moniker="YOUR_MONIKER" \
  --amount 1000000udsm \
  --identity "YOUR_KEYBASE_ID" \
  --website "YOUR_WEBSITE_URL" \
  --details "YOUR_DETAILS" \
  --from wallet \
  --commission-rate=0.05 \
  --commission-max-rate=0.20 \
  --commission-max-change-rate=0.01 \
  --min-self-delegation 1 \
  --gas auto \
  --fees=2000udsm \
  -y
```

Edit Validator
```
desmos tx staking edit-validator \
--new-moniker "YOUR_MONIKER " \
--identity "YOUR_KEYBASE_ID" \
--website "YOUR_WEBSITE_URL" \
--details "YOUR_DETAILS" \
--chain-id desmos-mainnet \
--commission-rate=0.01 \
--min-self-delegation=1 \
--from=wallet \
--gas auto \
-y
```


Unjail Validator
```
desmos tx slashing unjail --from wallet --chain-id desmos-mainnet --gas auto -y
```

Check Jailed Reason
```
desmos query slashing signing-info $(desmos tendermint show-validator)
```

### Token Management

Withdraw Rewards
```
desmos tx distribution withdraw-all-rewards --from wallet --chain-id desmos-mainnet --gas-adjustment 1.4 --gas auto --gas-prices="0.025udsm" -y
```

Withdraw Rewards with Comission
```
desmos tx distribution withdraw-rewards $(desmos keys show wallet --bech val -a) --commission --from wallet --chain-id desmos-mainnet --gas-adjustment 1.4 --gas auto --gas-prices="0.025udsm" -y
```

Delegate Token to your own validator
```
desmos tx staking delegate $(desmos keys show wallet --bech val -a) 100000000udsm --from wallet --chain-id desmos-mainnet --gas-adjustment 1.4 --gas auto --gas-prices="0.025udsm" -y
```

Delegate Token to other validator
```
desmos tx staking redelegate $(desmos keys show wallet --bech val -a) <TO_VALOPER_ADDRESS> 100000000udsm --from wallet --chain-id desmos-mainnet --gas-adjustment 1.4 --gas auto --gas-prices="0.025udsm" -y
```

Unbond Token from your validator
```
desmos tx staking unbond $(desmos keys show wallet --bech val -a) 100000000udsm --from wallet --chain-id desmos-mainnet --gas-adjustment 1.4 --gas auto --gas-prices="0.025udsm" -y
```

Send Token to another wallet
```
desmos tx bank send wallet <TO_WALLET_ADDRESS> 100000000udsm --from wallet --chain-id desmos-mainnet
```

### Governance 

Vote
You can change the value of `yes` to `no`,`abstain`,`nowithveto`

```
desmos tx gov vote 1 yes --from wallet --chain-id desmos-mainnet --gas-adjustment 1.4 --gas auto --gas-prices="0.025udsm" -y
```

### Other

Set Your own Custom Ports
You can change value `CUSTOM_PORT=104` To any other ports
```
CUSTOM_PORT=104
sed -i -e "s%^proxy_app = \"tcp://127.0.0.1:26658\"%proxy_app = \"tcp://127.0.0.1:${CUSTOM_PORT}658\"%; s%^laddr = \"tcp://127.0.0.1:26657\"%laddr = \"tcp://127.0.0.1:${CUSTOM_PORT}57\"%; s%^pprof_laddr = \"localhost:6060\"%pprof_laddr = \"localhost:${CUSTOM_PORT}60\"%; s%^laddr = \"tcp://0.0.0.0:26656\"%laddr = \"tcp://0.0.0.0:${CUSTOM_PORT}656\"%; s%^prometheus_listen_addr = \":26660\"%prometheus_listen_addr = \":${CUSTOM_PORT}60\"%" $HOME/.desmos/config/config.toml
sed -i -e "s%^address = \"tcp://0.0.0.0:1317\"%address = \"tcp://0.0.0.0:${CUSTOM_PORT}17\"%; s%^address = \":8080\"%address = \":${CUSTOM_PORT}80\"%; s%^address = \"0.0.0.0:9090\"%address = \"0.0.0.0:${CUSTOM_PORT}90\"%; s%^address = \"0.0.0.0:9091\"%address = \"0.0.0.0:${CUSTOM_PORT}91\"%" $HOME/.desmos/config/app.toml
```

Enable Indexing usually enabled by default
```
sed -i -e 's|^indexer *=.*|indexer = "kv"|' $HOME/.desmos/config/config.toml
```

Disable Indexing
```
sed -i -e 's|^indexer *=.*|indexer = "null"|' $HOME/.desmos/config/config.toml
```

Reset Chain Data
```
desmos tendermint unsafe-reset-all --home $HOME/.desmos --keep-addr-book
```

### Delete Node

WARNING! Use this command wisely 
Backup your key first it will remove desmos

```
sudo systemctl stop desmos && \
sudo systemctl disable desmos && \
rm /etc/systemd/system/desmos.service && \
sudo systemctl daemon-reload && \
cd $HOME && \
rm -rf .desmos && \
rm -rf $(which desmos)
```
