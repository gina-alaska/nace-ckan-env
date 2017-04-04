source 'https://supermarket.chef.io'
source :chef_server

def local_cookbook(name)
  cookbook name, path: "cookbooks/#{name}"
end

cookbook 'gina-server'
local_cookbook 'nace-ckan'
local_cookbook 'nace_ckan_app'

# TODO: migrate other ogc cookbooks
# local_cookbook 'gina_ws_wms'
# local_cookbook 'gina_ws_tiles'
