<p align="center">
  <img height="100" height="auto" src="https://github.com/hexskrt/logos/blob/main/gitopia.png?raw=true">
</p>

# Gitopia Mainnet | Chain ID : gitopia

### Custom Explorer:
>-  https://explorer.hexnodes.co/GITOPIA

### Public Endpoint

>- API : https://lcd.gitopia.hexnodes.co
>- RPC : https://rpc.gitopia.hexnodes.co
>- gRPC : https://grpc.gitopia.hexnodes.co

### Auto Installation

```
wget -O gitopia.sh https://raw.githubusercontent.com/hexskrt/mainnet/main/Gitopia/gitopia.sh && chmod +x gitopia.sh && ./gitopia.sh
```

### Snapshot updated every 5 hours

```
sudo systemctl stop gitopiad
cp $HOME/.gitopia/data/priv_validator_state.json $HOME/.gitopia/priv_validator_state.json.backup
rm -rf $HOME/.gitopia/data
curl -o - -L http://snap.hexnodes.co/gitopia/gitopia.latest.tar.lz4 | lz4 -c -d - | tar -x -C $HOME/.gitopia
mv $HOME/.gitopia/priv_validator_state.json.backup $HOME/.gitopia/data/priv_validator_state.json
sudo systemctl restart gitopiad && journalctl -u gitopiad -f -o cat
```


### State Sync

```
sudo systemctl stop gitopiad
cp $HOME/.gitopia/data/priv_validator_state.json $HOME/.gitopia/priv_validator_state.json.backup
gitopiad tendermint unsafe-reset-all --home $HOME/.gitopia

STATE_SYNC_RPC=https://rpc.gitopia.hexnodes.co:443
LATEST_HEIGHT=$(curl -s $STATE_SYNC_RPC/block | jq -r .result.block.header.height)
SYNC_BLOCK_HEIGHT=$(($LATEST_HEIGHT - 2000))
SYNC_BLOCK_HASH=$(curl -s "$STATE_SYNC_RPC/block?height=$SYNC_BLOCK_HEIGHT" | jq -r .result.block_id.hash)

sed -i.bak -E "s|^(enable[[:space:]]+=[[:space:]]+).*$|\1true| ; \
s|^(rpc_servers[[:space:]]+=[[:space:]]+).*$|\1\"$STATE_SYNC_RPC,$STATE_SYNC_RPC\"| ; \
s|^(trust_height[[:space:]]+=[[:space:]]+).*$|\1$BLOCK_HEIGHT| ; \
s|^(trust_hash[[:space:]]+=[[:space:]]+).*$|\1\"$TRUST_HASH\"|" $HOME/.gitopia/config/config.toml

mv $HOME/.gitopia/priv_validator_state.json.backup $HOME/.gitopia/data/priv_validator_state.json
sudo systemctl restart gitopiad && sudo journalctl -u gitopiad -f -o cat
```

### Gitopia CLI Cheatsheet

- Always be careful with the capitalized words
- Specify `--chain-id`

### Wallet Management

Add Wallet
Specify the value `wallet` with your own wallet name

```
gitopiad keys add wallet
```

Recover Wallet
```
gitopiad keys add wallet --recover
```

List Wallet
```
gitopiad keys list
```

Delete Wallet
```
gitopiad keys delete wallet
```

Check Wallet Balance
```
gitopiad q bank balances $(gitopiad keys show wallet -a)
```

### Validator Management

Please adjust `wallet` , `MONIKER` , `YOUR_KEYBASE_ID` , `YOUR_DETAILS` , `YOUR_WEBSITE_URL`

Create Validator
```
gitopiad tx staking create-validator \
  --chain-id gitopia \
  --pubkey="$(gitopiad tendermint show-validator)" \
  --moniker="YOUR_MONIKER" \
  --amount 1000000ulore \
  --identity "YOUR_KEYBASE_ID" \
  --website "YOUR_WEBSITE_URL" \
  --details "YOUR_DETAILS" \
  --from wallet \
  --commission-rate=0.05 \
  --commission-max-rate=0.20 \
  --commission-max-change-rate=0.01 \
  --min-self-delegation 1 \
  --gas auto \
  --fees=2000ulore \
  -y
```

Edit Validator
```
gitopiad tx staking edit-validator \
--new-moniker "YOUR_MONIKER " \
--identity "YOUR_KEYBASE_ID" \
--website "YOUR_WEBSITE_URL" \
--details "YOUR_DETAILS" \
--chain-id gitopia \
--commission-rate=0.01 \
--min-self-delegation=1 \
--from=wallet \
--gas auto \
-y
```


