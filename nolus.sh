#!/bin/bash
echo "=============================================================="
echo -e "\e[92m"
echo "      ====      ========  =========  =========  ============   "
echo "     =  + =     =  =====  ======  =  =    +  =  ========   =   "
echo "    =   +  =    =  =      ======  =  =  ======      =    =     "
echo "   =   ===  =   =  =      =   +   =  =  =       =    =======   "
echo "  ===      ===  ====      =========  =  =       ============   "
echo -e "\e[0m"
echo "=============================================================="
sleep 2

echo -e '\e[36mAuthor :\e[39m' ΛЯΛPZZ.ΣƬΉ
echo -e '\e[36mTelegram Group :\e[39m' @arapzz
echo -e '\e[36mYoutube :\e[39m' ΛЯΛPZZ.ΣƬΉ
echo "======================================="

if [ ! $NOLUS_NODENAME ]; then
read -p "Enter node name: " NOLUS_NODENAME
echo 'export NOLUS_NODENAME='\"${NOLUS_NODENAME}\" >> $HOME/.bash_profile
fi
echo 'source $HOME/.bashrc' >> $HOME/.bash_profile
. $HOME/.bash_profile
sleep 1
cd $HOME
sudo apt update
sudo apt install make clang pkg-config libssl-dev build-essential git jq ncdu bsdmainutils htop -y < "/dev/null"

echo -e '\n\e[42mInstall Go\e[0m\n' && sleep 1
cd $HOME
wget -O go1.19.2.linux-amd64.tar.gz https://golang.org/dl/go1.19.2.linux-amd64.tar.gz
rm -rf /usr/local/go && tar -C /usr/local -xzf go1.19.2.linux-amd64.tar.gz && rm go1.19.2.linux-amd64.tar.gz
echo 'export GOROOT=/usr/local/go' >> $HOME/.bash_profile
echo 'export GOPATH=$HOME/go' >> $HOME/.bash_profile
echo 'export GO111MODULE=on' >> $HOME/.bash_profile
echo 'export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin' >> $HOME/.bash_profile && . $HOME/.bash_profile
go version

echo -e '\n\e[42mInstall software\e[0m\n' && sleep 1
rm -rf $HOME/nolus-core
cd $HOME
git clone https://github.com/Nolus-Protocol/nolus-core
cd nolus-core
git checkout v0.1.39
make build
sudo mv ./target/release/nolusd /usr/local/bin/ || exit
nolusd init "$NOLUS_NODENAME" --chain-id=nolus-rila

#seeds="8e1590558d8fede2f8c9405b7ef550ff455ce842@51.79.30.9:26656,bfffaf3b2c38292bd0aa2a3efe59f210f49b5793@51.91.208.71:26656,106c6974096ca8224f20a85396155979dbd2fb09@198.244.141.176:26656"
peers="56cee116ac477689df3b4d86cea5e49cfb450dda@54.246.232.38:26656,56f14005119e17ffb4ef3091886e6f7efd375bfd@34.241.107.0:26656,7f26067679b4323496319fda007a279b52387d77@63.35.222.83:26656,7f4a1876560d807bb049b2e0d0aa4c60cc83aa0a@63.32.88.49:26656,3889ba7efc588b6ec6bdef55a7295f3dd559ebd7@3.249.209.26:26656,de7b54f988a5d086656dcb588f079eb7367f6033@34.244.137.169:26656"
#sed -i "s/^seeds *=.*/seeds = \"$seeds\"/;" $HOME/.nolus/config/config.toml
sed -i.default "s/^persistent_peers *=.*/persistent_peers = \"$peers\"/;" $HOME/.nolus/config/config.toml
sed -i.default 's/minimum-gas-prices =.*/minimum-gas-prices = "0.0025unls"/g' $HOME/.nolus/config/app.toml

sed -i "s/pruning *=.*/pruning = \"custom\"/g" $HOME/.nolus/config/app.toml
sed -i "s/pruning-keep-recent *=.*/pruning-keep-recent = \"100\"/g" $HOME/.nolus/config/app.toml
sed -i "s/pruning-interval *=.*/pruning-interval = \"10\"/g" $HOME/.nolus/config/app.toml

wget -O $HOME/.nolus/config/genesis.json https://raw.githubusercontent.com/Nolus-Protocol/nolus-networks/main/testnet/nolus-rila/genesis.json
nolusd tendermint unsafe-reset-all --home $HOME/.nolus
echo -e '\n\e[42mRunning\e[0m\n' && sleep 1
echo -e '\n\e[42mCreating a service\e[0m\n' && sleep 1

echo "[Unit]
Description=Nolus Node
After=network.target

[Service]
User=$USER
Type=simple
ExecStart=/usr/local/bin/nolusd start
Restart=on-failure
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target" > $HOME/nolusd.service
sudo mv $HOME/nolusd.service /etc/systemd/system
sudo tee <<EOF >/dev/null /etc/systemd/journald.conf
Storage=persistent
EOF
echo -e '\n\e[42mRunning a service\e[0m\n' && sleep 1
sudo systemctl restart systemd-journald
sudo systemctl daemon-reload
sudo systemctl enable nolusd
sudo systemctl restart nolusd

echo -e '\n\e[42mCheck node status\e[0m\n' && sleep 1
if [[ `service nolusd status | grep active` =~ "running" ]]; then
  echo -e "Your nolus node \e[32minstalled and works\e[39m!"
  echo -e "You can check node status by the command \e[7mservice nolusd status\e[0m"
  echo -e "Press \e[7mQ\e[0m for exit from status menu"
else
  echo -e "Your nolus node \e[31mwas not installed correctly\e[39m, please reinstall."
fi
