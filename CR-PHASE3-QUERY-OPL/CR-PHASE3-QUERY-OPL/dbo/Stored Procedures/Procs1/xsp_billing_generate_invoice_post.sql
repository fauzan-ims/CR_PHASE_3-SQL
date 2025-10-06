CREATE PROCEDURE [dbo].[xsp_billing_generate_invoice_post]
(
	@p_code					   nvarchar(50)
	--
	,@p_mod_date			   datetime
	,@p_mod_by				   nvarchar(15)
	,@p_mod_ip_address		   nvarchar(15)
)
as
BEGIN
/*
xsp_billing_scheme_insert
step generate
	insert ke tabel generate invoice detail. 
	untuk semua schedule yang jatuh tempo
	xsp_billing_generate_insert
	xsp_billing_generate_detail_generate

- posting
insert ke invoice 
	xsp_billing_generate_invoice_post

- ambil yang masuk ke scheme
	buatkan invoice
	update generate detail
	update schedule
	xsp_billing_generate_invoice_by_scheme

- generate invoice non scheme

	buatkan invoice group by biling to
	update generate invoice
	update schedule
	xsp_billing_generate_invoice_by_non_scheme

*/
	declare @msg		   nvarchar(max)
			,@invoice_no   nvarchar(50)
			,@agreement_no nvarchar(50) ;
	begin try 
	

		if exists
		(
			select	1
			from	dbo.billing_generate
			where	code			   = @p_code
			and		status = 'HOLD'
		)
		begin
			-- process billing with billing scheme
			BEGIN
				exec dbo.xsp_billing_generate_invoice_by_scheme @p_code				= @p_code				
																--
																,@p_mod_date		= @p_mod_date		
																,@p_mod_by			= @p_mod_by			
																,@p_mod_ip_address	= @p_mod_ip_address
			end
			-- process billing to invoice
			begin
				exec dbo.xsp_billing_generate_invoice_by_non_scheme @p_code				= @p_code				
																	--
																	,@p_mod_date		= @p_mod_date		
																	,@p_mod_by			= @p_mod_by			
																	,@p_mod_ip_address	= @p_mod_ip_address
			
			end

			-- update agreement status
			begin
				select	@invoice_no = invoice_no
				from	dbo.invoice
				where	generate_code = @p_code ; 

				exec dbo.xsp_agreement_update_sub_status @p_invoice_no		= @invoice_no
														 ,@p_mod_date		= @p_mod_date		
														 ,@p_mod_by			= @p_mod_by			
														 ,@p_mod_ip_address = @p_mod_ip_address
				
			end

			update	dbo.billing_generate
			set		status					= 'POST'
					--
					,mod_date				= @p_mod_date
					,mod_by					= @p_mod_by
					,mod_ip_address			= @p_mod_ip_address
			where	code					= @p_code ;

		end ;
		else
		begin
			set @msg = 'Data already post';
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





