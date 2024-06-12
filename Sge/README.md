<p align="center">
  <img height="100" height="auto" src="https://github.com/hexskrt/logos/blob/main/sge.jpg?raw=true">
</p>

# Sge Mainnet | Chain ID : sgenet-1

### Custom Explorer:
>-  https://explorer.hexnodes.one/SGE

### Public Endpoint

>- API : https://lcd.sge.hexnodes.one
>- RPC : https://rpc.sge.hexnodes.one
>- gRPC : https://grpc.sge.hexnodes.one

### Auto Installation

```
wget -O sge.sh https://raw.githubusercontent.com/hexskrt/mainnet/main/Sge/sge.sh && chmod +x sge.sh && ./sge.sh
```

### Snapshot

```
sudo systemctl stop sged
cp $HOME/.sge/data/priv_validator_state.json $HOME/.sge/priv_validator_state.json.backup
rm -rf $HOME/.sge/data
curl -o - -L http://snapshot.hexnodes.one/sge/sge.latest.tar.lz4 | lz4 -c -d - | tar -x -C $HOME/.sge
mv $HOME/.sge/priv_validator_state.json.backup $HOME/.sge/data/priv_validator_state.json
sudo systemctl restart sged && journalctl -u sged -f -o cat
```


### State Sync

```
sudo systemctl stop sged
cp $HOME/.sge/data/priv_validator_state.json $HOME/.sge/priv_validator_state.json.backup
sged tendermint unsafe-reset-all --home $HOME/.sge

STATE_SYNC_RPC=https://rpc.sge.hexnodes.one:443
LATEST_HEIGHT=$(curl -s $STATE_SYNC_RPC/block | jq -r .result.block.header.height)
SYNC_BLOCK_HEIGHT=$(($LATEST_HEIGHT - 2000))
SYNC_BLOCK_HASH=$(curl -s "$STATE_SYNC_RPC/block?height=$SYNC_BLOCK_HEIGHT" | jq -r .result.block_id.hash)

sed -i.bak -E "s|^(enable[[:space:]]+=[[:space:]]+).*$|\1true| ; \
s|^(rpc_servers[[:space:]]+=[[:space:]]+).*$|\1\"$STATE_SYNC_RPC,$STATE_SYNC_RPC\"| ; \
s|^(trust_height[[:space:]]+=[[:space:]]+).*$|\1$BLOCK_HEIGHT| ; \
s|^(trust_hash[[:space:]]+=[[:space:]]+).*$|\1\"$TRUST_HASH\"|" $HOME/.sge/config/config.toml

mv $HOME/.sge/priv_validator_state.json.backup $HOME/.sge/data/priv_validator_state.json
sudo systemctl restart sged && sudo journalctl -u sged -f -o cat
```

### Sge CLI Cheatsheet

- Always be careful with the capitalized words
- Specify `--chain-id`

### Wallet Management

Add Wallet
Specify the value `wallet` with your own wallet name

```
sged keys add wallet
```

Recover Wallet
```
sged keys add wallet --recover
```

List Wallet
```
sged keys list
```

Delete Wallet
```
sged keys delete wallet
```

Check Wallet Balance
```
sged q bank balances $(sged keys show wallet -a)
```

### Validator Management

Please adjust `wallet` , `MONIKER` , `YOUR_KEYBASE_ID` , `YOUR_DETAILS` , `YOUUR_WEBSITE_URL`

Create Validator
```
sged tx staking create-validator \
  --chain-id sgenet-1 \
  --pubkey="$(sged tendermint show-validator)" \
  --moniker="YOUR_MONIKER" \
  --amount 1000000usge \
  --identity "YOUR_KEYBASE_ID" \
  --website "YOUR_WEBSITE_URL" \
  --details "YOUR_DETAILS" \
  --from wallet \
  --commission-rate=0.05 \
  --commission-max-rate=0.20 \
  --commission-max-change-rate=0.01 \
  --min-self-delegation 1 \
  --gas auto \
  --fees=2000usge \
  -y
```

Edit Validator
```
sged tx staking edit-validator \
--new-moniker "YOUR_MONIKER " \
--identity "YOUR_KEYBASE_ID" \
--website "YOUR_WEBSITE_URL" \
--details "YOUR_DETAILS" \
--chain-id sgenet-1 \
--commission-rate=0.01 \
--min-self-delegation=1 \
--from=wallet \
--gas auto \
-y
```


