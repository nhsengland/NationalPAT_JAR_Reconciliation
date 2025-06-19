# National PAT - JAR Reconciliation - South West
## NHS England South West Intelligence and Insights

### What is the JAR/Activity and Planning Summary Report?

The FY24/25 Activity and Planning Summary Report provides an analysis of delivered activity by activity type together with trend information to assess changes in activity through time based on FY24/25 planning definitions. The report has been developed to allow the focus of the report to be switched between differing commissioning and provider responsibilities and geographies using the interactive functionality.

This is published on Futures: [National JAR Report](https://future.nhs.uk/OIforC/view?objectId=237850917)

### Scripts

#### Provider Focus
📝 National JAR methodology - Accident and Emergency Attendance script - Provider  
📝 National JAR methodology - Admitted patient care script - Provider  
📝 National JAR methodology - Outpatient Attendance script - Provider  
📝 National JAR methodology - Unit Cost and Activity Weighting - Provider 

#### 🔴 NEW - All scripts now migrated to UDAL and NCDR scripts removed
📝 National JAR methodology - Admitted Patient Care Episodes script - SUSLive (Provider) *- The SUS Live Episodes is not the source table used for the monthly published table, therefore will provide episode-level data and will remain within a 1% tolerance of the PAT tables.*   
📝 National JAR methodology - Admitted Patient Care Spells script - SUSLive (Provider)   
📝 National JAR methodology - Outpatient Attendance script - SUSLive (Provider)  

#### Commissioner Focus
📝 Modify scripts to use Pat_Commissioner or Der_Commissioner_codes and use CCG codes to pull Commissioner footprint, update where clause bring in local commissioner codes and update provider hieraches join to the commissioner hieraches table

### About the Scripts
🚑 **Accident and Emergency Attendance script**  
*This script covers Emergency Care attendances, sourced from the National PAT Intermediate EC SUS table*  

🏥 **Admitted patient care script**  
*This script covers both elective and non-elective hospital activity, sourced from the National PAT Intermediate Admitted Patient Care SUS table*  

👨‍⚕️ **Outpatient Attendance script**  
*This script covers Outpatient attendances, sourced from the National PAT Intermediate OP SUS table*  

💰 **Unit Cost and Activity Weighting** *- this has not been updated just yet M2 will be the release date of the 2324 reference costs, we currently do not have access to this data*
*This script provides a high-level overview of PoDs included in the EC, OP and APC outputs. It connects to the NHSE_Sandbox_Operations_Production repository to incorporate National Reference Costs (currently 2017-18) for reconciling cost-weighted activity outputs (Provider only).*

### Built With SQL in UDAL *(why not use databricks? Parquet locations added below)*

🛢️[SQL SSMS](https://learn.microsoft.com/en-us/sql/ssms/download-sql-server-management-studio-ssms?view=sql-server-ver16)  
🖲️[UDAL](https://rdweb.wvd.microsoft.com/)  
🧱[Databricks](Databricks)
	
#### 🖲️ Datasets in the UDAL Warehouse Repository on UDAL

**Monthly Published**  
🛢️ [UDALSQLMART_PatActivity].[PAT_Intermediate_Table_AE] (JAR Source)  
🛢️ [UDALSQLMART_PatActivity].[PAT_Intermediate_Table_APC] (JAR Source)  
🛢️ [UDALSQLMART_PatActivity].[PAT_Intermediate_Table_OP] (JAR Source)  

**Monthly Live**  
🛢️ [Reporting_MESH_APC].[APCE_Core_Union]  
🛢️ [Reporting_MESH_APC].[APCS_Core_Union]  
🛢️ [Reporting_MESH_APC].[OPA_Core_Union]  

**Weekly SUS** *This is actualy Daily SUS, we call it weekly because the ISN requires a submission every week, but providers can submit everyday should they want to*  
🛢️ [MESH_OPA].[APCE_Core_Daily]  
🛢️ [MESH_OPA].[APCS_Core_Daily]  
🛢️ [MESH_OPA].[OPA_Core_Daily]  

#### 🧱 Parquets in the Lake on Databricks - *Minor ammendments to scripts will be required to make them capatible for SQL spark*

**Monthly Published - JAR SOURCE**  
🛢️"abfss://restricted@udalstdatacuratedprod.dfs.core.windows.net/patientlevel/UDALSQLMART/PatActivity/PAT_Intermediate_Table_AE/"	
🛢️"abfss://restricted@udalstdatacuratedprod.dfs.core.windows.net/patientlevel/UDALSQLMART/PatActivity/PAT_Intermediate_Table_APC/" 	
🛢️"abfss://restricted@udalstdatacuratedprod.dfs.core.windows.net/patientlevel/UDALSQLMART/PatActivity/PAT_Intermediate_Table_OP/"	

**Monthly Live**  
🛢️"abfss://reporting@udalstdatacuratedprod.dfs.core.windows.net/restricted/patientlevel/MESH/APC/APCE_Core_Union/"  
🛢️"abfss://reporting@udalstdatacuratedprod.dfs.core.windows.net/restricted/patientlevel/MESH/APC/APCS_Core_Union/"  
🛢️"abfss://reporting@udalstdatacuratedprod.dfs.core.windows.net/restricted/patientlevel/MESH/OPA/OPA_Core_Union/"  

**Weekly SUS** *This is actualy Daily SUS, we call it weekly because the ISN requires a submission every week, but providers can submit everyday should they want to*  
🛢️"abfss://restricted@udalstdatacuratedprod.dfs.core.windows.net/patientlevel/MESH/APC/APCE_Core_Daily/"  
🛢️"abfss://restricted@udalstdatacuratedprod.dfs.core.windows.net/patientlevel/MESH/APC/APCS_Core_Daily/"  
🛢️"abfss://restricted@udalstdatacuratedprod.dfs.core.windows.net/patientlevel/MESH/OPA/OPA_Core_Daily/"  

### Contact

To find out more about the South West Intelligence and Insights Team visit our [South West Intelligence and Insights Team Futures Page](https://future.nhs.uk/SouthWestAnalytics)) or get in touch at [england.southwestanalytics@nhs.net](mailto:england.southwestanalytics@nhs.net). Alternatively, Please feel free to reach out to me directly:

📧 Email: [Destiny.Bradley@nhs.net](mailto:Destiny.Bradley@nhs.net)  
💬 Teams: [Join my Teams](https://teams.microsoft.com/l/chat/0/0?users=<destiny.bradley@nhs.net)

### Acknowledgements
Thanks to Bernardo Detanico for his ongoing support in applying National Logic.

