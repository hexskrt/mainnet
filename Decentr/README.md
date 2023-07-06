<p align="center">
  <img height="100" height="auto" src="https://github.com/hexskrt/logos/blob/main/dec.jpg?raw=true">
</p>

# Decentr Mainnet | Chain ID : mainnet-3

### Custom Explorer:
>-  https://explorer.hexnodes.co/DECENTR

### Public Endpoint

>- API : https://lcd.decentr.hexnodes.co
>- RPC : https://rpc.decentr.hexnodes.co
>- gRPC : https://grpc.decentr.hexnodes.co

### Auto Installation
```
wget -O decentr.sh https://raw.githubusercontent.com/hexskrt/mainnet/main/Decentr/decentr.sh && chmod +x decentr.sh && ./decentr.sh
```

### Snapshot updated every 5 hours
```
sudo systemctl stop decentrd
cp $HOME/.decentr/data/priv_validator_state.json $HOME/.decentr/priv_validator_state.json.backup
rm -rf $HOME/.decentr/data
curl -o - -L http://snap.hexnodes.co/decemtr/decentr.latest.tar.lz4 | lz4 -c -d - | tar -x -C $HOME/.decentr
mv $HOME/.decentr/priv_validator_state.json.backup $HOME/.decentr/data/priv_validator_state.json
sudo systemctl restart decentrd && journalctl -u decentrd -f -o cat
```


### State Sync
```
sudo systemctl stop decentrd
cp $HOME/.decentr/data/priv_validator_state.json $HOME/.decentr/priv_validator_state.json.backup
decentrd tendermint unsafe-reset-all --home $HOME/.decentr

STATE_SYNC_RPC=https://rpc.decentr.hexnodes.co:443
LATEST_HEIGHT=$(curl -s $STATE_SYNC_RPC/block | jq -r .result.block.header.height)
SYNC_BLOCK_HEIGHT=$(($LATEST_HEIGHT - 2000))
SYNC_BLOCK_HASH=$(curl -s "$STATE_SYNC_RPC/block?height=$SYNC_BLOCK_HEIGHT" | jq -r .result.block_id.hash)

sed -i.bak -E "s|^(enable[[:space:]]+=[[:space:]]+).*$|\1true| ; \
s|^(rpc_servers[[:space:]]+=[[:space:]]+).*$|\1\"$SNAP_RPC,$SNAP_RPC\"| ; \
s|^(trust_height[[:space:]]+=[[:space:]]+).*$|\1$BLOCK_HEIGHT| ; \
s|^(trust_hash[[:space:]]+=[[:space:]]+).*$|\1\"$TRUST_HASH\"|" $HOME/.decentr/config/config.toml

mv $HOME/.decentr/priv_validator_state.json.backup $HOME/.decentr/data/priv_validator_state.json
sudo systemctl restart decentrd && sudo journalctl -u decentrd -f -o cat
```

### Decentr CLI Cheatsheet

- Always be careful with the capitalized words
- Specify `--chain-id`

### Wallet Management

Add Wallet
Specify the value `wallet` with your own wallet name

```
decentrd keys add wallet
```

Recover Wallet
```
decentrd keys add wallet --recover
```

List Wallet
```
decentrd keys list
```

Delete Wallet
```
decentrd keys delete wallet
```

Check Wallet Balance
```
decentrd q bank balances $(decentrd keys show wallet -a)
```

### Validator Management

Please adjust `wallet` , `MONIKER` , `YOUR_KEYBASE_ID` , `YOUR_DETAILS` , `YOUUR_WEBSITE_URL`

Create Validator
```
decentrd tx staking create-validator \
  --chain-id mainnet-3 \
  --pubkey="$(decentrd tendermint show-validator)" \
  --moniker="YOUR_MONIKER" \
  --amount 1000000udec \
  --identity "YOUR_KEYBASE_ID" \
  --website "YOUR_WEBSITE_URL" \
  --details "YOUR_DETAILS" \
  --from wallet \
  --commission-rate=0.05 \
  --commission-max-rate=0.20 \
  --commission-max-change-rate=0.01 \
  --min-self-delegation 1 \
  --gas auto \
  --fees=2000udec \
  -y
```

Edit Validator
```
decentrd tx staking edit-validator \
--new-moniker "YOUR_MONIKER " \
--identity "YOUR_KEYBASE_ID" \
--website "YOUR_WEBSITE_URL" \
--details "YOUR_DETAILS" \
--chain-id mainnet-3 \
--commission-rate=0.01 \
--min-self-delegation=1 \
--from=wallet \
--gas auto \
-y
```


