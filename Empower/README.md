<p align="center">
  <img height="100" height="auto" src="https://github.com/hexskrt/logos/blob/main/empower.jpg?raw=true">
</p>

# Empowerchain Mainnet | Chain ID : empowerchain-1

### Custom Explorer:
>-  https://explorer.hexnodes.co/EMPOWER

### Public Endpoint

>- API : https://lcd.empower.hexnodes.co
>- RPC : https://rpc.empower.hexnodes.co
>- gRPC : https://grpc.empower.hexnodes.co

### Auto Installation

```
wget -O empower.sh https://raw.githubusercontent.com/hexskrt/mainnet/main/Empower/empower.sh && chmod +x empower.sh && ./empower.sh
```

### Snapshot updated every 5 hours

```
sudo systemctl stop empowerd
cp $HOME/.empowerchain/data/priv_validator_state.json $HOME/.empowerchain/priv_validator_state.json.backup
rm -rf $HOME/.empowerchain/data
curl -o - -L http://snap.hexnodes.co/empower/empower.latest.tar.lz4 | lz4 -c -d - | tar -x -C $HOME/.empowerchain
mv $HOME/.empowerchain/priv_validator_state.json.backup $HOME/.empowerchain/data/priv_validator_state.json
sudo systemctl restart empowerd && journalctl -u empowerd -f -o cat
```


### State Sync

```
sudo systemctl stop empowerd
cp $HOME/.empowerchain/data/priv_validator_state.json $HOME/.empowerchain/priv_validator_state.json.backup
empowerd tendermint unsafe-reset-all --home $HOME/.empowerchain

STATE_SYNC_RPC=https://rpc.empowerchain.hexnodes.co:443
LATEST_HEIGHT=$(curl -s $STATE_SYNC_RPC/block | jq -r .result.block.header.height)
SYNC_BLOCK_HEIGHT=$(($LATEST_HEIGHT - 2000))
SYNC_BLOCK_HASH=$(curl -s "$STATE_SYNC_RPC/block?height=$SYNC_BLOCK_HEIGHT" | jq -r .result.block_id.hash)

sed -i.bak -E "s|^(enable[[:space:]]+=[[:space:]]+).*$|\1true| ; \
s|^(rpc_servers[[:space:]]+=[[:space:]]+).*$|\1\"$SNAP_RPC,$SNAP_RPC\"| ; \
s|^(trust_height[[:space:]]+=[[:space:]]+).*$|\1$BLOCK_HEIGHT| ; \
s|^(trust_hash[[:space:]]+=[[:space:]]+).*$|\1\"$TRUST_HASH\"|" $HOME/.empowerchain/config/config.toml

mv $HOME/.empowerchain/priv_validator_state.json.backup $HOME/.empowerchain/data/priv_validator_state.json
sudo systemctl restart empowerd && sudo journalctl -u empowerd -f -o cat
```

### Empower CLI Cheatsheet

- Always be careful with the capitalized words
- Specify `--chain-id`

### Wallet Management

Add Wallet
Specify the value `wallet` with your own wallet name

```
empowerd keys add wallet
```

Recover Wallet
```
empowerd keys add wallet --recover
```

List Wallet
```
empowerd keys list
```

Delete Wallet
```
empowerd keys delete wallet
```

Check Wallet Balance
```
empowerd q bank balances $(empowerd keys show wallet -a)
```

### Validator Management

Please adjust `wallet` , `MONIKER` , `YOUR_KEYBASE_ID` , `YOUR_DETAILS` , `YOUUR_WEBSITE_URL`

Create Validator
```
empowerd tx staking create-validator \
  --chain-id empowerchain-1 \
  --pubkey="$(empowerd tendermint show-validator)" \
  --moniker="YOUR_MONIKER" \
  --amount 1000000umpwr \
  --identity "YOUR_KEYBASE_ID" \
  --website "YOUR_WEBSITE_URL" \
  --details "YOUR_DETAILS" \
  --from wallet \
  --commission-rate=0.05 \
  --commission-max-rate=0.20 \
  --commission-max-change-rate=0.01 \
  --min-self-delegation 1 \
  --gas auto \
  --fees=2000umpwr \
  -y
```

Edit Validator
```
empowerd tx staking edit-validator \
--new-moniker "YOUR_MONIKER " \
--identity "YOUR_KEYBASE_ID" \
--website "YOUR_WEBSITE_URL" \
--details "YOUR_DETAILS" \
--chain-id empowerchain-1 \
--commission-rate=0.01 \
--min-self-delegation=1 \
--from=wallet \
--gas auto \
-y
```


