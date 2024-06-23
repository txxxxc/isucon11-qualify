# >() がbashじゃないと使えないので
SHELL=/bin/bash

BENCH_ISSUE_NUMBER=18
ALP_ISSUE_NUMBER=1
PQD_ISSUE_NUMBER=2

# https://github.com/cli/cli/blob/trunk/docs/install_linux.md#official-sources
gh:
	type -p curl >/dev/null || (sudo apt update && sudo apt install curl -y)
	curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg \
	&& sudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg \
	&& echo "deb [arch=$$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
	&& sudo apt update \
	&& sudo apt install gh -y

git:
	git config --global user.name txxxxc
	git config --global user.email tt.ios.develop@gmail.com
	git config --global core.editor vim

alp:
	cat /var/log/nginx/access.log | alp json --sort sum -r -m '^/api/isu/[\w\d-]+$$,^/api/isu/[\w\d-]+/icon$$,^/api/isu/[\w\d-]+/graph$$,^/api/condition/[\w\d-]+$$,^/isu/[\w\d-]+/icon$$,^/isu/[\w\d-]+/graph$$,^/isu/[\w\d-]+$$,^/isu/[\w\d-]+/condition$$' -o count,method,uri,min,avg,max,sum

alp/send:
alp/send:
	cat /var/log/nginx/access.log | alp json --sort sum -r -m '^/api/isu/[\w\d-]+$$,^/api/isu/[\w\d-]+/icon$$,^/api/isu/[\w\d-]+/graph$$,^/api/condition/[\w\d-]+$$,^/isu/[\w\d-]+/icon$$,^/isu/[\w\d-]+/graph$$,^/isu/[\w\d-]+$$,^/isu/[\w\d-]+/condition$$' -o count,method,uri,min,avg,max,sum | gh issue comment $(ALP_ISSUE_NUMBER) -F -

mysqldump:
	mysqldump -u isucon -pisucon -h localhost --no-data isucondition > log/mysqldump/$$(date +%Y_%m%d_%H%M).txt

tools:
	sudo apt-get install -y percona-toolkit gv graphviz
	wget https://github.com/tkuchiki/alp/releases/download/v1.0.21/alp_linux_amd64.zip
	unzip alp_linux_amd64.zip
	sudo mv alp /usr/local/bin/
	rm -rf alp_linux_amd64.zip

.PHONY: bench
bench: 
	(cd bench && ./bench -all-addresses 127.0.0.11 -target 127.0.0.11:443 -tls -jia-service-url http://127.0.0.1:4999 | tee ~/log/bench/$$(date +%Y_%m%d_%H%M).txt)

bench/send: FILE=
bench/send:
	 cat $(FILE) | echo "\`\`\`$$(cat - )\`\`\`" | gh issue comment $(BENCH_ISSUE_NUMBER) -F -

build:
	(cd webapp/go && go build .)


symlink-nginx:
	sudo ln -sf webapp/isucondition.conf /etc/nginx/conf.d/isucondition.conf
	sudo systemctl restart nginx

mysql/client:
	@mysql -h 127.0.0.1 -P 3306 -u isucon isucondition -pisucon

rotate:
	sudo mv /var/log/mysql/slow-query.log /var/log/mysql/$$(date +%Y_%m%d_%H%M)_slow-query.log
	sudo systemctl restart mysqld.service
	sudo mv /var/log/nginx/access.log /var/log/nginx/$$(date +%Y_%m%d_%H%M).access.log
	sudo systemctl restart nginx.service

reload: 
	sudo systemctl restart isucondition.go.service

pt-query-digest:
	sudo pt-query-digest /var/log/mysql/slow-query.log | tee log/slow-query/$$(date +%Y_%m%d_%H%M).txt

pt-query-digest/send:
pt-query-digest/send:
	sudo pt-query-digest /var/log/mysql/slow-query.log | tee log/slow-query/$$(date +%Y_%m%d_%H%M).txt | gh issue comment $(PQD_ISSUE_NUMBER) -F -

serve: build reload

# echoを見せているのは、どんなクエリ投げたっけを見るためにしてる
mysql/query: QUERY=
mysql/query:
	echo "$(QUERY)" | $(MAKE) mysql/client

