

CREATE PROCEDURE dbo.xsp_faktur_no_replacement_update_post
(
	 @p_code							nvarchar (50)
	--
	,@p_mod_date						datetime
	,@p_mod_by							nvarchar(15)
	,@p_mod_ip_address					nvarchar(15)
)
as
begin
	declare		@msg					nvarchar(max)
				,@nomor_faktur_pajak	nvarchar(50)
				,@invoice_no			nvarchar(50)

	begin try
    
	if exists(
		select status from faktur_no_replacement where code = @p_code and STATUS <> 'HOLD')
		begin
			set @msg = 'Transaction Already Proceed'
			raiserror(@msg, 16, -1)
		end
	else
    begin
        
		if not exists (select 1 from dbo.faktur_no_replacement_detail where faktur_no_replacement_code = @p_code)
		begin
		    set @msg = 'Please Input Data Detail'
			raiserror(@msg, 16, -1)
		end

		update	dbo.faktur_no_replacement
		set		status			= 'POST'		
				--
				,mod_date		= @p_mod_date
				,mod_by			= @p_mod_by
				,mod_ip_address	= @p_mod_ip_address
		where	 code			= @p_code and status = 'HOLD' ;

			--sepria 07032025: update ke tabel: Billing > Invoice, 
			declare c_update_faktur_dummy cursor local fast_forward read_only for
			select	referensi
					,nomor_faktur_pajak
			from	dbo.faktur_no_replacement_detail
			where	faktur_no_replacement_code = @p_code

			open	c_update_faktur_dummy
			fetch	c_update_faktur_dummy 
			into	@invoice_no
					,@nomor_faktur_pajak

			while @@fetch_status = 0
			begin
			
				update	dbo.invoice
				set		faktur_no		= @nomor_faktur_pajak
						,mod_date		= @p_mod_date
						,mod_by			= @p_mod_by
						,mod_ip_address	= @p_mod_ip_address
				where	invoice_no		= @invoice_no

				fetch	c_update_faktur_dummy 
				into	@invoice_no
						,@nomor_faktur_pajak

			end
			close c_update_faktur_dummy
			deallocate c_update_faktur_dummy
    end

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
