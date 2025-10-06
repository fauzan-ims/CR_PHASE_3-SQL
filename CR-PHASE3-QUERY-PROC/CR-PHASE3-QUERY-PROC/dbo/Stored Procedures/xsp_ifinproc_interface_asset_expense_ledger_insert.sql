CREATE PROCEDURE dbo.xsp_ifinproc_interface_asset_expense_ledger_insert
(	
	@p_id							bigint = 0 output
	,@p_asset_code					nvarchar(50)
	,@p_date						datetime
	,@p_reff_code					nvarchar(50)
	,@p_reff_name					nvarchar(250)
	,@p_reff_remark					nvarchar(4000)
	,@p_expense_amount				decimal(18,2)
	,@p_agreement_no				nvarchar(50)
	,@p_client_name					nvarchar(250)
	,@p_settle_date					datetime
	,@p_job_status					nvarchar(15)
	--
	,@p_cre_date					datetime
	,@p_cre_by						nvarchar(50)
	,@p_cre_ip_address				nvarchar(50)
	,@p_mod_date					datetime
	,@p_mod_by						nvarchar(50)
	,@p_mod_ip_address				nvarchar(50)
)
as
begin
	declare @msg	nvarchar(max);

	begin try

		insert into dbo.ifinproc_interface_asset_expense_ledger
		(
			asset_code
			,date
			,reff_code
			,reff_name
			,reff_remark
			,expense_amount
			,agreement_no
			,client_name
			,settle_date
			,job_status
			--
			,cre_date
			,cre_by
			,cre_ip_address
			,mod_date
			,mod_by
			,mod_ip_address
		)
		values
		(
			@p_asset_code
			,@p_date
			,@p_reff_code
			,@p_reff_name
			,@p_reff_remark
			,@p_expense_amount
			,@p_agreement_no
			,@p_client_name
			,@p_settle_date
			,@p_job_status
			--
			,@p_cre_date
			,@p_cre_by
			,@p_cre_ip_address
			,@p_mod_date
			,@p_mod_by
			,@p_mod_ip_address
		)set @p_id = @@identity ;

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
