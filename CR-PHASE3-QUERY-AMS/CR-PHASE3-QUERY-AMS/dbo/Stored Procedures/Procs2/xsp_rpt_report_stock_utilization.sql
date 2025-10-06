--Created, Aliv at 29-05-2023
CREATE PROCEDURE dbo.xsp_rpt_report_stock_utilization
(
	@p_user_id			nvarchar(50) = ''
	,@p_as_of_date		datetime		= null
)
as
BEGIN

	delete rpt_report_stock_utilization
	where	user_id = @p_user_id;

	declare @msg							nvarchar(max)
			,@report_company				nvarchar(250)
			,@report_title					nvarchar(250)
			,@report_image					nvarchar(250)
			,@leased_object					nvarchar(50)
			,@year							int			
			,@plat_no						nvarchar(50)
			,@status						nvarchar(50)
			,@remarks						nvarchar(100)
			,@share_date					datetime	
			,@aging							int			
	
	begin try
	
		select	@report_company = value
		from	dbo.SYS_GLOBAL_PARAM
		where	CODE = 'COMP' ;

		set	@report_title = 'REPORT PER CUSTOMER';

		select	@report_image = value
		from	dbo.SYS_GLOBAL_PARAM
		where	CODE = 'IMGDSF' ;

	BEGIN

			insert into rpt_report_stock_utilization
			(
				user_id
				,report_company
				,report_title
				,report_image
				,leased_object		
				,year				
				,plat_no			
				,status			
				,remarks			
				,share_date		
				,aging					
			)
			VALUES
			(
				@p_user_id
				,@report_company				
				,@report_title
				,@report_image
				,@leased_object		
				,@year				
				,@plat_no			
				,@status			
				,@remarks			
				,@share_date		
				,@aging													
			)
	end
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
			set @msg = 'V' + ';' + @msg ;
		end ;
		else
		begin
			set @msg = 'E;' + dbo.xfn_get_msg_err_generic() + ';' + error_message() ;
		end ;

		raiserror(@msg, 16, -1) ;

		return ;
	end catch ;
end ;

