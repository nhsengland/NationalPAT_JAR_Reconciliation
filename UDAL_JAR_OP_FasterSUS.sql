WITH FSUS_OP AS (

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

,op.[Treatment_Function_Code]
,Core_HRG
,Responsible_Purchaser_Assignment_Method
,Treatment_Function_Desc
,YearMonth = Concat(year(Appointment_Date),Format(Month(Appointment_Date),'00'))
,concat(Der_Contact_Type,Der_Appointment_Type) as MetricID
,count(cast([Local_Patient_ID] as varchar)) as MetricValue
,o.STP_Name
,o.STP_Code

  
FROM [MESH_OPA].[OPA_Core_Daily] op

LEFT JOIN [Reporting_UKHD_ODS].[Provider_Hierarchies] o                        
ON op.Der_Provider_Code = o.Organisation_Code COLLATE Latin1_General_CI_AS  
 
left join [MESH_OPA].[OPA_2425_Der_Daily] as c
on op.OPA_Ident = c.[OPA_Ident]

left join [Internal_Reference].[UCSM_RefTFCs] as tfc
on op.[Treatment_Function_Code]  = tfc.[Treatment_Function_Code]


  WHERE  O.region_name = 'South West'
  and Der_Attendance_Type = 'Attend'
  AND Appointment_Date >= '2024-04-01'
  and op.[Treatment_Function_Code] NOT IN ('199', '223', '290', '291', '331', '344', '345', '346', '360', '424', '499', '501', '504', '560', '650', '651', '652', '653', '654', '655', '656', '657', '658', '659', '660', '661', '662', '700', '710', '711', '712', '713', '715', '720', '721', '722', '723', '724', '725', '726', '727', '730', '840', '920', 'NULL','812')  
  and [Der_Staff_Type] = 'Cons'
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
  and Responsible_Purchaser_Assignment_Method = 'Private Patient'	-- CAM Logic to remove private patients ( more inline with national logic and removes issue with ADMIN completeness)

 
 Group by

CASE WHEN Der_Provider_Code = 'RD3' THEN 'R0D'
	 WHEN Der_Provider_Code = 'RDZ' THEN 'R0D'
	 WHEN Der_Provider_Code = 'RBZ' THEN 'RH8'
	 WHEN Der_Provider_Code = 'RA3' THEN 'RA7'
	 WHEN Der_Provider_Code = 'RBA' THEN 'RH5'
	 WHEN Der_Provider_Code = 'R1G' THEN 'RA9'
	 WHEN Der_Provider_Code = 'RVJ13' THEN 'RVJ'
	 WHEN Der_Provider_Code = 'RA4' THEN 'RH5'
	 ELSE Der_Provider_Code END
	 	 	
     ,CASE WHEN o.organisation_name = 'ROYAL DEVON AND EXETER NHS FOUNDATION TRUST' THEN 'ROYAL DEVON UNIVERSITY HEALTHCARE NHS FOUNDATION TRUST'
	 WHEN o.organisation_name  = 'TAUNTON AND SOMERSET NHS FOUNDATION TRUST' THEN 'SOMERSET NHS FOUNDATION TRUST'
	 WHEN o.organisation_name  = 'NORTHERN DEVON HEALTHCARE NHS TRUST' THEN 'ROYAL DEVON UNIVERSITY HEALTHCARE NHS FOUNDATION TRUST'
	 WHEN o.organisation_name  = 'THE ROYAL BOURNEMOUTH AND CHRISTCHURCH HOSPITALS NHS FOUNDATION TRUST' THEN 'UNIVERSITY HOSPITAL DORSET NHS FOUNDATION TRUST'
	 WHEN o.organisation_name  = 'POOLE HOSPITAL NHS FOUNDATION TRUST' THEN 'UNIVERSITY HOSPITAL DORSET NHS FOUNDATION TRUST'
	 WHEN o.organisation_name  = 'TORBAY AND SOUTHERN DEVON HEALTH AND CARE NHS TRUST' THEN 'TORBAY AND SOUTH DEVON NHS FOUNDATION TRUST'
	 When o.organisation_name = 'EMERSONS GREEN NHS TREATMENT CENTRE' THEN 'NORTH BRISTOL NHS TRUST'
	 When o.organisation_name = 'YEOVIL DISTRICT HOSPITAL NHS FOUNDATION TRUST' THEN 'SOMERSET NHS FOUNDATION TRUST'	 
	 When o.Organisation_Name = 'UNIVERSITY HOSPITALS BRISTOL NHS FOUNDATION TRUST' then 'UNIVERSITY HOSPITALS BRISTOL AND WESTON NHS FOUNDATION TRUST'
	 ELSE o.organisation_name  END

,op.[Treatment_Function_Code] 
,Core_HRG
,Responsible_Purchaser_Assignment_Method
,Treatment_Function_Desc
,Appointment_Date
,concat(Der_Contact_Type,Der_Appointment_Type)
,o.STP_Name
,o.STP_Code)
 
 Select
 
Provider_Code
,organisation_name
,[Treatment_Function_Code] 
,Core_HRG
,Responsible_Purchaser_Assignment_Method
,Treatment_Function_Desc
,YearMonth
,CASE WHEN MetricID = 'F2FFUp' THEN 'Outpatient attendances (consultant led) - Follow-up attendance face to face'
	WHEN MetricID = 'F2FNew' THEN 'Outpatient attendances (consultant led) - First attendance face to face'
	WHEN MetricID = 'NF2FFUp' THEN  'Outpatient attendances (consultant led) - Follow-up telephone or Video consultation'
	WHEN MetricID = 'NF2FNew' THEN  'Outpatient attendances (consultant led) - First telephone or Video consultation'
	ELSE null end as MetricID
,MetricValue
,STP_Name
,STP_Code

from FSUS_OP