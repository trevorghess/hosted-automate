# See http://docs.chef.io/config_rb_knife.html for more information on knife configuration options

current_dir = File.dirname(__FILE__)
log_level                :info
log_location             STDOUT
node_name                "[[YOUR NODE NAME]]"
client_key               "#{current_dir}/[[YOUR NODE NAME]].pem"
chef_server_url          "https://api.chef.io/organizations/[[YOUR HOSTED ORG]]"
cookbook_path            ["#{current_dir}/../cookbooks"]
data_collector.server_url "https://[[YOUR AUTOMATE URL]]/data-collector/v0/"
data_collector.token "[[YOUR DATA COLLECTOR TOKEN]]"
