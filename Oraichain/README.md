<p align="center">
  <img height="100" height="auto" src="https://github.com/hexskrt/logos/blob/main/oraichain.jpg?raw=true">
</p>

# Oraichain Mainnet | Chain ID : Oraichain

### Custom Explorer:
>-  https://explorer.hexnodes.co/ORAICHAIN

### Public Endpoint

>- API : https://lcd.oraichain.hexnodes.co
>- RPC : https://rpc.oraichain.hexnodes.co
>- gRPC : https://grpc.oraichain.hexnodes.co

### Auto Installation

```
wget -O oraichain.sh https://raw.githubusercontent.com/hexskrt/mainnet/main/oraichain/oraichain.sh && chmod +x oraichain.sh && ./oraichain.sh
```

### Genesis
```
wget -O https://snapshot.hexnodes.co/oraid/genesis.json $HOME/.oraid/config/genesis.json
```

### Addrbook
```
wget -O https://snapshot.hexnodes.co/oraid/addrbook.json $HOME/.oraid/config/addrbook.json
```

### Snapshot

```
sudo systemctl stop oraid
cp $HOME/.oraid/data/priv_validator_state.json $HOME/.oraid/priv_validator_state.json.backup
rm -rf $HOME/.oraid/data
curl -o - -L http://snapshot.hexnodes.co/oraid/oraid.latest.tar.lz4 | lz4 -c -d - | tar -x -C $HOME/.oraid
mv $HOME/.oraid/priv_validator_state.json.backup $HOME/.oraid/data/priv_validator_state.json
sudo systemctl restart oraid && journalctl -u oraid -f -o cat
```


### State Sync

```
sudo systemctl stop oraid
cp $HOME/.oraid/data/priv_validator_state.json $HOME/.oraid/priv_validator_state.json.backup
oraid tendermint unsafe-reset-all --home $HOME/.oraid

STATE_SYNC_RPC=https://rpc.oraichain.hexnodes.co:443
LATEST_HEIGHT=$(curl -s $STATE_SYNC_RPC/block | jq -r .result.block.header.height)
SYNC_BLOCK_HEIGHT=$(($LATEST_HEIGHT - 2000))
SYNC_BLOCK_HASH=$(curl -s "$STATE_SYNC_RPC/block?height=$SYNC_BLOCK_HEIGHT" | jq -r .result.block_id.hash)

sed -i.bak -E "s|^(enable[[:space:]]+=[[:space:]]+).*$|\1true| ; \
s|^(rpc_servers[[:space:]]+=[[:space:]]+).*$|\1\"$SNAP_RPC,$SNAP_RPC\"| ; \
s|^(trust_height[[:space:]]+=[[:space:]]+).*$|\1$BLOCK_HEIGHT| ; \
s|^(trust_hash[[:space:]]+=[[:space:]]+).*$|\1\"$TRUST_HASH\"|" $HOME/.oraid/config/config.toml

mv $HOME/.oraid/priv_validator_state.json.backup $HOME/.oraid/data/priv_validator_state.json
sudo systemctl restart oraid && sudo journalctl -u oraid -f -o cat
```

### Oraichain CLI Cheatsheet

- Always be careful with the capitalized words
- Specify `--chain-id`

### Wallet Management

Add Wallet
Specify the value `wallet` with your own wallet name

```
oraid keys add wallet
```

Recover Wallet
```
oraid keys add wallet --recover
```

List Wallet
```
oraid keys list
```

Delete Wallet
```
oraid keys delete wallet
```

Check Wallet Balance
```
oraid q bank balances $(oraid keys show wallet -a)
```

### Validator Management

Please adjust `wallet` , `MONIKER` , `YOUR_KEYBASE_ID` , `YOUR_DETAILS` , `YOUUR_WEBSITE_URL`

Create Validator
```
oraid tx staking create-validator \
  --chain-id Oraichain \
  --pubkey="$(oraid tendermint show-validator)" \
  --moniker="YOUR_MONIKER" \
  --amount 1000000orai \
  --identity "YOUR_KEYBASE_ID" \
  --website "YOUR_WEBSITE_URL" \
  --details "YOUR_DETAILS" \
  --from wallet \
  --commission-rate=0.05 \
  --commission-max-rate=0.20 \
  --commission-max-change-rate=0.01 \
  --min-self-delegation 1 \
  --gas auto \
  --fees=2000orai \
  -y
```

