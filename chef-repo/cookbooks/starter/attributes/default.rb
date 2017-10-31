# This is a Chef attributes file. It can be used to specify default and override
# attributes to be applied to nodes that run this cookbook.

# Set a default name
default['starter_name'] = 'Sam Doe'
default['audit']['reporter'] = 'chef-automate'
default['audit']['fetcher'] = 'chef-automate'
default['audit']['profiles'] = [
      {
        'name' => 'cis-ubuntu16.04lts-level1-server',
        'compliance' => '[[YOUR AUTOMATE USER]]/cis-ubuntu16.04lts-level1-server',
        'version' => '0.1.0'
      }
    ]

# For further information, see the Chef documentation (https://docs.chef.io/essentials_cookbook_attribute_files.html).
