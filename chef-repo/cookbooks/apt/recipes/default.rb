if node['platform'] == 'debian' || node['platform'] == 'ubuntu'
 execute "apt-get update" do
   command "apt-get update"
 end