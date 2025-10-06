CREATE PROCEDURE dbo.xsp_sell_request_approve
(
	@p_code				nvarchar(50)
	,@p_approval_reff	nvarchar(250)
	,@p_approval_remark nvarchar(4000)
	--
	,@p_mod_date		datetime
	,@p_mod_by			nvarchar(15)
	,@p_mod_ip_address	nvarchar(15)
)
as
begin
	declare @msg			nvarchar(max);

	begin try
		
		--exec sp sell request post
		exec dbo.xsp_sale_post_for_sold_request @p_code				= @p_code
												,@p_mod_date		= @p_mod_date		
												,@p_mod_by			= @p_mod_by			
												,@p_mod_ip_address	= @p_mod_ip_address	
		
		
		
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




