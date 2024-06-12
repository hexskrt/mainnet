<p align="center">
  <img height="100" height="auto" src="https://github.com/hexskrt/logos/blob/main/terp.jpeg?raw=true">
</p>

# Terp Mainnet | Chain ID : morocco-1

### Custom Explorer:
>-  https://explorer.hexnodes.one/TERP

### Public Endpoint

>- API : https://lcd.terp.hexnodes.one
>- RPC : https://rpc.terp.hexnodes.one
>- gRPC : https://grpc.terp.hexnodes.one

### Auto Installation

```
wget -O terp.sh https://raw.githubusercontent.com/hexskrt/mainnet/main/Terp/terp.sh && chmod +x terp.sh && ./terp.sh
```

### Snapshot

```
sudo systemctl stop terpd
cp $HOME/.terp/data/priv_validator_state.json $HOME/.terp/priv_validator_state.json.backup
rm -rf $HOME/.terp/data
curl -o - -L http://snapshot.hexnodes.one/terp/terp.latest.tar.lz4 | lz4 -c -d - | tar -x -C $HOME/.terp
mv $HOME/.terp/priv_validator_state.json.backup $HOME/.terp/data/priv_validator_state.json
sudo systemctl restart terpd && journalctl -u terpd -f -o cat
```


### State Sync

```
sudo systemctl stop terpd
cp $HOME/.terp/data/priv_validator_state.json $HOME/.terp/priv_validator_state.json.backup
terpd tendermint unsafe-reset-all --home $HOME/.terp

STATE_SYNC_RPC=https://rpc.terp.hexnodes.one:443
LATEST_HEIGHT=$(curl -s $STATE_SYNC_RPC/block | jq -r .result.block.header.height)
SYNC_BLOCK_HEIGHT=$(($LATEST_HEIGHT - 2000))
SYNC_BLOCK_HASH=$(curl -s "$STATE_SYNC_RPC/block?height=$SYNC_BLOCK_HEIGHT" | jq -r .result.block_id.hash)

sed -i.bak -E "s|^(enable[[:space:]]+=[[:space:]]+).*$|\1true| ; \
s|^(rpc_servers[[:space:]]+=[[:space:]]+).*$|\1\"$STATE_SYNC_RPC,$STATE_SYNC_RPC\"| ; \
s|^(trust_height[[:space:]]+=[[:space:]]+).*$|\1$BLOCK_HEIGHT| ; \
s|^(trust_hash[[:space:]]+=[[:space:]]+).*$|\1\"$TRUST_HASH\"|" $HOME/.terp/config/config.toml

mv $HOME/.terp/priv_validator_state.json.backup $HOME/.terp/data/priv_validator_state.json
sudo systemctl restart terpd && sudo journalctl -u terpd -f -o cat
```

### Terp CLI Cheatsheet

- Always be careful with the capitalized words
- Specify `--chain-id`

### Wallet Management

Add Wallet
Specify the value `wallet` with your own wallet name

```
terpd keys add wallet
```

Recover Wallet
```
terpd keys add wallet --recover
```

List Wallet
```
terpd keys list
```

Delete Wallet
```
terpd keys delete wallet
```

Check Wallet Balance
```
terpd q bank balances $(terpd keys show wallet -a)
```

### Validator Management

Please adjust `wallet` , `MONIKER` , `YOUR_KEYBASE_ID` , `YOUR_DETAILS` , `YOUUR_WEBSITE_URL`

Create Validator
```
terpd tx staking create-validator \
  --chain-id morocco-1 \
  --pubkey="$(terpd tendermint show-validator)" \
  --moniker="YOUR_MONIKER" \
  --amount 1000000uterp \
  --identity "YOUR_KEYBASE_ID" \
  --website "YOUR_WEBSITE_URL" \
  --details "YOUR_DETAILS" \
  --from wallet \
  --commission-rate=0.05 \
  --commission-max-rate=0.20 \
  --commission-max-change-rate=0.01 \
  --min-self-delegation 1 \
  --gas auto \
  --fees=2000uterp \
  -y
```

Edit Validator
```
terpd tx staking edit-validator \
--new-moniker "YOUR_MONIKER " \
--identity "YOUR_KEYBASE_ID" \
--website "YOUR_WEBSITE_URL" \
--details "YOUR_DETAILS" \
--chain-id morocco-1 \
--commission-rate=0.01 \
--min-self-delegation=1 \
--from=wallet \
--gas auto \
-y
```


