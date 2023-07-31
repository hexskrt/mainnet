<p align="center">
  <img height="100" height="auto" src="https://github.com/hexskrt/logos/blob/main/meme.png?raw=true">
</p>

# Meme Network Mainnet | Chain ID : meme-1

### Custom Explorer:
>-  https://explorer.hexnodes.co/meme

### Public Endpoint

>- API : https://lcd.meme.hexnodes.co
>- RPC : https://rpc.meme.hexnodes.co
>- gRPC : https://grpc.memex.hexnodes.co

### Auto Installation

```
wget -O meme.sh https://raw.githubusercontent.com/hexskrt/mainnet/main/Meme/meme.sh && chmod +x meme.sh && ./meme.sh
```

### Genesis
```
wget -O https://snapshot.hexnodes.co/meme/genesis.json $HOME/.memed/config/genesis.json
```

### Addrbook
```
wget -O https://snapshot.hexnodes.co/meme/addrbook.json $HOME/.memed/config/addrbook.json
```

### Snapshot

```
sudo systemctl stop memed
cp $HOME/.memed/data/priv_validator_state.json $HOME/.memed/priv_validator_state.json.backup
rm -rf $HOME/.memed/data
curl -o - -L http://snapshot.hexnodes.co/meme/meme.latest.tar.lz4 | lz4 -c -d - | tar -x -C $HOME/.memed
mv $HOME/.memed/priv_validator_state.json.backup $HOME/.memed/data/priv_validator_state.json
sudo systemctl restart memed && journalctl -u memed -f -o cat
```


### State Sync

```
sudo systemctl stop memed
cp $HOME/.memed/data/priv_validator_state.json $HOME/.memed/priv_validator_state.json.backup
memed tendermint unsafe-reset-all --home $HOME/.memed

STATE_SYNC_RPC=https://rpc.meme.hexnodes.co:443
LATEST_HEIGHT=$(curl -s $STATE_SYNC_RPC/block | jq -r .result.block.header.height)
SYNC_BLOCK_HEIGHT=$(($LATEST_HEIGHT - 2000))
SYNC_BLOCK_HASH=$(curl -s "$STATE_SYNC_RPC/block?height=$SYNC_BLOCK_HEIGHT" | jq -r .result.block_id.hash)

sed -i.bak -E "s|^(enable[[:space:]]+=[[:space:]]+).*$|\1true| ; \
s|^(rpc_servers[[:space:]]+=[[:space:]]+).*$|\1\"$STATE_SYNC_RPC,$STATE_SYNC_RPC\"| ; \
s|^(trust_height[[:space:]]+=[[:space:]]+).*$|\1$BLOCK_HEIGHT| ; \
s|^(trust_hash[[:space:]]+=[[:space:]]+).*$|\1\"$TRUST_HASH\"|" $HOME/.memed/config/config.toml

mv $HOME/.memed/priv_validator_state.json.backup $HOME/.memed/data/priv_validator_state.json
sudo systemctl restart memed && sudo journalctl -u memed -f -o cat
```

### Meme Network CLI Cheatsheet

- Always be careful with the capitalized words
- Specify `--chain-id`

### Wallet Management

Add Wallet
Specify the value `wallet` with your own wallet name

```
memed keys add wallet
```

Recover Wallet
```
memed keys add wallet --recover
```

List Wallet
```
memed keys list
```

Delete Wallet
```
memed keys delete wallet
```

Check Wallet Balance
```
memed q bank balances $(memed keys show wallet -a)
```

### Validator Management

Please adjust `wallet` , `MONIKER` , `YOUR_KEYBASE_ID` , `YOUR_DETAILS` , `YOUUR_WEBSITE_URL`

Create Validator
```
memed tx staking create-validator \
  --chain-id meme-1 \
  --pubkey="$(memed tendermint show-validator)" \
  --moniker="YOUR_MONIKER" \
  --amount 1000000umeme \
  --identity "YOUR_KEYBASE_ID" \
  --website "YOUR_WEBSITE_URL" \
  --details "YOUR_DETAILS" \
  --from wallet \
  --commission-rate=0.05 \
  --commission-max-rate=0.20 \
  --commission-max-change-rate=0.01 \
  --min-self-delegation 1 \
  --gas auto \
  --fees=2000umeme \
  -y
```

