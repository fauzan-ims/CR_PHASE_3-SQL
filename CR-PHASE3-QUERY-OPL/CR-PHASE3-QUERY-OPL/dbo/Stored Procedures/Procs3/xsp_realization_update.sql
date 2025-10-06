CREATE PROCEDURE dbo.xsp_realization_update
(
	@p_code					nvarchar(50)
	,@p_remark				nvarchar(4000)
	,@p_delivery_from		nvarchar(20)
	,@p_delivery_pic_code	nvarchar(250) = null
	,@p_delivery_pic_name	nvarchar(250) = null
	,@p_deliver_by			nvarchar(50)  = null
	,@p_deliver_pic			nvarchar(250) = null
	,@p_result				nvarchar(4000) = null
	,@p_agreement_date		datetime
	--
	,@p_mod_date			datetime
	,@p_mod_by				nvarchar(15)
	,@p_mod_ip_address		nvarchar(15)
)
as
begin
	declare @msg nvarchar(max) ;

	begin try
		update	realization
		set		remark						= @p_remark  
				,delivery_from				= @p_delivery_from			
				,delivery_pic_code			= @p_delivery_pic_code		
				,delivery_pic_name			= @p_delivery_pic_name		
				,delivery_vendor_name		= @p_deliver_by	
				,delivery_vendor_pic_name	= @p_deliver_pic
				,result						= @p_result
				,agreement_date				= @p_agreement_date
				--
				,mod_date					= @p_mod_date
				,mod_by						= @p_mod_by
				,mod_ip_address				= @p_mod_ip_address
		where	code						= @p_code ;
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

