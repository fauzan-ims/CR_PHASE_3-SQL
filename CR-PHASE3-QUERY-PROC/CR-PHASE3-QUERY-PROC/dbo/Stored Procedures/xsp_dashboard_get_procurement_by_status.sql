CREATE PROCEDURE dbo.xsp_dashboard_get_procurement_by_status
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
	from		dbo.procurement
	where		status = 'NEW'
				and month(procurement_request_date) = month(dbo.xfn_get_system_date())
				and year(procurement_request_date) = year(dbo.xfn_get_system_date())
	union
	select		count(1)
				,2
				,'POST'
	from		dbo.procurement
	where		status = 'POST'
				and month(procurement_request_date) = month(dbo.xfn_get_system_date())
				and year(procurement_request_date) = year(dbo.xfn_get_system_date())
	union
	select		count(1)
				,3
				,'CANCEL'
	from		dbo.procurement
	where		status = 'CANCEL'
				and month(procurement_request_date) = month(dbo.xfn_get_system_date())
				and year(procurement_request_date) = year(dbo.xfn_get_system_date())
	

	select	total_data
			,reff_name
			,'Status' 'series_name'
	from	@temp_table
	order by order_key asc;
end ;
