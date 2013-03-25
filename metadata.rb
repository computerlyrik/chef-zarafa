maintainer       "computerlyrik"
maintainer_email "chef-cookbooks@computerlyrik.de"
license          "Apache 2.0"
description      "Installs/Configures zarafa"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          "1.3.0"


%w{ ubuntu debian }.each do |os|
  supports os
end

%w{ openssl database openldap clamav dspam }.each do |dep|
  depends dep
end
