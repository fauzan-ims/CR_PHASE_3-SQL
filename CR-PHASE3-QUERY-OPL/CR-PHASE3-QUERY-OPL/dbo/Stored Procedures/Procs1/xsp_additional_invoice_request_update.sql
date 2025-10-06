CREATE PROCEDURE [dbo].[xsp_additional_invoice_request_update]
(
	@p_code			   nvarchar(50)
	,@p_status		   nvarchar(10)
	,@p_from		   nvarchar(20) = ''
	--
	,@p_mod_date	   datetime
	,@p_mod_by		   nvarchar(15)
	,@p_mod_ip_address nvarchar(15)
)
as
begin
	declare @msg							  nvarchar(max)
			,@additional_invoice_request_code nvarchar(50)
			,@reff_code						  nvarchar(50) ;

	begin try
		if (@p_from = '')
		begin
			update	dbo.additional_invoice
			set		invoice_status	= @p_status
					--
					,mod_date		= @p_mod_date
					,mod_by			= @p_mod_by
					,mod_ip_address = @p_mod_ip_address
			where	code			= @p_code
		end

		declare curradditionalinvoice cursor fast_forward read_only for
		select	reff_code
				,additional_invoice_request_code
		from	dbo.additional_invoice_detail
		where	additional_invoice_code = @p_code ;

		open curradditionalinvoice ;

		fetch next from curradditionalinvoice
		into @reff_code
			 ,@additional_invoice_request_code ;

		while @@fetch_status = 0
		begin
			if exists
			(
				select	1
				from	dbo.additional_invoice_request
				where	reff_code = @reff_code
						and code  = @additional_invoice_request_code
			)
			begin
				update	dbo.additional_invoice_request
				set		status			= @p_status
						--
						,mod_date		= @p_mod_date
						,mod_by			= @p_mod_by
						,mod_ip_address = @p_mod_ip_address
				where	reff_code		= @reff_code
						and code		= @additional_invoice_request_code
			end ;

			fetch next from curradditionalinvoice
			into @reff_code
				 ,@additional_invoice_request_code ;
		end ;

		close curradditionalinvoice ;
		deallocate curradditionalinvoice ;
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

