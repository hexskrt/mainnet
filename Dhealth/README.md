<p align="center">
  <img height="100" height="auto" src="https://github.com/hexskrt/logos/blob/main/dhealth.png?raw=true">
</p>

# Dhealth Mainnet | Chain ID : dhealth

### Custom Explorer:
>-  https://explorer.hexnodes.one/DHEALTH

### Public Endpoint

>- API : https://lcd.dhealth.hexnodes.one
>- RPC : https://rpc.dhealth.hexnodes.one
>- gRPC : https://grpc.dhealth.hexnodes.one

### Auto Installation
```
wget -O dhealth.sh https://raw.githubusercontent.com/hexskrt/mainnet/main/Dhealth/dhealth.sh && chmod +x dhealth.sh && ./dhealth.sh
```

### Snapshot updated every 5 hours
```
sudo systemctl stop dhealthd
cp $HOME/.dhealth/data/priv_validator_state.json $HOME/.dhealth/priv_validator_state.json.backup
rm -rf $HOME/.dhealth/data
curl -o - -L http://snap.hexnodes.one/dhealth/dhealth.latest.tar.lz4 | lz4 -c -d - | tar -x -C $HOME/.dhealth
mv $HOME/.dhealth/priv_validator_state.json.backup $HOME/.dhealth/data/priv_validator_state.json
sudo systemctl restart dhealthd && journalctl -u dhealthd -f -o cat
```


### State Sync
```
sudo systemctl stop dhealthd
cp $HOME/.dhealth/data/priv_validator_state.json $HOME/.dhealth/priv_validator_state.json.backup
dhealthd tendermint unsafe-reset-all --home $HOME/.dhealth

STATE_SYNC_RPC=https://rpc.dhealth.hexnodes.one:443
LATEST_HEIGHT=$(curl -s $STATE_SYNC_RPC/block | jq -r .result.block.header.height)
SYNC_BLOCK_HEIGHT=$(($LATEST_HEIGHT - 2000))
SYNC_BLOCK_HASH=$(curl -s "$STATE_SYNC_RPC/block?height=$SYNC_BLOCK_HEIGHT" | jq -r .result.block_id.hash)

sed -i.bak -E "s|^(enable[[:space:]]+=[[:space:]]+).*$|\1true| ; \
s|^(rpc_servers[[:space:]]+=[[:space:]]+).*$|\1\"$STATE_SYNC_RPC,$STATE_SYNC_RPC\"| ; \
s|^(trust_height[[:space:]]+=[[:space:]]+).*$|\1$BLOCK_HEIGHT| ; \
s|^(trust_hash[[:space:]]+=[[:space:]]+).*$|\1\"$TRUST_HASH\"|" $HOME/.dhealth/config/config.toml

mv $HOME/.dhealth/priv_validator_state.json.backup $HOME/.dhealth/data/priv_validator_state.json
sudo systemctl restart dhealthd && sudo journalctl -u dhealthd -f -o cat
```

### Dhealth CLI Cheatsheet

- Always be careful with the capitalized words
- Specify `--chain-id`

### Wallet Management

Add Wallet
Specify the value `wallet` with your own wallet name

```
dhealthd keys add wallet
```

Recover Wallet
```
dhealthd keys add wallet --recover
```

List Wallet
```
dhealthd keys list
```

Delete Wallet
```
dhealthd keys delete wallet
```

Check Wallet Balance
```
dhealthd q bank balances $(dhealthd keys show wallet -a)
```

### Validator Management

Please adjust `wallet` , `MONIKER` , `YOUR_KEYBASE_ID` , `YOUR_DETAILS` , `YOUUR_WEBSITE_URL`

Create Validator
```
dhealthd tx staking create-validator \
  --chain-id mainnet-3 \
  --pubkey="$(dhealthd tendermint show-validator)" \
  --moniker="YOUR_MONIKER" \
  --amount 1000000udhp \
  --identity "YOUR_KEYBASE_ID" \
  --website "YOUR_WEBSITE_URL" \
  --details "YOUR_DETAILS" \
  --from wallet \
  --commission-rate=0.05 \
  --commission-max-rate=0.20 \
  --commission-max-change-rate=0.01 \
  --min-self-delegation 1 \
  --gas auto \
  --fees=2000udhp \
  -y
```

