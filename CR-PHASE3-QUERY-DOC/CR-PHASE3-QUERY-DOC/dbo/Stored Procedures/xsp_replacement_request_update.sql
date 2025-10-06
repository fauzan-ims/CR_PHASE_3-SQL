CREATE PROCEDURE dbo.xsp_replacement_request_update
(
	@p_id						 bigint  
	,@p_vendor_address			 nvarchar(4000)
	,@p_vendor_pic_name			 nvarchar(250)
	,@p_vendor_pic_area_phone_no nvarchar(4)
	,@p_vendor_pic_phone_no		 nvarchar(15) 
	--
	,@p_mod_date			     datetime
	,@p_mod_by				     nvarchar(15)
	,@p_mod_ip_address		     nvarchar(15)
)
as
begin
	declare @msg nvarchar(max) ;

	begin try
		update	replacement_request		   
		set		vendor_address			   	= @p_vendor_address			 
				,vendor_pic_name			= @p_vendor_pic_name			 
				,vendor_pic_area_phone_no  	= @p_vendor_pic_area_phone_no 
				,vendor_pic_phone_no		= @p_vendor_pic_phone_no		 
				--
				,mod_date					= @p_mod_date
				,mod_by						= @p_mod_by
				,mod_ip_address				= @p_mod_ip_address
		where	id							= @p_id ;
	end try
	begin catch 
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
