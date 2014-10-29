name             "zarafa"
maintainer       "computerlyrik"
maintainer_email "chef-cookbooks@computerlyrik.de"
license          "Apache 2.0"
description      "Installs/Configures zarafa"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          "3.1.0"

%w(ubuntu debian).each do |os|
  supports os
end

depends 'mysql', '>= 5.3.6'
%w(openssl database ark apache2 postfix certificate).each do |dep|
  depends dep
end
