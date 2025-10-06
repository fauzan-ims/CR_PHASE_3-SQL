--Created, Aliv at 29-05-2023
CREATE PROCEDURE dbo.xsp_rpt_stock_utilization
(
	@p_user_id		 nvarchar(50)
	,@p_as_of_date	 datetime
	,@p_is_condition nvarchar(1)
)
as
begin
	delete	rpt_stock_utilization
	where	user_id = @p_user_id ;

	declare @msg			 nvarchar(max)
			,@report_company nvarchar(250)
			,@report_title	 nvarchar(250)
			,@report_image	 nvarchar(250)
			,@leased_object	 nvarchar(50)
			,@year			 int
			,@plat_no		 nvarchar(50)
			,@status		 nvarchar(50)
			,@remarks		 nvarchar(100)
			,@share_date	 datetime
			,@aging			 int ;

	begin try
		select	@report_company = value
		from	dbo.SYS_GLOBAL_PARAM
		where	CODE = 'COMP2' ;

		set @report_title = N'Report Stock Car Utilization' ;

		select	@report_image = value
		from	dbo.SYS_GLOBAL_PARAM
		where	CODE = 'IMGDSF' ;

		begin
			insert into rpt_stock_utilization
			(
				user_id
				,report_company
				,report_title
				,report_image
				,as_of_date
				,leased_object
				,year
				,plat_no
				,status
				,remarks
				,share_date
				,aging
				,is_condition
			)
			select	@p_user_id
					,@report_company
					,@report_title
					,@report_image
					,@p_as_of_date
					,ast.item_name
					,avi.built_year
					,avi.plat_no
					,ast.status
					,ast.remarks
					,null
					,isnull(datediff(day, cast(ast.purchase_date as date), dbo.xfn_get_system_date()), 0)
					,@p_is_condition
			from	ifinams.dbo.asset					 ast
					inner join ifinams.dbo.asset_vehicle avi on avi.asset_code = ast.code
			where	ast.status							= 'STOCK'
					and cast(ast.purchase_date as date) <= cast(@p_as_of_date as date) ;

			if not exists
			(
				select	1
				from	dbo.rpt_stock_utilization
				where	user_id = @p_user_id
			)
			begin
				insert into dbo.rpt_stock_utilization
				(
					user_id
					,report_company
					,report_title
					,report_image
					,as_of_date
					,leased_object
					,year
					,plat_no
					,status
					,remarks
					,share_date
					,aging
					,is_condition
				)
				values
				(
					@p_user_id
					,@report_company
					,@report_title
					,@report_image
					,@p_as_of_date
					,null
					,null
					,null
					,null
					,null
					,null
					,null
					,@p_is_condition
				) ;
			end ;
		end ;
	end try
	begin catch
		declare @error int ;

		set @error = @@error ;

		if (@error = 2627)
		begin
			set @msg = dbo.xfn_get_msg_err_code_already_exist() ;
		end ;

		if (len(@msg) <> 0)
		begin
			set @msg = N'V' + N';' + @msg ;
		end ;
		else
		begin
			set @msg = N'E;' + dbo.xfn_get_msg_err_generic() + N';' + error_message() ;
		end ;

		raiserror(@msg, 16, -1) ;

		return ;
	end catch ;
end ;
