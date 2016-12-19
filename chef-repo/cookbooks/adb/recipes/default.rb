
include_recipe "apt"


package 'android-tools-adb' do
  action :install
  not_if { node['platform'] == 'centos' }
end

file '/bin/adb' do
  mode '0755'
  group 'root'
  owner 'root'
end

cookbook_file "/etc/init.d/adb" do
  owner node[:adb][:user]
  group node[:adb][:group]
  mode 00755
end

bash 'export_thermal_values' do
  code <<-EOH
    mkdir /home/szypekwsp/Thermal_measures
    adb shell ls sys/class/thermal/
    for f in *; do adb shell cat sys/class/thermal/$f/temp >> /home/szypekwsp/Thermal_measures/$f; done  
  EOH
  creates "/usr/local/bin/adb-server"
end

service 'adb' do
  provider Chef::Provider::Service::Upstart
  subscribes :restart, resources(:bash => "export_thermal_values")
  supports :restart => true, :start => true, :stop => true
end

execute 'battery_temperature' do
  command "adb shell dumpsys battery >> /home/szypekwsp/Thermal_measures/battery_temperature.txt && sed -n '/temperature/,/technology/p' /home/szypekwsp/Thermal_measures/battery_temperature.txt" && sed -i '1s/^/temperature: \n/' /home/szypekwsp/Thermal_measures/battery_temperature.txt
end

service 'adb' do
  supports :status => true
  action [ :enable, :start ]
end
