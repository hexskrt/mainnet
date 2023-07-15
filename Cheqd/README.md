<p align="center">
  <img height="100" height="auto" src="https://github.com/hexskrt/logos/blob/main/cheqd.png?raw=true">
</p>

# Cheqd Mainnet | Chain ID : cheqd-mainnet-1

### Custom Explorer:
>-  https://explorer.hexnodes.co/cheqd

### Public Endpoint

>- API : https://lcd.cheqd.hexnodes.co
>- RPC : https://rpc.cheqd.hexnodes.co
>- gRPC : https://grpc.cheqd.hexnodes.co

### Auto Installation
```
curl -sL https://raw.githubusercontent.com/hexskrt/mainnet/main/Cheqd/cheqd.sh > cheqd.sh && chmod +x cheqd.sh && ./cheqd.sh
```

### Snapshot ( Update Every 5 Hours )
```
sudo systemctl stop cheqd-noded
cp $HOME/.cheqdnode/data/priv_validator_state.json $HOME/.cheqdnode/priv_validator_state.json.backup
rm -rf $HOME/.cheqdnode/data

curl -L https://snap.hexnodes.co/ixo/ixo.latest.tar.lz4 | tar -Ilz4 -xf - -C $HOME/.cheqdnode/
mv $HOME/.cheqdnode/priv_validator_state.json.backup $HOME/.cheqdnode/data/priv_validator_state.json

sudo systemctl start cheqd-noded && sudo journalctl -fu cheqd-noded -o cat
```

### State Sync
```
sudo systemctl stop cheqd-noded
cp $HOME/.cheqdnode/data/priv_validator_state.json $HOME/.cheqdnode/priv_validator_state.json.backup
cheqd-noded tendermint unsafe-reset-all --home $HOME/.cheqdnode

STATE_SYNC_RPC=https://rpc.ixo.hexnodes.co:443
LATEST_HEIGHT=$(curl -s $STATE_SYNC_RPC/block | jq -r .result.block.header.height)
SYNC_BLOCK_HEIGHT=$(($LATEST_HEIGHT - 2000))
SYNC_BLOCK_HASH=$(curl -s "$STATE_SYNC_RPC/block?height=$SYNC_BLOCK_HEIGHT" | jq -r .result.block_id.hash)

sed -i \
  -e "s|^enable *=.*|enable = true|" \
  -e "s|^rpc_servers *=.*|rpc_servers = \"$STATE_SYNC_RPC,$STATE_SYNC_RPC\"|" \
  -e "s|^trust_height *=.*|trust_height = $SYNC_BLOCK_HEIGHT|" \
  -e "s|^trust_hash *=.*|trust_hash = \"$SYNC_BLOCK_HASH\"|" \
  $HOME/.cheqdnode/config/config.toml

mv $HOME/.cheqdnode/priv_validator_state.json.backup $HOME/.cheqdnode/data/priv_validator_state.json

sudo systemctl start cheqd-noded && sudo journalctl -u cheqd-noded -f --no-hostname -o cat
```

