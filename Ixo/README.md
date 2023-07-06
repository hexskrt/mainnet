<p align="center">
  <img height="100" height="auto" src="https://github.com/hexskrt/logos/blob/main/ixo.jpg?raw=true">
</p>

# Ixo Mainnet | Chain ID : ixo-5

### Custom Explorer:
>-  https://explorer.hexnodes.co/IXO

### Public Endpoint

>- API : https://lcd.ixo.hexnodes.co
>- RPC : https://rpc.ixo.hexnodes.co
>- gRPC : https://grpc.ixo.hexnodes.co

### Auto Installation
```
curl -sL https://raw.githubusercontent.com/hexskrt/mainnet/main/Ixo/ixo.sh > ixo.sh && chmod +x ixo.sh && ./ixo.sh
```

### Snapshot ( Update Every 5 Hours )
```
sudo systemctl stop ixod
cp $HOME/.ixod/data/priv_validator_state.json $HOME/.ixod/priv_validator_state.json.backup
rm -rf $HOME/.ixod/data

curl -L https://snap.hexnodes.co/ixo/ixo.latest.tar.lz4 | tar -Ilz4 -xf - -C $HOME/.ixod/
mv $HOME/.ixod/priv_validator_state.json.backup $HOME/.ixod/data/priv_validator_state.json

sudo systemctl start ixod && sudo journalctl -fu ixod -o cat
```

### State Sync
```
sudo systemctl stop ixod
cp $HOME/.ixod/data/priv_validator_state.json $HOME/.ixod/priv_validator_state.json.backup
ixod tendermint unsafe-reset-all --home $HOME/.ixod

STATE_SYNC_RPC=https://rpc.ixo.hexnodes.co:443
LATEST_HEIGHT=$(curl -s $STATE_SYNC_RPC/block | jq -r .result.block.header.height)
SYNC_BLOCK_HEIGHT=$(($LATEST_HEIGHT - 2000))
SYNC_BLOCK_HASH=$(curl -s "$STATE_SYNC_RPC/block?height=$SYNC_BLOCK_HEIGHT" | jq -r .result.block_id.hash)

sed -i \
  -e "s|^enable *=.*|enable = true|" \
  -e "s|^rpc_servers *=.*|rpc_servers = \"$STATE_SYNC_RPC,$STATE_SYNC_RPC\"|" \
  -e "s|^trust_height *=.*|trust_height = $SYNC_BLOCK_HEIGHT|" \
  -e "s|^trust_hash *=.*|trust_hash = \"$SYNC_BLOCK_HASH\"|" \
  $HOME/.ixod/config/config.toml

mv $HOME/.ixod/priv_validator_state.json.backup $HOME/.ixod/data/priv_validator_state.json

sudo systemctl start ixod && sudo journalctl -u ixod -f --no-hostname -o cat
```

