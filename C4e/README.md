# SnapShot (~2.5 GB) updated every 5 hours

```sudo systemctl stop c4ed
cp $HOME/.c4e-chain/data/priv_validator_state.json $HOME/.c4e-chain/priv_validator_state.json.backup
rm -rf $HOME/.c4e-chain/data
curl -o - -L http://snap.hexskrt.net/c4e/c4e.latest.tar.lz4 | lz4 -c -d - | tar -x -C $HOME/.c4e-chain
mv $HOME/.c4e-chain/priv_validator_state.json.backup $HOME/.c4e-chain/data/priv_validator_state.json
sudo systemctl restart c4ed && journalctl -u c4ed -f -o cat```
