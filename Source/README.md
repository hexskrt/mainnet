<p align="center">
  <img height="100" height="auto" src="https://github.com/hexskrt/logos/blob/main/source.jpg?raw=true">
</p>

# Source Mainnet | Chain ID : source-1

### Custom Explorer:
>-  https://explorer.hexnodes.co/source

### Public Endpoint

>- API : https://lcd.source.hexnodes.co
>- RPC : https://rpc.source.hexnodes.co
>- gRPC : https://grpc.source.hexnodes.co

### Auto Installation

```
wget -O source.sh https://raw.githubusercontent.com/hexskrt/mainnet/main/Source/source.sh && chmod +x source.sh && ./source.sh
```

### Snapshot

```
sudo systemctl stop sourced
cp $HOME/.source/data/priv_validator_state.json $HOME/.source/priv_validator_state.json.backup
rm -rf $HOME/.source/data
curl -o - -L http://snap.hexnodes.co/source/source.latest.tar.lz4 | lz4 -c -d - | tar -x -C $HOME/.source
mv $HOME/.source/priv_validator_state.json.backup $HOME/.source/data/priv_validator_state.json
sudo systemctl restart sourced && journalctl -u sourced -f -o cat
```


### State Sync

```
sudo systemctl stop sourced
cp $HOME/.source/data/priv_validator_state.json $HOME/.source/priv_validator_state.json.backup
sourced tendermint unsafe-reset-all --home $HOME/.source

STATE_SYNC_RPC=https://rpc.source.hexnodes.co:443
LATEST_HEIGHT=$(curl -s $STATE_SYNC_RPC/block | jq -r .result.block.header.height)
SYNC_BLOCK_HEIGHT=$(($LATEST_HEIGHT - 2000))
SYNC_BLOCK_HASH=$(curl -s "$STATE_SYNC_RPC/block?height=$SYNC_BLOCK_HEIGHT" | jq -r .result.block_id.hash)

sed -i.bak -E "s|^(enable[[:space:]]+=[[:space:]]+).*$|\1true| ; \
s|^(rpc_servers[[:space:]]+=[[:space:]]+).*$|\1\"$STATE_SYNC_RPC,$STATE_SYNC_RPC\"| ; \
s|^(trust_height[[:space:]]+=[[:space:]]+).*$|\1$BLOCK_HEIGHT| ; \
s|^(trust_hash[[:space:]]+=[[:space:]]+).*$|\1\"$TRUST_HASH\"|" $HOME/.source/config/config.toml

mv $HOME/.source/priv_validator_state.json.backup $HOME/.source/data/priv_validator_state.json
sudo systemctl restart sourced && sudo journalctl -u sourced -f -o cat
```

### Source CLI Cheatsheet

- Always be careful with the capitalized words
- Specify `--chain-id`

### Wallet Management

Add Wallet
Specify the value `wallet` with your own wallet name

```
sourced keys add wallet
```

Recover Wallet
```
sourced keys add wallet --recover
```

List Wallet
```
sourced keys list
```

Delete Wallet
```
sourced keys delete wallet
```

Check Wallet Balance
```
sourced q bank balances $(sourced keys show wallet -a)
```

### Validator Management

Please adjust `wallet` , `MONIKER` , `YOUR_KEYBASE_ID` , `YOUR_DETAILS` , `YOUUR_WEBSITE_URL`

Create Validator
```
sourced tx staking create-validator \
  --chain-id source-1 \
  --pubkey="$(sourced tendermint show-validator)" \
  --moniker="YOUR_MONIKER" \
  --amount 1000000usource \
  --identity "YOUR_KEYBASE_ID" \
  --website "YOUR_WEBSITE_URL" \
  --details "YOUR_DETAILS" \
  --from wallet \
  --commission-rate=0.05 \
  --commission-max-rate=0.20 \
  --commission-max-change-rate=0.01 \
  --min-self-delegation 1 \
  --gas auto \
  --gas-prices  0.025usource \
  -y
```

Edit Validator
```
sourced tx staking edit-validator \
--new-moniker "YOUR_MONIKER " \
--identity "YOUR_KEYBASE_ID" \
--website "YOUR_WEBSITE_URL" \
--details "YOUR_DETAILS" \
--chain-id source-1 \
--commission-rate=0.01 \
--min-self-delegation=1 \
--from=wallet \
--gas auto \
-y
```


