<p align="center">
  <img height="100" height="auto" src="https://github.com/hexskrt/logos/blob/main/planq.jpg?raw=true">
</p>

# Planq Mainnet | Chain ID : planq_7070-2

### Custom Explorer:
>-  https://explorer.hexnodes.co/PLANQ

### Public Endpoint

>- API : https://lcd.planq.hexnodes.co
>- RPC : https://rpc.planq.hexnodes.co
>- gRPC : https://grpc.planq.hexnodes.co

### Auto Installation

```
wget -O planq.sh https://raw.githubusercontent.com/hexskrt/mainnet/main/Planq/planq.sh && chmod +x planq.sh && ./planq.sh
```

### Snapshot

```
sudo systemctl stop planqd
cp $HOME/.planqd/data/priv_validator_state.json $HOME/.planqd/priv_validator_state.json.backup
rm -rf $HOME/.planqd/data
curl -o - -L http://snapshot.hexnodes.co/planq/planq.latest.tar.lz4 | lz4 -c -d - | tar -x -C $HOME/.planqd
mv $HOME/.planqd/priv_validator_state.json.backup $HOME/.planqd/data/priv_validator_state.json
sudo systemctl restart planqd && journalctl -u planqd -f -o cat
```


### State Sync

```
sudo systemctl stop planqd
cp $HOME/.planqd/data/priv_validator_state.json $HOME/.planqd/priv_validator_state.json.backup
planqd tendermint unsafe-reset-all --home $HOME/.planqd

STATE_SYNC_RPC=https://rpc.planq.hexnodes.co:443
STATE_SYNC_PEER=8391cf5a7fe59098205015870635f90acfb5dcb4@185.202.239.161:33656
LATEST_HEIGHT=$(curl -s $STATE_SYNC_RPC/block | jq -r .result.block.header.height)
SYNC_BLOCK_HEIGHT=$(($LATEST_HEIGHT - 2000))
SYNC_BLOCK_HASH=$(curl -s "$STATE_SYNC_RPC/block?height=$SYNC_BLOCK_HEIGHT" | jq -r .result.block_id.hash)

sed -i.bak -E "s|^(enable[[:space:]]+=[[:space:]]+).*$|\1true| ; \
s|^(rpc_servers[[:space:]]+=[[:space:]]+).*$|\1\"$SNAP_RPC,$SNAP_RPC\"| ; \
s|^(trust_height[[:space:]]+=[[:space:]]+).*$|\1$BLOCK_HEIGHT| ; \
s|^(trust_hash[[:space:]]+=[[:space:]]+).*$|\1\"$TRUST_HASH\"|" $HOME/.planqd/config/config.toml

mv $HOME/.planqd/priv_validator_state.json.backup $HOME/.planqd/data/priv_validator_state.json
sudo systemctl restart planqd && sudo journalctl -u planqd -f -o cat
```

### Empower CLI Cheatsheet

- Always be careful with the capitalized words
- Specify `--chain-id`

### Wallet Management

Add Wallet
Specify the value `wallet` with your own wallet name

```
planqd keys add wallet
```

Recover Wallet
```
planqd keys add wallet --recover
```

List Wallet
```
planqd keys list
```

Delete Wallet
```
planqd keys delete wallet
```

Check Wallet Balance
```
planqd q bank balances $(planqd keys show wallet -a)
```

### Validator Management

Please adjust `wallet` , `MONIKER` , `YOUR_KEYBASE_ID` , `YOUR_DETAILS` , `YOUUR_WEBSITE_URL`

Create Validator
```
planqd tx staking create-validator \
  --chain-id planq_7070-2 \
  --pubkey="$(planqd tendermint show-validator)" \
  --moniker="YOUR_MONIKER" \
  --amount 1000000aplanq \
  --identity "YOUR_KEYBASE_ID" \
  --website "YOUR_WEBSITE_URL" \
  --details "YOUR_DETAILS" \
  --from wallet \
  --commission-rate=0.05 \
  --commission-max-rate=0.20 \
  --commission-max-change-rate=0.01 \
  --min-self-delegation 1 \
  --gas auto \
  --fees=2000aplanq \
  -y
```

Edit Validator
```
planqd tx staking edit-validator \
--new-moniker "YOUR_MONIKER " \
--identity "YOUR_KEYBASE_ID" \
--website "YOUR_WEBSITE_URL" \
--details "YOUR_DETAILS" \
--chain-id planq_7070-2 \
--commission-rate=0.01 \
--min-self-delegation=1 \
--from=wallet \
--gas auto \
-y
```