### Live Peers
```
PEERS="0674ed40fc099c0aca4415998ace806c9c0baf49@45.77.61.128:26656,82203bc2944fdb529d0822f420cd4fa22fc9a202@51.178.65.225:36656,a2cc9e11a21634c60fcd7485284e7ec30e6bc08a@31.171.250.63:26656,15d16825e6304c446cde0996b4ee767bb741cbaf@199.247.8.89:26656,1c6803325e8d6836873f847e10473e84fc3f9797@185.232.70.121:26656,892534f6e75cd766a112028fe6cc23d2230ee406@194.163.149.50:26656,9e7dc0361b109b422474bc468c8e086e50357580@31.171.241.193:26656,4ad2c31b5ea26dbf33bb5666d1bd622cae30315c@142.132.158.93:16656,9f74a0bbe006bbd36c56075ad203996a5e3f4ddb@162.55.245.211:26656,73bd67bd7caab3dd510d9025ea5a58e773bbc7f2@51.89.7.179:26631,dde3d8aacfef1490ef4ae43698e3e2648bb8363c@80.64.208.42:26656,bf628a75679984560553e17bcaf4e15b7a6efc66@80.64.208.43:26656,05cd9a32419078db462c8d0ccb0c7b8e652a40d1@46.4.81.204:37656,d644b4ca0649939be69fd3ff88d510e10f7a8d14@51.83.131.162:28456,75e35c203c8ca5797b269aa334aa57b03cce9f22@65.108.70.119:39656,ce9af9dfffc176d7cd206ba369db0d3bc197d3c8@65.21.91.160:26858,db69f9d7309463bbab52af864b8ef174b77787c2@65.21.195.98:26696,98bbf556b8a6069bb7fa61fedda556dcd987e8a9@65.108.201.154:3000,ef2035826146c718a2196edfeca47630e14e36f7@135.181.223.115:2130,ff19775d8175130a1196824bb7c93e8e768e9ec8@135.148.169.198:16656,a988534ab1e4bc42aad26ea7ec7bdc7d5415a14c@107.6.2.27:32661,6a50fe8841ff021bc372dcd999b5a0d785b7f4b2@194.163.174.44:26656,556022a8b9b3a0b656060f32c9c1148987f75bb2@44.195.226.169:26656,f79da5c87e40587c4cfef5d7b7902b6e69ac62bf@188.166.183.216:26656,eae3be73cbf1ac5227f4e7eaf8745e08a54c2501@154.53.59.45:26656,a8d9811a2f08b8a6c77e4319097d6fd84520645e@139.84.226.60:26656,d43289423e8bea7c1090a7e92bf4488dd6d7e260@159.65.151.157:26656,0f409f22cb7efc329e22da0632d0591cb1135fca@135.181.216.151:28656,ed9a522cb8b4ecf1fefe6403be04424f1f6ebdf9@45.33.65.206:26656"
sed -i -e "s|^persistent_peers *=.*|persistent_peers = \"$PEERS\"|" $HOME/.ixod/config/config.toml
```
### Addrbook
```
curl -Ls https://snap.hexnodes.co/ixo/addrbook.json > $HOME/.ixod/config/addrbook.json
```
### Genesis
```
curl -Ls https://snap.hexnodes.co/ixo/genesis.json > $HOME/.ixod/config/genesis.json
```

### Ixo CLI Cheatsheet

- Always be careful with the capitalized words
- Specify `--chain-id`

### Wallet Management

Add Wallet
Specify the value `wallet` with your own wallet name

```
ixod keys add wallet
```

Recover Wallet
```
ixod keys add wallet --recover
```

List Wallet
```
ixod keys list
```

Delete Wallet
```
ixod keys delete wallet
```

Check Wallet Balance
```
ixod q bank balances $(ixod keys show wallet -a)
```

### Validator Management

Please adjust `wallet` , `MONIKER` , `YOUR_KEYBASE_ID` , `YOUR_DETAILS` , `YOUUR_WEBSITE_URL`

Create Validator
```
ixod tx staking create-validator \
  --chain-id ixo-5 \
  --pubkey="$(ixod tendermint show-validator)" \
  --moniker="YOUR_MONIKER" \
  --amount 1000000uixo \
  --identity "YOUR_KEYBASE_ID" \
  --website "YOUR_WEBSITE_URL" \
  --details "YOUR_DETAILS" \
  --from wallet \
  --commission-rate=0.05 \
  --commission-max-rate=0.20 \
  --commission-max-change-rate=0.01 \
  --min-self-delegation 1 \
  --gas auto \
  --fees=2000uixo \
  -y
```

Edit Validator
```
ixod tx staking edit-validator \
--new-moniker "YOUR_MONIKER " \
--identity "YOUR_KEYBASE_ID" \
--website "YOUR_WEBSITE_URL" \
--details "YOUR_DETAILS" \
--chain-id ixo-5 \
--commission-rate=0.01 \
--min-self-delegation=1 \
--from=wallet \
--gas auto \
-y
```


Unjail Validator
```
ixod tx slashing unjail --from wallet --chain-id ixo-5 --gas auto -y
```

Check Jailed Reason
```
ixod query slashing signing-info $(ixod tendermint show-validator)
```

