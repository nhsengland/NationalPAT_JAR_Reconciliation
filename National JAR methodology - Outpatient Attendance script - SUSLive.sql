SELECT 	
 
-- For assurance, we add in a case statement on Provider codes to make sure that all mergers are correctly captured
 
	 Der_Provider_Code
 
-- For assurance, we add in a case statement on Provider names to make sure that all mergers and name changes are correctly captured
 
     ,CASE WHEN o.Organisation_Name = 'ROYAL DEVON AND EXETER NHS FOUNDATION TRUST' THEN 'ROYAL DEVON UNIVERSITY HEALTHCARE NHS FOUNDATION TRUST'
	 WHEN o.Organisation_Name  = 'TAUNTON AND SOMERSET NHS FOUNDATION TRUST' THEN 'SOMERSET NHS FOUNDATION TRUST'
	 WHEN o.Organisation_Name  = 'NORTHERN DEVON HEALTHCARE NHS TRUST' THEN 'ROYAL DEVON UNIVERSITY HEALTHCARE NHS FOUNDATION TRUST'
	 WHEN o.Organisation_Name  = 'THE ROYAL BOURNEMOUTH AND CHRISTCHURCH HOSPITALS NHS FOUNDATION TRUST' THEN 'UNIVERSITY HOSPITAL DORSET NHS FOUNDATION TRUST'
	 WHEN o.Organisation_Name  = 'POOLE HOSPITAL NHS FOUNDATION TRUST' THEN 'UNIVERSITY HOSPITAL DORSET NHS FOUNDATION TRUST'
	 WHEN o.Organisation_Name  = 'TORBAY AND SOUTHERN DEVON HEALTH AND CARE NHS TRUST' THEN 'TORBAY AND SOUTH DEVON NHS FOUNDATION TRUST'
	 When o.Organisation_Name = 'EMERSONS GREEN NHS TREATMENT CENTRE' THEN 'NORTH BRISTOL NHS TRUST'
	 When o.Organisation_Name = 'YEOVIL DISTRICT HOSPITAL NHS FOUNDATION TRUST' THEN 'SOMERSET NHS FOUNDATION TRUST'	 
	 When o.Organisation_Name = 'UNIVERSITY HOSPITALS BRISTOL NHS FOUNDATION TRUST' then 'UNIVERSITY HOSPITALS BRISTOL AND WESTON NHS FOUNDATION TRUST'
	 ELSE o.Organisation_Name  END AS 'orgname'
 
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
 
 
FROM [NHSE_SUSPlus_Live].[dbo].[tbl_Data_SEM_OPA] as op
 
--Join to TFC table to bring in description
 
left join [NHSE_Sandbox_Operations].[Everyone].[UCSM_RefTFCs] as tfc
on op.Treatment_Function_Code = tfc.Treatment_Function_Code
 
--Join to reference tables to bring in provider and system names
 
left join [NHSE_Reference].[dbo].[tbl_Ref_ODS_Provider_Hierarchies] as o
on op.Der_Provider_Code = o.Organisation_Code
 
--Join to Der table to bring in CAM
 
LEFT JOIN [NHSE_SUSPlus_Live].[dbo].[tbl_Data_SEM_OPA_2425_Der] AS Der2425					
	ON Der2425.OPA_Ident = OP.OPA_Ident
 
WHERE 			
	op.Appointment_Date >= '2024-04-01' -- current FY, YTD
-- add in the below if you are looking at a range (for e.g between financial years)
and op.[Appointment_Date] < '2025-04-01'
 
-- Method to exclude mental health TFCs and Maternity TFCs (specific acute only)                              
AND op.Treatment_Function_Code NOT IN ('199', '223', '290', '291', '331', '344', '345', '346', '360', '424', '499', '501', '504', '560', '650', '651', '652', '653', '654', '655', '656', '657', '658', '659', '660', '661', '662', '700', '710', '711', '712', '713', '715', '720', '721', '722', '723', '724', '725', '726', '727', '730', '840', '920', 'NULL', '812')       
 
	and Der_Appointment_Type <> 'Unknown Appointment Type' -- exclude unknown appointments
    and Responsible_Purchaser_Assignment_Method NOT IN ('Private Patient')-- CAM Logic to remove private patients ( more inline with national logic and removes issue with ADMIN completeness)
	and Der_Staff_Type = 'cons' -- National planning guidance consultant led only
--	and o.NHSE_Organisation_Type like 'Acute%'-- acute providers only
	and Der_Attendance_Type = 'Attend'
	and o.Region_Name = 'South West'
	and Der_Provider_Code in ( -- SW Providers Acute Providers Only
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
 