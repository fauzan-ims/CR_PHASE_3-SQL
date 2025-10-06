--created by, Rian at 08/05/2023 

CREATE PROCEDURE [dbo].[xsp_due_date_change_amortization_history_update]
(
	@p_due_date_change_code nvarchar(50)
	,@p_installment_no		int
	,@p_asset_no			nvarchar(50)
	--,@p_due_date			datetime
	,@p_billing_date		DATETIME 
	--,@p_billing_amount		decimal(18, 2)
	--,@p_description			nvarchar(4000)
	,@p_old_or_new			nvarchar(3) = 'NEW'
	--
	,@p_mod_date			datetime
	,@p_mod_by				nvarchar(15)
	,@p_mod_ip_address		nvarchar(15)
)
as
begin
	declare @msg nvarchar(max) ;

	begin try
	
		if(@p_old_or_new = 'NEW')
		begin
			update	dbo.due_date_change_amortization_history
			set		billing_date			= @p_billing_date
					--,due_date_change_code	= @p_due_date_change_code
					--,installment_no			= @p_installment_no
					--,asset_no				= @p_asset_no
					--,due_date				= @p_due_date
					--,billing_amount			= @p_billing_amount
					--,description			= @p_description
					--,old_or_new				= @p_old_or_new
		
					--
					,mod_date				= @p_mod_date
					,mod_by					= @p_mod_by
					,mod_ip_address			= @p_mod_ip_address
			where	asset_no				= @p_asset_no 
			and		installment_no			= @p_installment_no
			and		due_date_change_code	= @p_due_date_change_code
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
