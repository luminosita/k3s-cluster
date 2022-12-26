echo 'network:
  version: 2
  ethernets:
    ens32:
      dhcp4: no' > tmp
echo "      addresses: " >> tmp
echo "        - $IP_ADDR/24" >> tmp
echo "      nameservers:" >> tmp
echo "        addresses: [8.8.8.8,8.8.4.4]" >> tmp
echo "      routes:" >> tmp
echo "        - to: default" >> tmp
echo "          via: $GATE" >> tmp

sudo mv tmp /etc/netplan/40-vagrant.yaml
sudo netplan apply