Unjail Validator
```
sged tx slashing unjail --from wallet --chain-id sgenet-1 --gas auto -y
```

Check Jailed Reason
```
sged query slashing signing-info $(sged tendermint show-validator)
```

### Token Management

Withdraw Rewards
```
sged tx distribution withdraw-all-rewards --from wallet --chain-id sgenet-1 --gas-adjustment 1.4 --gas auto --gas-prices="0usge" -y
```

Withdraw Rewards with Comission
```
sged tx distribution withdraw-rewards $(sged keys show wallet --bech val -a) --commission --from wallet --chain-id sgenet-1 --gas-adjustment 1.4 --gas auto --gas-prices="0usge" -y
```

Delegate Token to your own validator
```
sged tx staking delegate $(sged keys show wallet --bech val -a) 100000000usge --from wallet --chain-id sgenet-1 --gas-adjustment 1.4 --gas auto --gas-prices="0usge" -y
```

Delegate Token to other validator
```
sged tx staking redelegate $(sged keys show wallet --bech val -a) <TO_VALOPER_ADDRESS> 100000000usge --from wallet --chain-id sgenet-1 --gas-adjustment 1.4 --gas auto --gas-prices="0usge" -y
```

Unbond Token from your validator
```
sged tx staking unbond $(sged keys show wallet --bech val -a) 100000000usge --from wallet --chain-id sgenet-1 --gas-adjustment 1.4 --gas auto --gas-prices="0usge" -y
```

Send Token to another wallet
```
sged tx bank send wallet <TO_WALLET_ADDRESS> 100000000usge --from wallet --chain-id sgenet-1
```

### Governance 

Vote
You can change the value of `yes` to `no`,`abstain`,`nowithveto`

```
sged tx gov vote 1 yes --from wallet --chain-id sgenet-1 --gas-adjustment 1.4 --gas auto --gas-prices="0usge" -y
```

### Other

Set Your own Custom Ports
You can change value `CUSTOM_PORT=114` To any other ports
```
CUSTOM_PORT=108
sed -i -e "s%^proxy_app = \"tcp://127.0.0.1:26658\"%proxy_app = \"tcp://127.0.0.1:${CUSTOM_PORT}658\"%; s%^laddr = \"tcp://127.0.0.1:26657\"%laddr = \"tcp://127.0.0.1:${CUSTOM_PORT}57\"%; s%^pprof_laddr = \"localhost:6060\"%pprof_laddr = \"localhost:${CUSTOM_PORT}60\"%; s%^laddr = \"tcp://0.0.0.0:26656\"%laddr = \"tcp://0.0.0.0:${CUSTOM_PORT}656\"%; s%^prometheus_listen_addr = \":26660\"%prometheus_listen_addr = \":${CUSTOM_PORT}60\"%" $HOME/.sge/config/config.toml
sed -i -e "s%^address = \"tcp://0.0.0.0:1317\"%address = \"tcp://0.0.0.0:${CUSTOM_PORT}17\"%; s%^address = \":8080\"%address = \":${CUSTOM_PORT}80\"%; s%^address = \"0.0.0.0:9090\"%address = \"0.0.0.0:${CUSTOM_PORT}90\"%; s%^address = \"0.0.0.0:9091\"%address = \"0.0.0.0:${CUSTOM_PORT}91\"%" $HOME/.sge/config/app.toml
```

Enable Indexing usually enabled by default
```
sed -i -e 's|^indexer *=.*|indexer = "kv"|' $HOME/.sge/config/config.toml
```

Disable Indexing
```
sed -i -e 's|^indexer *=.*|indexer = "null"|' $HOME/.sge/config/config.toml
```

Reset Chain Data
```
sged tendermint unsafe-reset-all --home $HOME/.sge --keep-addr-book
```

### Delete Node

WARNING! Use this command wisely 
Backup your key first it will remove sge

```
sudo systemctl stop sged && \
sudo systemctl disable sged && \
rm /etc/systemd/system/sged.service && \
sudo systemctl daemon-reload && \
cd $HOME && \
rm -rf .sge && \
rm -rf $(which sged)
```
