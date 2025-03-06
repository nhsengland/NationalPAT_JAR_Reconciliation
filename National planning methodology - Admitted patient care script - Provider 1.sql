
-- National planning methodology - Admitted patient care script - Provider
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
	  When o.organisation_name = 'YEOVIL DISTRICT HOSPITAL NHS FOUNDATION TRUST' THEN 'SOMERSET NHS FOUNDATION TRUST'	 ELSE o.organisation_name  END AS 'organisation_name'

-- System names for the Provider

	,o.STP_Name

-- Isolate the Treatment Function Code and name the column appropriately

	,Left(apc.Dimention_3,3) as 'TFC'

-- Isolate the HRG and name the column appropriately

	,LEFT(apc.Dimention_7,5) as 'HRG'

-- This column identifies the Commissioner_Type (ICB commissioned Activity etc.)

	,PAT_Commissioner_Type

-- Brings in TFC Description

	,tfc.Treatment_Function_Desc

-- Brings in months in a YYYYMM format
	
	,YearMonth = CONCAT(YEAR(Discharge_Date),FORMAT(MONTH(Discharge_Date),'00'))

-- Case statement to group all NEL activity under NE - so emergency admissions = NE not EM	


	,CASE WHEN apc.[Der_Management_Type] = 'EM' then 'NE' ELSE apc.[Der_Management_Type] END AS 'Der_Management_Type'

-- Case statement to group LOS	

	,case when apc.Dimention_5 = 'A: 0 day LOS' then '0 Day LOS' ELSE '1+Day LOS'END AS 'LOS'

-- Sum all unadjusted activity - As submitted		

	,SUM(apc.[unadjusted]) as 'Total_Activity(Unadj)'

-- Sum all adjusted activity - this will include any imputations made by during the dq/processing that happens by the national team	

	,SUM(apc.[adjusted]) as 'Total_Activity(Adj)'

	


FROM [NHSE_SUSPlus_Reporting].[Data].[PAT_Intermediate_Table_APC] apc

--Join to TFC table to bring in description 

left join [NHSE_Sandbox_Operations].[Everyone].[UCSM_RefTFCs] as tfc
on Right(apc.Dimention_3,3) = tfc.Treatment_Function_Code

--Join to reference tables to bring in provider and system names

left join [NHSE_Reference].[dbo].[tbl_Ref_ODS_Provider_Hierarchies] as o
on apc.Provider_Current = o.Organisation_Code


WHERE 			
	apc.[Discharge_Date] >= '2023-04-01' -- current FY, YTD

-- add in the below if you are looking at a range (for e.g between financial years)
	and apc.[Discharge_Date] < '2025-04-01'

    and apc.[Commissioner_Type] <> 'Private Patient' -- Excluding private patients
	and apc.[Dimention_4] = 'Specific Acute' -- National planning guidance is specific acute only - excluding some maternity and LDA MH activity
	and Der_Management_Type in ('EL','DC') -- selecting the key elective PODS
	and apc.[Provider_Current] like 'R%'-- acute providers only
	and apc.[Provider_Current] <> 'RDY' -- remove community providers
	and apc.[Provider_Current] <> 'RTQ' -- remove community providers
	and apc.[Provider_Current] <> 'RJ8' -- remove community providers
	and o.Region_Name = 'South West' -- south west region only
--	and LEFT(apc.Dimention_7,5) like '%UZ%'
	
	
GROUP BY	

	 Provider_Current
	,o.organisation_name 
	,o.STP_Name
	,Left(apc.Dimention_3,3)
	,LEFT(apc.Dimention_7,5) 
	,PAT_Commissioner_Type
	,tfc.Treatment_Function_Desc
	,Discharge_Date
	,[Der_Management_Type]
	,apc.Dimention_5 
	,Dimention_9

GO


