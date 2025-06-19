SELECT 


CASE WHEN Der_Provider_Code = 'RD3' THEN 'R0D'
	 WHEN Der_Provider_Code = 'RDZ' THEN 'R0D'
	 WHEN Der_Provider_Code = 'RBZ' THEN 'RH8'
	 WHEN Der_Provider_Code = 'RA3' THEN 'RA7'
	 WHEN Der_Provider_Code = 'RBA' THEN 'RH5'
	 WHEN Der_Provider_Code = 'R1G' THEN 'RA9'
	 WHEN Der_Provider_Code = 'RVJ13' THEN 'RVJ'
	 WHEN Der_Provider_Code = 'RA4' THEN 'RH5'
	 ELSE Der_Provider_Code END AS 'Provider_Code'
	 	 	
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

,apc.[Treatment_Function_Code]
,apc.Spell_Core_HRG
,Responsible_Purchaser_Assignment_Method
,Treatment_Function_Desc
,YearMonth = Concat(year(Discharge_Date),Format(Month(Discharge_Date),'00'))
,case when Der_Management_Type = 'EM' then 'NE' else Der_Management_Type end as Der_Management_Type
,count(cast(apc.[APCE_Ident] as varchar)) as MetricValue
,o.STP_Name
,o.STP_Code

FROM [MESH_APC].[APCE_Core_Daily] as apc 

 
LEFT JOIN [Reporting_UKHD_ODS].[Provider_Hierarchies] o                        
ON apc.Der_Provider_Code = o.Organisation_Code COLLATE Latin1_General_CI_AS  

left join [Internal_Reference].[UCSM_RefTFCs] as tfc
on apc.[Treatment_Function_Code]  = tfc.[Treatment_Function_Code]

left join [MESH_APC].[APCE_Plus_Daily] as a
on apc.APCE_Ident = a.[APCE_Ident]

left join [MESH_APC].[APCS_2425_Der_Daily] as c
on apc.APCE_Ident = c.[APCS_Ident]

 where [Discharge_Date] >= '2024-04-01'
	and Der_Management_Type in ('DC','EL','EM','NE')
	and Der_Provider_Code  in ( -- SW Providers Acute Providers Only
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
	and a.SUS_Dominant_Episode_Flag = '1'
	and apc.[Treatment_Function_Code] NOT IN ('199', '223', '290', '291', '331', '344', '345', '346', '360', '424', '499', '501', '504', '560', '650', '651', '652', '653', '654', '655', '656', '657', '658', '659', '660', '661', '662', '700', '710', '711', '712', '713', '715', '720', '721', '722', '723', '724', '725', '726', '727', '730', '840', '920', 'NULL')  
    and c.Responsible_Purchaser_Assignment_Method <> 'Private Patient'	-- CAM Logic to remove private patients ( more inline with national logic and removes issue with ADMIN completeness)
	
Group by
Der_Provider_Code
,organisation_name
,apc.[Treatment_Function_Code]
,apc.Spell_Core_HRG
,Responsible_Purchaser_Assignment_Method
,Treatment_Function_Desc
,Discharge_Date
,case when Der_Management_Type = 'EM' then 'NE' else Der_Management_Type end
,o.STP_Name
,o.STP_Code

GO