Edit Validator
```
dhealthd tx staking edit-validator \
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
dhealthd tx slashing unjail --from wallet --chain-id mainnet-3 --gas auto -y
```

Check Jailed Reason
```
dhealthd query slashing signing-info $(dhealthd tendermint show-validator)
```

### Token Management

Withdraw Rewards
```
dhealthd tx distribution withdraw-all-rewards --from wallet --chain-id mainnet-3 --gas-adjustment 1.4 --gas auto --gas-prices="0.025udhp" -y
```

Withdraw Rewards with Comission
```
dhealthd tx distribution withdraw-rewards $(dhealthd keys show wallet --bech val -a) --commission --from wallet --chain-id mainnet-3 --gas-adjustment 1.4 --gas auto --gas-prices="0.025udhp" -y
```

Delegate Token to your own validator
```
dhealthd tx staking delegate $(dhealthd keys show wallet --bech val -a) 100000000udhp --from wallet --chain-id mainnet-3 --gas-adjustment 1.4 --gas auto --gas-prices="0.025udhp" -y
```

Delegate Token to other validator
```
dhealthd tx staking redelegate $(dhealthd keys show wallet --bech val -a) <TO_VALOPER_ADDRESS> 100000000udhp --from wallet --chain-id mainnet-3 --gas-adjustment 1.4 --gas auto --gas-prices="0.025udhp" -y
```

Unbond Token from your validator
```
dhealthd tx staking unbond $(dhealthd keys show wallet --bech val -a) 100000000udhp --from wallet --chain-id mainnet-3 --gas-adjustment 1.4 --gas auto --gas-prices="0.025udhp" -y
```

Send Token to another wallet
```
dhealthd tx bank send wallet <TO_WALLET_ADDRESS> 100000000udhp --from wallet --chain-id mainnet-3
```

### Governance 

Vote
You can change the value of `yes` to `no`,`abstain`,`nowithveto`

```
dhealthd tx gov vote 1 yes --from wallet --chain-id mainnet-3 --gas-adjustment 1.4 --gas auto --gas-prices="0.025udhp" -y
```

### Other

Set Your own Custom Ports
You can change value `CUSTOM_PORT=103` To any other ports
```
CUSTOM_PORT=103
sed -i -e "s%^proxy_app = \"tcp://127.0.0.1:26658\"%proxy_app = \"tcp://127.0.0.1:${CUSTOM_PORT}658\"%; s%^laddr = \"tcp://127.0.0.1:26657\"%laddr = \"tcp://127.0.0.1:${CUSTOM_PORT}57\"%; s%^pprof_laddr = \"localhost:6060\"%pprof_laddr = \"localhost:${CUSTOM_PORT}60\"%; s%^laddr = \"tcp://0.0.0.0:26656\"%laddr = \"tcp://0.0.0.0:${CUSTOM_PORT}656\"%; s%^prometheus_listen_addr = \":26660\"%prometheus_listen_addr = \":${CUSTOM_PORT}60\"%" $HOME/.dhealth/config/config.toml
sed -i -e "s%^address = \"tcp://0.0.0.0:1317\"%address = \"tcp://0.0.0.0:${CUSTOM_PORT}17\"%; s%^address = \":8080\"%address = \":${CUSTOM_PORT}80\"%; s%^address = \"0.0.0.0:9090\"%address = \"0.0.0.0:${CUSTOM_PORT}90\"%; s%^address = \"0.0.0.0:9091\"%address = \"0.0.0.0:${CUSTOM_PORT}91\"%" $HOME/.dhealth/config/app.toml
```

Enable Indexing usually enabled by default
```
sed -i -e 's|^indexer *=.*|indexer = "kv"|' $HOME/.dhealth/config/config.toml
```

Disable Indexing
```
sed -i -e 's|^indexer *=.*|indexer = "null"|' $HOME/.dhealth/config/config.toml
```

Reset Chain Data
```
dhealthd tendermint unsafe-reset-all --home $HOME/.dhealth --keep-addr-book
```

### Delete Node

WARNING! Use this command wisely 
Backup your key first it will remove dhealth

```
sudo systemctl stop dhealthd && \
sudo systemctl disable dhealthd && \
rm /etc/systemd/system/dhealthd.service && \
sudo systemctl daemon-reload && \
cd $HOME && \
rm -rf .dhealth && \
rm -rf $(which dhealthd)
```
