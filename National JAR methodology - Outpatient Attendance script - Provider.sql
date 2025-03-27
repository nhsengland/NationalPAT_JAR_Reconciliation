
-- National planning methodology - Outpatient Attendance script - Provider
-- Script annotated for handover by Destiny Bradley



SELECT 	

-- For assurance, we add in a case statement on Provider codes to make sure that all mergers are correctly captured

	 CASE WHEN Provider_Current = 'RD3' THEN 'R0D'
	 WHEN Provider_Current = 'RDZ' THEN 'R0D'
	 WHEN Provider_Current = 'RBZ' THEN 'RH8'
	 WHEN Provider_Current = 'RA3' THEN 'RA7'
	 WHEN Provider_Current = 'RBA' THEN 'RH5'
	 WHEN Provider_Current = 'R1G' THEN 'RA9'
	 WHEN Provider_Current = 'RVJ13' THEN 'RVJ'
	 WHEN Provider_Current = 'RA4' THEN 'RH5'
	 ELSE Provider_Current END AS 'Provider_Current'

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

	,RIGHT(op.Dimention_3,3) as 'TFC'

-- Isolate the HRG and name the column appropriately

	,Dimention_7 as 'HRG'

-- This column identifies the Commissioner_Type (ICB commissioned Activity etc.)

	,PAT_Commissioner_Type

	,CASE WHEN Der2425.Responsible_Purchaser_Assignment_Method IN ('Sub-ICB (Host Mapped)', 'Sub-ICB (Practice Mapped)', 'Sub-ICB (Postcode Mapped)','Sub-ICB (Provider Supplied)') THEN 'ICB Commissioned'
WHEN Der2425.Responsible_Purchaser_Assignment_Method IN ('NHSE (Contracted Specialised)', 'NHSE (NCA Specialised)','Sub-ICB (Host Mapped) (Delegated Spec Comm)','Sub-ICB (Host Mapped) (Delegated Spec Comm) (Delegated Sec Dent)','Sub-ICB (Postcode Mapped) (Delegated Spec Comm)','Sub-ICB (Postcode Mapped) (Delegated Spec Comm) (Delegated Sec Dent)','Sub-ICB (Practice Mapped) (Delegated Spec Comm)','Sub-ICB (Practice Mapped) (Delegated Spec Comm) (Delegated Sec Dent)','NHSE (Offender Health) (Delegated Spec Comm)','NHSE (Offender Health) (Delegated Spec Comm) (Delegated Sec Dent)','NHSE (Military Personnel) (Delegated Spec Comm)') Then 'Spec Comm'
WHEN Der2425.Responsible_Purchaser_Assignment_Method IN ('Sub-ICB (Host Mapped) (Delegated Sec Dent)', 'Sub-ICB (Practice Mapped) (Delegated Sec Dent)', 'Sub-ICB (Postcode Mapped) (Delegated Sec Dent)') Then 'Delegated Sec Dent'
WHEN Der2425.Responsible_Purchaser_Assignment_Method = 'NHSE (Secondary Dental)' Then 'Secondary Dental'
WHEN Der2425.Responsible_Purchaser_Assignment_Method IN ('NHSE (Military Personnel)','NHSE (Military Personnel) (Delegated Sec Dent)') Then 'Armed Forces'
WHEN Der2425.Responsible_Purchaser_Assignment_Method IN ('NHSE (Offender Health)','NHSE (Offender Health) (Delegated Sec Dent)') Then 'Health and Justice'
Else 'Other NHSE' End as CAM_Commissioner_Type

-- Brings in TFC Description

	,tfc.Treatment_Function_Desc

-- Brings in months in a YYYYMM format
	
	,YearMonth = CONCAT(YEAR(Attendance_Date),FORMAT(MONTH(Attendance_Date),'00'))

-- Case statement to group OP data in to highlevel PoD	

	,CASE WHEN [Dimention_1] LIKE 'Follow%' THEN 'Outpatient Follow-Up' WHEN [Dimention_1] LIKE '1st%' THEN 'Outpatient First Appointment' END as [High_Level_Pod]	

-- Sum all unadjusted activity - As submitted	

	,SUM(op.[unadjusted]) as 'Total_Activity(Unadj)'

-- Sum all adjusted activity - this will include any imputations made by during the dq/processing that happens by the national team	

	,SUM(op.[adjusted]) as 'Total_Activity(Adj)'




FROM [NHSE_SUSPlus_Reporting].[Data].[PAT_Intermediate_Table_OP] as op

--Join to TFC table to bring in description 

left join [NHSE_Sandbox_Operations].[Everyone].[UCSM_RefTFCs] as tfc
on Right(op.Dimention_3,3) = tfc.Treatment_Function_Code

--Join to reference tables to bring in provider and system names

left join [NHSE_Reference].[dbo].[tbl_Ref_ODS_Provider_Hierarchies] as o
on op.Provider_Current = o.Organisation_Code

LEFT JOIN [NHSE_SUSPlus_Live].[dbo].[tbl_Data_SEM_OPA_2425_Der] AS Der2425					
	ON Der2425.OPA_Ident = OP.OPA_Ident_min

WHERE 			
	op.Attendance_Date >= '2024-04-01' -- current FY, YTD

-- add in the below if you are looking at a range (for e.g between financial years)
 and op.[Attendance_Date] < '2025-04-01'

	and Commissioner_Type IN('CCG', 'CCG*', 'NHSE (Specialised Commissoning)', 'NHSE (Military Personnel)', 'NHSE (Offender Health)', 'NHSE (Secondary Dental)', 'NHSE (Military Personnel)*', 'NHSE (Offender Health)*', 'NHSE (Secondary Dental)*', 'NHSE (Public Health Screening)'
		, 'Devolved Administration', 'Devolved Administration*', 'Reciprocal OSVs', 'Non-reciprocal OSVs', 'OSV (Type Unknown)', 'OSV (Type Unknown)*') -- CAM Logic alighned with national pat
 	and [Dimention_1] <> 'Unknown Appointment Type' -- exclude unknown appointments
	and op.[Commissioner_Type] <> 'Private Patient' -- Excluding private patients
--	and op.Responsible_Purchaser_Assignment_Method NOT IN ('Reciprocal OSVs', 'Non-reciprocal OSVs', 'Private Patient', 'Devolved Administration')
	and [Dimention_4] = 'Consultant led: Specific Acute' -- National planning guidance is specific acute only - excluding some maternity and LDA MH activity
--	and op.[Provider_Current] like 'R%'-- acute providers only
--	and op.[Provider_Current] <> 'RDY' -- remove community providers
--	and op.[Provider_Current] <> 'RTQ' -- remove community providers
--	and op.[Provider_Current] <> 'RJ8' -- remove community providers
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
--	and o.Region_Name = 'South West'


GROUP BY	
OPA_Ident
	 ,Provider_Current
	,o.organisation_name 
	,o.STP_Name
	,Left(op.Dimention_3,3)
	,Dimention_7
	,PAT_Commissioner_Type
	,Der2425.Responsible_Purchaser_Assignment_Method
	,tfc.Treatment_Function_Desc
	,Attendance_Date
	,Dimention_1
	,Dimention_4
	,Dimention_5	


GO


