
-- Stored Procedure

-- Stored Procedure

CREATE PROCEDURE [dbo].[xsp_invoice_cancel]
(
	@p_invoice_no		nvarchar(50)
	--
	,@p_mod_date	    datetime
	,@p_mod_by		    nvarchar(15)
	,@p_mod_ip_address  nvarchar(15)
)
as
begin
	declare @msg						nvarchar(max)
			,@additional_invoice_code	nvarchar(50)

	begin try
		delete dbo.agreement_invoice
		where	invoice_no = @p_invoice_no ;

		delete dbo.agreement_invoice_pph
		where	invoice_no = @p_invoice_no ;

		delete dbo.agreement_asset_interest_income
		where	invoice_no = @p_invoice_no ;

		update dbo.agreement_asset_amortization
		set	generate_code	= null
			,invoice_no		= null
			--
			,mod_date		= @p_mod_date
			,mod_by			= @p_mod_by
			,mod_ip_address = @p_mod_ip_address
		where invoice_no	= @p_invoice_no

		if exists
		(
			select	1
			from	dbo.invoice
			where	invoice_no			   = @p_invoice_no
					and invoice_status	   = 'NEW'
		)
		begin
			select	@additional_invoice_code = additional_invoice_code
			from	dbo.invoice
			where	invoice_no = @p_invoice_no ;

			update	dbo.invoice
			set		invoice_status	= 'CANCEL'
					,faktur_no		= NULL
                    ,cancel_date	= @p_mod_date
					,cancel_by		= @p_mod_by
					--
					,mod_date		= @p_mod_date
					,mod_by			= @p_mod_by
					,mod_ip_address = @p_mod_ip_address
			where	invoice_no		= @p_invoice_no ;

			-- Louis Selasa, 12 Desember 2023 17.35.45 -- digunakan untuk mengembalikan faktur no yang sudah teralokasi tetapi status invoice masi NEW
			update	dbo.faktur_main
			set		status			= 'NEW'
					,invoice_no		= null
					--
					,mod_date		= @p_mod_date
					,mod_by			= @p_mod_by
					,mod_ip_address = @p_mod_ip_address
			where	invoice_no		= @p_invoice_no


			if (isnull(@additional_invoice_code, '') <> '')
			begin
				exec dbo.xsp_additional_invoice_request_update @p_code			   = @additional_invoice_code
																,@p_status		   = N'HOLD'
																,@p_mod_date	   = @p_mod_date
																,@p_mod_by		   = @p_mod_ip_address
																,@p_mod_ip_address = @p_mod_by

			end
		end ;												  
		else												  
		begin
			set @msg = 'Data already proceed'
			raiserror(@msg, 16, 1) ;
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
