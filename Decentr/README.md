## Auto Installation

```
wget -O decentr.sh https://raw.githubusercontent.com/hexskrt/mainnet/main/LumenX/decentr.sh && chmod +x decentr.sh && ./decentr.sh
```

## SnapShot (2.5 GB) updated every 5 hours

```
sudo systemctl stop decentrd
cp $HOME/.decentr/data/priv_validator_state.json $HOME/.decentr/priv_validator_state.json.backup
rm -rf $HOME/.decentr/data
curl -o - -L http://snap.hexskrt.net/c4e/c4e.latest.tar.lz4 | lz4 -c -d - | tar -x -C $HOME/.decentr
mv $HOME/.decentr/priv_validator_state.json.backup $HOME/.decentr/data/priv_validator_state.json
sudo systemctl restart decentrd && journalctl -u decentrd -f -o cat
```
