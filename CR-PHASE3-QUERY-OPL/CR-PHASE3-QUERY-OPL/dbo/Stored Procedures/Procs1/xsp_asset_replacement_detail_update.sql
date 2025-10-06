CREATE PROCEDURE dbo.xsp_asset_replacement_detail_update
(
	@p_id								bigint
	,@p_estimate_return_date			datetime = null
	,@p_remark							nvarchar(4000)=''
	,@p_delivery_address				nvarchar(4000)=''
	,@p_contact_phone_no				nvarchar(4000)=''
	,@p_contact_name					nvarchar(4000)=''
		--
	,@p_mod_date						datetime
	,@p_mod_by							nvarchar(15)
	,@p_mod_ip_address					nvarchar(15)
)
as
begin
	declare @msg nvarchar(max) ;

	begin try

		if (@p_estimate_return_date < dbo.xfn_get_system_date())
		begin
			set	@msg = 'Date must be greater than System Date'
			raiserror (@msg, 16, 1) ;
		end

		update	dbo.asset_replacement_detail
		set		estimate_return_date	= @p_estimate_return_date
				,remark					= @p_remark
				,delivery_address		= @p_delivery_address	
				,contact_phone_no		= @p_contact_phone_no	
				,contact_name			= @p_contact_name		
					--
				,mod_date				= @p_mod_date
				,mod_by					= @p_mod_by
				,mod_ip_address	= @p_mod_ip_address
		where	id	= @p_id

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