Edit Validator
```
oraid tx staking edit-validator \
--new-moniker "YOUR_MONIKER " \
--identity "YOUR_KEYBASE_ID" \
--website "YOUR_WEBSITE_URL" \
--details "YOUR_DETAILS" \
--chain-id Oraichain \
--commission-rate=0.01 \
--min-self-delegation=1 \
--from=wallet \
--gas auto \
-y
```


Unjail Validator
```
oraid tx slashing unjail --from wallet --chain-id Oraichain --gas auto -y
```

Check Jailed Reason
```
oraid query slashing signing-info $(oraid tendermint show-validator)
```

### Token Management

Withdraw Rewards
```
oraid tx distribution withdraw-all-rewards --from wallet --chain-id Oraichain --gas-adjustment 1.4 --gas auto --gas-prices="0.025orai" -y
```

Withdraw Rewards with Comission
```
oraid tx distribution withdraw-rewards $(oraid keys show wallet --bech val -a) --commission --from wallet --chain-id Oraichain --gas-adjustment 1.4 --gas auto --gas-prices="0.025orai" -y
```

Delegate Token to your own validator
```
oraid tx staking delegate $(oraid keys show wallet --bech val -a) 100000000orai --from wallet --chain-id Oraichain --gas-adjustment 1.4 --gas auto --gas-prices="0.025orai" -y
```

Delegate Token to other validator
```
oraid tx staking redelegate $(oraid keys show wallet --bech val -a) <TO_VALOPER_ADDRESS> 100000000orai --from wallet --chain-id Oraichain --gas-adjustment 1.4 --gas auto --gas-prices="0.025orai" -y
```

Unbond Token from your validator
```
oraid tx staking unbond $(oraid keys show wallet --bech val -a) 100000000orai --from wallet --chain-id Oraichain --gas-adjustment 1.4 --gas auto --gas-prices="0.025orai" -y
```

Send Token to another wallet
```
oraid tx bank send wallet <TO_WALLET_ADDRESS> 100000000orai --from wallet --chain-id Oraichain
```

### Governance 

Vote
You can change the value of `yes` to `no`,`abstain`,`nowithveto`

```
oraid tx gov vote 1 yes --from wallet --chain-id Oraichain --gas-adjustment 1.4 --gas auto --gas-prices="0.025orai" -y
```

### Other

Set Your own Custom Ports
You can change value `CUSTOM_PORT=107` To any other ports
```
CUSTOM_PORT=107
sed -i -e "s%^proxy_app = \"tcp://127.0.0.1:26658\"%proxy_app = \"tcp://127.0.0.1:${CUSTOM_PORT}658\"%; s%^laddr = \"tcp://127.0.0.1:26657\"%laddr = \"tcp://127.0.0.1:${CUSTOM_PORT}57\"%; s%^pprof_laddr = \"localhost:6060\"%pprof_laddr = \"localhost:${CUSTOM_PORT}60\"%; s%^laddr = \"tcp://0.0.0.0:26656\"%laddr = \"tcp://0.0.0.0:${CUSTOM_PORT}656\"%; s%^prometheus_listen_addr = \":26660\"%prometheus_listen_addr = \":${CUSTOM_PORT}60\"%" $HOME/.oraid/config/config.toml
sed -i -e "s%^address = \"tcp://0.0.0.0:1317\"%address = \"tcp://0.0.0.0:${CUSTOM_PORT}17\"%; s%^address = \":8080\"%address = \":${CUSTOM_PORT}80\"%; s%^address = \"0.0.0.0:9090\"%address = \"0.0.0.0:${CUSTOM_PORT}90\"%; s%^address = \"0.0.0.0:9091\"%address = \"0.0.0.0:${CUSTOM_PORT}91\"%" $HOME/.oraid/config/app.toml
```

Enable Indexing usually enabled by default
```
sed -i -e 's|^indexer *=.*|indexer = "kv"|' $HOME/.oraid/config/config.toml
```

Disable Indexing
```
sed -i -e 's|^indexer *=.*|indexer = "null"|' $HOME/.oraid/config/config.toml
```

Reset Chain Data
```
oraid tendermint unsafe-reset-all --home $HOME/.oraid --keep-addr-book
```

### Delete Node

WARNING! Use this command wisely 
Backup your key first it will remove oraichain

```
sudo systemctl stop oraid && \
sudo systemctl disable oraid && \
rm /etc/systemd/system/oraid.service && \
sudo systemctl daemon-reload && \
cd $HOME && \
rm -rf .oraid && \
rm -rf $(which oraid)
```
