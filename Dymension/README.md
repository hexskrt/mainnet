<p align="center">
  <img height="100" height="auto" src="https://github.com/hexskrt/logos/blob/main/dymension.jpg?raw=true">
</p>

# Dymension Mainnet | Chain ID : dymension_1100-1

### Custom Explorer:
>-  https://explorer.hexnodes.one/DYMENSION

### Public Endpoint

>- API : https://lcd.dymension.hexnodes.one
>- RPC : https://rpc.dymension.hexnodes.one
>- gRPC : https://grpc.dymension.hexnodes.one

### Auto Installation
```
wget -O dymension.sh https://raw.githubusercontent.com/hexskrt/mainnet/main/Dymension/dymension.sh && chmod +x dymension.sh && ./dymension.sh
```

### Snapshot updated every 5 hours
```
sudo systemctl stop dymd
cp $HOME/.dymension/data/priv_validator_state.json $HOME/.dymension/priv_validator_state.json.backup
rm -rf $HOME/.dymension/data
curl -o - -L https://snap.nodex.one/dymension/dymension-latest.tar.lz4 | lz4 -c -d - | tar -x -C $HOME/.dymension
mv $HOME/.dymension/priv_validator_state.json.backup $HOME/.dymension/data/priv_validator_state.json
sudo systemctl restart dymd && journalctl -u dymd -f -o cat
```


### State Sync
```
sudo systemctl stop dymd
cp $HOME/.dymension/data/priv_validator_state.json $HOME/.dymension/priv_validator_state.json.backup
dymd tendermint unsafe-reset-all --home $HOME/.dymension

STATE_SYNC_RPC=https://rpc.dymension.hexnodes.one:443
LATEST_HEIGHT=$(curl -s $STATE_SYNC_RPC/block | jq -r .result.block.header.height)
SYNC_BLOCK_HEIGHT=$(($LATEST_HEIGHT - 2000))
SYNC_BLOCK_HASH=$(curl -s "$STATE_SYNC_RPC/block?height=$SYNC_BLOCK_HEIGHT" | jq -r .result.block_id.hash)

sed -i.bak -E "s|^(enable[[:space:]]+=[[:space:]]+).*$|\1true| ; \
s|^(rpc_servers[[:space:]]+=[[:space:]]+).*$|\1\"$STATE_SYNC_RPC,$STATE_SYNC_RPC\"| ; \
s|^(trust_height[[:space:]]+=[[:space:]]+).*$|\1$BLOCK_HEIGHT| ; \
s|^(trust_hash[[:space:]]+=[[:space:]]+).*$|\1\"$TRUST_HASH\"|" $HOME/.dymension/config/config.toml

mv $HOME/.dymension/priv_validator_state.json.backup $HOME/.dymension/data/priv_validator_state.json
sudo systemctl restart dymd && sudo journalctl -u dymd -f -o cat
```

### Dymension CLI Cheatsheet

- Always be careful with the capitalized words
- Specify `--chain-id`

### Wallet Management

Add Wallet
Specify the value `wallet` with your own wallet name

```
dymd keys add wallet
```

Recover Wallet
```
dymd keys add wallet --recover
```

List Wallet
```
dymd keys list
```

Delete Wallet
```
dymd keys delete wallet
```

Check Wallet Balance
```
dymd q bank balances $(dymd keys show wallet -a)
```

### Validator Management

Please adjust `wallet` , `MONIKER` , `YOUR_KEYBASE_ID` , `YOUR_DETAILS` , `YOUUR_WEBSITE_URL`

Create Validator
```
dymd tx staking create-validator \
  --chain-id dymension_1100-1 \
  --pubkey="$(dymd tendermint show-validator)" \
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
dymd tx staking edit-validator \
--new-moniker "YOUR_MONIKER " \
--identity "YOUR_KEYBASE_ID" \
--website "YOUR_WEBSITE_URL" \
--details "YOUR_DETAILS" \
--chain-id dymension_1100-1 \
--commission-rate=0.01 \
--min-self-delegation=1 \
--from=wallet \
--gas auto \
-y
```


Unjail Validator
```
dymd tx slashing unjail --from wallet --chain-id dymension_1100-1 --gas auto -y
```

