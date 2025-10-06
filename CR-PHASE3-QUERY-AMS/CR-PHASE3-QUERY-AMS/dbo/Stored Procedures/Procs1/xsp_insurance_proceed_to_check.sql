CREATE PROCEDURE [dbo].[xsp_insurance_proceed_to_check]
(
	@p_code			   nvarchar(50)
	--
	,@p_mod_date	   datetime
	,@p_mod_by		   nvarchar(15)
	,@p_mod_ip_address nvarchar(15)
)
as
begin
	declare @msg					 nvarchar(max)
			,@status				 nvarchar(20)
			,@faktur_no				 nvarchar(50)
			,@faktur_date			 datetime
			,@value1				 int
			,@value2				 int
			,@invoice_date			 datetime
			,@ppn_amount			 decimal(18, 2)
			,@cre_by				 nvarchar(250)
			,@total_premi_buy_amount decimal(18, 2)
			,@invoice_code			 nvarchar(50)
			,@payment_name			 nvarchar(250)
			,@bank_name				 nvarchar(250)
			,@bank_account_no		 nvarchar(250)
			,@bank_account_name		 nvarchar(250)
			,@insurance_code		 nvarchar(50) ;

	begin try
		select	@status				= policy_payment_status
				,@faktur_no			= faktur_no
				,@cre_by			= cre_by
				,@invoice_code		= invoice_no
				,@insurance_code	= insurance_code
		from	dbo.insurance_policy_main
		where	code = @p_code ;

		select	@value1 = value
		from	dbo.sys_global_param
		where	CODE = 'INSINV' ;

		select	@value2 = value
		from	dbo.sys_global_param
		where	CODE = 'INSINV' ;

		if exists
		(
			select	1
			from	dbo.insurance_policy_main					   a
					inner join dbo.insurance_policy_asset		   b on b.policy_code		  = a.code
					inner join dbo.insurance_policy_asset_coverage c on c.register_asset_code = b.code
			where	a.code							  = @p_code
					and isnull(c.master_tax_code, '') = ''
		)
		begin
			set @msg = N'Please input tax in coverage first.' ;

			raiserror(@msg, 16, -1) ;
		end ;

		if (@cre_by not like '%MIG%')
		begin
			if (@invoice_date < dateadd(month, -@value1, dbo.xfn_get_system_date()))
			begin
				if (@value1 <> 0)
				begin
					set @msg = N'Realization invoice date cannot be back dated for more than ' + convert(varchar(1), @value1) + N' months.' ;

					raiserror(@msg, 16, -1) ;
				end ;
				else if (@value1 = 0)
				begin
					set @msg = N'Realization invoice date must be equal than system date.' ;

					raiserror(@msg, 16, -1) ;
				end ;
			end ;

			if (@faktur_date < dateadd(month, -@value2, dbo.xfn_get_system_date()))
			begin
				if (@value2 <> 0)
				begin
					set @msg = N'Faktur date cannot be back dated for more than ' + convert(varchar(1), @value2) + N' months.' ;

					raiserror(@msg, 16, -1) ;
				end ;
				else if (@value2 = 0)
				begin
					set @msg = N'Faktur date must be equal than system date.' ;

					raiserror(@msg, 16, -1) ;
				end ;
			end ;
		end ;

		-- Hari - 19.Jul.2023 05:08 PM --	perubahan cara ambil amount by invoice no
		select	@total_premi_buy_amount = isnull(sum(ipac.buy_amount), 0)
		from	dbo.insurance_policy_asset					   ipa
				inner join dbo.insurance_policy_asset_coverage ipac on ipac.register_asset_code = ipa.code
		where	policy_code		 = @p_code
				and invoice_code = @invoice_code ;

		--and	ipac.coverage_type = 'NEW' -- (+) Ari 2024-01-03 ket : hanya yg New yg dibayar
		if (@total_premi_buy_amount = 0)
		begin
			set @msg = N'Premi amount must be greater than 0' ;

			raiserror(@msg, 16, -1) ;
		end ;

		select	top 1
				@payment_name		= mis.insurance_name
				,@bank_name			= mib.bank_name
				,@bank_account_no	= mib.bank_account_no
				,@bank_account_name = mib.bank_account_name
		from	dbo.master_insurance_bank		mib
				inner join dbo.master_insurance mis on mis.code = mib.insurance_code
		where	mib.insurance_code = @insurance_code
				and mib.is_default = '1' ;

		if (@bank_name is null)
		begin
			set @msg = N'Please setting default insurance bank' ;

			raiserror(@msg, 16, -1) ;
		end ;

		select	@ppn_amount = sum(ipac.initial_discount_ppn)
		from	dbo.insurance_policy_asset					   apa
				inner join dbo.insurance_policy_asset_coverage ipac on ipac.register_asset_code = apa.code
		where	apa.policy_code = @p_code ;

		--validasi untuk faktur number agar tidak bisa kosong jika pph amount ada nilainya 
		if (isnull(@faktur_no, '') = '')
		   and	(@ppn_amount > 0)
		begin
			set @msg = N'Faktur Number cant be empty.' ;

			raiserror(@msg, 16, -1) ;
		end ;

		-- (+) Ari 2024-01-03 ket : validasi invoice tidak boleh kosong
		if (isnull(@invoice_code, '') = '')
		begin
			set @msg = N'Invoice Number cant be empty.' ;

			raiserror(@msg, 16, -1) ;
		end ;

		if (@status = 'HOLD')
		begin
			update	dbo.insurance_policy_main
			set		policy_payment_status	= 'ON CHECK'
					--
					,mod_date				= @p_mod_date
					,mod_by					= @p_mod_by
					,mod_ip_address			= @p_mod_ip_address
			where	code = @p_code ;
		end ;
		else
		begin
			set @msg = N'Data Already Proceed' ;

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
