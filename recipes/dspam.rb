
include_recipe "dspam"


node.set["clamav"]["clamd"]["tcp_socket"] = 3310
node.set["clamav"]["clamd"]["tcp_addr"] = "127.0.0.1"
include_recipe "clamav"

#template "/etc/dspam/dspam.conf"

template "/etc/postfix/dspam_filter_access" do
  notifies :restart, resources(:service => "postfix")
end


template "/etc/postfix/master.cf" do
  notifies :restart, resources(:service => "postfix")
end


template "/etc/dspam/dspam.conf" do
  notifies :restart, resources(:service => "dspam")
  notifies :restart, resources(:service => "postfix")
end

