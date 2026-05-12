
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
	 WHEN Provider_Current = 'B4B4S' THEN 'RD1'
	 ELSE Provider_Current END AS 'Provider_Current'
-- For assurance, we add in a case statement on Provider names to make sure that all mergers and name changes are correctly captured

  ,CASE WHEN o.Organisation_name = 'ROYAL DEVON AND EXETER NHS FOUNDATION TRUST' THEN 'ROYAL DEVON UNIVERSITY HEALTHCARE NHS FOUNDATION TRUST'
	 WHEN o.Organisation_name  = 'TAUNTON AND SOMERSET NHS FOUNDATION TRUST' THEN 'SOMERSET NHS FOUNDATION TRUST'
	 WHEN o.Organisation_name  = 'NORTHERN DEVON HEALTHCARE NHS TRUST' THEN 'ROYAL DEVON UNIVERSITY HEALTHCARE NHS FOUNDATION TRUST'
	 WHEN o.Organisation_name  = 'THE ROYAL BOURNEMOUTH AND CHRISTCHURCH HOSPITALS NHS FOUNDATION TRUST' THEN 'UNIVERSITY HOSPITAL DORSET NHS FOUNDATION TRUST'
	 WHEN o.Organisation_name  = 'POOLE HOSPITAL NHS FOUNDATION TRUST' THEN 'UNIVERSITY HOSPITAL DORSET NHS FOUNDATION TRUST'
	 WHEN o.Organisation_name  = 'TORBAY AND SOUTHERN DEVON HEALTH AND CARE NHS TRUST' THEN 'TORBAY AND SOUTH DEVON NHS FOUNDATION TRUST'
	 When o.Organisation_name = 'EMERSONS GREEN NHS TREATMENT CENTRE' THEN 'NORTH BRISTOL NHS TRUST'
	 WHEN o.organisation_name = 'BSW BANES LOCALITY CDC' THEN 'ROYAL UNITED HOSPITALS BATH NHS FOUNDATION TRUST'
	 When o.Organisation_name = 'YEOVIL DISTRICT HOSPITAL NHS FOUNDATION TRUST' THEN 'SOMERSET NHS FOUNDATION TRUST' ELSE o.Organisation_name  END AS 'orgname'

	,o.STP_Name

-- Isolate the HRG and name the column appropriately

	,LEFT(ae.Dimention_7,5) as 'HRG'

-- This column identifies the Commissioner_Type (ICB commissioned Activity etc.)

	,PAT_Commissioner_Type

-- Brings in months in a YYYYMM format
	
	,YearMonth = CONCAT(YEAR([Attendance_Date]),FORMAT(MONTH([Attendance_Date]),'00'))

-- Bring in activity type	

,CASE 
when ae.[Dimention_1] = 'Multi-Specialty A&E (Type 1)' then 'AE Type 1&2'
when ae.[Dimention_1] = 'Single Specialty A&E (Type 2)' then 'AE Type 1&2'
when ae.[Dimention_1] = 'Minor Injuries Unit (Type 3)' then 'AE Type Other'
when ae.[Dimention_1] = 'unknown' then 'AE Type Other'
END AS 'Der_Management_Type'

-- Sum all unadjusted activity - As submitted		

	,SUM(ae.[unadjusted]) as 'Total_Activity(Unadj)'

-- Sum all adjusted activity - this will include any imputations made by during the dq/processing that happens by the national team	

	,SUM(ae.[adjusted]) as 'Total_Activity(Adj)'

FROM [UDALLAKEMART_PatActivity].[PAT_Intermediate_Table_AE] AE

LEFT JOIN [Reporting_UKHD_ODS].[Provider_Hierarchies] o                        
ON ae.Provider_Current = o.Organisation_Code COLLATE Latin1_General_CI_AS  


WHERE 		

	ae.[Attendance_Date] >= '2025-04-01' -- current FY, YTD

-- add in the below if you are looking at a range (for e.g between financial years)
--	and ae.[Attendance_Date] < '2026-04-01'
	and ae.[Commissioner_Type] <> 'Private Patient' -- Excluding private patients
	and [Provider_Current]  in ('RD1','RN3','RNZ','RA7','RVJ','REF','RA9','RH8','RK9','RBD','R0D','RTE','RH5','RVJ13','B4B4S')
	and Dimention_1 <> 'Ambulatory Care (Type 5)'

	
	
GROUP BY	
   CASE WHEN Provider_Current = 'RD3' THEN 'R0D'
	 WHEN Provider_Current = 'RDZ' THEN 'R0D'
	 WHEN Provider_Current = 'RBZ' THEN 'RH8'
	 WHEN Provider_Current = 'RA3' THEN 'RA7'
	 WHEN Provider_Current = 'RBA' THEN 'RH5'
	 WHEN Provider_Current = 'R1G' THEN 'RA9'
	 WHEN Provider_Current = 'RVJ13' THEN 'RVJ'
	 WHEN Provider_Current = 'RA4' THEN 'RH5'
	 WHEN Provider_Current = 'B4B4S' THEN 'RD1'
	 ELSE Provider_Current END

  ,CASE WHEN o.Organisation_name = 'ROYAL DEVON AND EXETER NHS FOUNDATION TRUST' THEN 'ROYAL DEVON UNIVERSITY HEALTHCARE NHS FOUNDATION TRUST'
	 WHEN o.Organisation_name  = 'TAUNTON AND SOMERSET NHS FOUNDATION TRUST' THEN 'SOMERSET NHS FOUNDATION TRUST'
	 WHEN o.Organisation_name  = 'NORTHERN DEVON HEALTHCARE NHS TRUST' THEN 'ROYAL DEVON UNIVERSITY HEALTHCARE NHS FOUNDATION TRUST'
	 WHEN o.Organisation_name  = 'THE ROYAL BOURNEMOUTH AND CHRISTCHURCH HOSPITALS NHS FOUNDATION TRUST' THEN 'UNIVERSITY HOSPITAL DORSET NHS FOUNDATION TRUST'
	 WHEN o.Organisation_name  = 'POOLE HOSPITAL NHS FOUNDATION TRUST' THEN 'UNIVERSITY HOSPITAL DORSET NHS FOUNDATION TRUST'
	 WHEN o.Organisation_name  = 'TORBAY AND SOUTHERN DEVON HEALTH AND CARE NHS TRUST' THEN 'TORBAY AND SOUTH DEVON NHS FOUNDATION TRUST'
	 When o.Organisation_name = 'EMERSONS GREEN NHS TREATMENT CENTRE' THEN 'NORTH BRISTOL NHS TRUST'
	 WHEN o.organisation_name = 'BSW BANES LOCALITY CDC' THEN 'ROYAL UNITED HOSPITALS BATH NHS FOUNDATION TRUST'
	 When o.Organisation_name = 'YEOVIL DISTRICT HOSPITAL NHS FOUNDATION TRUST' THEN 'SOMERSET NHS FOUNDATION TRUST' ELSE o.Organisation_name END
	,o.STP_Name
	,LEFT(ae.Dimention_7,5)
	,PAT_Commissioner_Type
	,CONCAT(YEAR([Attendance_Date]),FORMAT(MONTH([Attendance_Date]),'00'))
	,CASE 
	when ae.[Dimention_1] = 'Multi-Specialty A&E (Type 1)' then 'AE Type 1&2'
	when ae.[Dimention_1] = 'Single Specialty A&E (Type 2)' then 'AE Type 1&2'
	when ae.[Dimention_1] = 'Minor Injuries Unit (Type 3)' then 'AE Type Other'
	when ae.[Dimention_1] = 'unknown' then 'AE Type Other'
	END

	GO


