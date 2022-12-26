echo "SSH Host"
echo $SSH_HOST

echo 'Copying host public SSH Keys to the VM'
mkdir -p /home/vagrant/.ssh
chmod 700 /home/vagrant/.ssh
cat /home/vagrant/id_rsa.pub >> /home/vagrant/.ssh/authorized_keys
chmod -R 600 /home/vagrant/.ssh/authorized_keys
echo "Host $SSH_HOST" >> /home/vagrant/.ssh/config
echo 'StrictHostKeyChecking no' >> /home/vagrant/.ssh/config
echo 'UserKnownHostsFile /dev/null' >> /home/vagrant/.ssh/config
chmod -R 600 /home/vagrant/.ssh/config
rm /home/vagrant/id_rsa.pub

echo 'Recreating OpenSSH keys'
sudo /bin/rm -v /etc/ssh/ssh_host_*

#need to suppress debconf: unable to initialize frontend: Dialog error with >/dev/null 2>&1
sudo dpkg-reconfigure openssh-server >/dev/null 2>&1
