# configuration for contents manager
c.HDFSContentsManager.hdfs_namenode_host='${conf.namenodeIp}'
c.HDFSContentsManager.hdfs_namenode_port=${conf.namenodePort}
c.HDFSContentsManager.root_dir='${conf.baseDirectory}'
c.HDFSContentsManager.hdfs_user = '${conf.hdfsUser}'
c.HDFSContentsManager.hadoop_client_env_opts = '-D fs.permissions.umask-mode=0002'

c.NotebookApp.contents_manager_class = '${conf.contentsManager}'