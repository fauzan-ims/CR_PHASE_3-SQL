CREATE PROCEDURE dbo.xsp_dashboard_get_procurement_request_by_status
(
	@p_company_code		nvarchar(50)
)
as
begin
	declare @msg nvarchar(max) ;

	declare @temp_table table
	(
		total_data int
		,order_key int
		,reff_name nvarchar(250)
	) ;

	insert into @temp_table
	(
		total_data
		,order_key
		,reff_name
	)
	select		count(1)
				,1
				,'NEW'
	from		dbo.procurement_request
	where		status = 'NEW'
				and month(request_date) = month(dbo.xfn_get_system_date())
				and year(request_date) = year(dbo.xfn_get_system_date())
	union
	select		count(1)
				,2
				,'ON PROCESS'
	from		dbo.procurement_request
	where		status = 'ON PROGRESS'
				and month(request_date) = month(dbo.xfn_get_system_date())
				and year(request_date) = year(dbo.xfn_get_system_date())
	union
	select		count(1)
				,3
				,'POST'
	from		dbo.procurement_request
	where		status = 'POST'
				and month(request_date) = month(dbo.xfn_get_system_date())
				and year(request_date) = year(dbo.xfn_get_system_date())
	union
	select		count(1)
				,4
				,'VERIFIED'
	from		dbo.procurement_request
	where		status = 'VERIFIED'
				and month(request_date) = month(dbo.xfn_get_system_date())
				and year(request_date) = year(dbo.xfn_get_system_date())
	union
	select		count(1)
				,5
				,'CANCEL'
	from		dbo.procurement_request
	where		status = 'CANCEL'
				and month(request_date) = month(dbo.xfn_get_system_date())
				and year(request_date) = year(dbo.xfn_get_system_date())
	union
	select		count(1)
				,6
				,'REJECTED'
	from		dbo.procurement_request
	where		status = 'REJECTED'
				and month(request_date) = month(dbo.xfn_get_system_date())
				and year(request_date) = year(dbo.xfn_get_system_date())
	

	select	total_data
			,reff_name
			,'Status' 'series_name'
	from	@temp_table
	order by order_key asc;
end ;
