c = get_config()

<#if instanceOf(conf.remoteFSDriver, HDFSContentsRemoteDriver)>
c.HDFSContentsManager.hdfs_namenode_host='${conf.remoteFSDriver.namenodeIp}'
c.HDFSContentsManager.hdfs_namenode_port=${conf.remoteFSDriver.namenodePort}
c.HDFSContentsManager.root_dir='${conf.remoteFSDriver.baseDirectory}'
c.HDFSContentsManager.hdfs_user = '${conf.remoteFSDriver.hdfsUser}'
c.HDFSContentsManager.hadoop_client_env_opts = '-D fs.permissions.umask-mode=0002'
c.NotebookApp.contents_manager_class = '${conf.remoteFSDriver.contentsManager}'
</#if>

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

# memory
c.ResourceUseDisplay.mem_limit = ${conf.allocatedNotebookMBs?c}*1024*1024

# cpu
c.ResourceUseDisplay.track_cpu_percent = True
c.ResourceUseDisplay.cpu_limit = ${conf.allocatedNotebookCores?c}

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

c.FileCheckpoints.checkpoint_dir='${conf.secretDirectory}'

import os
os.environ['REST_ENDPOINT'] = "${conf.hopsworksEndpoint}"
os.environ['ELASTIC_ENDPOINT'] = "${conf.elasticEndpoint}"
os.environ['HADOOP_USER_NAME'] = "${conf.hdfsUser}"
os.environ['JUPYTER_CERTS_DIR'] = "${conf.jupyterCertsDirectory}"
os.environ['HOPSWORKS_PROJECT_ID'] = "${conf.project.id?c}"
os.environ['REQUESTS_VERIFY'] = "${conf.requestsVerify?c}"
os.environ['DOMAIN_CA_TRUSTSTORE'] = "${conf.domainCATruststore}"
os.environ['HADOOP_HOME'] = "${conf.hadoopHome}"
os.environ['SERVICE_DISCOVERY_DOMAIN'] = "${conf.serviceDiscoveryDomain}"
# hopsworks hostname
os.environ['HOPSWORKS_PUBLIC_HOST'] = "${conf.hopsworksPublicHost}"

<#if conf.kafkaBrokers?has_content>
os.environ['KAFKA_BROKERS'] = "${conf.kafkaBrokers}"
</#if>

os.environ['SECRETS_DIR'] = "${conf.secretDirectory}"

os.environ['HADOOP_CLASSPATH_GLOB'] = "${conf.hadoopClasspathGlob}"
os.environ['HADOOP_LOG_DIR'] = "/tmp"


<#if instanceOf(conf.remoteFSDriver, HopsfsMountRemoteDriver)>
# hopsfs-mount does not support xattr. If we save the file then we loose the xattr information of the notebook
# We need to put back the xattr after saving the notebook.
import concurrent.futures
notebook_save_thread_pool = concurrent.futures.ThreadPoolExecutor(max_workers=7)

def notebook_post_save_hook(model, os_path, contents_manager, **kwargs):
    # only run on notebooks
    if model['type'] != 'notebook':
        return
    try:
        import sys
        import threading
        from hops import util
        if 'hops.util' in sys.modules:
            notebook_save_thread_pool.submit(util.notebook_post_save, os_path.replace(os.environ["JUPYTER_DATA_DIR"], ""))
    except Exception as err:
        return

c.FileContentsManager.post_save_hook = notebook_post_save_hook

c.NotebookNotary.data_dir = "${conf.secretDirectory}"
</#if>