### Live Peers
```
PEERS="0674ed40fc099c0aca4415998ace806c9c0baf49@45.77.61.128:26656,82203bc2944fdb529d0822f420cd4fa22fc9a202@51.178.65.225:36656,a2cc9e11a21634c60fcd7485284e7ec30e6bc08a@31.171.250.63:26656,15d16825e6304c446cde0996b4ee767bb741cbaf@199.247.8.89:26656,1c6803325e8d6836873f847e10473e84fc3f9797@185.232.70.121:26656,892534f6e75cd766a112028fe6cc23d2230ee406@194.163.149.50:26656,9e7dc0361b109b422474bc468c8e086e50357580@31.171.241.193:26656,4ad2c31b5ea26dbf33bb5666d1bd622cae30315c@142.132.158.93:16656,9f74a0bbe006bbd36c56075ad203996a5e3f4ddb@162.55.245.211:26656,73bd67bd7caab3dd510d9025ea5a58e773bbc7f2@51.89.7.179:26631,dde3d8aacfef1490ef4ae43698e3e2648bb8363c@80.64.208.42:26656,bf628a75679984560553e17bcaf4e15b7a6efc66@80.64.208.43:26656,05cd9a32419078db462c8d0ccb0c7b8e652a40d1@46.4.81.204:37656,d644b4ca0649939be69fd3ff88d510e10f7a8d14@51.83.131.162:28456,75e35c203c8ca5797b269aa334aa57b03cce9f22@65.108.70.119:39656,ce9af9dfffc176d7cd206ba369db0d3bc197d3c8@65.21.91.160:26858,db69f9d7309463bbab52af864b8ef174b77787c2@65.21.195.98:26696,98bbf556b8a6069bb7fa61fedda556dcd987e8a9@65.108.201.154:3000,ef2035826146c718a2196edfeca47630e14e36f7@135.181.223.115:2130,ff19775d8175130a1196824bb7c93e8e768e9ec8@135.148.169.198:16656,a988534ab1e4bc42aad26ea7ec7bdc7d5415a14c@107.6.2.27:32661,6a50fe8841ff021bc372dcd999b5a0d785b7f4b2@194.163.174.44:26656,556022a8b9b3a0b656060f32c9c1148987f75bb2@44.195.226.169:26656,f79da5c87e40587c4cfef5d7b7902b6e69ac62bf@188.166.183.216:26656,eae3be73cbf1ac5227f4e7eaf8745e08a54c2501@154.53.59.45:26656,a8d9811a2f08b8a6c77e4319097d6fd84520645e@139.84.226.60:26656,d43289423e8bea7c1090a7e92bf4488dd6d7e260@159.65.151.157:26656,0f409f22cb7efc329e22da0632d0591cb1135fca@135.181.216.151:28656,ed9a522cb8b4ecf1fefe6403be04424f1f6ebdf9@45.33.65.206:26656"
sed -i -e "s|^persistent_peers *=.*|persistent_peers = \"$PEERS\"|" $HOME/.cheqdnode/config/config.toml
```
### Addrbook
```
curl -Ls https://ss.hexnodes.co/cheqd/addrbook.json > $HOME/.cheqdnode/config/addrbook.json
```
### Genesis
```
curl -Ls https://ss.hexnodes.co/cheqd/genesis.json > $HOME/.cheqdnode/config/genesis.json
```

### Cheqd CLI Cheatsheet

- Always be careful with the capitalized words
- Specify `--chain-id`

### Wallet Management

Add Wallet
Specify the value `wallet` with your own wallet name

```
cheqd-noded keys add wallet
```

Recover Wallet
```
cheqd-noded keys add wallet --recover
```

List Wallet
```
cheqd-noded keys list
```

Delete Wallet
```
cheqd-noded keys delete wallet
```

Check Wallet Balance
```
cheqd-noded q bank balances $(cheqd-noded keys show wallet -a)
```

### Validator Management

Please adjust `wallet` , `MONIKER` , `YOUR_KEYBASE_ID` , `YOUR_DETAILS` , `YOUUR_WEBSITE_URL`

Create Validator
```
cheqd-noded tx staking create-validator \
  --chain-id cheqd-mainnet-1 \
  --pubkey="$(cheqd-noded tendermint show-validator)" \
  --moniker="YOUR_MONIKER" \
  --amount 1000000ncheqd \
  --identity "YOUR_KEYBASE_ID" \
  --website "YOUR_WEBSITE_URL" \
  --details "YOUR_DETAILS" \
  --from wallet \
  --commission-rate=0.05 \
  --commission-max-rate=0.20 \
  --commission-max-change-rate=0.01 \
  --min-self-delegation 1 \
  --gas auto \
  --fees=5000000ncheq \
  -y
```

Edit Validator
```
cheqd-noded tx staking edit-validator \
--new-moniker "YOUR_MONIKER " \
--identity "YOUR_KEYBASE_ID" \
--website "YOUR_WEBSITE_URL" \
--details "YOUR_DETAILS" \
--chain-id cheqd-mainnet-1 \
--commission-rate=0.01 \
--min-self-delegation=1 \
--from=wallet \
--gas auto \
-y
```


Unjail Validator
```
cheqd-noded tx slashing unjail --from wallet --chain-id cheqd-mainnet-1 --gas auto -y
```

Check Jailed Reason
```
cheqd-noded query slashing signing-info $(cheqd-noded tendermint show-validator)
```

### Token Management

