# This is a Chef recipe file. It can be used to specify resources which will
# apply configuration to a server.

include_recipe 'audit::default'

log "Welcome to Chef, #{node["starter_name"]}!" do
  level :info
end

file '/etc/helloworld.txt' do
  content 'helloworld'
  owner 'root'
  group 'root'
  mode '0755'
  action :create
end



# For more information, see the documentation: https://docs.chef.io/essentials_cookbook_recipes.html
