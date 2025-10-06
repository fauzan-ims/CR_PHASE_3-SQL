CREATE PROCEDURE dbo.xsp_application_fee_update
(
	@p_id						   bigint
	,@p_application_no			   nvarchar(50)
	,@p_fee_code				   nvarchar(50)
	,@p_default_fee_rate		   decimal(9, 6)  = 0
	,@p_default_fee_amount		   decimal(18, 2) = 0
	,@p_fee_amount				   decimal(18, 2) 
	,@p_remarks					   nvarchar(4000) = ''
	--
	,@p_mod_date				   datetime
	,@p_mod_by					   nvarchar(15)
	,@p_mod_ip_address			   nvarchar(15)
)
as
begin
	declare @msg nvarchar(max) ;

	begin try

		update	application_fee
		set		fee_code			= @p_fee_code
				,default_fee_rate	= @p_default_fee_rate
				,default_fee_amount = @p_default_fee_amount
				,fee_amount			= @p_fee_amount 
				,remarks			= @p_remarks
				--
				,mod_date			= @p_mod_date
				,mod_by				= @p_mod_by
				,mod_ip_address		= @p_mod_ip_address
		where	id					= @p_id
				and application_no	= @p_application_no ;

		--exec dbo.xsp_application_refund_update_is_valid @p_application_no = @p_application_no ;

		--exec dbo.xsp_application_main_financing_amount_update @p_application_no = @p_application_no
		--													  ,@p_update_type = 'FEE'
		--													  ,@p_mod_date = @p_mod_date
		--													  ,@p_mod_by = @p_mod_by
		--													  ,@p_mod_ip_address = @p_mod_ip_address ;
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

