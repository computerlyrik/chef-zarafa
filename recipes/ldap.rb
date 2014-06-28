template "/etc/zarafa/ldap.cfg" do
  variables ({:ldap_server => ldap_server})
  notifies :restart, "service[zarafa-server]"
  only_if { node['zarafa']['backend_type'] == 'ldap' }
end

