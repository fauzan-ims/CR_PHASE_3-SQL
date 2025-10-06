--Created, Aliv at 29-05-2023
CREATE PROCEDURE dbo.xsp_rpt_detail_unit_stock
(
	@p_user_id			nvarchar(50) = ''
	,@monthly			int = null
)
as
BEGIN

	delete rpt_detail_unit_stock
	where	user_id = @p_user_id;

	declare @msg							nvarchar(max)
			,@report_company				nvarchar(250)
			,@report_title					nvarchar(250)
			,@report_image					nvarchar(250)
			,@status_allocation				nvarchar(50)	
			,@status						nvarchar(50)	
	
	begin try
	
		select	@report_company = value
		from	dbo.SYS_GLOBAL_PARAM
		where	CODE = 'COMP2' ;

		set	@report_title = 'REPORT PER CUSTOMER';

		select	@report_image = value
		from	dbo.SYS_GLOBAL_PARAM
		where	CODE = 'IMGDSF' ;

	BEGIN

			insert into rpt_detail_unit_stock
			(
				user_id
				,report_company
				,report_title
				,report_image
				,status_allocation	
				,status			
				,parameter_month	
			)
			VALUES
			(
				@p_user_id
				,@report_company				
				,@report_title
				,@report_image
				,@status_allocation	
				,@status				
				,@monthly												
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

