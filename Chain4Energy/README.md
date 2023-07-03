<p align="center">
  <img height="100" height="auto" src="https://github.com/hexskrt/logos/blob/main/c4e.jpg?raw=true">
</p>

# Chain4Energy Mainnet | Chain ID : perun-1

### Official Documentation:
>- [Chain4Energy](https://docs.c4e.io/validatorsGuide/mainnet/system-preparation.html)

### Custom Explorer:
>-  https://explorer.hexnodes.co/CHAIN4ENERGY

### Public Endpoint

>- API : https://lcd.chain4energy.hexnodes.co
>- RPC : https://rpc.chain4energy.hexnodes.co
>- gRPC : https://grpc.chain4energy.hexnodes.co

### Auto Installation
```
wget -O c4e.sh https://raw.githubusercontent.com/hexskrt/mainnet/main/Chain4Energy/c4e.sh && chmod +x c4e.sh && ./c4e.sh
```

### Snapshot updated every 5 hours

```
sudo systemctl stop c4ed
cp $HOME/.c4e-chain/data/priv_validator_state.json $HOME/.c4e-chain/priv_validator_state.json.backup
rm -rf $HOME/.c4e-chain/data
curl -o - -L http://snap.hexnodes.co/c4e/c4e.latest.tar.lz4 | lz4 -c -d - | tar -x -C $HOME/.c4e-chain
mv $HOME/.c4e-chain/priv_validator_state.json.backup $HOME/.c4e-chain/data/priv_validator_state.json
sudo systemctl restart c4ed && journalctl -u c4ed -f -o cat
```


### State Sync

```
sudo systemctl stop c4ed
cp $HOME/.c4e-chain/data/priv_validator_state.json $HOME/.c4e-chain/priv_validator_state.json.backup
c4ed tendermint unsafe-reset-all --home $HOME/.c4e-chain

STATE_SYNC_RPC=https://rpc.c4e.hexnodes.co:27656
STATE_SYNC_PEER=a2012f7a7f735cdb80b1536b012f708002fe74de@rpc.c4e.hexnodes.co:27656
LATEST_HEIGHT=$(curl -s $STATE_SYNC_RPC/block | jq -r .result.block.header.height)
SYNC_BLOCK_HEIGHT=$(($LATEST_HEIGHT - 2000))
SYNC_BLOCK_HASH=$(curl -s "$STATE_SYNC_RPC/block?height=$SYNC_BLOCK_HEIGHT" | jq -r .result.block_id.hash)

sed -i.bak -E "s|^(enable[[:space:]]+=[[:space:]]+).*$|\1true| ; \
s|^(rpc_servers[[:space:]]+=[[:space:]]+).*$|\1\"$SNAP_RPC,$SNAP_RPC\"| ; \
s|^(trust_height[[:space:]]+=[[:space:]]+).*$|\1$BLOCK_HEIGHT| ; \
s|^(trust_hash[[:space:]]+=[[:space:]]+).*$|\1\"$TRUST_HASH\"|" $HOME/.c4e-chain/config/config.toml

mv $HOME/.c4e-chain/priv_validator_state.json.backup $HOME/.c4e-chain/data/priv_validator_state.json
sudo systemctl restart c4e-chaind && sudo journalctl -u c4e-chaind -f -o cat
```

### C4E CLI Cheatsheet

- Always be careful with the capitalized words
- Specify `--chain-id`

### Wallet Management

Add Wallet
Specify the value `wallet` with your own wallet name

```
c4ed keys add wallet
```

Recover Wallet
```
c4ed keys add wallet --recover
```

List Wallet
```
c4ed keys list
```

Delete Wallet
```
c4ed keys delete wallet
```

Check Wallet Balance
```
c4ed q bank balances $(c4ed keys show wallet -a)
```

### Validator Management

Please adjust `wallet` , `MONIKER` , `YOUR_KEYBASE_ID` , `YOUR_DETAILS` , `YOUUR_WEBSITE_URL`

Create Validator
```
c4ed tx staking create-validator \
  --chain-id perun-1 \
  --pubkey="$(c4ed tendermint show-validator)" \
  --moniker="YOUR_MONIKER" \
  --amount 1000000uc4e \
  --identity "YOUR_KEYBASE_ID" \
  --website "YOUR_WEBSITE_URL" \
  --details "YOUR_DETAILS" \
  --from wallet \
  --commission-rate=0.05 \
  --commission-max-rate=0.20 \
  --commission-max-change-rate=0.01 \
  --min-self-delegation 1 \
  --gas auto \
  --fees=2000uc4e \
  -y
```

Edit Validator
```
c4ed tx staking edit-validator \
--new-moniker "YOUR_MONIKER " \
--identity "YOUR_KEYBASE_ID" \
--website "YOUR_WEBSITE_URL" \
--details "YOUR_DETAILS" \
--chain-id perun-1 \
--commission-rate=0.01 \
--min-self-delegation=1 \
--from=wallet \
--gas auto \
-y
```


Unjail Validator
```
c4ed tx slashing unjail --from wallet --chain-id perun-1 --gas auto -y
```

Check Jailed Reason
```
c4ed query slashing signing-info $(c4ed tendermint show-validator)
```

### Token Management

Withdraw Rewards
```
c4ed tx distribution withdraw-all-rewards --from wallet --chain-id perun-1 --gas-adjustment 1.4 --gas auto --gas-prices="0.025uc4e" -y
```

Withdraw Rewards with Comission
```
c4ed tx distribution withdraw-rewards $(c4ed keys show wallet --bech val -a) --commission --from wallet --chain-id perun-1 --gas-adjustment 1.4 --gas auto --gas-prices="0.025uc4e" -y
```

Delegate Token to your own validator
```
c4ed tx staking delegate $(c4ed keys show wallet --bech val -a) 100000000uc4e --from wallet --chain-id perun-1 --gas-adjustment 1.4 --gas auto --gas-prices="0.025uc4e" -y
```

Delegate Token to other validator
```
c4ed tx staking redelegate $(c4ed keys show wallet --bech val -a) <TO_VALOPER_ADDRESS> 100000000uc4e --from wallet --chain-id perun-1 --gas-adjustment 1.4 --gas auto --gas-prices="0.025uc4e" -y
```

Unbond Token from your validator
```
c4ed tx staking unbond $(c4ed keys show wallet --bech val -a) 100000000uc4e --from wallet --chain-id perun-1 --gas-adjustment 1.4 --gas auto --gas-prices="0.025uc4e" -y
```

Send Token to another wallet
```
c4ed tx bank send wallet <TO_WALLET_ADDRESS> 100000000uc4e --from wallet --chain-id perun-1
```

### Governance 

Vote
You can change the value of `yes` to `no`,`abstain`,`nowithveto`

```
c4ed tx gov vote 1 yes --from wallet --chain-id perun-1 --gas-adjustment 1.4 --gas auto --gas-prices="0.025uc4e" -y
```

### Other

Set Your own Custom Ports
You can change value `CUSTOM_PORT=101` To any other ports
```
CUSTOM_PORT=101
sed -i -e "s%^proxy_app = \"tcp://127.0.0.1:26658\"%proxy_app = \"tcp://127.0.0.1:${CUSTOM_PORT}58\"%; s%^laddr = \"tcp://127.0.0.1:26657\"%laddr = \"tcp://127.0.0.1:${CUSTOM_PORT}57\"%; s%^pprof_laddr = \"localhost:6060\"%pprof_laddr = \"localhost:${CUSTOM_PORT}60\"%; s%^laddr = \"tcp://0.0.0.0:26656\"%laddr = \"tcp://0.0.0.0:${CUSTOM_PORT}56\"%; s%^prometheus_listen_addr = \":26660\"%prometheus_listen_addr = \":${CUSTOM_PORT}60\"%" $HOME/.c4e-chain/config/config.toml
sed -i -e "s%^address = \"tcp://0.0.0.0:1317\"%address = \"tcp://0.0.0.0:${CUSTOM_PORT}317\"%; s%^address = \":8080\"%address = \":${CUSTOM_PORT}80\"%; s%^address = \"0.0.0.0:9090\"%address = \"0.0.0.0:${CUSTOM_PORT}90\"%; s%^address = \"0.0.0.0:9091\"%address = \"0.0.0.0:${CUSTOM_PORT}91\"%" $HOME/.c4e-chain/config/app.toml
```

Enable Indexing usually enabled by default
```
sed -i -e 's|^indexer *=.*|indexer = "kv"|' $HOME/.c4e-chain/config/config.toml
```

Disable Indexing
```
sed -i -e 's|^indexer *=.*|indexer = "null"|' $HOME/.c4e-chain/config/config.toml
```

Reset Chain Data
```
c4ed tendermint unsafe-reset-all --home $HOME/.c4e-chain --keep-addr-book
```

### Delete Node

WARNING! Use this command wisely 
Backup your key first it will remove c4e

```
sudo systemctl stop c4ed && \
sudo systemctl disable c4ed && \
rm /etc/systemd/system/c4ed.service && \
sudo systemctl daemon-reload && \
cd $HOME && \
rm -rf .c4e-chain && \
rm -rf $(which c4ed)
```
