CREATE PROCEDURE dbo.xsp_dashboard_get_asset_by_category
(
	@p_company_code		nvarchar(50)
)
as
begin
	declare @msg			nvarchar(max)
			,@total_data	int
			,@region_name	nvarchar(250)
			,@status		nvarchar(250)
			,@series_name	nvarchar(50)
			,@year			nvarchar(4)
			,@code			nvarchar(50)
	
	declare cursor_name cursor fast_forward read_only for
	select		distinct
				count(category_code)
				,category_name 
	from		dbo.asset
	where		status = 'AVAILABLE'
	and			company_code = 'DSF' 
	group by	category_name --,  
	
	open cursor_name
	
	fetch next from cursor_name 
	into @total_data
		,@region_name 

	while @@fetch_status = 0
	begin
			declare @temp_table table
			(
				total_data		decimal(18,2)
				,reff_name		nvarchar(250)
				,series_name	nvarchar(50) 
			) ;

			insert into @temp_table
			(
				total_data
				,reff_name
				,series_name 
			)
			values
			(	@total_data
				,@region_name
				,'Aset By Category'   
			) 

			
		
		    fetch next from cursor_name 
			into @total_data
				,@region_name 
		end
	
	close cursor_name
	deallocate cursor_name

	select	total_data
			,reff_name 
	from	@temp_table ;

end ;
