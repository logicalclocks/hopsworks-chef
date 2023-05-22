action :create_ssh_nodes do 
  asadmin_cmd=new_resource.asadmin_cmd
  payara_config=new_resource.payara_config
  domain_name=new_resource.domain_name
  password_file=new_resource.password_file
  username=new_resource.username
  admin_port=new_resource.admin_port
  nodedir=new_resource.nodedir
  glassfish_user_home=new_resource.glassfish_user_home
  ssh_nodes=new_resource.nodes

  count_nodes_cmd="#{asadmin_cmd} list-nodes | wc -l"
  ssh_nodes.each do |val|
    glassfish_asadmin "create-node-ssh --nodehost #{val} --installdir #{node['glassfish']['base_dir']}/versions/current --nodedir #{nodedir} --sshkeyfile #{glassfish_user_home}/.ssh/id_ed25519 worker$(#{count_nodes_cmd})" do
      domain_name domain_name
      password_file password_file
      username username
      admin_port admin_port
      secure false
      not_if "#{asadmin_cmd} list-nodes -l | grep #{val}"
    end
    # count node will not work here b/c we might have created a new node 
    worker_name_cmd = "#{asadmin_cmd} list-nodes -l | grep #{val} | awk '{print $1}'"
    index_cmd="#{worker_name_cmd} | awk -F'[^0-9]*' '$0=$2'"
    glassfish_asadmin "create-instance --config #{payara_config} --node $(#{worker_name_cmd}) instance$(#{index_cmd})" do
      domain_name domain_name
      password_file password_file
      username username
      admin_port admin_port
      secure false
      not_if "#{asadmin_cmd} list-instances -l | grep #{val}"
    end

    instance_name_cmd="#{asadmin_cmd} list-instances -l | grep #{val} | awk '{print $1}'"
    glassfish_asadmin "create-system-properties --target $(#{instance_name_cmd}) hazelcast.local.publicAddress=#{val}" do
      domain_name domain_name
      password_file password_file
      username username
      admin_port admin_port
      secure false
      not_if "#{asadmin_cmd} list-system-properties $(#{instance_name_cmd}) | grep hazelcast.local.publicAddress=#{val}"
    end
  end
end

action :create_config_nodes do 
  asadmin_cmd=new_resource.asadmin_cmd
  payara_config=new_resource.payara_config
  domain_name=new_resource.domain_name
  password_file=new_resource.password_file
  username=new_resource.username
  admin_port=new_resource.admin_port
  nodedir=new_resource.nodedir
  config_nodes=new_resource.nodes

  count_nodes_cmd="#{asadmin_cmd} list-nodes | wc -l"
  config_nodes.each do |val| 
    glassfish_asadmin "create-node-config --nodehost #{val} --installdir #{node['glassfish']['base_dir']}/versions/current --nodedir #{nodedir} worker$(#{count_nodes_cmd})" do
      domain_name domain_name
      password_file password_file
      username username
      admin_port admin_port
      secure false
      not_if "#{asadmin_cmd} list-nodes -l | grep #{val}"
    end
  end
end