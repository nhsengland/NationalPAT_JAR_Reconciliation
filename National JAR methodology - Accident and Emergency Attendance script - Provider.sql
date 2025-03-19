
-- National planning methodology - Accident and Emergency Attendance - Provider
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

-- Isolate the HRG and name the column appropriately

	,LEFT(ae.Dimention_7,5) as 'HRG'

-- This column identifies the Commissioner_Type (ICB commissioned Activity etc.)

	,PAT_Commissioner_Type

-- Brings in months in a YYYYMM format
	
	,YearMonth = CONCAT(YEAR([Attendance_Date]),FORMAT(MONTH([Attendance_Date]),'00'))

-- Bring in activity type	

	,ae.[Dimention_1]	

-- Sum all unadjusted activity - As submitted		

	,SUM(ae.[unadjusted]) as 'Total_Activity(Unadj)'

-- Sum all adjusted activity - this will include any imputations made by during the dq/processing that happens by the national team	

	,SUM(ae.[adjusted]) as 'Total_Activity(Adj)'


FROM [NHSE_SUSPlus_Reporting].[Data].[PAT_Intermediate_Table_AE] AE


--Join to reference tables to bring in provider and system names

left join [NHSE_Reference].[dbo].[tbl_Ref_ODS_Provider_Hierarchies] as o
on ae.Provider_Current = o.Organisation_Code


WHERE 		

	ae.[Attendance_Date] >= '2024-04-01' -- current FY, YTD

-- add in the below if you are looking at a range (for e.g between financial years)
--	and ae.[Attendance_Date] < '2025-04-01'
	and ae.[Commissioner_Type] <> 'Private Patient' -- Excluding private patients
--	and ae.[Provider_Current] like 'R%'-- acute providers only
--	and ae.[Provider_Current] <> 'RDY' -- remove community providers
--	and ae.[Provider_Current] <> 'RTQ' -- remove community providers
--	and ae.[Provider_Current] <> 'RJ8' -- remove community providers
--	and o.Region_Name = 'South West' -- south west region only
	and ae.[Provider_Current] in ( -- SW Providers Acute Providers Only
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
	,o.organisation_name 
	,o.STP_Name
	,LEFT(ae.Dimention_7,5)
	,PAT_Commissioner_Type
	,[Attendance_Date]
	,ae.[Dimention_1]	

GO


