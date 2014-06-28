
[![Build Status](https://travis-ci.org/computerlyrik/chef-zarafa.png)](https://travis-ci.org/computerlyrik/chef-zarafa)
# Description

## Source code
Here is the Source code repository,  
**please fork and contribute**  
http://github.com/computerlyrik/chef-zarafa

## Motivation
Having a eMail Server with exchange (mail/contacts/calendar) Support automatically setup for you?  
Working with mobile devices and want your 'own Server' for you or your business?  
*Here we go.*

## Supports
- Automatic download and installation of zarafa
- Automatic setup of z-sync (exchange plugin)
- Using TLS for your connection encrytpion
- Authenticating and delivering mail into zarafa mailboxes

## Features
- Syncing your Android/i/Windows Phone with ActiveSync
- eMail Push
- Receive and send eMail via imap
- Have two rich Webinterfaces to login wherever, whenever you want

# Requirements

## Operating System and Hardware Reqirements
See the Zarafa documentation for Hardware req  
The recipes itself currently support Debian 7.5

## Cookbooks
- **database** and **mysql**  
  for setting up the mysql DB
- **apache2**  
  our favourite webserver
- **postfix**  
  our favourite mailserver
- **certificate**  
  Managing your certificate for https/TLS via a databag.  
  http://community.opscode.com/cookbooks/certificate
- **openssl**
- **ark**

# Attributes
Some pre-settings have been made. Please see attributes ruby files for reference.

## required
Example
```ruby

default['zarafa']['catchall_user'] = "mydeliverymail@mydomain.com"
default['zarafa']['certificate_databag_id'] = 'mySecureDataBag'
```

## optional
Example, expecting to run on `myhostname.example.com`
```ruby
default['zarafa']['additional_domains'] = ['example.net', 'example.org']
```

# Cookbooks
## zarafa::default
Combines all cookbooks to setup a server

## zarafa::apache2
Set up and configure Apache2 Webserver

## zarafa::postfix
Make some basic configuration for the postfix Server.  
Calls the other sub-recipies

### zarafa::postfix_virtual_users
Configure postfix to read Mailboxses from MySQL and deliver them via lmtp[1[1].  
By default [2] server installation is configured to only deliver to unix system users.  
[1] http://doc.zarafa.com/7.1/Administrator_Manual/en-US/html/_MTAIntegration.html#_configure_zcp_postfix_integration_with_the_db_plugin  
[2] http://www.zarafa.com/wiki/index.php/Installing_Zarafa_from_packages
### zarafa::postfix_catchall
Sets up an alias-DB for postfix to have the configured CatchAll user for the all domains we configured

### zarafa::postfix_stmpd_sasl
By default, the postfix server takes all eMail via port 25. If the Server is directly connected to the internet you want to secure this connection only for logged-in users.  
This recipe configures sasl to authenticate via the rimap protocol.
http://www.zarafa.com/wiki/index.php/SMTP-Auth_for_IMAP_users

## zarafa::mysql
Set up the Database for zarafa

## zarafa::zarafa-server
Installs the zarafa server exactly as described here: http://www.zarafa.com/wiki/index.php/Installing_Zarafa_from_packages

## zarafa::zarafa-gateway
Enables TLS on zarafa-gateway. This is used for port 145 (imap) TLS connections.

## zarafa::z-push
Install and activate ActiveSync on Zarafa Server
**For more see http://www.zarafa.com/content/mobility**


# Usage
- set all attributes mentioned above
- run ```zarafa::default```
- login to server and do
```bash
sudo /usr/bin/zarafa-admin -c test -p password -e test@example.com -f "Zarafa Test"
```

# Contact
see metadata.rb

# TODO
- fix vmail (mailbox transport or virtual boxes)
