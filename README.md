# Tutorial testnet NODE Humans.AI 


## Referensi

[Dokumen resmi](https://docs.humans.zone/run-nodes/testnet/joining-testnet.html/)

[Explorer](https://explorer.humans.zone/humans-testnet/)

[Server discord](https://discord.com/invite/humansdotai)

[Twitter](https://twitter.com/humansdotai/)

## Spesifikasi

### Persyaratan perangkat keras

| Komponen | Spesifikasi minimal |
|----------|---------------------|
|RAM|8 GB RAM|
|CPU|Quad-Core|
|Disk|250 GB SSD|
|Koneksi|1 Gbps for Download / 100 Mbps for Upload|

### Persyaratan perangkat lunak

| Komponen | Spesifikasi minimal |
|----------|---------------------|
|System|Ubuntu 20.04 (LTS) X64|

## Run node and creath Validator

### STEP 1 : Perbarui sistem

```
sudo apt update
sudo apt upgrade --yes
```

## STEP 2 : Installing the Humans Binary

Instal Opsi 1 | Mengunduh biner

```
wget https://github.com/humansdotai/humans/releases/download/latest/humans_latest_linux_amd64.tar.gz
```

extract file humans 

```
tar -xvf humans_latest_linux_amd64.tar.gz
```

salin humans ke folder /usr/local/bin

```
sudo  cphumansd /usr/local/bin/humansd
```
> Done Lanjut Opsi 2

### Instal Opsi 2 | Membangun dari Kode Sumber

Instal make dan gcc

```
sudo apt-get update
sudo apt-get upgrade
sudo apt install git build-essential ufw curl jq snapd --yes
```

Install Go lang

```
wget https://golang.org/dl/go1.18.2.linux-amd64.tar.gz
sudo tar -C /usr/local -xzf go1.18.2.linux-amd64.tar.gz
```

export to bin

```
export GOROOT=/usr/local/go
export GOPATH=$HOME/go
export GO111MODULE=on
export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin
```

Kompilasi kode sumber mengkloning humansdotai/humans repo

```
cd  $HOME
git clone https://github.com/humansdotai/humans
cd humans
git checkout v1.0.0
go build -o humansd cmd/humansd/main.go
```
> Setelah build, salin langsung ke folder /usr/local/bin 

```
sudo  cp humansd /usr/local/bin/humansd
```

cek humansd version

```
humansd version
```

> Jika muncul v1.0.0 artinya sukses
> jika terjadi eror "humansd: command not found" 

atur konfigurasi shell

```
export PATH=$PATH:$(go env GOPATH)/bin
```

### STEP 3 : Setup System Daemon

1. Instal Cosmovisor with go install

```
go install cosmossdk.io/tools/cosmovisor/cmd/cosmovisor@latest
```

2. Siapkan variabel lingkungan

```
export DAEMON_NAME=humansd
export DAEMON_HOME=$HOME/.humans
source ~/.profile
```

3. Buat direktori yang diperlukan

```
mkdir -p $DAEMON_HOME/cosmovisor/genesis/bin
mkdir -p $DAEMON_HOME/cosmovisor/upgrades
```

4. Tambahkan versi asal dari biner

```
cp ~/go/bin/humansd $DAEMON_HOME/cosmovisor/genesis/bin
```

5. Buat layanan untuk Cosmovisor

```
sudo tee /etc/systemd/system/cosmovisor-humans.service<<EOF
[Unit]
Description=Cosmovisor for Humans Node
Requires=network-online.target
After=network-online.target

[Service]
Type=exec
User=<your_user>
Group=<your_user_group>
ExecStart=/home/<your_user>/go/bin/cosmovisor run start --home /home/<your_user>/
Restart=on-failure
RestartSec=3
Environment="DAEMON_NAME=humansd"
Environment="DAEMON_HOME=/home/<your_user>/.humans"
Environment="DAEMON_ALLOW_DOWNLOAD_BINARIES=false"
Environment="DAEMON_RESTART_AFTER_UPGRADE=true"
Environment="DAEMON_LOG_BUFFER_SIZE=512"
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target
EOF
```

Aktifkan layanan:

```
sudo systemctl daemon-reload
sudo systemctl enable cosmovisor-humans
```

### STEP 4 : Creath wallet & Perbarui daftar peer

1. Inisiasi rantai

```
cd $HOME
humansd init <moniker-name> --chain-id=testnet-1 --home $HOME/.humans
```
> moniker-name ganti dengan nama kalian

2. Buat dompet

```
humansd keys add <key-name>
```
> key-name ganti nama kalian atau samain nama moniker 

3. Konfigurasi genesis.json

```
curl -s https://rpc-testnet.humans.zone/genesis | jq -r .result.genesis > genesis.json
```
Kemudian salin file genesis ke folder $HOME/.humans/config

```
cp genesis.json $HOME /.humans/config/genesis.json
```

4. Konfigurasi persistent_peers.txt

buat file di home ber nama persistent_peers.txt
```
nano persistent_peers.txt
```

isi dengan 
```
1df6735ac39c8f07ae5db31923a0d38ec6d1372b@45.136.40.6:26656
9726b7ba17ee87006055a9b7a45293bfd7b7f0fc@45.136.40.16:26656
6e84cde074d4af8a9df59d125db3bf8d6722a787@45.136.40.18:26656
eda3e2255f3c88f97673d61d6f37b243de34e9d9@45.136.40.13:26656
4de8c8acccecc8e0bed4a218c2ef235ab68b5cf2@45.136.40.12:26656
```
> simpan file dengan ketik ctrl + x terus y

lalu Jalankan
```
export PEERS=$(cat persistent_peers.txt| tr '\n' '_' | sed 's/_/,/g;s/,$//;s/^/"/;s/$/"/') && sed -i "s/persistent_peers = \"\"/persistent_peers = ${PEERS}/g" $HOME/.humans/config/config.toml
```

5. Tetapkan harga gas minimum

```
sed -i 's/minimum-gas-prices =.*/minimum-gas-prices = "0.025uheart"/g' $HOME/.humans/config/app.toml
```

6. Perbarui parameter waktu blok

```
CONFIG_TOML="$HOME/.humans/config/config.toml"
 sed -i 's/timeout_propose =.*/timeout_propose = "100ms"/g' $CONFIG_TOML
 sed -i 's/timeout_propose_delta =.*/timeout_propose_delta = "500ms"/g' $CONFIG_TOML
 sed -i 's/timeout_prevote =.*/timeout_prevote = "100ms"/g' $CONFIG_TOML
 sed -i 's/timeout_prevote_delta =.*/timeout_prevote_delta = "500ms"/g' $CONFIG_TOML
 sed -i 's/timeout_precommit =.*/timeout_precommit = "100ms"/g' $CONFIG_TOML
 sed -i 's/timeout_precommit_delta =.*/timeout_precommit_delta = "500ms"/g' $CONFIG_TOML
 sed -i 's/timeout_commit =.*/timeout_commit = "1s"/g' $CONFIG_TOML
 sed -i 's/skip_timeout_commit =.*/skip_timeout_commit = false/g' $CONFIG_TOML
```

7. Konfigurasikan pemangkasan

Untuk penggunaan ruang disk yang lebih rendah, kami menyarankan pengaturan pemangkasan menggunakan konfigurasi di bawah ini
```
PRUNING="custom"
PRUNING_KEEP_RECENT="100"
PRUNING_INTERVAL="10"

sed -i -e "s/^pruning *=.*/pruning = \"$PRUNING\"/" $HOME/.humans/config/app.toml
sed -i -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \
\"$PRUNING_KEEP_RECENT\"/" $HOME/.humans/config/app.toml
sed -i -e "s/^pruning-interval *=.*/pruning-interval = \
\"$PRUNING_INTERVAL\"/" $HOME/.humans/config/app.toml
```

8. Mulai node

```
sudo systemctl start humansd
sudo systemctl start cosmovisor-humans
humansd start
```

9. Minta token dari [Discord Faucet untuk testnet-1](https://discord.com/invite/humansdotai/) (membuka jendela baru)dalam #testnet-faucetjika diperlukan. Gunakan $help untuk melihat fungsi faucet lainnya. Ganti alamat di bawah ini dengan alamat Anda sendiri. Harap diperhatikan, bahwa batas permintaan mingguan saat ini untuk Discord Humans Faucet adalah 10HEART ( 10000000uheart)

```
$request human1ppa65ec56rqvf4z4v393l0n7llnscw483yftrk
```

Outputnya akan terlihat mirip dengan ini.

```
@YourDiscordHandle - {
"transaction": "3D14B2B146F618F81381786807A8EB7F1E3053F5494F6FDD99BF9CC20F4B7D5D",
"block": 49335,
"gas": 76364    
}
```

dan dapatkan role ⚔️ Testnet  react emoji di channel #roles


### STEP 5 : Buat validator jika block sudah syncron

```
humansd tx staking create-validator \
--amount 10000000uheart \
--commission-max-change-rate "0.1" \
--commission-max-rate "0.20" \
--commission-rate "0.1" \
--min-self-delegation "1" \
--details "put your validator description there" \
--pubkey=$(humansd tendermint show-validator) \
--moniker <your_moniker> \
--chain-id testnet-1 \
--gas-prices 0.025uheart \
--from <key-name>
```

> Kalian edit <key-name> dan <your-moniker>

### DONE SELESAI, tunggu update selanjutnya atau bisa pantau Discord nya