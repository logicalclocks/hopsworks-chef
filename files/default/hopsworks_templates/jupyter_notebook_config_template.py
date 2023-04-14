c = get_config()

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

def script_post_save(model, os_path, contents_manager, **kwargs):
    """scrub output before saving notebooks"""
    # only run on notebooks
    if model['type'] != 'notebook':
        return
    if os.environ['JUPYTER_HOPSFS_MOUNT']:
        import sys
        import logging
        import re
        relative_path = re.sub("/proc/\d+/root/home/yarnapp/" + os.environ['HADOOP_USER_NAME'] + "/", "", os_path)
        logging.info("Attaching notebook configuration to file " + relative_path)
        try:
            from hops import util
        except ImportError:
            logging.error("Failed to import hops-util in notebook post save hook.")
            return
        if 'hops.util' in sys.modules:
            kernel_id = get_notebook_kernel_id(relative_path)
            if kernel_id != "":
                try:
                    util.attach_jupyter_configuration_to_notebook(kernel_id=kernel_id)
                except Exception as e:
                    logging.error("Failed to attach notebook configuration: " + e.message)
            else:
                logging.error("No kernel id for notebook " + relative_path)
        else:
            return
def get_notebook_kernel_id(path):
    """
    Return the full path of the jupyter notebook.
    """
    if path != "":
        import json
        import os.path
        import re
        import requests
        import logging
        try:
            from requests.compat import urljoin
            from notebook.notebookapp import list_running_servers
        except ImportError as e:
            logging.log("Failed to import some stuff " + e.message)
            return ""
        servers = list_running_servers()
        for ss in servers:
            response = requests.get(urljoin(ss['url'], 'api/sessions'), params={'token': ss.get('token', '')})
            for nn in json.loads(response.text):
                if nn['notebook']['path'] == path:
                    return nn['kernel']['id']
    return ""

c.FileContentsManager.post_save_hook = script_post_save