Unjail Validator
```
sourced tx slashing unjail --from wallet --chain-id source-1 --gas auto -y
```

Check Jailed Reason
```
sourced query slashing signing-info $(sourced tendermint show-validator)
```

### Token Management

Withdraw Rewards
```
sourced tx distribution withdraw-all-rewards --from wallet --chain-id source-1 --gas-adjustment 1.4 --gas auto --gas-prices="0.025usource" -y
```

Withdraw Rewards with Comission
```
sourced tx distribution withdraw-rewards $(sourced keys show wallet --bech val -a) --commission --from wallet --chain-id source-1 --gas-adjustment 1.4 --gas auto --gas-prices="0.025usource" -y
```

Delegate Token to your own validator
```
sourced tx staking delegate $(sourced keys show wallet --bech val -a) 100000000usource --from wallet --chain-id source-1 --gas-adjustment 1.4 --gas auto --gas-prices="0.025usource" -y
```

Delegate Token to other validator
```
sourced tx staking redelegate $(sourced keys show wallet --bech val -a) <TO_VALOPER_ADDRESS> 100000000usource --from wallet --chain-id source-1 --gas-adjustment 1.4 --gas auto --gas-prices="0.025usource" -y
```

Unbond Token from your validator
```
sourced tx staking unbond $(sourced keys show wallet --bech val -a) 100000000usource --from wallet --chain-id source-1 --gas-adjustment 1.4 --gas auto --gas-prices="0.025usource" -y
```

Send Token to another wallet
```
sourced tx bank send wallet <TO_WALLET_ADDRESS> 100000000usource --from wallet --chain-id source-1
```

### Governance 

Vote
You can change the value of `yes` to `no`,`abstain`,`nowithveto`

```
sourced tx gov vote 1 yes --from wallet --chain-id source-1 --gas-adjustment 1.4 --gas auto --gas-prices="0.025usource" -y
```

### Other

Set Your own Custom Ports
You can change value `CUSTOM_PORT=114` To any other ports
```
CUSTOM_PORT=108
sed -i -e "s%^proxy_app = \"tcp://127.0.0.1:26658\"%proxy_app = \"tcp://127.0.0.1:${CUSTOM_PORT}658\"%; s%^laddr = \"tcp://127.0.0.1:26657\"%laddr = \"tcp://127.0.0.1:${CUSTOM_PORT}57\"%; s%^pprof_laddr = \"localhost:6060\"%pprof_laddr = \"localhost:${CUSTOM_PORT}60\"%; s%^laddr = \"tcp://0.0.0.0:26656\"%laddr = \"tcp://0.0.0.0:${CUSTOM_PORT}656\"%; s%^prometheus_listen_addr = \":26660\"%prometheus_listen_addr = \":${CUSTOM_PORT}60\"%" $HOME/.source/config/config.toml
sed -i -e "s%^address = \"tcp://0.0.0.0:1317\"%address = \"tcp://0.0.0.0:${CUSTOM_PORT}17\"%; s%^address = \":8080\"%address = \":${CUSTOM_PORT}80\"%; s%^address = \"0.0.0.0:9090\"%address = \"0.0.0.0:${CUSTOM_PORT}90\"%; s%^address = \"0.0.0.0:9091\"%address = \"0.0.0.0:${CUSTOM_PORT}91\"%" $HOME/.source/config/app.toml
```

Enable Indexing usually enabled by default
```
sed -i -e 's|^indexer *=.*|indexer = "kv"|' $HOME/.source/config/config.toml
```

Disable Indexing
```
sed -i -e 's|^indexer *=.*|indexer = "null"|' $HOME/.source/config/config.toml
```

Reset Chain Data
```
sourced tendermint unsafe-reset-all --home $HOME/.source --keep-addr-book
```

### Delete Node

WARNING! Use this command wisely 
Backup your key first it will remove source

```
sudo systemctl stop sourced && \
sudo systemctl disable sourced && \
rm /etc/systemd/system/sourced.service && \
sudo systemctl daemon-reload && \
cd $HOME && \
rm -rf .source && \
rm -rf $(which sourced)
```
