--Created, Aliv at 29-05-2023
CREATE PROCEDURE dbo.xsp_rpt_report_per_customer
(
	@p_user_id			nvarchar(50) = ''
	,@p_branch_code		NVARCHAR(50) = ''
)
as
BEGIN

	delete dbo.rpt_report_per_customer
	where	user_id = @p_user_id;

	declare @msg							nvarchar(max)
			,@report_company				nvarchar(250)
			,@report_title					nvarchar(250)
			,@report_image					nvarchar(250)
			,@customer_name					nvarchar(50)
			,@total_unit					int			
			,@total_budget					decimal(18, 2)
			,@current_budget				decimal(18, 2)
			,@total_actual_cost				decimal(18, 2)
			,@sisa_budget					decimal(18, 2)
			,@actual_cos_or_total_budget	decimal(9, 6)
			,@actual_cos_or_current_budget	decimal(9, 6)
	
	begin try
	
		select	@report_company = value
		from	dbo.SYS_GLOBAL_PARAM
		where	CODE = 'COMP' ;

		set	@report_title = 'REPORT PER CUSTOMER';

		select	@report_image = value
		from	dbo.SYS_GLOBAL_PARAM
		where	CODE = 'IMGDSF' ;

	BEGIN

			insert into rpt_report_per_customer
			(
				user_id
				,report_company
				,report_title
				,report_image
				,customer_name
				,total_unit
				,total_budget
				,current_budget
				,total_actual_cost
				,sisa_budget
				,actual_cos_or_total_budget
				,actual_cos_or_current_budget

			)
			VALUES
			(
				@p_user_id
				,@report_company				
				,@report_title
				,@report_image
				,@customer_name					
				,@total_unit					
				,@total_budget					
				,@current_budget				
				,@total_actual_cost				
				,@sisa_budget					
				,@actual_cos_or_total_budget	
				,@actual_cos_or_current_budget	
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