Check Jailed Reason
```
dymd query slashing signing-info $(dymd tendermint show-validator)
```

### Token Management

Withdraw Rewards
```
dymd tx distribution withdraw-all-rewards --from wallet --chain-id dymension_1100-1 --gas-adjustment 1.4 --gas auto --gas-prices="20000000000adym" -y
```

Withdraw Rewards with Comission
```
dymd tx distribution withdraw-rewards $(dymd keys show wallet --bech val -a) --commission --from wallet --chain-id dymension_1100-1 --gas-adjustment 1.4 --gas auto --gas-prices="20000000000adym" -y
```

Delegate Token to your own validator
```
dymd tx staking delegate $(dymd keys show wallet --bech val -a) 100000000udec --from wallet --chain-id dymension_1100-1 --gas-adjustment 1.4 --gas auto --gas-prices="20000000000adym" -y
```

Delegate Token to other validator
```
dymd tx staking redelegate $(dymd keys show wallet --bech val -a) <TO_VALOPER_ADDRESS> 100000000udec --from wallet --chain-id dymension_1100-1 --gas-adjustment 1.4 --gas auto --gas-prices="20000000000adym" -y
```

Unbond Token from your validator
```
dymd tx staking unbond $(dymd keys show wallet --bech val -a) 100000000udec --from wallet --chain-id dymension_1100-1 --gas-adjustment 1.4 --gas auto --gas-prices="20000000000adym" -y
```

Send Token to another wallet
```
dymd tx bank send wallet <TO_WALLET_ADDRESS> 100000000udec --from wallet --chain-id dymension_1100-1
```

### Governance 

Vote
You can change the value of `yes` to `no`,`abstain`,`nowithveto`

```
dymd tx gov vote 1 yes --from wallet --chain-id dymension_1100-1 --gas-adjustment 1.4 --gas auto --gas-prices="20000000000adym" -y
```

### Other

Set Your own Custom Ports
You can change value `CUSTOM_PORT=103` To any other ports
```
CUSTOM_PORT=103
sed -i -e "s%^proxy_app = \"tcp://127.0.0.1:26658\"%proxy_app = \"tcp://127.0.0.1:${CUSTOM_PORT}658\"%; s%^laddr = \"tcp://127.0.0.1:26657\"%laddr = \"tcp://127.0.0.1:${CUSTOM_PORT}57\"%; s%^pprof_laddr = \"localhost:6060\"%pprof_laddr = \"localhost:${CUSTOM_PORT}60\"%; s%^laddr = \"tcp://0.0.0.0:26656\"%laddr = \"tcp://0.0.0.0:${CUSTOM_PORT}656\"%; s%^prometheus_listen_addr = \":26660\"%prometheus_listen_addr = \":${CUSTOM_PORT}60\"%" $HOME/.dymension/config/config.toml
sed -i -e "s%^address = \"tcp://0.0.0.0:1317\"%address = \"tcp://0.0.0.0:${CUSTOM_PORT}17\"%; s%^address = \":8080\"%address = \":${CUSTOM_PORT}80\"%; s%^address = \"0.0.0.0:9090\"%address = \"0.0.0.0:${CUSTOM_PORT}90\"%; s%^address = \"0.0.0.0:9091\"%address = \"0.0.0.0:${CUSTOM_PORT}91\"%" $HOME/.dymension/config/app.toml
```

Enable Indexing usually enabled by default
```
sed -i -e 's|^indexer *=.*|indexer = "kv"|' $HOME/.dymension/config/config.toml
```

Disable Indexing
```
sed -i -e 's|^indexer *=.*|indexer = "null"|' $HOME/.dymension/config/config.toml
```

Reset Chain Data
```
dymd tendermint unsafe-reset-all --home $HOME/.dymension --keep-addr-book
```

### Delete Node

WARNING! Use this command wisely 
Backup your key first it will remove dymension

```
sudo systemctl stop dymd && \
sudo systemctl disable dymd && \
rm /etc/systemd/system/dymd.service && \
sudo systemctl daemon-reload && \
cd $HOME && \
rm -rf .dymension && \
rm -rf $(which dymd)
```
