action :create_timers do
  exec = "#{node['ndb']['scripts_dir']}/mysql-client.sh"

  bash 'create_timers_tables' do
    user "root"
    code <<-EOF
      set -e
      #{exec} -e \"CREATE DATABASE IF NOT EXISTS glassfish_timers CHARACTER SET latin1\"
      #{exec} -e \"GRANT ALL PRIVILEGES ON glassfish_timers.* TO \'#{node['hopsworks']['mysql']['user']}\'@\'127.0.0.1\';\"
      #{exec} glassfish_timers < #{new_resource.tables_path}
    EOF
    not_if "#{exec} -e 'show databases' | grep glassfish_timers"
  end

end
