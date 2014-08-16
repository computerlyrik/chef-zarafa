name             "zarafa"
maintainer       "computerlyrik"
maintainer_email "chef-cookbooks@computerlyrik.de"
license          "Apache 2.0"
description      "Installs/Configures zarafa"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          "2.9.2"

%w(ubuntu debian).each do |os|
  supports os
end

%w(openssl database mysql ark apache2 postfix certificate).each do |dep|
  depends dep
end
