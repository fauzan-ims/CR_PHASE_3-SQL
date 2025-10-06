CREATE PROCEDURE [dbo].[deskcoll_main_apply_to_all]
(
	@p_id			   bigint
	--
	,@p_mod_date	   datetime
	,@p_mod_by		   nvarchar(15)
	,@p_mod_ip_address nvarchar(15)
)
as
begin
	declare @msg			 nvarchar(max)
			,@result_code	 nvarchar(50)
			,@result_remarks nvarchar(4000) ;

	begin try
		select	@result_code	 = result_code
				,@result_remarks = result_remarks
		from	dbo.deskcoll_main
		where	id = @p_id ;

		update	dbo.deskcoll_invoice
		set		result_code			= @result_code
				,remark				= @result_remarks
				,mod_date			= @p_mod_date
				,mod_by				= @p_mod_by
				,mod_ip_address		= @p_mod_ip_address
		where	deskcoll_main_id	= @p_id ;
--update	di
--set RESULT_CODE = @result_code
--	,REMARK = @result_remarks
--	,MOD_DATE = @p_mod_date
--	,MOD_BY = @p_mod_by
--	,MOD_IP_ADDRESS = @p_mod_ip_address
--from	DESKCOLL_INVOICE	di
--		join dbo.INVOICE on INVOICE.INVOICE_NO = di.INVOICE_NO
--where DESKCOLL_MAIN_ID = @p_id and	INVOICE_STATUS = 'POST' ;
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
			set @msg = N'V' + N';' + @msg ;
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
				set @msg = N'E;' + dbo.xfn_get_msg_err_generic() + N';' + error_message() ;
			end ;
		end ;

		raiserror(@msg, 16, -1) ;

		return ;
	end catch ;
end ;
