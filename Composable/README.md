<p align="center">
  <img height="100" height="auto" src="https://github.com/hexskrt/logos/blob/main/composable.jpg?raw=true">
</p>

# Composable Mainnet | Chain ID : centauri-1

### Custom Explorer:
>-  https://explorer.hexnodes.co/COMPOSABLE

### Public Endpoint

>- API : https://lcd.composable.hexnodes.co
>- RPC : https://rpc.composable.hexnodes.co
>- gRPC : https://grpc.composable.hexnodes.co

### Auto Installation
```
wget -O centauri.sh https://raw.githubusercontent.com/hexskrt/mainnet/main/Composable/centauri.sh && chmod +x centauri.sh && ./centauri.sh
```

### Snapshot updated every 5 hours

```
sudo systemctl stop centaurid
cp $HOME/.banksy/data/priv_validator_state.json $HOME/.banksy/priv_validator_state.json.backup
rm -rf $HOME/.banksy/data
curl -o - -L http://snap.hexnodes.co/composable/composable.latest.tar.lz4 | lz4 -c -d - | tar -x -C $HOME/.banksy
mv $HOME/.banksy/priv_validator_state.json.backup $HOME/.banksy/data/priv_validator_state.json
sudo systemctl restart centaurid && journalctl -u centaurid -f -o cat
```


### State Sync

```
sudo systemctl stop centaurid
cp $HOME/.banksy/data/priv_validator_state.json $HOME/.banksy/priv_validator_state.json.backup
centaurid tendermint unsafe-reset-all --home $HOME/.banksy

STATE_SYNC_RPC=https://rpc.composable.hexnodes.co:443
LATEST_HEIGHT=$(curl -s $STATE_SYNC_RPC/block | jq -r .result.block.header.height)
SYNC_BLOCK_HEIGHT=$(($LATEST_HEIGHT - 2000))
SYNC_BLOCK_HASH=$(curl -s "$STATE_SYNC_RPC/block?height=$SYNC_BLOCK_HEIGHT" | jq -r .result.block_id.hash)

sed -i.bak -E "s|^(enable[[:space:]]+=[[:space:]]+).*$|\1true| ; \
s|^(rpc_servers[[:space:]]+=[[:space:]]+).*$|\1\"$STATE_SYNC_RPC,$STATE_SYNC_RPC\"| ; \
s|^(trust_height[[:space:]]+=[[:space:]]+).*$|\1$BLOCK_HEIGHT| ; \
s|^(trust_hash[[:space:]]+=[[:space:]]+).*$|\1\"$TRUST_HASH\"|" $HOME/.banksy/config/config.toml

mv $HOME/.banksy/priv_validator_state.json.backup $HOME/.banksy/data/priv_validator_state.json
sudo systemctl restart centaurid && sudo journalctl -u centaurid -f -o cat
```

### Composable CLI Cheatsheet

- Always be careful with the capitalized words
- Specify `--chain-id`

### Wallet Management

Add Wallet
Specify the value `wallet` with your own wallet name

```
centaurid keys add wallet
```

Recover Wallet
```
centaurid keys add wallet --recover
```

List Wallet
```
centaurid keys list
```

Delete Wallet
```
centaurid keys delete wallet
```

Check Wallet Balance
```
centaurid q bank balances $(centaurid keys show wallet -a)
```

### Validator Management

Please adjust `wallet` , `MONIKER` , `YOUR_KEYBASE_ID` , `YOUR_DETAILS` , `YOUUR_WEBSITE_URL`

Create Validator
```
centaurid tx staking create-validator \
  --chain-id centauri-1 \
  --pubkey="$(centaurid tendermint show-validator)" \
  --moniker="YOUR_MONIKER" \
  --amount 1000000ppica \
  --identity "YOUR_KEYBASE_ID" \
  --website "YOUR_WEBSITE_URL" \
  --details "YOUR_DETAILS" \
  --from wallet \
  --commission-rate=0.05 \
  --commission-max-rate=0.20 \
  --commission-max-change-rate=0.01 \
  --min-self-delegation 1 \
  --gas auto \
  --fees=2000ppica \
  -y
```

Edit Validator
```
centaurid tx staking edit-validator \
--new-moniker "YOUR_MONIKER " \
--identity "YOUR_KEYBASE_ID" \
--website "YOUR_WEBSITE_URL" \
--details "YOUR_DETAILS" \
--chain-id centauri-1 \
--commission-rate=0.01 \
--min-self-delegation=1 \
--from=wallet \
--gas auto \
-y
```


