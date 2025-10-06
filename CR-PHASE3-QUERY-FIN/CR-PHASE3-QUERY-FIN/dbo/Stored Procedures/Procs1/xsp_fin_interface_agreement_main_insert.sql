CREATE PROCEDURE dbo.xsp_fin_interface_agreement_main_insert
(
	@p_id						 bigint = 0 output
	,@p_agreement_no			 nvarchar(50)
	,@p_agreement_external_no	 nvarchar(50)
	,@p_branch_code				 nvarchar(50)
	,@p_branch_name				 nvarchar(250)
	,@p_agreement_date			 datetime
	,@p_agreement_status		 nvarchar(10)
	,@p_agreement_sub_status	 nvarchar(20)
	,@p_currency_code			 nvarchar(3)
	,@p_termination_date		 datetime
	,@p_termination_status		 nvarchar(20)
	,@p_client_code				 nvarchar(50)
	,@p_client_name				 nvarchar(250)
	,@p_asset_description		 nvarchar(250)
	,@p_collateral_description	 nvarchar(250)
	,@p_last_paid_installment_no int
	,@p_overdue_period			 int
	,@p_is_remedial				 nvarchar(1)
	,@p_is_wo					 nvarchar(1)
	,@p_installment_amount		 decimal(18, 2)
	,@p_installment_due_date	 datetime
	,@p_overdue_days			 int
	,@p_factoring_type			 nvarchar(10)
	,@p_job_status				 nvarchar(10)
	,@p_failed_remarks			 nvarchar(4000)
	--
	,@p_cre_date				 datetime
	,@p_cre_by					 nvarchar(15)
	,@p_cre_ip_address			 nvarchar(15)
	,@p_mod_date				 datetime
	,@p_mod_by					 nvarchar(15)
	,@p_mod_ip_address			 nvarchar(15)
)
as
begin
	declare @msg nvarchar(max) ;

	if @p_is_remedial = 'T'
		set @p_is_remedial = '1' ;
	else
		set @p_is_remedial = '0' ;

	if @p_is_wo = 'T'
		set @p_is_wo = '1' ;
	else
		set @p_is_wo = '0' ;

	begin try
		insert into fin_interface_agreement_main
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
			,factoring_type
			,job_status
			,failed_remarks
			--
			,cre_date
			,cre_by
			,cre_ip_address
			,mod_date
			,mod_by
			,mod_ip_address
		)
		values
		(	@p_agreement_no
			,@p_agreement_external_no
			,@p_branch_code
			,@p_branch_name
			,@p_agreement_date
			,@p_agreement_status
			,@p_agreement_sub_status
			,@p_currency_code
			,@p_termination_date
			,@p_termination_status
			,@p_client_code
			,@p_client_name
			,@p_asset_description
			,@p_collateral_description
			,@p_last_paid_installment_no
			,@p_overdue_period
			,@p_is_remedial
			,@p_is_wo
			,@p_installment_amount
			,@p_installment_due_date
			,@p_overdue_days
			,@p_factoring_type
			,@p_job_status
			,@p_failed_remarks
			--
			,@p_cre_date
			,@p_cre_by
			,@p_cre_ip_address
			,@p_mod_date
			,@p_mod_by
			,@p_mod_ip_address
		) ;

		set @p_id = @@identity ;
	end try
	begin catch
		declare @error int ;

		set @error = @@error ;

		if (@error = 2627)
		begin
			set @msg = dbo.xfn_get_msg_err_code_already_exist() ;
		end ;
		else if (@error = 547)
		begin
			set @msg = dbo.xfn_get_msg_err_code_already_used() ;
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
