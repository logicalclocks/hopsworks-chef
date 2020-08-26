import airflow

from datetime import datetime, timedelta
from airflow import DAG

from hopsworks_plugin.operators.hopsworks_operator import HopsworksLaunchOperator
from hopsworks_plugin.operators.hopsworks_operator import HopsworksFeatureValidationResult
from hopsworks_plugin.sensors.hopsworks_sensor import HopsworksJobSuccessSensor

# Username in Hopsworks
# Click on Account from the top right drop-down menu
DAG_OWNER = '${dag.owner}'

# Project name this DAG belongs to
PROJECT_NAME = '${dag.projectName}'


####################
## DAG definition ##
####################
delta = timedelta(minutes=-10)
now = datetime.now()

args = {
    'owner': DAG_OWNER,
    'depends_on_past': False,

    # DAG should have run 10 minutes before now
    # It will be automatically scheduled to run
    # when we upload the file in Hopsworks
    'start_date': now + delta,

    # Uncomment the following line if you want Airflow
    # to authenticate to Hopsworks using API key
    # instead of JWT
    #
    # NOTE: Edit only YOUR_API_KEY
    #
    <#if dag.apiKey??>'params': {'hw_api_key': '${dag.apiKey}'}</#if>
}

# Our DAG
dag = DAG(
    # Arbitrary identifier/name
    dag_id = "${dag.id}",
    default_args = args,

    # Run the DAG only one time
    # It can take Cron like expressions
    # E.x. run every 30 minutes: */30 * * * * 
    <#if dag.scheduleInterval??>schedule_interval = "${dag.scheduleInterval}"</#if>
)


<#list dag.operators>
 <#items as operator>

  <#if instanceOf(operator, AirflowJobLaunchOperator)>
${operator.id} = HopsworksLaunchOperator(dag=dag,
					 project_name="${operator.projectName}",
					 task_id="${operator.id}",
					 job_name="${operator.jobName}",
					 job_arguments="${operator.jobArgs}",
					 wait_for_completion=<#if operator.wait>True<#else>False</#if>)
					 
  <#elseif instanceOf(operator, AirflowJobSuccessSensor)>
${operator.id} = HopsworksJobSuccessSensor(dag=dag,
					   project_name="${operator.projectName}",
                                   	   task_id="${operator.id}",
                                   	   job_name="${operator.jobName}")

 <#elseif instanceOf(operator, AirflowFeatureValidationResultOperator)>
${operator.id} = HopsworksFeatureValidationResult(dag=dag,
					          project_name="${operator.projectName}",
                                   	          task_id="${operator.id}",
                                   	          feature_group_name="${operator.featureGroupName}")
  </#if>
 </#items>
</#list>


<#list dag.operators>
 <#items as operator>
  <#if operator.upstream??>
${operator.id}.set_upstream(${operator.upstream})
  </#if>
 </#items>
</#list>
