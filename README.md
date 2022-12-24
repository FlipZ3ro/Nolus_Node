# Tutorial testnet Nolus Node Copas nodes.guru


## Referensi

[Dokumen resmi](https://docs-nolus-protocol.notion.site/Run-a-Node-58c9af73bf5945988e902b4b8741f918)

[Explorer](https://nolus.explorers.guru/)

[Server discord](https://discord.com/invite/nolus-protocol)

[Twitter](https://twitter.com/nolusprotocol)

## Spesifikasi

### Persyaratan perangkat keras

| Komponen | Spesifikasi minimal |
|----------|---------------------|
|RAM|4 GB RAM|
|CPU|2 vCPU|
|Disk|120 GB SSD|


## INSTALASI CEPAT

### Copas comand install otomatis di bawah ini

```
wget -q -O nolus.sh https://api.nodes.guru/nolus.sh && chmod +x nolus.sh && sudo /bin/bash nolus.sh
source $HOME/.bash_profile
```

### Buat dompet dan simpan pharse nya

```
nolusd keys add wallet
```

>Copy anddress dan request faucet di discord

### Cek Balance

```
nolusd q bank balances YOUR_WALLET_ADDRESS
```

## Comand Tambahan untuk memastikan node sinkron

Cek status False
```
curl -s localhost:26657/status | jq .result.sync_info.catching_up
```

Cek Logs
```
journalctl -u nolusd -f
```

> Jikas status sudah False berarti sudah singkron


### Creat Vlidator

```
nolusd tx staking create-validator \
--amount=1000000unls \
--pubkey=$(nolusd tendermint show-validator) \
--moniker="$NOLUS_NODENAME" \
--chain-id=nolus-rila \
--commission-rate="0.1" \
--commission-max-rate="0.10" \
--commission-max-change-rate="0.01" \
--min-self-delegation="1000000" \
--gas-prices 0.0042unls \
--from=wallet \
-y
```


### Comand untuk menghapus node 

```
systemctl stop nolusd
systemctl disable nolusd
rm -rf $(which nolusd) ~/.nolus ~/nolus-core
```
