--created by, Rian at 08/05/2023 

CREATE PROCEDURE dbo.xsp_due_date_change_amortization_history_insert
(
	@p_due_date_change_code nvarchar(50)
	,@p_installment_no		int
	,@p_asset_no			nvarchar(50)
	,@p_due_date			datetime
	,@p_billing_date		datetime
	,@p_billing_amount		decimal(18, 2)
	,@p_description			nvarchar(4000)
	,@p_old_or_new			nvarchar(3)
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
	declare @msg nvarchar(max) ;

	begin try
		insert into dbo.due_date_change_amortization_history
		(
			due_date_change_code
			,installment_no
			,asset_no
			,due_date
			,billing_date
			,billing_amount
			,description
			,old_or_new
			--
			,cre_date
			,cre_by
			,cre_ip_address
			,mod_date
			,mod_by
			,mod_ip_address
		)
		values
		(	@p_due_date_change_code
			,@p_installment_no
			,@p_asset_no
			,@p_due_date
			,@p_billing_date
			,@p_billing_amount
			,@p_description
			,@p_old_or_new
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

		--if (@error = 2627)
		--begin
		--	set @msg = dbo.xfn_get_msg_err_code_already_exist() ;
		--end ;

		if (len(@msg) <> 0)
		begin
			set @msg = 'V' + ';' + @msg ;
		end ;
		else
		begin
			if (
				   error_message() like '%V;%'
				   or	error_message() like '%E;%'
			   )
			begin
				set @msg = error_message() ;
			end ;
			else
			begin
				set @msg = 'E;' + dbo.xfn_get_msg_err_generic() + ';' + error_message() ;
			end ;
		end ;

		raiserror(@msg, 16, -1) ;

		return ;
	end catch ;
end ;
