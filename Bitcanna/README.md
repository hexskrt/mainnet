<h3><p style="font-size:14px" align="right">Visit Our Website :
<a href="https://hexnodes.co" target="_blank">Hexnodes</a></p></h3>
<h3><p style="font-size:14px" align="right">Hetzner :
<a href="https://hetzner.cloud/?ref=c0IeszbF5Sk4" target="_blank">Deploy Your VPS With Hetzner 20€ Bonus</a></h3>
<hr>

<p align="center">
  <img height="100" height="auto" src="https://github.com/hexskrt/logos/blob/main/bcna.png?raw=true">
</p>

# Bitcanna Mainnet | Chain ID : bitcanna-1

### Official Documentation:
>- [Bitcanna](https://docs.bitcanna.io/guides/validator-setup-guide)

### Custom Explorer:
>-  https://explorer.hexnodes.co/bitcanna

### Public Endpoint

>- API : https://lcd.bitcanna.hexnodes.co
>- RPC : https://rpc.bitcanna.hexnodes.co
>- gRPC : https://grpc.bitcanna.hexnodes.co

### Snapshot ( Update Every 5 Hours )
```
sudo systemctl stop bcnad
cp $HOME/.bcna/data/priv_validator_state.json $HOME/.bcna/priv_validator_state.json.backup
rm -rf $HOME/.bcna/data

curl -L https://snap.hexnodes.co/bitcanna/bitcanna.latest.tar.lz4 | tar -Ilz4 -xf - -C $HOME/.bcna/
mv $HOME/.bcna/priv_validator_state.json.backup $HOME/.bcna/data/priv_validator_state.json

sudo systemctl start bcnad && sudo journalctl -fu bcnad -o cat
```

### State Sync
```
sudo systemctl stop bcnad
cp $HOME/.bcna/data/priv_validator_state.json $HOME/.bcna/priv_validator_state.json.backup
bcnad tendermint unsafe-reset-all --home $HOME/.bcna

STATE_SYNC_RPC=https://rpc.bitcanna.hexnodes.co:443
LATEST_HEIGHT=$(curl -s $STATE_SYNC_RPC/block | jq -r .result.block.header.height)
SYNC_BLOCK_HEIGHT=$(($LATEST_HEIGHT - 2000))
SYNC_BLOCK_HASH=$(curl -s "$STATE_SYNC_RPC/block?height=$SYNC_BLOCK_HEIGHT" | jq -r .result.block_id.hash)

sed -i \
  -e "s|^enable *=.*|enable = true|" \
  -e "s|^rpc_servers *=.*|rpc_servers = \"$STATE_SYNC_RPC,$STATE_SYNC_RPC\"|" \
  -e "s|^trust_height *=.*|trust_height = $SYNC_BLOCK_HEIGHT|" \
  -e "s|^trust_hash *=.*|trust_hash = \"$SYNC_BLOCK_HASH\"|" \
  $HOME/.bcna/config/config.toml

mv $HOME/.bcna/priv_validator_state.json.backup $HOME/.bcna/data/priv_validator_state.json

sudo systemctl start bcnad && sudo journalctl -u bcnad -f --no-hostname -o cat
```

### Live Peers
```
PEERS="$(curl -sS https://rpc.bitcanna.hexnodes.co/net_info | jq -r '.result.peers[] | "\(.node_info.id)@\(.remote_ip):\(.node_info.listen_addr)"' | awk -F ':' '{print $1":"$(NF)}' | sed -z 's|\n|,|g;s|.$||')"
sed -i -e "s|^persistent_peers *=.*|persistent_peers = \"$PEERS\"|" $HOME/.bcna/config/config.toml
```
### Addrbook
```
curl -Ls https://snap.hexnodes.co/bitcanna/addrbook.json > $HOME/.bcna/config/addrbook.json
```
### Genesis
```
curl -Ls https://snap.hexnodes.co/bitcanna/genesis.json > $HOME/.bcna/config/genesis.json
```