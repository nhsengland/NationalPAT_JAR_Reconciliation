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

#### 🔴 NEW  
📝 National JAR methodology - Admitted Patient Care Episodes script - SUSLive (Provider) *The SUS Live Episodes is not the source table used for the monthly published table, therefore will provide episode-level data and will remain within a 1% tolerance of the PAT tables.*    
📝 National JAR methodology - Admitted Patient Care Spells script - SUSLive (Provider)   
📝 National JAR methodology - Outpatient Attendance script - SUSLive (Provider)  

#### Commissioner Focus
📝 National JAR methodology - Accident and Emergency Attendance script - Comm  
📝 National JAR methodology - Admitted patient care script - Comm  
📝 National JAR methodology - Outpatient Attendance script - Comm  

### About the Scripts
🚑 **Accident and Emergency Attendance script**  
*This script covers Emergency Care attendances, sourced from the National PAT Intermediate EC SUS table*  

🏥 **Admitted patient care script**  
*This script covers both elective and non-elective hospital activity, sourced from the National PAT Intermediate Admitted Patient Care SUS table*  

👨‍⚕️ **Outpatient Attendance script**  
*This script covers Outpatient attendances, sourced from the National PAT Intermediate OP SUS table*  

💰 **Unit Cost and Activity Weighting**  
*This script provides a high-level overview of PoDs included in the EC, OP and APC outputs. It connects to the NHSE_Sandbox_Operations_Production repository to incorporate National Reference Costs (currently 2017-18) for reconciling cost-weighted activity outputs (Provider only).*

### Built With SQL in NCDR (National Reporting has not moved over to UDAL yet - ETA May). 

🛢️[SQL SSMS](https://learn.microsoft.com/en-us/sql/ssms/download-sql-server-management-studio-ssms?view=sql-server-ver16)  
🖲️[NCDR](https://rdsweb101.gemcsu.nhs.uk/RDWeb/Pages/en-US/login.aspx?ReturnUrl=%2fRDWeb%2fPages%2frdp%2fcpub-NHSE_-_Analysts-NHSE_-_Analysts-CmsRdsh.rdp)


#### Datasets in the NHSE_SUSPlus_Reporting Repository on NCDR - (Home of the Official JAR Monthly Published reporting tables)
  
🛢️ PAT_Intermediate_Table_AE  
🛢️ PAT_Intermediate_Table_APC  
🛢️ PAT_Intermediate_Table_OP

#### Datasets in the NHSE_SUSPlus_Reporting Repository on NCDR - (Home of the SUS+ Live tables - Source for the Monthly Published reporting tables)

🛢️ tbl_Data_SEM_APCE  
🛢️ tbl_Data_SEM_OPA

### Contact

To find out more about the South West Intelligence and Insights Team visit our [South West Intelligence and Insights Team Futures Page](https://future.nhs.uk/SouthWestAnalytics)) or get in touch at [england.southwestanalytics@nhs.net](mailto:england.southwestanalytics@nhs.net). Alternatively, Please feel free to reach out to me directly:

📧 Email: [Destiny.Bradley@nhs.net](mailto:Destiny.Bradley@nhs.net)  
💬 Teams: [Join my Teams](https://teams.microsoft.com/l/chat/0/0?users=<destiny.bradley@nhs.net)

### Acknowledgements
Thanks to Bernardo Detanico for his ongoing support in applying National Logic.

