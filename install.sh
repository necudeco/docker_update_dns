cp update_dns.sh /usr/local/bin/
chmod +x /usr/local/bin/update_dns.sh

cp update_dns.service /etc/systemd/system/update_dns.service

systemctl daemon-reload
systemctl enable update_dns.service
systemctl start  update_dns.service


