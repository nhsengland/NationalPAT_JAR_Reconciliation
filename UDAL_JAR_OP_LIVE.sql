SELECT 	
 
-- For assurance, we add in a case statement on Provider codes to make sure that all mergers are correctly captured
 
	 CASE WHEN op.Der_Provider_Code = 'RD3' THEN 'R0D'
	 WHEN op.Der_Provider_Code = 'RDZ' THEN 'R0D'
	 WHEN op.Der_Provider_Code = 'RBZ' THEN 'RH8'
	 WHEN op.Der_Provider_Code = 'RA3' THEN 'RA7'
	 WHEN op.Der_Provider_Code = 'RBA' THEN 'RH5'
	 WHEN op.Der_Provider_Code = 'R1G' THEN 'RA9'
	 WHEN op.Der_Provider_Code = 'RVJ13' THEN 'RVJ'
	 WHEN op.Der_Provider_Code = 'RA4' THEN 'RH5'
	 ELSE op.Der_Provider_Code END AS 'Der_Provider_Code'

-- For assurance, we add in a case statement on Provider names to make sure that all mergers and name changes are correctly captured

     ,CASE WHEN o.organisation_name = 'ROYAL DEVON AND EXETER NHS FOUNDATION TRUST' THEN 'ROYAL DEVON UNIVERSITY HEALTHCARE NHS FOUNDATION TRUST'
	 WHEN o.organisation_name  = 'TAUNTON AND SOMERSET NHS FOUNDATION TRUST' THEN 'SOMERSET NHS FOUNDATION TRUST'
	 WHEN o.organisation_name  = 'NORTHERN DEVON HEALTHCARE NHS TRUST' THEN 'ROYAL DEVON UNIVERSITY HEALTHCARE NHS FOUNDATION TRUST'
	 WHEN o.organisation_name  = 'THE ROYAL BOURNEMOUTH AND CHRISTCHURCH HOSPITALS NHS FOUNDATION TRUST' THEN 'UNIVERSITY HOSPITAL DORSET NHS FOUNDATION TRUST'
	 WHEN o.organisation_name  = 'POOLE HOSPITAL NHS FOUNDATION TRUST' THEN 'UNIVERSITY HOSPITAL DORSET NHS FOUNDATION TRUST'
	 WHEN o.organisation_name  = 'TORBAY AND SOUTHERN DEVON HEALTH AND CARE NHS TRUST' THEN 'TORBAY AND SOUTH DEVON NHS FOUNDATION TRUST'
	 When o.organisation_name = 'EMERSONS GREEN NHS TREATMENT CENTRE' THEN 'NORTH BRISTOL NHS TRUST'
	 When o.organisation_name = 'YEOVIL DISTRICT HOSPITAL NHS FOUNDATION TRUST' THEN 'SOMERSET NHS FOUNDATION TRUST'	 
	 When o.Organisation_Name = 'UNIVERSITY HOSPITALS BRISTOL NHS FOUNDATION TRUST' then 'UNIVERSITY HOSPITALS BRISTOL AND WESTON NHS FOUNDATION TRUST'
	 ELSE o.organisation_name  END AS 'organisation_name'
 
-- System names for the Provider
 
	,o.STP_Name
 
-- Isolate the Treatment Function Code and name the column appropriately
	,op.Treatment_Function_Code as 'TFC'
 
-- Isolate the HRG and name the column appropriately
 
	,op.Core_HRG as 'HRG'
-- This column identifies the Commissioner_Type (ICB commissioned Activity etc.)
 
	,Centralised = CASE WHEN Der2425.Responsible_Purchaser_Assignment_Method IN ('Sub-ICB (Host Mapped)', 'Sub-ICB (Practice Mapped)', 'Sub-ICB (Postcode Mapped)','Sub-ICB (Provider Supplied)') THEN 'ICB Commissioned'
