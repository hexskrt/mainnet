<p align="center">
  <img height="100" height="auto" src="https://github.com/hexskrt/logos/blob/main/mun.png?raw=true">
</p>

# Mun Blockchain | Chain ID : mun-1

### Custom Explorer:
>-  https://explorer.hexnodes.co/mun

### Public Endpoint

>- API : https://lcd.mun.hexnodes.co
>- RPC : https://rpc.mun.hexnodes.co
>- gRPC : https://grpc.mun.hexnodes.co

### Auto Installation

```
wget -O mun.sh https://raw.githubusercontent.com/hexskrt/mainnet/main/Mun/mun.sh && chmod +x mun.sh && ./mun.sh
```

### Genesis
```
wget -O https://snapshot.hexnodes.co/.mun/genesis.json $HOME/.mun/config/genesis.json
```

### Addrbook
```
wget -O https://snapshot.hexnodes.co/.mun/addrbook.json $HOME/.mun/config/addrbook.json
```

### Snapshot

```
sudo systemctl stop mund
cp $HOME/.mun/data/priv_validator_state.json $HOME/.mun/priv_validator_state.json.backup
rm -rf $HOME/.mun/data
curl -o - -L http://snapshot.hexnodes.co/mun/mun.latest.tar.lz4 | lz4 -c -d - | tar -x -C $HOME/.mun
mv $HOME/.mun/priv_validator_state.json.backup $HOME/.mun/data/priv_validator_state.json
sudo systemctl restart mund && journalctl -u mund -f -o cat
```


### State Sync

```
sudo systemctl stop mund
cp $HOME/.mun/data/priv_validator_state.json $HOME/.mun/priv_validator_state.json.backup
mund tendermint unsafe-reset-all --home $HOME/.mun

STATE_SYNC_RPC=https://rpc.mun.hexnodes.co:443
LATEST_HEIGHT=$(curl -s $STATE_SYNC_RPC/block | jq -r .result.block.header.height)
SYNC_BLOCK_HEIGHT=$(($LATEST_HEIGHT - 2000))
SYNC_BLOCK_HASH=$(curl -s "$STATE_SYNC_RPC/block?height=$SYNC_BLOCK_HEIGHT" | jq -r .result.block_id.hash)

sed -i.bak -E "s|^(enable[[:space:]]+=[[:space:]]+).*$|\1true| ; \
s|^(rpc_servers[[:space:]]+=[[:space:]]+).*$|\1\"$STATE_SYNC_RPC,$STATE_SYNC_RPC\"| ; \
s|^(trust_height[[:space:]]+=[[:space:]]+).*$|\1$BLOCK_HEIGHT| ; \
s|^(trust_hash[[:space:]]+=[[:space:]]+).*$|\1\"$TRUST_HASH\"|" $HOME/.mun/config/config.toml

mv $HOME/.mun/priv_validator_state.json.backup $HOME/.mun/data/priv_validator_state.json
sudo systemctl restart mund && sudo journalctl -u mund -f -o cat
```

### Mun CLI Cheatsheet

- Always be careful with the capitalized words
- Specify `--chain-id`

### Wallet Management

Add Wallet
Specify the value `wallet` with your own wallet name

```
mund keys add wallet
```

Recover Wallet
```
mund keys add wallet --recover
```

List Wallet
```
mund keys list
```

Delete Wallet
```
mund keys delete wallet
```

Check Wallet Balance
```
mund q bank balances $(mund keys show wallet -a)
```

### Validator Management

Please adjust `wallet` , `MONIKER` , `YOUR_KEYBASE_ID` , `YOUR_DETAILS` , `YOUUR_WEBSITE_URL`

Create Validator
```
mund tx staking create-validator \
  --chain-id mun-1 \
  --pubkey="$(mund tendermint show-validator)" \
  --moniker="YOUR_MONIKER" \
  --amount 1000000umun \
  --identity "YOUR_KEYBASE_ID" \
  --website "YOUR_WEBSITE_URL" \
  --details "YOUR_DETAILS" \
  --from wallet \
  --commission-rate=0.05 \
  --commission-max-rate=0.20 \
  --commission-max-change-rate=0.01 \
  --min-self-delegation 1 \
  --gas auto \
  --fees=200umun \
  -y
```