Withdraw Rewards
```
cheqd-noded tx distribution withdraw-all-rewards --from wallet --chain-id cheqd-mainnet-1 --gas-adjustment 1.4 --gas auto --gas-prices="0.025ncheqd" -y
```

Withdraw Rewards with Comission
```
cheqd-noded tx distribution withdraw-rewards $(cheqd-noded keys show wallet --bech val -a) --commission --from wallet --chain-id cheqd-mainnet-1 --gas-adjustment 1.4 --gas auto --gas-prices="0.025ncheqd" -y
```

Delegate Token to your own validator
```
cheqd-noded tx staking delegate $(cheqd-noded keys show wallet --bech val -a) 100000000ncheqd --from wallet --chain-id cheqd-mainnet-1 --gas-adjustment 1.4 --gas auto --gas-prices="0.025ncheqd" -y
```

Delegate Token to other validator
```
cheqd-noded tx staking redelegate $(cheqd-noded keys show wallet --bech val -a) <TO_VALOPER_ADDRESS> 100000000ncheqd --from wallet --chain-id cheqd-mainnet-1 --gas-adjustment 1.4 --gas auto --gas-prices="0.025ncheqd" -y
```

Unbond Token from your validator
```
cheqd-noded tx staking unbond $(cheqd-noded keys show wallet --bech val -a) 100000000ncheqd --from wallet --chain-id cheqd-mainnet-1 --gas-adjustment 1.4 --gas auto --gas-prices="0.025ncheqd" -y
```

Send Token to another wallet
```
cheqd-noded tx bank send wallet <TO_WALLET_ADDRESS> 100000000ncheqd --from wallet --chain-id cheqd-mainnet-1
```

### Governance 

Vote
You can change the value of `yes` to `no`,`abstain`,`nowithveto`

```
cheqd-noded tx gov vote 1 yes --from wallet --chain-id cheqd-mainnet-1 --gas-adjustment 1.4 --gas auto --gas-prices="0.025ncheqd" -y
```

### Other

Set Your own Custom Ports
You can change value `CUSTOM_PORT=102` To any other ports
```
CUSTOM_PORT=102
sed -i -e "s%^proxy_app = \"tcp://127.0.0.1:26658\"%proxy_app = \"tcp://127.0.0.1:${CUSTOM_PORT}58\"%; s%^laddr = \"tcp://127.0.0.1:26657\"%laddr = \"tcp://127.0.0.1:${CUSTOM_PORT}57\"%; s%^pprof_laddr = \"localhost:6060\"%pprof_laddr = \"localhost:${CUSTOM_PORT}60\"%; s%^laddr = \"tcp://0.0.0.0:26656\"%laddr = \"tcp://0.0.0.0:${CUSTOM_PORT}56\"%; s%^prometheus_listen_addr = \":26660\"%prometheus_listen_addr = \":${CUSTOM_PORT}60\"%" $HOME/.cheqdnode/config/config.toml
sed -i -e "s%^address = \"tcp://0.0.0.0:1317\"%address = \"tcp://0.0.0.0:${CUSTOM_PORT}17\"%; s%^address = \":8080\"%address = \":${CUSTOM_PORT}80\"%; s%^address = \"0.0.0.0:9090\"%address = \"0.0.0.0:${CUSTOM_PORT}90\"%; s%^address = \"0.0.0.0:9091\"%address = \"0.0.0.0:${CUSTOM_PORT}91\"%" $HOME/.cheqdnode/config/app.toml
```

Enable Indexing usually enabled by default
```
sed -i -e 's|^indexer *=.*|indexer = "kv"|' $HOME/.cheqdnode/config/config.toml
```

Disable Indexing
```
sed -i -e 's|^indexer *=.*|indexer = "null"|' $HOME/.cheqdnode/config/config.toml
```

Reset Chain Data
```
cheqd-noded tendermint unsafe-reset-all --home $HOME/.cheqdnode --keep-addr-book
```

### Delete Node

WARNING! Use this command wisely 
Backup your key first it will remove Cheqd

```
sudo systemctl stop cheqd-noded && \
sudo systemctl disable cheqd-noded && \
rm /etc/systemd/system/cheqd-noded.service && \
sudo systemctl daemon-reload && \
cd $HOME && \
rm -rf .cheqdnode && \
rm -rf $(which cheqd-noded)
```
