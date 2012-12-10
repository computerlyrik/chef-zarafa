maintainer       "YOUR_COMPANY_NAME"
maintainer_email "YOUR_EMAIL"
license          "All rights reserved"
description      "Installs/Configures zarafa"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          "1.1.0"


%w{ ubuntu debian }.each do |os|
  supports os
end

%w{ openssl database openldap }.each do |dep|
  depends dep
end