Unjail Validator
```
empowerd tx slashing unjail --from wallet --chain-id empowerchain-1 --gas auto -y
```

Check Jailed Reason
```
empowerd query slashing signing-info $(empowerd tendermint show-validator)
```

### Token Management

Withdraw Rewards
```
empowerd tx distribution withdraw-all-rewards --from wallet --chain-id empowerchain-1 --gas-adjustment 1.4 --gas auto --gas-prices="0.025umpwr" -y
```

Withdraw Rewards with Comission
```
empowerd tx distribution withdraw-rewards $(empowerd keys show wallet --bech val -a) --commission --from wallet --chain-id empowerchain-1 --gas-adjustment 1.4 --gas auto --gas-prices="0.025umpwr" -y
```

Delegate Token to your own validator
```
empowerd tx staking delegate $(empowerd keys show wallet --bech val -a) 100000000umpwr --from wallet --chain-id empowerchain-1 --gas-adjustment 1.4 --gas auto --gas-prices="0.025umpwr" -y
```

Delegate Token to other validator
```
empowerd tx staking redelegate $(empowerd keys show wallet --bech val -a) <TO_VALOPER_ADDRESS> 100000000umpwr --from wallet --chain-id empowerchain-1 --gas-adjustment 1.4 --gas auto --gas-prices="0.025umpwr" -y
```

Unbond Token from your validator
```
empowerd tx staking unbond $(empowerd keys show wallet --bech val -a) 100000000umpwr --from wallet --chain-id empowerchain-1 --gas-adjustment 1.4 --gas auto --gas-prices="0.025umpwr" -y
```

Send Token to another wallet
```
empowerd tx bank send wallet <TO_WALLET_ADDRESS> 100000000umpwr --from wallet --chain-id empowerchain-1
```

### Governance 

Vote
You can change the value of `yes` to `no`,`abstain`,`nowithveto`

```
empowerd tx gov vote 1 yes --from wallet --chain-id empowerchain-1 --gas-adjustment 1.4 --gas auto --gas-prices="0.025umpwr" -y
```

### Other

Set Your own Custom Ports
You can change value `CUSTOM_PORT=104` To any other ports
```
CUSTOM_PORT=104
sed -i -e "s%^proxy_app = \"tcp://127.0.0.1:26658\"%proxy_app = \"tcp://127.0.0.1:${CUSTOM_PORT}658\"%; s%^laddr = \"tcp://127.0.0.1:26657\"%laddr = \"tcp://127.0.0.1:${CUSTOM_PORT}57\"%; s%^pprof_laddr = \"localhost:6060\"%pprof_laddr = \"localhost:${CUSTOM_PORT}60\"%; s%^laddr = \"tcp://0.0.0.0:26656\"%laddr = \"tcp://0.0.0.0:${CUSTOM_PORT}656\"%; s%^prometheus_listen_addr = \":26660\"%prometheus_listen_addr = \":${CUSTOM_PORT}60\"%" $HOME/.empowerchain/config/config.toml
sed -i -e "s%^address = \"tcp://0.0.0.0:1317\"%address = \"tcp://0.0.0.0:${CUSTOM_PORT}17\"%; s%^address = \":8080\"%address = \":${CUSTOM_PORT}80\"%; s%^address = \"0.0.0.0:9090\"%address = \"0.0.0.0:${CUSTOM_PORT}90\"%; s%^address = \"0.0.0.0:9091\"%address = \"0.0.0.0:${CUSTOM_PORT}91\"%" $HOME/.empowerchain/config/app.toml
```

Enable Indexing usually enabled by default
```
sed -i -e 's|^indexer *=.*|indexer = "kv"|' $HOME/.empowerchain/config/config.toml
```

Disable Indexing
```
sed -i -e 's|^indexer *=.*|indexer = "null"|' $HOME/.empowerchain/config/config.toml
```

Reset Chain Data
```
empowerd tendermint unsafe-reset-all --home $HOME/.empowerchain --keep-addr-book
```

### Delete Node

WARNING! Use this command wisely 
Backup your key first it will remove empower

```
sudo systemctl stop empowerd && \
sudo systemctl disable empowerd && \
rm /etc/systemd/system/empowerd.service && \
sudo systemctl daemon-reload && \
cd $HOME && \
rm -rf .empowerchain && \
rm -rf $(which empowerd)
```
