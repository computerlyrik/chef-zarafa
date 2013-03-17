##CONFIGURE Z-PUSH############################################

#get and untar z-push
#template "/usr/share/z-push/config.php" => set timezone

#TODO verify and setup installation process
# TODO implement update process with notifies
#remote_file "#{Chef::Config[:file_cache_path]}/z-push-2.0.7-1690.tar.gz" do
#  source "http://zarafa-deutschland.de/z-push-download/final/2.0/z-push-2.0.7-1690.tar.gz"
#  #checksum node['z-push']['checksum']
#  mode "0644"
#end

#bash "get & install-z-push" do
#  cwd Chef::Config[:file_cache_path]
#  code <<-EOF
#tar -xvf z-push-2.0.7-1690.tar.gz
#(mkdir -p /usr/share/z-push && cp -R z-push-2.0.7-1690/* /usr/share/z-push)
#EOF
#end

template "/usr/share/z-push/config.php" do
  notifies :restart, resources(:service=>"zarafa-server")
end

directory "/var/lib/z-push" do
  mode 0755
  owner "www-data"
  group "www-data"
end

directory "/var/log/z-push" do
  mode 0755
  owner "www-data"
  group "www-data"
end

template "/etc/apache2/conf.d/z-push" do
  notifies :reload, resources(:service=>"apache2")
end