Edit Validator
```
memed tx staking edit-validator \
--new-moniker "YOUR_MONIKER " \
--identity "YOUR_KEYBASE_ID" \
--website "YOUR_WEBSITE_URL" \
--details "YOUR_DETAILS" \
--chain-id meme-1 \
--commission-rate=0.01 \
--min-self-delegation=1 \
--from=wallet \
--gas auto \
-y
```


Unjail Validator
```
memed tx slashing unjail --from wallet --chain-id meme-1 --gas auto -y
```

Check Jailed Reason
```
memed query slashing signing-info $(memed tendermint show-validator)
```

### Token Management

Withdraw Rewards
```
memed tx distribution withdraw-all-rewards --from wallet --chain-id meme-1 --gas-adjustment 1.4 --gas auto --gas-prices="0.025umeme" -y
```

Withdraw Rewards with Comission
```
memed tx distribution withdraw-rewards $(memed keys show wallet --bech val -a) --commission --from wallet --chain-id meme-1 --gas-adjustment 1.4 --gas auto --gas-prices="0.025umeme" -y
```

Delegate Token to your own validator
```
memed tx staking delegate $(memed keys show wallet --bech val -a) 100000000umeme --from wallet --chain-id meme-1 --gas-adjustment 1.4 --gas auto --gas-prices="0.025umeme" -y
```

Delegate Token to other validator
```
memed tx staking redelegate $(memed keys show wallet --bech val -a) <TO_VALOPER_ADDRESS> 100000000umeme --from wallet --chain-id meme-1 --gas-adjustment 1.4 --gas auto --gas-prices="0.025umeme" -y
```

Unbond Token from your validator
```
memed tx staking unbond $(memed keys show wallet --bech val -a) 100000000umeme --from wallet --chain-id meme-1 --gas-adjustment 1.4 --gas auto --gas-prices="0.025umeme" -y
```

Send Token to another wallet
```
memed tx bank send wallet <TO_WALLET_ADDRESS> 100000000umeme --from wallet --chain-id meme-1
```

### Governance 

Vote
You can change the value of `yes` to `no`,`abstain`,`nowithveto`

```
memed tx gov vote 1 yes --from wallet --chain-id meme-1 --gas-adjustment 1.4 --gas auto --gas-prices="0.025umeme" -y
```

### Other

Set Your own Custom Ports
You can change value `CUSTOM_PORT=110` To any other ports
```
CUSTOM_PORT=108
sed -i -e "s%^proxy_app = \"tcp://127.0.0.1:26658\"%proxy_app = \"tcp://127.0.0.1:${CUSTOM_PORT}658\"%; s%^laddr = \"tcp://127.0.0.1:26657\"%laddr = \"tcp://127.0.0.1:${CUSTOM_PORT}57\"%; s%^pprof_laddr = \"localhost:6060\"%pprof_laddr = \"localhost:${CUSTOM_PORT}60\"%; s%^laddr = \"tcp://0.0.0.0:26656\"%laddr = \"tcp://0.0.0.0:${CUSTOM_PORT}656\"%; s%^prometheus_listen_addr = \":26660\"%prometheus_listen_addr = \":${CUSTOM_PORT}60\"%" $HOME/.memed/config/config.toml
sed -i -e "s%^address = \"tcp://0.0.0.0:1317\"%address = \"tcp://0.0.0.0:${CUSTOM_PORT}17\"%; s%^address = \":8080\"%address = \":${CUSTOM_PORT}80\"%; s%^address = \"0.0.0.0:9090\"%address = \"0.0.0.0:${CUSTOM_PORT}90\"%; s%^address = \"0.0.0.0:9091\"%address = \"0.0.0.0:${CUSTOM_PORT}91\"%" $HOME/.memed/config/app.toml
```

Enable Indexing usually enabled by default
```
sed -i -e 's|^indexer *=.*|indexer = "kv"|' $HOME/.memed/config/config.toml
```

Disable Indexing
```
sed -i -e 's|^indexer *=.*|indexer = "null"|' $HOME/.memed/config/config.toml
```

Reset Chain Data
```
memed unsafe-reset-all --home $HOME/.memed
```

### Delete Node

WARNING! Use this command wisely 
Backup your key first it will remove meme network

```
sudo systemctl stop memed && \
sudo systemctl disable memed && \
rm /etc/systemd/system/memed.service && \
sudo systemctl daemon-reload && \
cd $HOME && \
rm -rf .memed && \
rm -rf $(which memed)
```