WHEN Der2425.Responsible_Purchaser_Assignment_Method IN ('NHSE (Contracted Specialised)', 'NHSE (NCA Specialised)','Sub-ICB (Host Mapped) (Delegated Spec Comm)','Sub-ICB (Host Mapped) (Delegated Spec Comm) (Delegated Sec Dent)','Sub-ICB (Postcode Mapped) (Delegated Spec Comm)','Sub-ICB (Postcode Mapped) (Delegated Spec Comm) (Delegated Sec Dent)','Sub-ICB (Practice Mapped) (Delegated Spec Comm)','Sub-ICB (Practice Mapped) (Delegated Spec Comm) (Delegated Sec Dent)','NHSE (Offender Health) (Delegated Spec Comm)','NHSE (Offender Health) (Delegated Spec Comm) (Delegated Sec Dent)','NHSE (Military Personnel) (Delegated Spec Comm)') Then 'Spec Comm'
WHEN Der2425.Responsible_Purchaser_Assignment_Method IN ('Sub-ICB (Host Mapped) (Delegated Sec Dent)', 'Sub-ICB (Practice Mapped) (Delegated Sec Dent)', 'Sub-ICB (Postcode Mapped) (Delegated Sec Dent)') Then 'Delegated Sec Dent'
WHEN Der2425.Responsible_Purchaser_Assignment_Method = 'NHSE (Secondary Dental)' Then 'Secondary Dental'
WHEN Der2425.Responsible_Purchaser_Assignment_Method IN ('NHSE (Military Personnel)','NHSE (Military Personnel) (Delegated Sec Dent)') Then 'Armed Forces'
WHEN Der2425.Responsible_Purchaser_Assignment_Method IN ('NHSE (Offender Health)','NHSE (Offender Health) (Delegated Sec Dent)') Then 'Health and Justice'
Else 'Other NHSE' End
 
-- Brings in TFC Description
 
	,tfc.Treatment_Function_Desc
 
-- Brings in months in a YYYYMM format
	,YearMonth = CONCAT(YEAR(Appointment_Date),FORMAT(MONTH(Appointment_Date),'00'))
 
-- Case statement to group OP data in to highlevel PoD	
 
	,CASE WHEN Der_Appointment_Type LIKE 'FUp' THEN 'OPAFU' WHEN Der_Appointment_Type LIKE 'New' THEN 'OPFA' END as 'Metric_Type'	
 
-- Sum all unadjusted activity - As submitted	
 
,count(cast(op.[OPA_Ident] as varchar)) as 'Total_Activity(Unadj)'
 
 
FROM [Reporting_MESH_OPA].[OPA_Core_Union] as op
 
--Join to TFC table to bring in description
 
left join [Internal_Reference].[UCSM_RefTFCs] as tfc
on op.[Treatment_Function_Code]  = tfc.[Treatment_Function_Code]
 
--Join to reference tables to bring in provider and system names
 
LEFT JOIN [Reporting_UKHD_ODS].[Provider_Hierarchies] o                        
ON op.Der_Provider_Code = o.Organisation_Code COLLATE Latin1_General_CI_AS  
 
--Join to Der table to bring in CAM
 
LEFT JOIN [Reporting_MESH_OPA].[OPA_2425_Der_Union] AS Der2425					
ON OP.OPA_Ident = Der2425.OPA_Ident


 
WHERE 			
	op.Appointment_Date >= '2024-04-01' -- current FY, YTD
-- add in the below if you are looking at a range (for e.g between financial years)
and op.[Appointment_Date] < '2025-04-01'
 
-- Method to exclude mental health TFCs and Maternity TFCs (specific acute only)                              
AND op.Treatment_Function_Code NOT IN ('199', '223', '290', '291', '331', '344', '345', '346', '360', '424', '499', '501', '504', '560', '650', '651', '652', '653', '654', '655', '656', '657', '658', '659', '660', '661', '662', '700', '710', '711', '712', '713', '715', '720', '721', '722', '723', '724', '725', '726', '727', '730', '840', '920', 'NULL', '812')       
 
	and Der_Appointment_Type <> 'Unknown Appointment Type' -- exclude unknown appointments
    and Responsible_Purchaser_Assignment_Method NOT IN ('Private Patient')-- CAM Logic to remove private patients ( more inline with national logic and removes issue with ADMIN completeness)
	and Der_Staff_Type = 'cons' -- National planning guidance consultant led only
	and Der_Attendance_Type = 'Attend'
	and o.Region_Name = 'South West'
    and [Der_Provider_Code] in ( -- SW Providers Acute Providers Only
		'RD1',
		'RN3',
		'RNZ',
		'RA7',
		'RVJ',
		'REF',
		'RA9',
		'RH8',
		'RK9',
		'RBD',
		'R0D',
		'RTE',
		'RH5')

	
GROUP BY	
 
Der_Provider_Code
,o.organisation_name
,o.STP_Name
,op.Treatment_Function_Code
,op.Core_HRG
,Der2425.Responsible_Purchaser_Assignment_Method
,tfc.Treatment_Function_Desc
,Appointment_Date
,Der_Appointment_Type 
GO
 