
-- National planning methodology - Unit Cost and Activity Weighting
-- Script annotated for handover by Destiny Bradley


with CTE_APC as (SELECT 	


-- Name the Activity type

'APC Elective' as 'Activity type'
	
-- Sum Unit Costs		

,SUM(c.Unit_Cost_all) as Unit_cost

	
FROM [NHSE_SUSPlus_Reporting].[Data].[PAT_Intermediate_Table_APC] apc

--Join to reference tables to bring in provider and system names

left join [NHSE_Reference].[dbo].[tbl_Ref_ODS_Provider_Hierarchies] as o
on apc.Provider_Current = o.Organisation_Code

--Join to National Unit cost table to bring in unit costs

left join[NHSE_Sandbox_Operations_Production].[dbo].[RefCost_APC_National_1718] as c
on apc.[APCS_Ident_min] = c.[APCS_Ident]


WHERE 			
	apc.[Discharge_Date] >= '2024-04-01' -- current FY, YTD

-- add in the below if you are looking at a range (for e.g between financial years)
--	and apc.[Discharge_Date] < '2025-04-01'

	and apc.[Commissioner_Type] <> 'Private Patient' -- Excluding private patients
	and apc.[Dimention_4] = 'Specific Acute' -- National planning guidance is specific acute only - excluding some maternity and LDA MH activity
	and Der_Management_Type in ('EL','DC') -- selecting the key elective PODS
	and apc.[Provider_Current] like 'R%'-- acute providers only
	and apc.[Provider_Current] <> 'RDY' -- remove community providers
	and apc.[Provider_Current] <> 'RTQ' -- remove community providers
	and apc.[Provider_Current] <> 'RJ8' -- remove community providers
	and o.Region_Name = 'South West') -- south west region only
	
	
,CTE_OPFU as (


SELECT

-- Name the Activity type

'Outpatient Follow-Up' as 'Activity type'	
	
-- Sum Unit Costs		

,SUM(c.Unit_Cost_all) as Unit_cost

FROM [NHSE_SUSPlus_Reporting].[Data].[PAT_Intermediate_Table_OP] as op

--Join to reference tables to bring in provider and system names

left join [NHSE_Reference].[dbo].[tbl_Ref_ODS_Provider_Hierarchies] as o
on op.Provider_Current = o.Organisation_Code

--Join to National Unit cost table to bring in unit costs

left join[NHSE_Sandbox_Operations_Production].[dbo].[RefCost_OP_National_1718] as c
on op.[OPA_Ident_min] = c.[OPA_Ident]


WHERE 			
	op.Attendance_Date >= '2024-04-01' -- current FY, YTD

-- add in the below if you are looking at a range (for e.g between financial years)
-- and op.[Attendance_Date] < '2024-04-01'

	and Commissioner_Type IN('CCG', 'CCG*', 'NHSE (Specialised Commissoning)', 'NHSE (Military Personnel)', 'NHSE (Offender Health)', 'NHSE (Secondary Dental)', 'NHSE (Military Personnel)*', 'NHSE (Offender Health)*', 'NHSE (Secondary Dental)*', 'NHSE (Public Health Screening)'
		, 'Devolved Administration', 'Devolved Administration*', 'Reciprocal OSVs', 'Non-reciprocal OSVs', 'OSV (Type Unknown)', 'OSV (Type Unknown)*') -- CAM Logic alighned with national pat
 	and [Dimention_1] <> 'Unknown Appointment Type' -- exclude unknown appointments
	and [Dimention_1] LIKE 'Follow%'
	and op.[Commissioner_Type] <> 'Private Patient' -- Excluding private patients
	and [Dimention_4] = 'Consultant led: Specific Acute' -- National planning guidance is specific acute only - excluding some maternity and LDA MH activity
	and op.[Provider_Current] like 'R%'-- acute providers only
	and op.[Provider_Current] <> 'RDY' -- remove community providers
	and op.[Provider_Current] <> 'RTQ' -- remove community providers
	and op.[Provider_Current] <> 'RJ8' -- remove community providers
	and o.Region_Name = 'South West') -- south west region only

