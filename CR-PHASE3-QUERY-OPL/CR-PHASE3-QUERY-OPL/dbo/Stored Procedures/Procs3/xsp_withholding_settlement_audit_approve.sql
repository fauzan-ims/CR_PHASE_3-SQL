/*
exec dbo.xsp_withholding_settlement_audit_approve @p_code = N'' -- nvarchar(50)
												  ,@p_approval_reff = N'' -- nvarchar(250)
												  ,@p_approval_remark = N'' -- nvarchar(4000)
												  ,@p_mod_date = '2023-06-02 11.20.33' -- datetime
												  ,@p_mod_by = N'' -- nvarchar(15)
												  ,@p_mod_ip_address = N'' -- nvarchar(15)
*/

-- Louis Jumat, 02 Juni 2023 18.19.29 -- 
CREATE PROCEDURE [dbo].[xsp_withholding_settlement_audit_approve]
(
	@p_code			    nvarchar(50)
	,@p_approval_reff	nvarchar(250)
	,@p_approval_remark	nvarchar(4000)
	--
	,@p_mod_date	    datetime
	,@p_mod_by		    nvarchar(15)
	,@p_mod_ip_address  nvarchar(15)
)
as
begin
	declare @msg		 nvarchar(max)
			,@year		 int
			,@invoice_no nvarchar(50) ;

	begin try
		if exists
		(
			select	1
			from	dbo.withholding_settlement_audit
			where	code	   = @p_code
					and status = 'ON PROCESS'
		)
		begin
			update	dbo.withholding_settlement_audit
			set		status				= 'APPROVE'
					--
					,mod_date			= @p_mod_date
					,mod_by				= @p_mod_by
					,mod_ip_address		= @p_mod_ip_address
			where	code				= @p_code
			 
			--declare currinvoicepph cursor fast_forward read_only for
			--select	invoice_no
			--from	dbo.invoice_pph
			--where	audit_code			  = @p_code
			--		and settlement_status = 'HOLD' ;

			--open currinvoicepph ;

			--fetch next from currinvoicepph
			--into @invoice_no ;

			--while @@fetch_status = 0
			--begin
				--exec dbo.xsp_invoice_pph_audit_journal @p_reff_name			= N'WITHHOLDING SETTLEMENT AUDIT'
				--									   ,@p_reff_code		= @invoice_no
				--									   ,@p_value_date		= @p_mod_date
				--									   ,@p_trx_date			= @p_mod_date
				--									   ,@p_mod_date			= @p_mod_date
				--									   ,@p_mod_by			= @p_mod_by
				--									   ,@p_mod_ip_address	= @p_mod_ip_address

				exec dbo.xsp_invoice_pph_audit_journal @p_code				= @p_code 
													   ,@p_mod_date			= @p_mod_date
													   ,@p_mod_by			= @p_mod_by
													   ,@p_mod_ip_address	= @p_mod_ip_address
				
			--	fetch next from currinvoicepph
			--	into @invoice_no ;
			--end ;

			--close currinvoicepph ;
			--deallocate currinvoicepph ;

			--update	dbo.invoice_pph
			--set		settlement_status	= 'POST'
			--		--
			--		,mod_date			= @p_mod_date
			--		,mod_by				= @p_mod_by
			--		,mod_ip_address		= @p_mod_ip_address
			--where	audit_code			= @p_code 
		end ;
		else
		begin
			set @msg = 'Data already proceed' ;

			raiserror(@msg, 16, -1) ;
		end ;
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
