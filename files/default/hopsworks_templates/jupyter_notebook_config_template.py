c = get_config()
c.HDFSContentsManager.hdfs_namenode_host='${conf.namenodeIp}'
c.HDFSContentsManager.hdfs_namenode_port=${conf.namenodePort}
c.HDFSContentsManager.root_dir='/Projects/${conf.project.name}${conf.baseDirectory}'
c.HDFSContentsManager.hdfs_user = '${conf.hdfsUser}'
c.HDFSContentsManager.hadoop_client_env_opts = '-D fs.permissions.umask-mode=0002'

c.NotebookApp.contents_manager_class = '${conf.contentsManager}'

c.NotebookApp.ip = '127.0.0.1'
c.NotebookApp.open_browser = False

c.NotebookApp.notebook_dir = '${conf.secretDirectory}'

c.NotebookApp.port_retries = 0
c.NotebookApp.port = ${conf.port?c}

# This is needed for Google Facets
# https://github.com/pair-code/facets
c.NotebookApp.iopub_data_rate_limit=10000000

c.NotebookApp.base_url='/hopsworks-api/jupyter/${conf.port?c}/'
c.Application.log_level="WARN"
c.JupyterConsoleApp.kernel_name="PySpark"

c.KernelSpecManager.whitelist = {${conf.whiteListedKernels}}
c.KernelSpecManager.ensure_native_kernel=False

#Available kernels:
#  sparkkernel                   /usr/local/share/jupyter/kernels/sparkkernel
#  pysparkkernel                 /usr/local/share/jupyter/kernels/pysparkkernel
#  pyspark3kernel                /usr/local/share/jupyter/kernels/pyspark3kernel
#  sparkrkernel                  /usr/local/share/jupyter/kernels/sparkrkernel
#  python2                       /usr/local/share/jupyter/kernels/python-kernel

c.NotebookApp.allow_origin = '${conf.allowOrigin}'
c.NotebookApp.tornado_settings = {
    'ws_ping_interval': ${conf.wsPingInterval?c},
    'headers': {
        'Content-Security-Policy': "frame-ancestors 'self' "
    }
}


import os
os.environ['REST_ENDPOINT'] = "${conf.hopsworksEndpoint}"
os.environ['ELASTIC_ENDPOINT'] = "${conf.elasticEndpoint}"
os.environ['HADOOP_USER_NAME'] = "${conf.hdfsUser}"
os.environ['JUPYTER_CERTS_DIR'] = "${conf.jupyterCertsDirectory}"
os.environ['HOPSWORKS_PROJECT_ID'] = "${conf.project.id}"
os.environ['REQUESTS_VERIFY'] = "${conf.requestsVerify?c}"
os.environ['DOMAIN_CA_TRUSTSTORE_PEM'] = "${conf.domainCATruststorePem}"
os.environ['HADOOP_HOME'] = "${conf.hadoopHome}"
os.environ['SERVICE_DISCOVERY_DOMAIN'] = "${conf.serviceDiscoveryDomain}"

c.GitHandlersConfiguration.api_key = "${conf.apiKey}"
os.environ['FLINK_CONF_DIR'] = "${conf.flinkConfDirectory}"
