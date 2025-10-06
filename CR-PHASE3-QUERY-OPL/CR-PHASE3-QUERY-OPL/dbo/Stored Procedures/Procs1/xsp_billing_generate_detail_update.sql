CREATE PROCEDURE dbo.xsp_billing_generate_detail_update
(
	@p_id						bigint
	,@p_generate_code			nvarchar(50)
	,@p_agreement_no			nvarchar(50)
	,@p_asset_no				nvarchar(50)
	,@p_billing_no				int
	,@p_due_date				datetime
	,@p_rental_amount			decimal(18, 2)
	,@p_description				nvarchar(4000)
		--
	,@p_mod_date				datetime
	,@p_mod_by					nvarchar(15)
	,@p_mod_ip_address			nvarchar(15)
)
as
begin
	declare @msg nvarchar(max) ;

	begin try

		update	billing_generate_detail
		set		agreement_no	= @p_agreement_no
				,asset_no		= @p_asset_no
				,billing_no		= @p_billing_no
				,due_date		= @p_due_date
				,rental_amount	= @p_rental_amount
				,description	= @p_description
				--
				,mod_date	= @p_mod_date
				,mod_by	= @p_mod_by
				,mod_ip_address	= @p_mod_ip_address
		where		id	= @p_id

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
end
