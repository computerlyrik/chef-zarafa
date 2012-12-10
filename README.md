Description
===========

Setup Zarafa to 
- sync your Android/i/Windows Phone (ActiveSync)
- have eMail push
- receive and send emails via imap
- Webinterface to manage all

Requirements
============

mysql and database cookbook

modified openldap_cookbook reachable at ...TODO

Attributes
==========

Set up a catchall user with
node['zarafa']['catchall'] = "mail@mydomain.com"

Usage
=====

run recipe



