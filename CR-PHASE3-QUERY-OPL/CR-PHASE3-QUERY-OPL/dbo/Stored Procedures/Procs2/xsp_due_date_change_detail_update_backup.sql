--created by, Rian at 04/05/2023 

create PROCEDURE dbo.xsp_due_date_change_detail_update_backup
(
	@p_id						bigint
	,@p_due_date_change_code	nvarchar(50)
	,@p_new_due_date_day		datetime = null
	--
	,@p_mod_date				datetime
	,@p_mod_by					nvarchar(15)
	,@p_mod_ip_address			nvarchar(15)
)
as
begin
	declare @msg					nvarchar(max) 
			,@asset_no				nvarchar(50)
			,@agreement_no			nvarchar(50)
			,@due_date				datetime	
			,@max_installment_no	int
			,@min_installment_no	int
			,@is_change				nvarchar(1)
			,@old_due_date			datetime
			,@at_installment_no		int
			,@first_payment_type    nvarchar(3)

	begin try

		if (@p_new_due_date_day is null)
		begin
			set @msg = 'Please Insert New Due Date.'
			raiserror (@msg, 16, -1)
		end 

		--select is change dari data sebelumnya terlebih dahulu
		select	@is_change = is_change
		from	dbo.due_date_change_detail
		where	id = @p_id ;

		--jika is change nya 0 maka set is change menjadi 1 dan sebalik nya
		if (@is_change = '0')
		begin 
			if @p_new_due_date_day < dbo.xfn_get_system_date()
			begin
				set @msg = 'New Due Date Must be Greater or Equal Than System Date.'
				raiserror (@msg, 16, -1)
			end

			--ambil agreement no
			select	@agreement_no = agreement_no
			from	dbo.due_date_change_main
			where	code = @p_due_date_change_code

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
			 
			--if exists (select 1 from dbo.agreement_main where agreement_no = @agreement_no and first_payment_type = 'ADV')
			--begin
			--	--select minimal installment no dari tabel agreement asset amortization
			--		select	@min_installment_no = min(billing_no)
			--		from	dbo.agreement_asset_amortization
			--		where	asset_no	   = @asset_no
			--		and		(invoice_no is not null
			--				or due_date <= dbo.xfn_get_system_date())	
			--end ;
			--else
			begin
				--select minimal installment no dari tabel agreement asset amortization
					--select	@min_installment_no = max(billing_no)
					--from	dbo.agreement_asset_amortization
					--where	asset_no	   = @asset_no
					--and		(invoice_no is not null
					--		or due_date <= dbo.xfn_get_system_date()) ; 
					if (@first_payment_type = 'ARR')
					begin
						select	@min_installment_no = min(billing_no)
						from	dbo.agreement_asset_amortization
						where	asset_no		 = @asset_no
								and
								(
									invoice_no is null
									and due_date >= @p_new_due_date_day
								) ;
					end ;
					else
					begin 
						select	@min_installment_no = max(billing_no)
						from	dbo.agreement_asset_amortization
						where	asset_no		 = @asset_no
								and
								(
									invoice_no is null
									and 
									due_date <= @p_new_due_date_day
								) ;
					end ;
			end ; 
			 
			--validasi jika invoice already generate
			if (isnull(@min_installment_no, 0) = 0)
			begin
				set @msg = 'Due Date must be greater Than First Billing Date or last Invoice Date';
				raiserror(@msg, 16, -1) ;
			end

			
			--if exists (select 1 from dbo.agreement_main where agreement_no = @agreement_no and first_payment_type = 'ADV')
			--begin
			--	--select min installment no yang due date nya lebih besar dari new due date
			--	select	@at_installment_no = MAX(installment_no)
			--	from	dbo.due_date_change_amortization_history
			--	where	asset_no				 = @asset_no
			--			and due_date_change_code = @p_due_date_change_code
			--			and due_date			 < @p_new_due_date_day ;	
			--end ;
			--else
			--begin
			--	--select min installment no yang due date nya lebih besar dari new due date
			--	select	@at_installment_no = min(installment_no)
			--	from	dbo.due_date_change_amortization_history
			--	where	asset_no				 = @asset_no
			--			and due_date_change_code = @p_due_date_change_code
			--			and due_date			 > @p_new_due_date_day ;
			--end ;

			--select due date dari tabel agreement amortization berdasarkan asset no dan billing no(installment)
			select	@due_date = due_date
			from	dbo.agreement_asset_amortization
			where	asset_no	   = @asset_no
					and billing_no = @min_installment_no ;

			--select old due date dari tabel agreement asset amortization
			select	@old_due_date = max(due_date)
			from	dbo.agreement_asset_amortization
			where	asset_no	   = @asset_no
			and		(invoice_no is not null
					or due_date <= dbo.xfn_get_system_date())

			--validasi new due date day tidak boleh lebih kecil dari old date
			--if (@p_new_due_date_day <= @old_due_date)
			--begin
			--	set @msg = 'New Due Date must be greater than : ' + convert(varchar(30), @old_due_date, 103);
			--	raiserror(@msg, 16, -1) ;
			--end

			--validasi jika installment no yang di input <= 0
			if (@min_installment_no <= 0)
			begin
				set @msg = 'At Installment No. must be greater than 0';
				raiserror(@msg, 16, -1) ;
			end

			--validasi instalmentn yang di pilih tidak boleh lebih besar dari max installment no
			if (@max_installment_no < @min_installment_no)
			begin
				set @msg = 'At Installment No. must be less than Max Installment No. : ' + cast(@max_installment_no as nvarchar(10));
				raiserror(@msg, 16, -1) ;
			end

			--validasi installment yang di pilih tidak boleh lebih kecil dari min installment no
			--if (@min_installment_no > @at_installment_no)
			--begin
			--	set @msg = 'At Installment No. : ' + cast(@at_installment_no as nvarchar(10)) + ' is Overdue, Minimum Installment No. must be : ' + cast(@min_installment_no + 1 as nvarchar(10)) ;

			--	raiserror(@msg, 16, -1) ;
			--end ;

			--update data di tabel due date change detail
			update	dbo.due_date_change_detail 
			set		at_installment_no		= @min_installment_no--@at_installment_no
					,old_due_date_day		= @due_date
					,is_change				= '1'
					,new_due_date_day		= @p_new_due_date_day
					,os_rental_amount		= dbo.xfn_agreement_get_all_os_principal(@agreement_no, @p_new_due_date_day, @asset_no)
					--
					,mod_date				= @p_mod_date
					,mod_by					= @p_mod_by
					,mod_ip_address			= @p_mod_ip_address
			where	id = @p_id ;

			--lakukan calculate
			exec dbo.xsp_due_date_change_main_generate_amortization @p_asset_no					= @asset_no
																	,@p_due_date_change_code	= @p_due_date_change_code
																	--
																	,@p_mod_date				= @p_mod_date
																	,@p_mod_by					= @p_mod_by
																	,@p_mod_ip_address			= @p_mod_ip_address
		
		--jika is change nya sama dengan 1 maka hanya lakukan update is change menjadi 0
		end
		else
		begin
			--validasi terlebih dahulu harus ada data minimal 1 yang is change nya = 1
			--if not exists
			--(
			--	select	1
			--	from	dbo.due_date_change_detail
			--	where	due_date_change_code = @p_due_date_change_code
			--			and is_change		 = '1'
			--			and	id				 <> @p_id
			--)
			--begin
			--	set @msg = 'Please select at least 1 Asset' ;

			--	raiserror(@msg, 16, 1) ;
			--end ;

			--update data di tabel due date change detail
			update	dbo.due_date_change_detail
			set		is_change				= '0'
					--
					,mod_date				= @p_mod_date
					,mod_by					= @p_mod_by
					,mod_ip_address			= @p_mod_ip_address
			where	id = @p_id ;
			
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