,CTE_OPFA as (


SELECT

-- Name the Activity type

'Outpatient First Appointment' as 'Activity type'	
	
-- Sum Unit Costs		

,SUM(c.Unit_Cost_all) as Unit_cost

FROM [NHSE_SUSPlus_Reporting].[Data].[PAT_Intermediate_Table_OP] as op

--Join to reference tables to bring in provider and system names

left join [NHSE_Reference].[dbo].[tbl_Ref_ODS_Provider_Hierarchies] as o
on op.Provider_Current = o.Organisation_Code

--Join to National Unit cost table to bring in unit costs

left join[NHSE_Sandbox_Operations_Production].[dbo].[RefCost_OP_National_1718] as c
on op.[OPA_Ident_min] = c.[OPA_Ident]


WHERE 			
	op.Attendance_Date >= '2024-04-01' -- current FY, YTD

-- add in the below if you are looking at a range (for e.g between financial years)
-- and op.[Attendance_Date] < '2024-04-01'

	and Commissioner_Type IN('CCG', 'CCG*', 'NHSE (Specialised Commissoning)', 'NHSE (Military Personnel)', 'NHSE (Offender Health)', 'NHSE (Secondary Dental)', 'NHSE (Military Personnel)*', 'NHSE (Offender Health)*', 'NHSE (Secondary Dental)*', 'NHSE (Public Health Screening)'
		, 'Devolved Administration', 'Devolved Administration*', 'Reciprocal OSVs', 'Non-reciprocal OSVs', 'OSV (Type Unknown)', 'OSV (Type Unknown)*') -- CAM Logic alighned with national pat
 	and [Dimention_1] <> 'Unknown Appointment Type' -- exclude unknown appointments
	and [Dimention_1] LIKE '1st%'
	and op.[Commissioner_Type] <> 'Private Patient' -- Excluding private patients
	and [Dimention_4] = 'Consultant led: Specific Acute' -- National planning guidance is specific acute only - excluding some maternity and LDA MH activity
	and op.[Provider_Current] like 'R%'-- acute providers only
	and op.[Provider_Current] <> 'RDY' -- remove community providers
	and op.[Provider_Current] <> 'RTQ' -- remove community providers
	and op.[Provider_Current] <> 'RJ8' -- remove community providers
	and o.Region_Name = 'South West') -- south west region only

,CTE_NEL as (

SELECT 	

-- Name the Activity type

'APC Non - Elective' as 'Activity type'
	
-- Sum Unit Costs		

,SUM(c.Unit_Cost_all) as Unit_cost

	
FROM [NHSE_SUSPlus_Reporting].[Data].[PAT_Intermediate_Table_APC] apc

--Join to reference tables to bring in provider and system names

left join [NHSE_Reference].[dbo].[tbl_Ref_ODS_Provider_Hierarchies] as o
on apc.Provider_Current = o.Organisation_Code

--Join to National Unit cost table to bring in unit costs

left join[NHSE_Sandbox_Operations_Production].[dbo].[RefCost_APC_National_1718] as c
on apc.[APCS_Ident_min] = c.[APCS_Ident]


WHERE 			
	apc.[Discharge_Date] >= '2024-04-01' -- current FY, YTD

-- add in the below if you are looking at a range (for e.g between financial years)
--	and apc.[Discharge_Date] < '2025-04-01'

	and apc.[Commissioner_Type] <> 'Private Patient' -- Excluding private patients
	and apc.[Dimention_4] = 'Specific Acute' -- National planning guidance is specific acute only - excluding some maternity and LDA MH activity
	and Der_Management_Type in ('EM','NE') -- selecting the key elective PODS
	and apc.[Provider_Current] like 'R%'-- acute providers only
	and apc.[Provider_Current] <> 'RDY' -- remove community providers
	and apc.[Provider_Current] <> 'RTQ' -- remove community providers
	and apc.[Provider_Current] <> 'RJ8' -- remove community providers
	and o.Region_Name = 'South West') -- south west region only



,CTE_AE as (

SELECT

'A&E ALL' as 'Activity type'
	
-- Sum Unit Costs		

,SUM(c.Unit_Cost_all) as Unit_cost

--,Format(SUM(c.Unit_Cost_all),'£#,0.') as Unit_cost


FROM [NHSE_SUSPlus_Reporting].[Data].[PAT_Intermediate_Table_AE] AE

--Join to National Unit cost table to bring in unit costs

left join[NHSE_Sandbox_Operations_Production].[dbo].[RefCost_AE_National_1718] as c
on AE.[AEA_Ident_min] = c.[AEA_Ident]

--Join to reference tables to bring in provider and system names

left join [NHSE_Reference].[dbo].[tbl_Ref_ODS_Provider_Hierarchies] as o
on ae.Provider_Current = o.Organisation_Code


WHERE 		

	ae.[Attendance_Date] >= '2024-04-01' -- current FY, YTD

-- add in the below if you are looking at a range (for e.g between financial years)
--	and ae.[Attendance_Date] < '2025-04-01'
	and ae.[Commissioner_Type] <> 'Private Patient' -- Excluding private patients
	and ae.[Provider_Current] like 'R%'-- acute providers only
	and ae.[Provider_Current] <> 'RDY' -- remove community providers
	and ae.[Provider_Current] <> 'RTQ' -- remove community providers
	and ae.[Provider_Current] <> 'RJ8' -- remove community providers
	and o.Region_Name = 'South West') -- south west region only


,CTE_ALL as (

Select *

From CTE_APC

union all

Select *

From CTE_OPFA

union all

Select *

From CTE_OPFU

union all

Select *

From CTE_NEL

union all

Select *

From CTE_AE)

,CTE_TOTES as (Select 

'Total' as 'Actvity Type'
,SUM(Unit_Cost) as Unit_cost

FROM CTE_ALL)


,CTE_OUTPUT as (

Select 

[Actvity Type]
,unit_cost
,1 as Proportion

FROM CTE_TOTES

union

select 

[Activity Type]
,Unit_cost
,Unit_cost/(select Unit_cost FROM CTE_TOTES) as Proportion


FROM CTE_ALL)

Select

[Actvity Type]
,Format((Unit_Cost),'£#,0.') as Unit_cost
,FORMAT(Proportion,'#,0.00%') as Proportion

FROM CTE_OUTPUT