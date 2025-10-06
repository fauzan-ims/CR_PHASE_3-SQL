create PROCEDURE dbo.xsp_sell_approve
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
	declare @msg			nvarchar(max)
			,@id			bigint
			,@remarks		nvarchar(4000)
			,@level_status	nvarchar(250)
			,@level_code	nvarchar(20)

	begin try
		select @id = id 
		from dbo.sale_detail
		where sale_code = @p_code

		--exec sp sell settlement post
		exec dbo.xsp_sale_detail_post @p_id					= @id
									  ,@p_mod_date			= @p_mod_date		
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




