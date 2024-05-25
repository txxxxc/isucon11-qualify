# >() がbashじゃないと使えないので
SHELL=/bin/bash
# Issue番号は用途によって分けているけど、とりあえずDB周りは1
ISSUE=1

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
	cat /var/log/nginx/access.log | alp json --sort sum -r \ 
	-m '^/api/isu/[\w\d-]+$$,^/api/isu/[\w\d-]+/icon$$,^/api/isu/[\w\d-]+/graph$$,^/api/condition/[\w\d-]+$$,^/isu/[\w\d-]+/icon$$,^/isu/[\w\d-]+/graph$$,^/isu/[\w\d-]+$$,^/isu/[\w\d-]+/condition$$' \
        -o count,method,uri,min,avg,max,sum

mysqldump:
	mysqldump -u isucon -pisucon -h localhost --no-data isucondition > log/mysqldump/$(date +%Y%m%d%H%M).txt

tools:
	sudo apt-get install percona-toolkit
	wget https://github.com/tkuchiki/alp/releases/download/v1.0.21/alp_linux_amd64.zip
	unzip alp_linux_amd64.zip
	sudo mv alp /usr/local/bin/
	rm -rf alp_linux_amd64.zip

symlink-nginx:
	sudo ln -sf webapp/isucondition.conf /etc/nginx/conf.d/isucondition.conf
	sudo systemctl restart nginx

# isucon11qの接続パラメータであるため、今後いい感じにする
mysql/client:
	@mysql -h 127.0.0.1 -P 3306 -u isucon isucondition -pisucon

# echoを見せているのは、どんなクエリ投げたっけを見るためにしてる
mysql/query: QUERY=
mysql/query:
	echo "$(QUERY)" | $(MAKE) mysql/client

mysql/query/gh: QUERY=
mysql/query/gh:
	$(MAKE) mysql/query QUERY="$(QUERY)" | tee >(gh issue comment $(ISSUE) -F -)
