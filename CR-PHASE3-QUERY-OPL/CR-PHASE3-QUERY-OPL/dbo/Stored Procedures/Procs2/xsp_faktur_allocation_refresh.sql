CREATE PROCEDURE dbo.xsp_faktur_allocation_refresh
(
	@p_allocation_code nvarchar(50)
	--		
	,@p_mod_date	   datetime
	,@p_mod_by		   nvarchar(15)
	,@p_mod_ip_address nvarchar(15)
	,@p_cre_date	   datetime
	,@p_cre_by		   nvarchar(15)
	,@p_cre_ip_address nvarchar(15)
)
as
begin
	declare @msg			   nvarchar(max)
			,@invoice_no	   nvarchar(50)
			,@as_of_date	   datetime
			,@id			   bigint
			,@new_faktur	   nvarchar(50)
			,@branch_code	   nvarchar(50)
			,@faktur_type	   nvarchar(3)
			,@count_invoice	   int
			,@count_faktur	   int
			,@new_invoice_date datetime ;

	begin try

		-- mengembali status faktur yang assign menjadi new
		update	dbo.faktur_main
		set		status = 'NEW'
				,invoice_no = null
		where	faktur_no in
				(
					select	substring(faktur_no, 5, 18)
					from	dbo.faktur_allocation_detail
					where	allocation_code = @p_allocation_code
				) ;

		delete	dbo.faktur_allocation_detail
		where	allocation_code = @p_allocation_code ;

		select	@as_of_date = as_of_date
				,@branch_code = branch_code
		from	faktur_allocation
		where	code = @p_allocation_code ;

		-- validasi hanya boleh 1 transaksi yang pending	
		--if exists (select 1 from dbo.faktur_allocation where status = 'HOLD' AND branch_code = @branch_code and code <> @p_allocation_code)

		--begin
		--	set @msg = 'Please complete pending Faktur Allocation transaction.'
		--	raiserror(@msg, 16, -1) ;
		--end

		-- delete data sebelumnya
		delete	faktur_allocation_detail
		where	allocation_code = @p_allocation_code ;

		-- insert date ke tabel faktur_allocation_detail
		insert into faktur_allocation_detail
		(
			allocation_code
			,invoice_no
			,faktur_no
			--
			,cre_date
			,cre_by
			,cre_ip_address
			,mod_date
			,mod_by
			,mod_ip_address
		)
		select	@p_allocation_code
				,invoice_no
				,isnull(faktur_no, '')
				--
				,@p_cre_date
				,@p_cre_by
				,@p_cre_ip_address
				,@p_mod_date
				,@p_mod_by
				,@p_mod_ip_address
		from	dbo.invoice
		where	new_invoice_date		  <= @as_of_date
				and (invoice_status in ( 'NEW' ))
				and isnull(faktur_no, '') = ''
				and total_ppn_amount	  > 0 ;

		--validasi
		begin
			/* declare variables */
			declare @new_invoice_year int ;

			declare curr_validation cursor fast_forward read_only for
			select		year(inv.new_invoice_date)
			from		faktur_allocation_detail fad
						inner join dbo.invoice inv on (inv.invoice_no = fad.invoice_no)
			where		allocation_code = @p_allocation_code
			group by	year(inv.new_invoice_date) ;

			open curr_validation ;

			fetch next from curr_validation
			into @new_invoice_year ;

			while @@fetch_status = 0
			begin

				-- validasi jumlah invoice mencukupi
				if ((
						select	count(1)
						from	invoice
						where	year(new_invoice_date)	  = @new_invoice_year
								and invoice_status in
								(
									'NEW'
								)
								and isnull(faktur_no, '') = ''
								and total_ppn_amount	  > 0
					) >
				   (
					   select	count(1)
					   from		dbo.faktur_main
					   where	status	 = 'NEW'
								and year = @new_invoice_year
				   )
				   )
				begin

					--menghitung jumlah invoice dan faktur 
					select	@count_invoice = count(1)
					from	invoice
					where	year(new_invoice_date)	  = @new_invoice_year
							and invoice_status in
					(
						'NEW'
					)
							and isnull(faktur_no, '') = '' ;

					select	@count_faktur = count(1)
					from	dbo.faktur_main
					where	status	 = 'NEW'
							and year = @new_invoice_year ;

					set @msg = N'Insufficient Faktur No.,  Number Of Invoice : ' + convert(varchar(30), @count_invoice, 103) + N' Invoice Periode ' + cast(@new_invoice_year as nvarchar(4)) + N', Outstanding Faktur : ' + convert(varchar(30), @count_faktur, 103) + N'. Please Register Faktur No' ;
					 
					raiserror(@msg, 16, -1) ;
				end ;

				fetch next from curr_validation
				into @new_invoice_year ;
			end ;

			close curr_validation ;
			deallocate curr_validation ;
		end ;

		declare c_faktur cursor for
		select	fad.id
				,fad.invoice_no
				,inv.new_invoice_date
		from	faktur_allocation_detail fad
				inner join dbo.invoice inv on (inv.invoice_no = fad.invoice_no)
		where	allocation_code = @p_allocation_code ;

		open c_faktur ;

		fetch next from c_faktur
		into @id
			 ,@invoice_no
			 ,@new_invoice_date ;

		while @@fetch_status = 0
		begin
			-- ambil jenis faktur nya
			select	top 1
					@faktur_type = aa.billing_to_faktur_type
			from	dbo.agreement_asset aa
					inner join dbo.invoice_detail id on id.asset_no = aa.asset_no
			where	id.invoice_no = @invoice_no ;

			-- ambil nomor faktur
			select		top 1
						@new_faktur = faktur_no
			from		dbo.faktur_main
			where		status	 = 'NEW'
						and substring(faktur_no, 5, 18) not in
							(
								select	faktur_no
								from	dbo.faktur_allocation_detail fal
										inner join dbo.faktur_allocation fa on (fa.code = fal.allocation_code)
								where	fa.status not in
			(
				'CANCEL'
			)
										and fa.code <> @p_allocation_code
							)
						and year = cast(year(@new_invoice_date) as nvarchar(4))
			order by	faktur_no asc ;

			-- pakai nomor faktur untuk update 
			update	faktur_allocation_detail
			set		faktur_no = @faktur_type + '0.' + @new_faktur
			where	id = @id ;

			-- update no faktur yang terpakai
			update	dbo.faktur_main
			set		status = 'ASSIGN'
					,invoice_no = @invoice_no
			where	faktur_no = @new_faktur ;

			fetch next from c_faktur
			into @id
				 ,@invoice_no
				 ,@new_invoice_date ;
		end ;

		close c_faktur ;
		deallocate c_faktur ;
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
