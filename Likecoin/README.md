<p align="center">
  <img height="100" height="auto" src="https://github.com/hexskrt/logos/blob/main/likecoin.png?raw=true">
</p>

# Likecoin Mainnet | Chain ID : likecoin-mainnet-2

### Custom Explorer:
>-  https://explorer.hexnodes.co/likecoin

### Public Endpoint

>- API : https://lcd.likecoin.hexnodes.co
>- RPC : https://rpc.likecoin.hexnodes.co
>- gRPC : https://grpc.likecoinx.hexnodes.co

### Auto Installation

```
wget -O likecoin.sh https://raw.githubusercontent.com/hexskrt/mainnet/main/Likecoin/likecoin.sh && chmod +x likecoin.sh && ./likecoin.sh
```

### Genesis
```
wget -O https://raw.githubusercontent.com/hexskrt/mainnet/main/Likecoin/genesis.json $HOME/.liked/config/genesis.json
```

### Addrbook
```
wget -O https://raw.githubusercontent.com/hexskrt/mainnet/main/Likecoin/addrbook.json $HOME/.liked/config/addrbook.json
```

### Snapshot (Soon!)

```
sudo systemctl stop liked
cp $HOME/.liked/data/priv_validator_state.json $HOME/.liked/priv_validator_state.json.backup
rm -rf $HOME/.liked/data
curl -o - -L http://snapshot.hexnodes.co/likecoin/likecoin.latest.tar.lz4 | lz4 -c -d - | tar -x -C $HOME/.liked
mv $HOME/.liked/priv_validator_state.json.backup $HOME/.liked/data/priv_validator_state.json
sudo systemctl restart liked && journalctl -u liked -f -o cat
```


### State Sync

```
sudo systemctl stop liked
cp $HOME/.liked/data/priv_validator_state.json $HOME/.liked/priv_validator_state.json.backup
liked tendermint unsafe-reset-all --home $HOME/.liked

STATE_SYNC_RPC=https://rpc.likecoin.hexnodes.co:443
LATEST_HEIGHT=$(curl -s $STATE_SYNC_RPC/block | jq -r .result.block.header.height)
SYNC_BLOCK_HEIGHT=$(($LATEST_HEIGHT - 2000))
SYNC_BLOCK_HASH=$(curl -s "$STATE_SYNC_RPC/block?height=$SYNC_BLOCK_HEIGHT" | jq -r .result.block_id.hash)

sed -i.bak -E "s|^(enable[[:space:]]+=[[:space:]]+).*$|\1true| ; \
s|^(rpc_servers[[:space:]]+=[[:space:]]+).*$|\1\"$STATE_SYNC_RPC,$STATE_SYNC_RPC\"| ; \
s|^(trust_height[[:space:]]+=[[:space:]]+).*$|\1$BLOCK_HEIGHT| ; \
s|^(trust_hash[[:space:]]+=[[:space:]]+).*$|\1\"$TRUST_HASH\"|" $HOME/.liked/config/config.toml

mv $HOME/.liked/priv_validator_state.json.backup $HOME/.liked/data/priv_validator_state.json
sudo systemctl restart liked && sudo journalctl -u liked -f -o cat
```

### Likecoin CLI Cheatsheet

- Always be careful with the capitalized words
- Specify `--chain-id`

### Wallet Management

Add Wallet
Specify the value `wallet` with your own wallet name

```
liked keys add wallet
```

Recover Wallet
```
liked keys add wallet --recover
```

List Wallet
```
liked keys list
```

Delete Wallet
```
liked keys delete wallet
```

Check Wallet Balance
```
liked q bank balances $(liked keys show wallet -a)
```

### Validator Management

Please adjust `wallet` , `MONIKER` , `YOUR_KEYBASE_ID` , `YOUR_DETAILS` , `YOUUR_WEBSITE_URL`

Create Validator
```
liked tx staking create-validator \
  --chain-id likecoin-mainnet-2 \
  --pubkey="$(liked tendermint show-validator)" \
  --moniker="YOUR_MONIKER" \
  --amount 1000000nanolike \
  --identity "YOUR_KEYBASE_ID" \
  --website "YOUR_WEBSITE_URL" \
  --details "YOUR_DETAILS" \
  --from wallet \
  --commission-rate=0.05 \
  --commission-max-rate=0.20 \
  --commission-max-change-rate=0.01 \
  --min-self-delegation 1 \
  --gas auto \
  --fees=2000nanolike \
  -y
```

