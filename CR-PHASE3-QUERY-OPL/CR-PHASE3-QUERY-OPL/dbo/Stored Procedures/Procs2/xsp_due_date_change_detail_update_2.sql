--created by, Rian at 04/05/2023 

CREATE PROCEDURE dbo.xsp_due_date_change_detail_update_2
(
	@p_id						BIGINT
	,@p_due_date_change_code	NVARCHAR(50)
	--,@p_new_due_date_day		datetime		= null
	--
	,@p_mod_date				DATETIME
	,@p_mod_by					NVARCHAR(15)
	,@p_mod_ip_address			NVARCHAR(15)
	,@p_new_billing_date_day	DATETIME		= NULL	
	,@p_is_change				NVARCHAR(1)		= '0'
	,@p_is_change_billing_date	NVARCHAR(1)		= '0' --jika yang di ubah adalah billing date
	,@p_billing_mode			nvarchar(15)	= null
	,@p_prorate					nvarchar(15)	= 'NO'
	,@p_date_for_billing		int				= 0
)
as
begin
	declare @msg					nvarchar(max) 
			,@asset_no				nvarchar(50)
			,@agreement_no			nvarchar(50)
			,@due_date				datetime	
			,@max_installment_no	int
			,@min_installment_no	int
			,@old_due_date			datetime
			,@at_installment_no		int
			,@first_payment_type    nvarchar(3)
			,@billing_date			datetime
            ,@old_billing_date		datetime
			--
			,@billing_mode			nvarchar(15)
			,@prorate				nvarchar(15)
			,@date_for_billing		int		
	begin try

	
		--ambil agreement no
		select	@agreement_no		= agreement_no
				,@billing_mode		= billing_mode
				,@prorate			= is_prorate
				,@date_for_billing	= billing_mode_date
		from	dbo.due_date_change_main
		where	code = @p_due_date_change_code;

		--ambil asset no dari tabel due date change detail
		select	@asset_no = asset_no
		from	dbo.due_date_change_detail
		where	id = @p_id ;

		--select maximal installment no dari tabel agreement asset amortization
		select	@max_installment_no = max(billing_no)
		from	dbo.agreement_asset_amortization
		where	asset_no = @asset_no ;


		select	@first_payment_type = first_payment_type
		from	dbo.agreement_asset
		where	asset_no = @asset_no ;

		if(isnull(@p_billing_mode,'') = '') set @p_billing_mode = @billing_mode
		if(isnull(@p_prorate,'') = '') set @p_prorate = @prorate

		if(@p_billing_mode <> @billing_mode)
		begin
			if(isnull(@p_date_for_billing,0) = 0) set @p_date_for_billing = @date_for_billing
		end
		

		--if (@first_payment_type = 'ARR')
		--begin
		--	select	@min_installment_no = min(billing_no)
		--	from	dbo.agreement_asset_amortization
		--	where	asset_no		 = @asset_no
		--			and
		--			(
		--				invoice_no is null
		--				and due_date >= @p_new_due_date_day
		--			) ;
		--end ;
		--else
		begin 
			select	@min_installment_no = max(billing_no)
			from	dbo.agreement_asset_amortization
			where	asset_no		 = @asset_no
					and
					(
						invoice_no is null
						and due_date <= @p_new_billing_date_day
					) ;
		end ;

		select	@due_date = due_date
				,@billing_date = billing_date
		from	dbo.agreement_asset_amortization
		where	asset_no	   = @asset_no
				and billing_no = @min_installment_no ;

		select	@old_due_date = max(due_date)
				,@old_billing_date = max(billing_date)
		from	dbo.agreement_asset_amortization
		where	asset_no	   = @asset_no
		and
			(
				isnull(invoice_no, '')		   <> ''
				or
				(
					due_date				   <= dbo.xfn_get_system_date()
					and isnull(invoice_no, '') = ''
					and billing_no < @min_installment_no
				)
			) ;

		-- BILLING
		if (@p_is_change_billing_date = '1')
		begin
			if (@p_billing_mode IN ('BEFORE DUE','BY DATE'))
			begin
				if(@p_date_for_billing <= 0)
				begin
					set @msg = 'Date Cannot Be 0'
					raiserror (@msg, 16, -1)
				end
		
				if(@p_date_for_billing > 31)
				begin
					set @msg = 'Date Cannot Be More Than 31'
					raiserror (@msg, 16, -1)
				end
			end

		    if (@p_new_billing_date_day is null)
			begin
				set @msg = 'Please Insert New Billing Date.'
				raiserror (@msg, 16, -1)
			end

			--validasi new due date day tidak boleh lebih kecil dari old date
			if (@min_installment_no = '1')
			begin
				select	@old_due_date = handover_bast_date
				from	dbo.agreement_asset
				where	asset_no	   = @asset_no

				if (cast(@p_new_billing_date_day as date) < cast(@old_due_date as date))
				begin
					set @msg =  'New Billing Date must be greater or Equal than : ' + convert(varchar(30), @old_due_date, 103);
					raiserror (@msg, 16, -1)
				end
			end
			else if (cast(@p_new_billing_date_day as date) < cast(@old_billing_date as date))
			begin
				set @msg =  'New Billing Date must be greater or Equal than : ' + convert(varchar(30), @old_billing_date, 103);
				raiserror (@msg, 16, -1)
			end
            
			if(@p_billing_mode = 'END MONTH' AND @p_new_billing_date_day <> EOMONTH(@p_new_billing_date_day))
			begin
			    set @msg = 'New Billing Date Must Be End Of Month'
				raiserror(@msg, 16, -1) ;
			end
				---- validasi jika is_prorate = 1, maka date yang di input di new_due_date atau new_billing_date harus akhir bulan
			--if (@p_prorate = 'YES' AND @p_is_change_billing_date = '1' AND @p_new_billing_date <> eomonth(@p_new_billing_date) and @first_payment_type = 'ARR')
			--begin
			--    set @msg = 'Prorate = Yes, New Billing Date Must Be End Of Month'
			--	raiserror(@msg, 16, -1) ;
			--end
			--else if (@p_prorate = 'YES' AND @p_is_change_billing_date = '1' AND @p_new_billing_date <> (datefromparts(year(@p_new_billing_date), month(@p_new_billing_date), 1)) and @first_payment_type = 'ADV')
			--begin
			--    set @msg = 'Prorate = Yes, New Billing Date Must Be Beginning Of Month'
			--	raiserror(@msg, 16, -1) ;
			--end

			--update data di tabel due date change detail
			update	dbo.due_date_change_detail 
			set		at_installment_no		= @min_installment_no--@at_installment_no
					--
					,old_billing_date		= @billing_date
					,is_change_billing_date	= @p_is_change_billing_date
					,new_billing_date		= @p_new_billing_date_day
					,billing_mode			= @p_billing_mode
					,prorate				= @p_prorate	
					,date_for_billing		= @p_date_for_billing	
					--
					,mod_date				= @p_mod_date
					,mod_by					= @p_mod_by
					,mod_ip_address			= @p_mod_ip_address
			where	id = @p_id ;

		end
		else 
		begin
			--update data di tabel due date change detail
			update	dbo.due_date_change_detail
			set		is_change_billing_date	= '0'
					--
					,mod_date				= @p_mod_date
					,mod_by					= @p_mod_by
					,mod_ip_address			= @p_mod_ip_address
			where	id = @p_id ;
			
		end

		-- DUE
		--if (@p_is_change = '1')
		--begin

		--	--if (@p_new_due_date_day is null)
		--	--begin
		--	--	set @msg = 'Please Insert New Due Date.'
		--	--	raiserror (@msg, 16, -1)
		--	--end 
			
		--	--validasi jika invoice already generate
		--	if (isnull(@min_installment_no, 0) = 0)
		--	begin
		--		set @msg = 'Due Date must be greater Than First Billing Date or last Invoice Date';
		--		raiserror(@msg, 16, -1) ;
		--	end

		--	--validasi new due date day tidak boleh lebih kecil dari old date
		--	if (@min_installment_no = '1')
		--	begin
		--		select	@old_due_date = handover_bast_date
		--		from	dbo.agreement_asset
		--		where	asset_no	   = @asset_no

		--		if (cast(@p_new_due_date_day as date) < cast(@old_due_date as date))
		--		begin
		--			set @msg =  'New Due Date must be greater or Equal than : ' + convert(varchar(30), @old_due_date, 103);
		--			raiserror (@msg, 16, -1)
		--		end
		--	end
		--	else if (cast(@p_new_due_date_day as date) < cast(@old_due_date as date))
		--	begin
		--		set @msg =  'New Due Date must be greater or Equal than : ' + convert(varchar(30), @old_due_date, 103);
		--		raiserror (@msg, 16, -1)
		--	end
		
		--	--validasi jika installment no yang di input <= 0
		--	if (@min_installment_no <= 0)
		--	begin
		--		set @msg = 'At Installment No. must be greater than 0';
		--		raiserror(@msg, 16, -1) ;
		--	end

		--	--validasi instalmentn yang di pilih tidak boleh lebih besar dari max installment no
		--	if (@max_installment_no < @min_installment_no)
		--	begin
		--		set @msg = 'At Installment No. must be less than Max Installment No. : ' + cast(@max_installment_no as nvarchar(10));
		--		raiserror(@msg, 16, -1) ;
		--	end

		--	-- validasi jika is_prorate = 1, maka date yang di input di new_due_date
		--	if (@p_prorate = 'YES' AND @p_is_change = '1' AND @p_new_due_date_day <> eomonth(@p_new_due_date_day) and @first_payment_type = 'ARR')
		--	begin
		--	    set @msg = 'Prorate = Yes, New Due Date Must Be End Of Month'
		--		raiserror(@msg, 16, -1) ;
		--	end
		--	else if (@p_prorate = 'YES' AND @p_is_change = '1' AND @p_new_due_date_day <> (datefromparts(year(@p_new_due_date_day), month(@p_new_due_date_day), 1)) and @first_payment_type = 'ADV')
		--	begin
		--	    set @msg = 'Prorate = Yes, New Due Date Must Be Beginning Of Month'
		--		raiserror(@msg, 16, -1) ;
		--	end
			
		--	--update data di tabel due date change detail
		--	update	dbo.due_date_change_detail 
		--	set		at_installment_no		= @min_installment_no--@at_installment_no
		--			,old_due_date_day		= @due_date
		--			,is_change				= @p_is_change
		--			,new_due_date_day		= @p_new_due_date_day
		--			,os_rental_amount		= dbo.xfn_agreement_get_all_os_principal(@agreement_no, @p_new_due_date_day, @asset_no)
		--			--
		--			--,billing_mode			= @p_billing_mode
		--			,prorate				= @p_prorate	
		--			--,date_for_billing		= @p_date_for_billing	
		--			--
		--			,mod_date				= @p_mod_date
		--			,mod_by					= @p_mod_by
		--			,mod_ip_address			= @p_mod_ip_address
		--	where	id = @p_id ;
						
		----jika is change nya sama dengan 1 maka hanya lakukan update is change menjadi 0
		--end
		--else 
		--begin
		--	--update data di tabel due date change detail
		--	update	dbo.due_date_change_detail
		--	set		is_change				= '0'
		--			--
		--			,mod_date				= @p_mod_date
		--			,mod_by					= @p_mod_by
		--			,mod_ip_address			= @p_mod_ip_address
		--	where	id = @p_id ;
			
		--end
        

		if (isnull(@p_is_change_billing_date,'0') = '1')
		begin
		    ----lakukan calculate
			exec dbo.xsp_due_date_change_main_generate_amortization @p_asset_no					= @asset_no
																	,@p_due_date_change_code	= @p_due_date_change_code
																	--
																	,@p_mod_date				= @p_mod_date
																	,@p_mod_by					= @p_mod_by
																	,@p_mod_ip_address			= @p_mod_ip_address
		
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