Unjail Validator
```
gitopiad tx slashing unjail --from wallet --chain-id gitopia --gas auto -y
```

Check Jailed Reason
```
gitopiad query slashing signing-info $(gitopiad tendermint show-validator)
```

### Token Management

Withdraw Rewards
```
gitopiad tx distribution withdraw-all-rewards --from wallet --chain-id gitopia --gas-adjustment 1.4 --gas auto --gas-prices="0.025ulore" -y
```

Withdraw Rewards with Comission
```
gitopiad tx distribution withdraw-rewards $(gitopiad keys show wallet --bech val -a) --commission --from wallet --chain-id gitopia --gas-adjustment 1.4 --gas auto --gas-prices="0.025ulore" -y
```

Delegate Token to your own validator
```
gitopiad tx staking delegate $(gitopiad keys show wallet --bech val -a) 100000000ulore --from wallet --chain-id gitopia --gas-adjustment 1.4 --gas auto --gas-prices="0.025ulore" -y
```

Delegate Token to other validator
```
gitopiad tx staking redelegate $(gitopiad keys show wallet --bech val -a) <TO_VALOPER_ADDRESS> 100000000ulore --from wallet --chain-id gitopia --gas-adjustment 1.4 --gas auto --gas-prices="0.025ulore" -y
```

Unbond Token from your validator
```
gitopiad tx staking unbond $(gitopiad keys show wallet --bech val -a) 100000000ulore --from wallet --chain-id gitopia --gas-adjustment 1.4 --gas auto --gas-prices="0.025ulore" -y
```

Send Token to another wallet
```
gitopiad tx bank send wallet <TO_WALLET_ADDRESS> 100000000ulore --from wallet --chain-id gitopia
```

### Governance 

Vote
You can change the value of `yes` to `no`,`abstain`,`nowithveto`

```
gitopiad tx gov vote 1 yes --from wallet --chain-id gitopia --gas-adjustment 1.4 --gas auto --gas-prices="0.025ulore" -y
```

### Other

Set Your own Custom Ports
You can change value `CUSTOM_PORT=105` To any other ports
```
CUSTOM_PORT=105
sed -i -e "s%^proxy_app = \"tcp://127.0.0.1:26658\"%proxy_app = \"tcp://127.0.0.1:${CUSTOM_PORT}658\"%; s%^laddr = \"tcp://127.0.0.1:26657\"%laddr = \"tcp://127.0.0.1:${CUSTOM_PORT}57\"%; s%^pprof_laddr = \"localhost:6060\"%pprof_laddr = \"localhost:${CUSTOM_PORT}60\"%; s%^laddr = \"tcp://0.0.0.0:26656\"%laddr = \"tcp://0.0.0.0:${CUSTOM_PORT}656\"%; s%^prometheus_listen_addr = \":26660\"%prometheus_listen_addr = \":${CUSTOM_PORT}60\"%" $HOME/.gitopia/config/config.toml
sed -i -e "s%^address = \"tcp://0.0.0.0:1317\"%address = \"tcp://0.0.0.0:${CUSTOM_PORT}17\"%; s%^address = \":8080\"%address = \":${CUSTOM_PORT}80\"%; s%^address = \"0.0.0.0:9090\"%address = \"0.0.0.0:${CUSTOM_PORT}90\"%; s%^address = \"0.0.0.0:9091\"%address = \"0.0.0.0:${CUSTOM_PORT}91\"%" $HOME/.gitopia/config/app.toml
```

Enable Indexing usually enabled by default
```
sed -i -e 's|^indexer *=.*|indexer = "kv"|' $HOME/.gitopia/config/config.toml
```

Disable Indexing
```
sed -i -e 's|^indexer *=.*|indexer = "null"|' $HOME/.gitopia/config/config.toml
```

Reset Chain Data
```
gitopiad tendermint unsafe-reset-all --home $HOME/.gitopia --keep-addr-book
```

### Delete Node

WARNING! Use this command wisely 
Backup your key first it will remove gitopia

```
sudo systemctl stop gitopiad && \
sudo systemctl disable gitopiad && \
rm /etc/systemd/system/gitopiad.service && \
sudo systemctl daemon-reload && \
cd $HOME && \
rm -rf .gitopia && \
rm -rf $(which gitopiad)
```
