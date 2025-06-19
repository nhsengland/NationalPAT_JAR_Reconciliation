
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

  ,CASE WHEN o.Organisation_name = 'ROYAL DEVON AND EXETER NHS FOUNDATION TRUST' THEN 'ROYAL DEVON UNIVERSITY HEALTHCARE NHS FOUNDATION TRUST'
	 WHEN o.Organisation_name  = 'TAUNTON AND SOMERSET NHS FOUNDATION TRUST' THEN 'SOMERSET NHS FOUNDATION TRUST'
	 WHEN o.Organisation_name  = 'NORTHERN DEVON HEALTHCARE NHS TRUST' THEN 'ROYAL DEVON UNIVERSITY HEALTHCARE NHS FOUNDATION TRUST'
	 WHEN o.Organisation_name  = 'THE ROYAL BOURNEMOUTH AND CHRISTCHURCH HOSPITALS NHS FOUNDATION TRUST' THEN 'UNIVERSITY HOSPITAL DORSET NHS FOUNDATION TRUST'
	 WHEN o.Organisation_name  = 'POOLE HOSPITAL NHS FOUNDATION TRUST' THEN 'UNIVERSITY HOSPITAL DORSET NHS FOUNDATION TRUST'
	 WHEN o.Organisation_name  = 'TORBAY AND SOUTHERN DEVON HEALTH AND CARE NHS TRUST' THEN 'TORBAY AND SOUTH DEVON NHS FOUNDATION TRUST'
	 When o.Organisation_name = 'EMERSONS GREEN NHS TREATMENT CENTRE' THEN 'NORTH BRISTOL NHS TRUST'
	  When o.Organisation_name = 'YEOVIL DISTRICT HOSPITAL NHS FOUNDATION TRUST' THEN 'SOMERSET NHS FOUNDATION TRUST' ELSE o.Organisation_name  END AS 'orgname'

-- System names for the Provider

	,o.STP_Name

-- Isolate the Treatment Function Code and name the column appropriately

	,Right(op.Dimention_3,3) as 'TFC'

-- Isolate the HRG and name the column appropriately

	,Dimention_7 as 'HRG'

-- This column identifies the Commissioner_Type (ICB commissioned Activity etc.)

	,PAT_Commissioner_Type

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


FROM [UDALSQLMART_PatActivity].[PAT_Intermediate_Table_OP] op


--Join to TFC table to bring in description 

left join [Internal_Reference].[UCSM_RefTFCs] as tfc
on Right(op.Dimention_3,3) = tfc.[Treatment_Function_Code]

--Join to reference tables to bring in provider and system names

LEFT JOIN [Reporting_UKHD_ODS].[Provider_Hierarchies] o                        
ON op.Provider_Current = o.Organisation_Code COLLATE Latin1_General_CI_AS  


WHERE 			
	op.Attendance_Date >= '2024-03-01' -- current FY, YTD

-- add in the below if you are looking at a range (for e.g between financial years)
 and op.[Attendance_Date] < '2026-04-01'

	and Commissioner_Type IN('CCG', 'CCG*', 'NHSE (Specialised Commissoning)', 'NHSE (Military Personnel)', 'NHSE (Offender Health)', 'NHSE (Secondary Dental)', 'NHSE (Military Personnel)*', 'NHSE (Offender Health)*', 'NHSE (Secondary Dental)*', 'NHSE (Public Health Screening)'
		, 'Devolved Administration', 'Devolved Administration*', 'Reciprocal OSVs', 'Non-reciprocal OSVs', 'OSV (Type Unknown)', 'OSV (Type Unknown)*') -- CAM Logic alighned with national pat
 	and [Dimention_1] <> 'Unknown Appointment Type' -- exclude unknown appointments
	and op.[Commissioner_Type] <> 'Private Patient' -- Excluding private patients
	and [Dimention_4] = 'Consultant led: Specific Acute' -- National planning guidance is specific acute only - excluding some maternity and LDA MH activity
--	and Right(op.Dimention_3,3) not in ('812', '360')
	and op.[Provider_Current] in ( 
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

	 Provider_Current
	 ,o.Organisation_name
	 ,o.STP_Name
	,Right(op.Dimention_3,3)
	,Dimention_7
	,PAT_Commissioner_Type
	,tfc.Treatment_Function_Desc
	,Attendance_Date
	,Dimention_1


GO


