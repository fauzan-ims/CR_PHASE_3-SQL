--Created, Aliv at 29-05-2023
CREATE PROCEDURE dbo.xsp_rpt_report_per_unit
(
	@p_user_id			nvarchar(50) = ''
	,@p_branch_code		NVARCHAR(50) = ''
)
as
BEGIN

	delete dbo.rpt_report_per_unit
	where	user_id = @p_user_id;

	declare @msg							nvarchar(max)
			,@report_company				nvarchar(250)
			,@report_title					nvarchar(250)
			,@report_image					nvarchar(250)	
			,@agreement_no					nvarchar(50)	
			,@customer						nvarchar(150)	
			,@obj_lease						nvarchar(50)	
			,@provinsi						nvarchar(50)	
			,@kota							nvarchar(50)	
			,@plat_no						nvarchar(50)	
			,@chassis_no					nvarchar(50)	
			,@engine_no						nvarchar(50)	
			,@periode						nvarchar(50)	
			,@contract_period_from			datetime		
			,@contract_period_to			datetime		
			,@budget_skd					decimal(18,2)
			,@budget_month					decimal(18,2)	
			,@current_period				int	
			,@current_budget				decimal(18,2)	
			,@current_maintenance			decimal(18,2)	
			,@frequency_service				int
			,@profit_loss					decimal(18,2)	
	
	begin try
	
		select	@report_company = value
		from	dbo.SYS_GLOBAL_PARAM
		where	CODE = 'COMP' ;

		set	@report_title = 'PHYSICAL UNIT CHECKING FORM';

		select	@report_image = value
		from	dbo.SYS_GLOBAL_PARAM
		where	CODE = 'IMGDSF' ;

	BEGIN

			insert into rpt_report_per_unit
			(
				user_id
				,report_company
				,report_title
				,report_image
				,agreement_no
				,customer
				,obj_lease
				,provinsi
				,kota
				,plat_no
				,chassis_no
				,engine_no
				,periode
				,contract_period_from
				,contract_period_to
				,budget_skd
				,budget_month
				,current_period
				,current_budget
				,current_maintenance
				,frequency_service
				,profit_loss


			)
			VALUES
			(
				@p_user_id
				,@report_company				
				,@report_title
				,@report_image
				,@agreement_no			
				,@customer				
				,@obj_lease				
				,@provinsi				
				,@kota					
				,@plat_no				
				,@chassis_no			
				,@engine_no				
				,@periode				
				,@contract_period_from	
				,@contract_period_to	
				,@budget_skd			
				,@budget_month			
				,@current_period		
				,@current_budget		
				,@current_maintenance	
				,@frequency_service		
				,@profit_loss			
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

