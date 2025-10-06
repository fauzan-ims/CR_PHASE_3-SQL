CREATE PROCEDURE dbo.xsp_opl_interface_agreement_main_out_insert
(
	@p_agreement_no	   nvarchar(50)
	--
	,@p_cre_date	   datetime
	,@p_cre_by		   nvarchar(15)
	,@p_cre_ip_address nvarchar(15)
	,@p_mod_date	   datetime
	,@p_mod_by		   nvarchar(15)
	,@p_mod_ip_address nvarchar(15)
)
as
begin
	declare @msg nvarchar(max) ;

	begin try
		insert into dbo.opl_interface_agreement_main_out
		(
			agreement_no
			,agreement_external_no
			,application_no
			,agreement_date
			,agreement_status
			,termination_date
			,termination_status
			,branch_code
			,branch_name
			,initial_branch_code
			,initial_branch_name
			,collateral_description
			,asset_description
			,facility_code
			,facility_name
			,purpose_loan_code
			,purpose_loan_name
			,purpose_loan_detail_code
			,purpose_loan_detail_name
			,currency_code
			,client_type
			,client_no
			,client_name
			,payment_with_code
			,payment_with_name
			,last_paid_period
			,overdue_period
			,overdue_days
			,overdue_installment_amount
			,overdue_penalty_amount
			,outstanding_installment_amount
			,outstanding_deposit_amount
			,factoring_type
			,reff_1
			,reff_2
			,reff_3
			,reff_4
			,reff_5
			,reff_6
			,reff_7
			,reff_8
			,reff_9
			,reff_10
			--
			,cre_date
			,cre_by
			,cre_ip_address
			,mod_date
			,mod_by
			,mod_ip_address
		)
		select	am.agreement_no
				,agreement_external_no
				,application_no
				,agreement_date
				,agreement_status
				,termination_date
				,termination_status
				,branch_code
				,branch_name
				,initial_branch_code
				,initial_branch_name
				,null
				,isnull(ass.asset_name, '')
				,facility_code
				,facility_name
				,null
				,null
				,null
				,null
				,am.currency_code
				,client_type
				,client_no
				,client_name
				,null --isnull(at.payment_with_code, '')
				,null --isnull(at.payment_with_name, '')
				,null --isnull(ai.last_paid_period, '')
				,null --isnull(ai.ovd_period, 0)
				,null --isnull(ai.ovd_days, 0)
				,null --isnull(ai.ovd_installment_amount, 0)
				,null --isnull(ai.ovd_penalty_amount, 0)
				,null --isnull(ai.os_installment_amount, 0)
				,null --isnull(ai.os_deposit_installment_amount, 0)
				,null --am.factoring_type
				,null --ame.reff_1
				,null --ame.reff_2
				,null --ame.reff_3
				,null --ame.reff_4
				,null --ame.reff_5
				,null --ame.reff_6
				,null --ame.reff_7
				,null --ame.reff_8
				,null --ame.reff_9
				,null --ame.reff_10
				--
				,@p_cre_date
				,@p_cre_by
				,@p_cre_ip_address
				,@p_mod_date
				,@p_mod_by
				,@p_mod_ip_address
		from	dbo.agreement_main am
				outer apply
		(
			select top 1
					asset_name
			from	dbo.agreement_asset ass
			where	ass.agreement_no = am.agreement_no
		) ass 
		where	am.agreement_no = @p_agreement_no ;
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