Unjail Validator
```
planqd tx slashing unjail --from wallet --chain-id planq_7070-2 --gas auto -y
```

Check Jailed Reason
```
planqd query slashing signing-info $(planqd tendermint show-validator)
```

### Token Management

Withdraw Rewards
```
planqd tx distribution withdraw-all-rewards --from wallet --chain-id planq_7070-2 --gas-adjustment 1.4 --gas auto --gas-prices="0.025aplanq" -y
```

Withdraw Rewards with Comission
```
planqd tx distribution withdraw-rewards $(planqd keys show wallet --bech val -a) --commission --from wallet --chain-id planq_7070-2 --gas-adjustment 1.4 --gas auto --gas-prices="0.025aplanq" -y
```

Delegate Token to your own validator
```
planqd tx staking delegate $(planqd keys show wallet --bech val -a) 100000000aplanq --from wallet --chain-id planq_7070-2 --gas-adjustment 1.4 --gas auto --gas-prices="0.025aplanq" -y
```

Delegate Token to other validator
```
planqd tx staking redelegate $(planqd keys show wallet --bech val -a) <TO_VALOPER_ADDRESS> 100000000aplanq --from wallet --chain-id planq_7070-2 --gas-adjustment 1.4 --gas auto --gas-prices="0.025aplanq" -y
```

Unbond Token from your validator
```
planqd tx staking unbond $(planqd keys show wallet --bech val -a) 100000000aplanq --from wallet --chain-id planq_7070-2 --gas-adjustment 1.4 --gas auto --gas-prices="0.025aplanq" -y
```

Send Token to another wallet
```
planqd tx bank send wallet <TO_WALLET_ADDRESS> 100000000aplanq --from wallet --chain-id planq_7070-2
```

### Governance 

Vote
You can change the value of `yes` to `no`,`abstain`,`nowithveto`

```
planqd tx gov vote 1 yes --from wallet --chain-id planq_7070-2 --gas-adjustment 1.4 --gas auto --gas-prices="0.025aplanq" -y
```

### Other

Set Your own Custom Ports
You can change value `CUSTOM_PORT=104` To any other ports
```
CUSTOM_PORT=107
sed -i -e "s%^proxy_app = \"tcp://127.0.0.1:26658\"%proxy_app = \"tcp://127.0.0.1:${CUSTOM_PORT}658\"%; s%^laddr = \"tcp://127.0.0.1:26657\"%laddr = \"tcp://127.0.0.1:${CUSTOM_PORT}57\"%; s%^pprof_laddr = \"localhost:6060\"%pprof_laddr = \"localhost:${CUSTOM_PORT}60\"%; s%^laddr = \"tcp://0.0.0.0:26656\"%laddr = \"tcp://0.0.0.0:${CUSTOM_PORT}656\"%; s%^prometheus_listen_addr = \":26660\"%prometheus_listen_addr = \":${CUSTOM_PORT}60\"%" $HOME/.planqd/config/config.toml
sed -i -e "s%^address = \"tcp://0.0.0.0:1317\"%address = \"tcp://0.0.0.0:${CUSTOM_PORT}17\"%; s%^address = \":8080\"%address = \":${CUSTOM_PORT}80\"%; s%^address = \"0.0.0.0:9090\"%address = \"0.0.0.0:${CUSTOM_PORT}90\"%; s%^address = \"0.0.0.0:9091\"%address = \"0.0.0.0:${CUSTOM_PORT}91\"%" $HOME/.planqd/config/app.toml
```

Enable Indexing usually enabled by default
```
sed -i -e 's|^indexer *=.*|indexer = "kv"|' $HOME/.planqd/config/config.toml
```

Disable Indexing
```
sed -i -e 's|^indexer *=.*|indexer = "null"|' $HOME/.planqd/config/config.toml
```

Reset Chain Data
```
planqd tendermint unsafe-reset-all --home $HOME/.planqd --keep-addr-book
```

### Delete Node

WARNING! Use this command wisely 
Backup your key first it will remove empower

```
sudo systemctl stop planqd && \
sudo systemctl disable planqd && \
rm /etc/systemd/system/planqd.service && \
sudo systemctl daemon-reload && \
cd $HOME && \
rm -rf .planqd && \
rm -rf $(which planqd)
```
