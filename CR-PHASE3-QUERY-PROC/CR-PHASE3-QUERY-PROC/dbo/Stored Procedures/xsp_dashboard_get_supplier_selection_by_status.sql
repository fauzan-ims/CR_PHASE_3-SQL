create PROCEDURE [dbo].[xsp_dashboard_get_supplier_selection_by_status]
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
				,'HOLD'
	from		dbo.supplier_selection
	where		status = 'HOLD'

	union
	select		count(1)
				,2
				,'POST'
	from		dbo.supplier_selection
	where		status = 'POST'

	union
	select		count(1)
				,3
				,'CANCEL'
	from		dbo.supplier_selection
	where		status = 'CANCEL'

	union
	select		count(1)
				,3
				,'ON PROCESS'
	from		dbo.supplier_selection
	where		status = 'ON PROCESS'

	union
	select		count(1)
				,3
				,'REJECT'
	from		dbo.supplier_selection
	where		status = 'REJECT'

	union
	select		count(1)
				,3
				,'APPROVE'
	from		dbo.supplier_selection
	where		status = 'APPROVE'

	select	total_data
			,reff_name
			,'Status' 'series_name'
	from	@temp_table
	order by order_key asc;
end ;
