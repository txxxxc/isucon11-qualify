sudo mv /var/log/mysql/slow-query.log /var/log/mysql/$(date +%Y_%m%d_%H%M)_slow-query.log
sudo systemctl restart mysqld.service
sudo mv /var/log/nginx/access.log /var/log/nginx/$(date +%Y_%m%d_%H%M).access.log
sudo systemctl restart nginx.service
