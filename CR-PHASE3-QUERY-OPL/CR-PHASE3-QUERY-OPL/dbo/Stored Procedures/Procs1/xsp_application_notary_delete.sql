CREATE PROCEDURE dbo.xsp_application_notary_delete
(
	@p_id			   bigint
	,@p_application_no nvarchar(50)
	--
	,@p_mod_date	   datetime
	,@p_mod_by		   nvarchar(15)
	,@p_mod_ip_address nvarchar(15)
)
as
begin
	declare @msg		   nvarchar(max)
			,@total_notary decimal(18, 2) ;

	begin try
		select	@total_notary = isnull(sum(total_notary_amount), 0)
		from	dbo.application_notary an
		where	application_no = @p_application_no ;

		delete application_notary
		where	id				   = @p_id
				and application_no = @p_application_no ;

		exec dbo.xsp_application_notary_fee_update @p_application_no	= @p_application_no
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
		else if (@error = 547)
		begin
			set @msg = dbo.xfn_get_msg_err_code_already_used() ;
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

