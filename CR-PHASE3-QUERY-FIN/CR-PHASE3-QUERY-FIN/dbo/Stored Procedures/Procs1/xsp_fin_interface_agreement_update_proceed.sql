/*
	created: Fadlan, 27 Mei 2021
*/
CREATE procedure dbo.xsp_fin_interface_agreement_update_proceed
(		
	@p_agreement_no			nvarchar(50)
	--
	,@p_cre_date			datetime
	,@p_cre_by				nvarchar(15)
	,@p_cre_ip_address		nvarchar(15)
	,@p_mod_date			datetime
	,@p_mod_by				nvarchar(15)
	,@p_mod_ip_address		nvarchar(15)
)
as
begin
	declare @msg						nvarchar(max)
			,@agreement_status			nvarchar(10)
			,@agreement_sub_status		nvarchar(10)
			,@termination_date			datetime
			,@termination_status		nvarchar(10)
			,@client_name				nvarchar(250)
			,@is_remedial				nvarchar(1)
			,@last_paid_installment_no	int
			,@overdue_period			int
			,@overdue_days				int
			,@is_wo						nvarchar(1);
			
	begin try
				
		select @agreement_status		= agreement_status
			 ,@agreement_sub_status		= agreement_sub_status
			 ,@termination_date			= termination_date
			 ,@termination_status		= termination_status
			 ,@last_paid_installment_no = last_paid_installment_no
			 ,@overdue_period			= overdue_period
			 ,@is_remedial				= is_remedial
			 ,@is_wo					= is_wo
			 ,@overdue_days				= overdue_days
		from  dbo.fin_interface_agreement_update
		where	agreement_no = @p_agreement_no

		update dbo.agreement_main
		set agreement_status    		= @agreement_status		
			,agreement_sub_status		= @agreement_sub_status
			,termination_date			= @termination_date
			,termination_status			= @termination_status	
			,last_paid_installment_no	= @last_paid_installment_no
            ,overdue_period				= @overdue_period
            ,overdue_days				= @overdue_days
            ,is_remedial				= @is_remedial
            ,is_wo						= @is_wo
		    ,cre_by						= @p_mod_by						
		    ,cre_ip_address				= @p_mod_ip_address					
		    ,mod_date					= @p_mod_date						
		    ,mod_by						= @p_mod_by							
		    ,mod_ip_address				= @p_mod_ip_address					
		where agreement_no				= @p_agreement_no

		update	dbo.fin_interface_agreement_update --cek poin
		set		job_status = 'POST'
				,failed_remarks = null
		where	agreement_no = @p_agreement_no
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

