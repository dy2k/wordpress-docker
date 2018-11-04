# WordPress Docker Compose
This docker-compose performs the following tasks:
- Setup a set of WordPress PHP-FPM and MySQL docker instances
- Initialize a certificate using Let's Encrypt with Cloudflare
- Create cron job to check and auto-renew certificate with certbot
- Enable HTTPS hosting using NGINX and FastCGI
- Watch for certificate file changes on renewal to reload NGINX
## Get Started
### Dependencies
Requires Docker, Docker Compose, Git. See [Docker's documentation](https://docs.docker.com/install/) for installation instructions. E.g.
```sh
yum install -y python34 python34-pip
pip3 install --upgrade pip
pip3 install docker-compose
```
### Installation
Clone the repository to start configuration and bootstrapping.
```sh
mkdir -p /root/docker/wordpress
git clone https://github.com/dy2k/wordpress-docker.git /root/docker/wordpress
```
### Configuration
Create configuration files for cerbot, cloudflare, mysql, nginx and wordpress. These files would be loaded to docker as environment variables to start the docker instances. 
```sh
vi /root/docker/wordpress/certbot.env
vi /root/docker/wordpress/cloudflare.ini
vi /root/docker/wordpress/mysql.env
vi /root/docker/wordpress/nginx.env
vi /root/docker/wordpress/wordpress.env
```
#### Cerbot
Sample certbot configuration to set email account for let's Encrypt registration and correct timezone for triggering auto-renewal.
```sh
EMAIL=<your email>
TIMEZONE=<your timezone>
```
#### Cloudflare
Sample cloudflare configuration to perform domain verification using DNS. The domain information would be set in NGINX. 
```sh
dns_cloudflare_email=<your cloudflare account>
dns_cloudflare_api_key=<your cloudflare api key>
```
This file should have its permission set to 600. See [Certbot's documentation](https://certbot-dns-cloudflare.readthedocs.io/en/latest/)
```sh
chmod go-r /root/docker/wordpress/cloudflare.ini
```
#### MySQL
Sample MySQL configuration to load the database initially.
```sh
MYSQL_ROOT_PASSWORD=<your root password>
MYSQL_DATABASE=<your wordpress database>
MYSQL_USER=<your wordpress database user>
MYSQL_PASSWORD=<your wordpress database password>
```
#### NGINX
Sample NGINX configuration. The domain set here will be used to replace the hostname in the nginx default configuration.
```sh
DOMAIN=<your owned domain>
```
#### WordPress
Sample WordPress configuration. The database user and password should match the one set in MySQL.
```sh
WORDPRESS_DB_HOST=mysql:3306
WORDPRESS_DB_USER=<your wordpress database>
WORDPRESS_DB_PASSWORD=<your wordpress database password>
```
### Usage
Run docker-compose to get all things done in one go.
```
docker-compose up
```
