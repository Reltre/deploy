source /tmp/load_variables.sh

sudo apt-get update -y
sudo apt-get install build-essential -y
sudo apt-get install git rubygems rubygems-integration -y

# SSL
wget https://dl.eff.org/certbot-auto
chmod a+x certbot-auto

./certbot-auto certonly --non-interactive --standalone -d $DOMAIN_NAME -d www.$DOMAIN_NAME --email $EMAIL --agree-tos
#sudo iptables -t nat -A PREROUTING -p tcp --dport 80 -j REDIRECT --to-port 8080

sudo groupadd deploy
sudo useradd -m hellogov
sudo usermod -append --groups deploy

sudo mkdir -p $APP_DIR
sudo chown hellogov:hellogov $APP_DIR
sudo -u hellogov mkdir -p $APP_DIR
sudo -u hellogov mkdir -p $ARCHIVE_DIR

sudo -u hellogov git clone $GIT_DEPLOY_URL $REMOTE_SCRIPT_PATH/deploy
sudo chown hellogov:hellogov $REMOTE_SCRIPT_PATH/deploy
sudo chmod o+w $REMOTE_SCRIPT_PATH/deploy
find $REMOTE_SCRIPT_PATH/deploy/*.sh -type f -exec sudo chmod u+x  {} \; 

sed -i -e 's/###DOMAIN_NAME###/'"$DOMAIN_NAME"'/g' $REMOTE_SCRIPT_PATH/deploy/conf/nginx/hellogov.conf

# nginx
sudo apt-get install nginx -y
sudo cp $REMOTE_SCRIPT_PATH/deploy/conf/nginx/hellogov.conf /etc/nginx/sites-available/hellogov.conf
sudo ln -s /etc/nginx/sites-available/hellogov.conf /etc/nginx/sites-enabled/hellogov.conf
sudo service nginx reload

cd /home/hellogov
#sudo -u hellogov npm install pm2@latest -g

curl -sL https://deb.nodesource.com/setup_7.x | sudo -E bash -
sudo apt-get install nodejs -y
sudo npm install pm2@latest -g
sudo gem install sass