Unjail Validator
```
decentrd tx slashing unjail --from wallet --chain-id mainnet-3 --gas auto -y
```

Check Jailed Reason
```
decentrd query slashing signing-info $(decentrd tendermint show-validator)
```

### Token Management

Withdraw Rewards
```
decentrd tx distribution withdraw-all-rewards --from wallet --chain-id mainnet-3 --gas-adjustment 1.4 --gas auto --gas-prices="0.025udec" -y
```

Withdraw Rewards with Comission
```
decentrd tx distribution withdraw-rewards $(decentrd keys show wallet --bech val -a) --commission --from wallet --chain-id mainnet-3 --gas-adjustment 1.4 --gas auto --gas-prices="0.025udec" -y
```

Delegate Token to your own validator
```
decentrd tx staking delegate $(decentrd keys show wallet --bech val -a) 100000000udec --from wallet --chain-id mainnet-3 --gas-adjustment 1.4 --gas auto --gas-prices="0.025udec" -y
```

Delegate Token to other validator
```
decentrd tx staking redelegate $(decentrd keys show wallet --bech val -a) <TO_VALOPER_ADDRESS> 100000000udec --from wallet --chain-id mainnet-3 --gas-adjustment 1.4 --gas auto --gas-prices="0.025udec" -y
```

Unbond Token from your validator
```
decentrd tx staking unbond $(decentrd keys show wallet --bech val -a) 100000000udec --from wallet --chain-id mainnet-3 --gas-adjustment 1.4 --gas auto --gas-prices="0.025udec" -y
```

Send Token to another wallet
```
decentrd tx bank send wallet <TO_WALLET_ADDRESS> 100000000udec --from wallet --chain-id mainnet-3
```

### Governance 

Vote
You can change the value of `yes` to `no`,`abstain`,`nowithveto`

```
decentrd tx gov vote 1 yes --from wallet --chain-id mainnet-3 --gas-adjustment 1.4 --gas auto --gas-prices="0.025udec" -y
```

### Other

Set Your own Custom Ports
You can change value `CUSTOM_PORT=103` To any other ports
```
CUSTOM_PORT=103
sed -i -e "s%^proxy_app = \"tcp://127.0.0.1:26658\"%proxy_app = \"tcp://127.0.0.1:${CUSTOM_PORT}658\"%; s%^laddr = \"tcp://127.0.0.1:26657\"%laddr = \"tcp://127.0.0.1:${CUSTOM_PORT}57\"%; s%^pprof_laddr = \"localhost:6060\"%pprof_laddr = \"localhost:${CUSTOM_PORT}60\"%; s%^laddr = \"tcp://0.0.0.0:26656\"%laddr = \"tcp://0.0.0.0:${CUSTOM_PORT}656\"%; s%^prometheus_listen_addr = \":26660\"%prometheus_listen_addr = \":${CUSTOM_PORT}60\"%" $HOME/.decentr/config/config.toml
sed -i -e "s%^address = \"tcp://0.0.0.0:1317\"%address = \"tcp://0.0.0.0:${CUSTOM_PORT}17\"%; s%^address = \":8080\"%address = \":${CUSTOM_PORT}80\"%; s%^address = \"0.0.0.0:9090\"%address = \"0.0.0.0:${CUSTOM_PORT}90\"%; s%^address = \"0.0.0.0:9091\"%address = \"0.0.0.0:${CUSTOM_PORT}91\"%" $HOME/.decentr/config/app.toml
```

Enable Indexing usually enabled by default
```
sed -i -e 's|^indexer *=.*|indexer = "kv"|' $HOME/.decentr/config/config.toml
```

Disable Indexing
```
sed -i -e 's|^indexer *=.*|indexer = "null"|' $HOME/.decentr/config/config.toml
```

Reset Chain Data
```
decentrd tendermint unsafe-reset-all --home $HOME/.decentr --keep-addr-book
```

### Delete Node

WARNING! Use this command wisely 
Backup your key first it will remove decentr

```
sudo systemctl stop decentrd && \
sudo systemctl disable decentrd && \
rm /etc/systemd/system/decentrd.service && \
sudo systemctl daemon-reload && \
cd $HOME && \
rm -rf .decentr && \
rm -rf $(which decentrd)
```
