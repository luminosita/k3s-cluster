echo 'network:
  version: 2
  ethernets:
    ens32:
      dhcp4: no' > tmp
echo "      addresses: [$IP_ADDR/24]" >> tmp
echo "      gateway4: $GATE" >> tmp
echo '      nameservers:
        addresses: [8.8.8.8,8.8.4.4]' >> tmp

#sudo mv tmp /etc/netplan/00-installer-config.yaml
#sudo netplan apply