Unjail Validator
```
terpd tx slashing unjail --from wallet --chain-id morocco-1 --gas auto -y
```

Check Jailed Reason
```
terpd query slashing signing-info $(terpd tendermint show-validator)
```

### Token Management

Withdraw Rewards
```
terpd tx distribution withdraw-all-rewards --from wallet --chain-id morocco-1 --gas-adjustment 1.4 --gas auto --gas-prices="0.025uterp" -y
```

Withdraw Rewards with Comission
```
terpd tx distribution withdraw-rewards $(terpd keys show wallet --bech val -a) --commission --from wallet --chain-id morocco-1 --gas-adjustment 1.4 --gas auto --gas-prices="0.025uterp" -y
```

Delegate Token to your own validator
```
terpd tx staking delegate $(terpd keys show wallet --bech val -a) 100000000uterp --from wallet --chain-id morocco-1 --gas-adjustment 1.4 --gas auto --gas-prices="0.025uterp" -y
```

Delegate Token to other validator
```
terpd tx staking redelegate $(terpd keys show wallet --bech val -a) <TO_VALOPER_ADDRESS> 100000000uterp --from wallet --chain-id morocco-1 --gas-adjustment 1.4 --gas auto --gas-prices="0.025uterp" -y
```

Unbond Token from your validator
```
terpd tx staking unbond $(terpd keys show wallet --bech val -a) 100000000uterp --from wallet --chain-id morocco-1 --gas-adjustment 1.4 --gas auto --gas-prices="0.025uterp" -y
```

Send Token to another wallet
```
terpd tx bank send wallet <TO_WALLET_ADDRESS> 100000000uterp --from wallet --chain-id morocco-1
```

### Governance 

Vote
You can change the value of `yes` to `no`,`abstain`,`nowithveto`

```
terpd tx gov vote 1 yes --from wallet --chain-id morocco-1 --gas-adjustment 1.4 --gas auto --gas-prices="0.025uterp" -y
```

### Other

Set Your own Custom Ports
You can change value `CUSTOM_PORT=115` To any other ports
```
CUSTOM_PORT=115
sed -i -e "s%^proxy_app = \"tcp://127.0.0.1:26658\"%proxy_app = \"tcp://127.0.0.1:${CUSTOM_PORT}658\"%; s%^laddr = \"tcp://127.0.0.1:26657\"%laddr = \"tcp://127.0.0.1:${CUSTOM_PORT}57\"%; s%^pprof_laddr = \"localhost:6060\"%pprof_laddr = \"localhost:${CUSTOM_PORT}60\"%; s%^laddr = \"tcp://0.0.0.0:26656\"%laddr = \"tcp://0.0.0.0:${CUSTOM_PORT}656\"%; s%^prometheus_listen_addr = \":26660\"%prometheus_listen_addr = \":${CUSTOM_PORT}60\"%" $HOME/.terp/config/config.toml
sed -i -e "s%^address = \"tcp://0.0.0.0:1317\"%address = \"tcp://0.0.0.0:${CUSTOM_PORT}17\"%; s%^address = \":8080\"%address = \":${CUSTOM_PORT}80\"%; s%^address = \"0.0.0.0:9090\"%address = \"0.0.0.0:${CUSTOM_PORT}90\"%; s%^address = \"0.0.0.0:9091\"%address = \"0.0.0.0:${CUSTOM_PORT}91\"%" $HOME/.terp/config/app.toml
```

Enable Indexing usually enabled by default
```
sed -i -e 's|^indexer *=.*|indexer = "kv"|' $HOME/.terp/config/config.toml
```

Disable Indexing
```
sed -i -e 's|^indexer *=.*|indexer = "null"|' $HOME/.terp/config/config.toml
```

Reset Chain Data
```
terpd tendermint unsafe-reset-all --home $HOME/.terp --keep-addr-book
```

### Delete Node

WARNING! Use this command wisely 
Backup your key first it will remove terp

```
sudo systemctl stop terpd && \
sudo systemctl disable terpd && \
rm /etc/systemd/system/terpd.service && \
sudo systemctl daemon-reload && \
cd $HOME && \
rm -rf .terp && \
rm -rf $(which terpd)
```
