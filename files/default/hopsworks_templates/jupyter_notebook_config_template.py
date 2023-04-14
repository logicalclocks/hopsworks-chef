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

# hopsfs-mount does not support xattr. If we save the file then we loose the xattr info of the notebook
# We need to put back the xattr after saving the notebook.
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
        except ImportError as err:
            logging.error(err)
            return
        if 'hops.util' in sys.modules:
            kernel_id = get_notebook_kernel_id(relative_path)
            logging.info("Kernel id is " + kernel_id)
            if kernel_id != "":
                try:
                    util.attach_jupyter_configuration_to_notebook(kernel_id)
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
        import os.path
        import re
        import logging
        try:
            from requests.compat import urljoin
            from notebook.notebookapp import list_running_servers
            from hops import util
            from hops import constants as hops_constants
        except ImportError as e:
            logging.error(e)
            return ""
        for srv in list_running_servers():
            resource_url = srv['base_url'] + "api/sessions?token=" + srv.get('token', '')
            method = hops_constants.HTTP_CONFIG.HTTP_GET
            headers = {hops_constants.HTTP_CONFIG.HTTP_CONTENT_TYPE: hops_constants.HTTP_CONFIG.HTTP_APPLICATION_JSON}
            response = util.send_request(method, resource_url, headers=headers)
            response_object = response.json()
            if response.status_code >= 400:
                error_code, error_msg, user_msg = util._parse_rest_error(response_object)
                logging.log("Failed to get active sessions".format(resource_url, response.status_code, response.reason,
                                                                   error_code, error_msg, user_msg))
                return ""
            for session in response_object:
                if session['notebook']['path'] == path:
                    return session['kernel']['id']
    return ""

c.FileContentsManager.post_save_hook = script_post_save

