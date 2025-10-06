CREATE PROCEDURE dbo.xsp_application_information_insert
(
	@p_application_no		  nvarchar(50)
	,@p_workflow_step		  int
	,@p_application_flow_code nvarchar(50)
	,@p_screen_flow_code	  nvarchar(50)
	,@p_is_refunded			  nvarchar(1)
	,@p_reff_loan_no		  nvarchar(50) = null 
	--
	,@p_cre_date			  datetime
	,@p_cre_by				  nvarchar(15)
	,@p_cre_ip_address		  nvarchar(15)
	,@p_mod_date			  datetime
	,@p_mod_by				  nvarchar(15)
	,@p_mod_ip_address		  nvarchar(15)
)
as
begin
	declare @msg nvarchar(max) ;

	begin try
		insert into application_information
		(
			application_no
			,workflow_step
			,application_flow_code
			,screen_flow_code
			,is_refunded
			,reff_loan_no 
			--
			,cre_date
			,cre_by
			,cre_ip_address
			,mod_date
			,mod_by
			,mod_ip_address
		)
		values
		(	@p_application_no
			,@p_workflow_step
			,@p_application_flow_code
			,@p_screen_flow_code
			,@p_is_refunded
			,@p_reff_loan_no 
			--
			,@p_cre_date
			,@p_cre_by
			,@p_cre_ip_address
			,@p_mod_date
			,@p_mod_by
			,@p_mod_ip_address
		) ;
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
			if (error_message() like '%V;%' or error_message() like '%E;%')
			begin
				set @msg = error_message() ;
			end
			else 
			begin
				set @msg = 'E;' + dbo.xfn_get_msg_err_generic() + ';' + error_message() ;
			end
		end ;

		raiserror(@msg, 16, -1) ;

		return ;
	end catch ;	
end ;