Edit Validator
```
mund tx staking edit-validator \
--new-moniker "YOUR_MONIKER " \
--identity "YOUR_KEYBASE_ID" \
--website "YOUR_WEBSITE_URL" \
--details "YOUR_DETAILS" \
--chain-id mun-1 \
--commission-rate=0.01 \
--min-self-delegation=1 \
--from=wallet \
--gas auto \
-y
```


Unjail Validator
```
mund tx slashing unjail --from wallet --chain-id mun-1 --gas auto -y
```

Check Jailed Reason
```
mund query slashing signing-info $(mund tendermint show-validator)
```

### Token Management

Withdraw Rewards
```
mund tx distribution withdraw-all-rewards --from wallet --chain-id mun-1 --gas-adjustment 1.4 --gas auto --gas-prices="0.025umun" -y
```

Withdraw Rewards with Comission
```
mund tx distribution withdraw-rewards $(mund keys show wallet --bech val -a) --commission --from wallet --chain-id mun-1 --gas-adjustment 1.4 --gas auto --gas-prices="0.025umun" -y
```

Delegate Token to your own validator
```
mund tx staking delegate $(mund keys show wallet --bech val -a) 100000000umun --from wallet --chain-id mun-1 --gas-adjustment 1.4 --gas auto --gas-prices="0.025umun" -y
```

Delegate Token to other validator
```
mund tx staking redelegate $(mund keys show wallet --bech val -a) <TO_VALOPER_ADDRESS> 100000000umun --from wallet --chain-id mun-1 --gas-adjustment 1.4 --gas auto --gas-prices="0.025umun" -y
```

Unbond Token from your validator
```
mund tx staking unbond $(mund keys show wallet --bech val -a) 100000000umun --from wallet --chain-id mun-1 --gas-adjustment 1.4 --gas auto --gas-prices="0.025umun" -y
```

Send Token to another wallet
```
mund tx bank send wallet <TO_WALLET_ADDRESS> 100000000umun --from wallet --chain-id mun-1
```

### Governance 

Vote
You can change the value of `yes` to `no`,`abstain`,`nowithveto`

```
mund tx gov vote 1 yes --from wallet --chain-id mun-1 --gas-adjustment 1.4 --gas auto --gas-prices="0.025umun" -y
```

### Other

Set Your own Custom Ports
You can change value `CUSTOM_PORT=111` To any other ports
```
CUSTOM_PORT=107
sed -i -e "s%^proxy_app = \"tcp://127.0.0.1:26658\"%proxy_app = \"tcp://127.0.0.1:${CUSTOM_PORT}658\"%; s%^laddr = \"tcp://127.0.0.1:26657\"%laddr = \"tcp://127.0.0.1:${CUSTOM_PORT}57\"%; s%^pprof_laddr = \"localhost:6060\"%pprof_laddr = \"localhost:${CUSTOM_PORT}60\"%; s%^laddr = \"tcp://0.0.0.0:26656\"%laddr = \"tcp://0.0.0.0:${CUSTOM_PORT}656\"%; s%^prometheus_listen_addr = \":26660\"%prometheus_listen_addr = \":${CUSTOM_PORT}60\"%" $HOME/.mun/config/config.toml
sed -i -e "s%^address = \"tcp://0.0.0.0:1317\"%address = \"tcp://0.0.0.0:${CUSTOM_PORT}17\"%; s%^address = \":8080\"%address = \":${CUSTOM_PORT}80\"%; s%^address = \"0.0.0.0:9090\"%address = \"0.0.0.0:${CUSTOM_PORT}90\"%; s%^address = \"0.0.0.0:9091\"%address = \"0.0.0.0:${CUSTOM_PORT}91\"%" $HOME/.mun/config/app.toml
```

Enable Indexing usually enabled by default
```
sed -i -e 's|^indexer *=.*|indexer = "kv"|' $HOME/.mun/config/config.toml
```

Disable Indexing
```
sed -i -e 's|^indexer *=.*|indexer = "null"|' $HOME/.mun/config/config.toml
```

Reset Chain Data
```
mund tendermint unsafe-reset-all --home $HOME/.mun --keep-addr-book
```

### Delete Node

WARNING! Use this command wisely 
Backup your key first it will remove mun

```
sudo systemctl stop mund && \
sudo systemctl disable mund && \
rm /etc/systemd/system/mund.service && \
sudo systemctl daemon-reload && \
cd $HOME && \
rm -rf .mun && \
rm -rf $(which mund)
```
