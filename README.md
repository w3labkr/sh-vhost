# Amp Vhost   
Easy and quick installation of amp vhost (None | Laravel | Wordpress | Laravel and Wordpress Integration) on ubuntu 18.04+.   

## Firewall   
If you are installing scripts on cloud servers like aws, gcloud and azure, you need to open the following ports.   
```
apache: 80/tcp, 443/tcp
ssh: 22/tcp
ftp: 20:21/tcp, 990/tcp, 12000:12100/tcp
mariadb: 3306/tcp
memcached: 11211/tcp
redis: 6379/tcp
elasticsearch: 9200/tcp
smtp: 25/tcp, 465/tcp, 587/tcp, 2525/tcp
pop3: 110/tcp, 995/tcp
imap: 143/tcp, 993/tcp
```

## Structure   
```
o
|-- os/
|   |-- os_version/
|   |   `-- package/
|   |       |-- etc/
|   |       |-- lib/
|   |       |-- tmp/
|   |       `-- tmpl/
|   |-- functions.sh
|   `-- utils.sh
`-- env
```

## Syntax   
```
$ ./<command>.sh
or
$ ./<command>.sh <package-name> <package-name> <package-name>
```

## Download   
```
$ sudo su
$ git clone https://github.com/w3src/sh-vhost.git
$ cd sh-vhost
$ chmod +x ./*.sh
```

## Usage   

### Install   
Package installation.   
```
$ ./install.sh
or
$ ./install.sh os host apache2 ufw sendmail fail2ban vsftpd mariadb php npm laravel wp-cli
```

### Update   
Download the latest version of the Amp Vhost.   
```
$ ./update.sh
```

### Uninstall   
Remove the package completely.   
```
$ ./uninstall.sh
or
$ ./uninstall.sh apache2 ufw sendmail fail2ban vsftpd mariadb php npm
```

### Wizard   
Frequently used systemctl commands such as status, start, stop, reload, restart, enable, disable and etc.   
```
$ ./wizard.sh
or
$ ./wizard.sh apache2 fail2ban mariadb vsftpd
```

## Support   
ubuntu 18.04+   

## License   
[MIT License](LICENSE)   