### Token Management

Withdraw Rewards
```
ixod tx distribution withdraw-all-rewards --from wallet --chain-id ixo-5 --gas-adjustment 1.4 --gas auto --gas-prices="0.025uixo" -y
```

Withdraw Rewards with Comission
```
ixod tx distribution withdraw-rewards $(ixod keys show wallet --bech val -a) --commission --from wallet --chain-id ixo-5 --gas-adjustment 1.4 --gas auto --gas-prices="0.025uixo" -y
```

Delegate Token to your own validator
```
ixod tx staking delegate $(ixod keys show wallet --bech val -a) 100000000uixo --from wallet --chain-id ixo-5 --gas-adjustment 1.4 --gas auto --gas-prices="0.025uixo" -y
```

Delegate Token to other validator
```
ixod tx staking redelegate $(ixod keys show wallet --bech val -a) <TO_VALOPER_ADDRESS> 100000000uixo --from wallet --chain-id ixo-5 --gas-adjustment 1.4 --gas auto --gas-prices="0.025uixo" -y
```

Unbond Token from your validator
```
ixod tx staking unbond $(ixod keys show wallet --bech val -a) 100000000uixo --from wallet --chain-id ixo-5 --gas-adjustment 1.4 --gas auto --gas-prices="0.025uixo" -y
```

Send Token to another wallet
```
ixod tx bank send wallet <TO_WALLET_ADDRESS> 100000000uixo --from wallet --chain-id ixo-5
```

### Governance 

Vote
You can change the value of `yes` to `no`,`abstain`,`nowithveto`

```
ixod tx gov vote 1 yes --from wallet --chain-id ixo-5 --gas-adjustment 1.4 --gas auto --gas-prices="0.025uixo" -y
```

### Other

Set Your own Custom Ports
You can change value `CUSTOM_PORT=106` To any other ports
```
CUSTOM_PORT=106
sed -i -e "s%^proxy_app = \"tcp://127.0.0.1:26658\"%proxy_app = \"tcp://127.0.0.1:${CUSTOM_PORT}58\"%; s%^laddr = \"tcp://127.0.0.1:26657\"%laddr = \"tcp://127.0.0.1:${CUSTOM_PORT}57\"%; s%^pprof_laddr = \"localhost:6060\"%pprof_laddr = \"localhost:${CUSTOM_PORT}60\"%; s%^laddr = \"tcp://0.0.0.0:26656\"%laddr = \"tcp://0.0.0.0:${CUSTOM_PORT}56\"%; s%^prometheus_listen_addr = \":26660\"%prometheus_listen_addr = \":${CUSTOM_PORT}60\"%" $HOME/.ixod/config/config.toml
sed -i -e "s%^address = \"tcp://0.0.0.0:1317\"%address = \"tcp://0.0.0.0:${CUSTOM_PORT}17\"%; s%^address = \":8080\"%address = \":${CUSTOM_PORT}80\"%; s%^address = \"0.0.0.0:9090\"%address = \"0.0.0.0:${CUSTOM_PORT}90\"%; s%^address = \"0.0.0.0:9091\"%address = \"0.0.0.0:${CUSTOM_PORT}91\"%" $HOME/.ixod/config/app.toml
```

Enable Indexing usually enabled by default
```
sed -i -e 's|^indexer *=.*|indexer = "kv"|' $HOME/.ixod/config/config.toml
```

Disable Indexing
```
sed -i -e 's|^indexer *=.*|indexer = "null"|' $HOME/.ixod/config/config.toml
```

Reset Chain Data
```
ixod tendermint unsafe-reset-all --home $HOME/.ixod --keep-addr-book
```

### Delete Node

WARNING! Use this command wisely 
Backup your key first it will remove ixo

```
sudo systemctl stop ixod && \
sudo systemctl disable ixod && \
rm /etc/systemd/system/ixod.service && \
sudo systemctl daemon-reload && \
cd $HOME && \
rm -rf .ixod && \
rm -rf $(which ixod)
```