Edit Validator
```
liked tx staking edit-validator \
--new-moniker "YOUR_MONIKER " \
--identity "YOUR_KEYBASE_ID" \
--website "YOUR_WEBSITE_URL" \
--details "YOUR_DETAILS" \
--chain-id likecoin-mainnet-2 \
--commission-rate=0.01 \
--min-self-delegation=1 \
--from=wallet \
--gas auto \
-y
```


Unjail Validator
```
liked tx slashing unjail --from wallet --chain-id likecoin-mainnet-2 --gas auto -y
```

Check Jailed Reason
```
liked query slashing signing-info $(liked tendermint show-validator)
```

### Token Management

Withdraw Rewards
```
liked tx distribution withdraw-all-rewards --from wallet --chain-id likecoin-mainnet-2 --gas-adjustment 1.4 --gas auto --gas-prices="1nanolike" -y
```

Withdraw Rewards with Comission
```
liked tx distribution withdraw-rewards $(liked keys show wallet --bech val -a) --commission --from wallet --chain-id likecoin-mainnet-2 --gas-adjustment 1.4 --gas auto --gas-prices="1nanolike" -y
```

Delegate Token to your own validator
```
liked tx staking delegate $(liked keys show wallet --bech val -a) 100000000nanolike --from wallet --chain-id likecoin-mainnet-2 --gas-adjustment 1.4 --gas auto --gas-prices="1nanolike" -y
```

Delegate Token to other validator
```
liked tx staking redelegate $(liked keys show wallet --bech val -a) <TO_VALOPER_ADDRESS> 100000000nanolike --from wallet --chain-id likecoin-mainnet-2 --gas-adjustment 1.4 --gas auto --gas-prices="1nanolike" -y
```

Unbond Token from your validator
```
liked tx staking unbond $(liked keys show wallet --bech val -a) 100000000nanolike --from wallet --chain-id likecoin-mainnet-2 --gas-adjustment 1.4 --gas auto --gas-prices="1nanolike" -y
```

Send Token to another wallet
```
liked tx bank send wallet <TO_WALLET_ADDRESS> 100000000nanolike --from wallet --chain-id likecoin-mainnet-2
```

### Governance 

Vote
You can change the value of `yes` to `no`,`abstain`,`nowithveto`

```
liked tx gov vote 1 yes --from wallet --chain-id likecoin-mainnet-2 --gas-adjustment 1.4 --gas auto --gas-prices="1nanolike" -y
```

### Other

Set Your own Custom Ports
You can change value `CUSTOM_PORT=108` To any other ports
```
CUSTOM_PORT=108
sed -i -e "s%^proxy_app = \"tcp://127.0.0.1:26658\"%proxy_app = \"tcp://127.0.0.1:${CUSTOM_PORT}658\"%; s%^laddr = \"tcp://127.0.0.1:26657\"%laddr = \"tcp://127.0.0.1:${CUSTOM_PORT}57\"%; s%^pprof_laddr = \"localhost:6060\"%pprof_laddr = \"localhost:${CUSTOM_PORT}60\"%; s%^laddr = \"tcp://0.0.0.0:26656\"%laddr = \"tcp://0.0.0.0:${CUSTOM_PORT}656\"%; s%^prometheus_listen_addr = \":26660\"%prometheus_listen_addr = \":${CUSTOM_PORT}60\"%" $HOME/.liked/config/config.toml
sed -i -e "s%^address = \"tcp://0.0.0.0:1317\"%address = \"tcp://0.0.0.0:${CUSTOM_PORT}17\"%; s%^address = \":8080\"%address = \":${CUSTOM_PORT}80\"%; s%^address = \"0.0.0.0:9090\"%address = \"0.0.0.0:${CUSTOM_PORT}90\"%; s%^address = \"0.0.0.0:9091\"%address = \"0.0.0.0:${CUSTOM_PORT}91\"%" $HOME/.liked/config/app.toml
```

Enable Indexing usually enabled by default
```
sed -i -e 's|^indexer *=.*|indexer = "kv"|' $HOME/.liked/config/config.toml
```

Disable Indexing
```
sed -i -e 's|^indexer *=.*|indexer = "null"|' $HOME/.liked/config/config.toml
```

Reset Chain Data
```
liked unsafe-reset-all --home $HOME/.liked
```

### Delete Node

WARNING! Use this command wisely 
Backup your key first it will remove likecoin

```
sudo systemctl stop liked && \
sudo systemctl disable liked && \
rm /etc/systemd/system/liked.service && \
sudo systemctl daemon-reload && \
cd $HOME && \
rm -rf .liked && \
rm -rf $(which liked)
```
