/*
	created: Fadlan, 27 Mei 2021
*/
create procedure dbo.xsp_fin_interface_agreement_main_proceed
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
	declare @msg						nvarchar(max);
			
	begin try
				
		insert into dbo.AGREEMENT_MAIN
		(
			agreement_no
			,agreement_external_no
			,branch_code
			,branch_name
			,agreement_date
			,agreement_status
			,agreement_sub_status
			,currency_code
			,termination_date
			,termination_status
			,client_code
			,client_name
			,asset_description
			,collateral_description
			,last_paid_installment_no
			,overdue_period
			,is_remedial
			,is_wo
			,installment_amount
			,installment_due_date
			,overdue_days
			,cre_by
			,cre_ip_address
			,mod_date
			,mod_by
			,mod_ip_address
		)
		select	agreement_no
				,agreement_external_no
				,branch_code
				,branch_name
				,agreement_date
				,agreement_status
				,agreement_sub_status
				,currency_code
				,termination_date
				,termination_status
				,client_code
				,client_name
				,asset_description
				,collateral_description
				,last_paid_installment_no
				,overdue_period
				,is_remedial
				,is_wo
				,installment_amount
				,installment_due_date
				,overdue_days
				,@p_mod_by		
				,@p_mod_ip_address 
				,@p_mod_date		
				,@p_mod_by		
				,@p_mod_ip_address  
		from  dbo.fin_interface_agreement_main
		where agreement_no = @p_agreement_no

		update	dbo.fin_interface_agreement_main --cek poin
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