Unjail Validator
```
centaurid tx slashing unjail --from wallet --chain-id centauri-1 --gas auto -y
```

Check Jailed Reason
```
centaurid query slashing signing-info $(centaurid tendermint show-validator)
```

### Token Management

Withdraw Rewards
```
centaurid tx distribution withdraw-all-rewards --from wallet --chain-id centauri-1 --gas-adjustment 1.4 --gas auto --gas-prices="0.025ppica" -y
```

Withdraw Rewards with Comission
```
centaurid tx distribution withdraw-rewards $(centaurid keys show wallet --bech val -a) --commission --from wallet --chain-id centauri-1 --gas-adjustment 1.4 --gas auto --gas-prices="0.025ppica" -y
```

Delegate Token to your own validator
```
centaurid tx staking delegate $(centaurid keys show wallet --bech val -a) 100000000ppica --from wallet --chain-id centauri-1 --gas-adjustment 1.4 --gas auto --gas-prices="0.025ppica" -y
```

Delegate Token to other validator
```
centaurid tx staking redelegate $(centaurid keys show wallet --bech val -a) <TO_VALOPER_ADDRESS> 100000000ppica --from wallet --chain-id centauri-1 --gas-adjustment 1.4 --gas auto --gas-prices="0.025ppica" -y
```

Unbond Token from your validator
```
centaurid tx staking unbond $(centaurid keys show wallet --bech val -a) 100000000ppica --from wallet --chain-id centauri-1 --gas-adjustment 1.4 --gas auto --gas-prices="0.025ppica" -y
```

Send Token to another wallet
```
centaurid tx bank send wallet <TO_WALLET_ADDRESS> 100000000ppica --from wallet --chain-id centauri-1
```

### Governance 

Vote
You can change the value of `yes` to `no`,`abstain`,`nowithveto`

```
centaurid tx gov vote 1 yes --from wallet --chain-id centauri-1 --gas-adjustment 1.4 --gas auto --gas-prices="0.025ppica" -y
```

### Other

Set Your own Custom Ports
You can change value `CUSTOM_PORT=102` To any other ports
```
CUSTOM_PORT=102
sed -i -e "s%^proxy_app = \"tcp://127.0.0.1:26658\"%proxy_app = \"tcp://127.0.0.1:${CUSTOM_PORT}658\"%; s%^laddr = \"tcp://127.0.0.1:26657\"%laddr = \"tcp://127.0.0.1:${CUSTOM_PORT}57\"%; s%^pprof_laddr = \"localhost:6060\"%pprof_laddr = \"localhost:${CUSTOM_PORT}60\"%; s%^laddr = \"tcp://0.0.0.0:26656\"%laddr = \"tcp://0.0.0.0:${CUSTOM_PORT}656\"%; s%^prometheus_listen_addr = \":26660\"%prometheus_listen_addr = \":${CUSTOM_PORT}60\"%" $HOME/.banksy/config/config.toml
sed -i -e "s%^address = \"tcp://0.0.0.0:1317\"%address = \"tcp://0.0.0.0:${CUSTOM_PORT}17\"%; s%^address = \":8080\"%address = \":${CUSTOM_PORT}80\"%; s%^address = \"0.0.0.0:9090\"%address = \"0.0.0.0:${CUSTOM_PORT}90\"%; s%^address = \"0.0.0.0:9091\"%address = \"0.0.0.0:${CUSTOM_PORT}91\"%" $HOME/.banksy/config/app.toml
```

Enable Indexing usually enabled by default
```
sed -i -e 's|^indexer *=.*|indexer = "kv"|' $HOME/.banksy/config/config.toml
```

Disable Indexing
```
sed -i -e 's|^indexer *=.*|indexer = "null"|' $HOME/.banksy/config/config.toml
```

Reset Chain Data
```
centaurid tendermint unsafe-reset-all --home $HOME/.banksy --keep-addr-book
```

### Delete Node

WARNING! Use this command wisely 
Backup your key first it will remove composable

```
sudo systemctl stop centaurid && \
sudo systemctl disable centaurid && \
rm /etc/systemd/system/centaurid.service && \
sudo systemctl daemon-reload && \
cd $HOME && \
rm -rf .banksy && \
rm -rf $(which centaurid)
```
