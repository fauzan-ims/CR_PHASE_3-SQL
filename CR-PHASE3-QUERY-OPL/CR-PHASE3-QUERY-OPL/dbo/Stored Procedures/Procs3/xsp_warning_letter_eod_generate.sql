/*
exec xsp_warning_letter_eod_generate
*/
-- Louis Senin, 20 Februari 2023 10.54.06 -- 
CREATE PROCEDURE dbo.xsp_warning_letter_eod_generate
as
begin

	declare @msg					nvarchar(max)
			--
			,@overdue_days				int
			,@facility_code				nvarchar(50)
			,@agreement_no				nvarchar(50)
			,@client_no					nvarchar(400)
			,@sp1_overdue_days			int
			,@sp2_overdue_days			int
			,@sp3_overdue_days			int
			,@letter_type				nvarchar(10)
			,@branch_code				nvarchar(50)
			,@branch_name				nvarchar(250)
			,@letter_no_sp1				nvarchar(50)
			,@letter_no_sp2				nvarchar(50)
			,@letter_no_somasi			nvarchar(50)
			,@installment_no			int
			,@previews_installment_no	int
			,@as_of_date				datetime
			,@no						int				= 1
			--
			,@mod_date					datetime		= dbo.xfn_get_system_date()
			,@mod_by					nvarchar(15)	= N'EOD'
			,@mod_ip_address			nvarchar(15)	= N'SYSTEM' ;

	begin try
		--jika as of date merupakan hari libur ( sabtu minggu / publik holiday)
		if not exists
		(
			select	1
			where @mod_date in
						(
							select	cast(HOLIDAY_DATE as date)
							from	IFINSYS.dbo.SYS_HOLIDAY
							where IS_ACTIVE = '1'
						)
				or	datepart(DW, @mod_date) in (1, 7	-- angka 1 adalah hari minggu, angka 7 adalah sabtu
												)
		)
		begin
			declare @temp_table table
			(
				sp_day int
			) ;

			insert into @temp_table
			(
				sp_day
			)
			select	SP1_DAYS
			from	MASTER_FACILITY
			union
			select	SP2_DAYS
			from	MASTER_FACILITY
			union
			select	SOMASI_DAYS
			from	MASTER_FACILITY ;

			while (@no <= 7)
			begin
				set @as_of_date = cast(dateadd(day, (@no * -1), dbo.xfn_get_system_date()) as date) ;

				--jika as of date merupakan hari libur ( sabtu minggu / publik holiday)
				if exists
				(
					select	1
					where @as_of_date in
									(
										select	cast(HOLIDAY_DATE as date)
										from	IFINSYS.dbo.SYS_HOLIDAY
										where IS_ACTIVE = '1'
									)
						or	datepart(DW, @as_of_date) in (1, 7	-- angka 1 adalah hari minggu, angka 7 adalah sabtu
														)
				)
				begin
					insert into @temp_table
					(
						sp_day
					)
					select	SP1_DAYS + @no
					from	MASTER_FACILITY
					union
					select	SP2_DAYS + @no
					from	MASTER_FACILITY
					union
					select	SOMASI_DAYS + @no
					from	MASTER_FACILITY ;

					set @no += 1 ;
				end ;
				--jika bukan publik holiday / hari sab/ming
				else
				begin
					break ;
				end ;
			end ;

			declare c_main cursor local fast_forward for
			--select	max(ai.OVD_DAYS)				'OVD_DAYS'
			--		,count(ai.AGREEMENT_NO)		'AGREEMENT_NO'
			--		,am.CLIENT_NO
			--		,max(am.BRANCH_CODE)		'BRANCH_CODE'
			--		,max(am.BRANCH_NAME)		'BRANCH_NAME'
			--		,max(mf.SP1_DAYS)			'SP1_DAYS'
			--		,max(mf.SP2_DAYS)			'SP2_DAYS'
			--		,max(mf.SOMASI_DAYS)		'SOMASI_DAYS'
			--		,max(ai.LAST_PAID_PERIOD + 1) 'LAST_PAID_PERIOD'
			--from	dbo.AGREEMENT_INFORMATION	ai
			--		inner join dbo.AGREEMENT_MAIN am on (am.AGREEMENT_NO = ai.AGREEMENT_NO)
			--		inner join dbo.MASTER_FACILITY mf on (mf.CODE = am.FACILITY_CODE)
			--where ai.OVD_DAYS in
			--	(
			--		select sp_day from @temp_table
			--	) and am.AGREEMENT_STATUS = 'GO LIVE' and	OVD_DAYS > 0
			--group by am.CLIENT_NO ;

			--cr phase 3, ambil dari invoice yang telat
			select	distinct inv.client_no
					,inv.branch_code
					,inv.branch_name
			from	dbo.invoice inv
					outer apply (	select	max(mf.sp1_days)			'sp1_days'
											,max(mf.sp2_days)			'sp2_days'
											,max(mf.somasi_days)		'somasi_days'
									from	dbo.invoice_detail invd
											inner join dbo.agreement_main am on am.agreement_no = invd.agreement_no
											inner join dbo.master_facility mf on (mf.code = am.facility_code)
									where	invd.invoice_no = inv.invoice_no
								) mf
			where	cast(inv.invoice_due_date as date) < cast(@mod_date as date)
			and		inv.invoice_status = 'POST'

			open c_main ;
			fetch c_main
			into @client_no
				,@branch_code
				,@branch_name

			while @@fetch_status = 0
			begin
				
				select	@overdue_days		=  datediff(day,min(inv.invoice_due_date),@mod_date)
						,@sp1_overdue_days	= max(sp1_days)
						,@sp2_overdue_days	= max(sp2_days)
						,@sp3_overdue_days	= max(somasi_days)
				from	dbo.invoice inv
						outer apply (	select	max(mf.sp1_days)			'sp1_days'
												,max(mf.sp2_days)			'sp2_days'
												,max(mf.somasi_days)		'somasi_days'
										from	dbo.invoice_detail invd
												inner join dbo.agreement_main am on am.agreement_no = invd.agreement_no
												inner join dbo.master_facility mf on (mf.code = am.facility_code)
										where	invd.invoice_no = inv.invoice_no
									) mf
				where	cast(inv.invoice_due_date as date) < cast(@mod_date as date)
				and		inv.invoice_status = 'POST'
				and		inv.client_no = @client_no

				if (
					@overdue_days >= @sp1_overdue_days and @overdue_days < @sp2_overdue_days
				)
				begin
					set @letter_type = N'SP1' ;
				end ;
				else if (
							@overdue_days >= @sp2_overdue_days and @overdue_days < @sp3_overdue_days
						)
				begin
					set @letter_type = N'SP2' ;
				end ;
				else if (@overdue_days >= @sp3_overdue_days)
				begin
					set @letter_type = N'SOMASI' ;
				end ;

				exec dbo.xsp_warning_letter_insert @p_code = ''
													,@p_branch_code = @branch_code
													,@p_branch_name = @branch_name
													,@p_letter_status = 'HOLD'
													,@p_letter_date = @mod_date
													,@p_letter_no = @letter_no_somasi output
													,@p_letter_type = @letter_type
													,@p_agreement_no = @agreement_no
													,@p_generate_type = 'EOD'
													,@p_client_no = @client_no
													--
													,@p_cre_date = @mod_date
													,@p_cre_by = @mod_by
													,@p_cre_ip_address = @mod_ip_address
													,@p_mod_date = @mod_date
													,@p_mod_by = @mod_by
													,@p_mod_ip_address = @mod_ip_address ;

				--if (@letter_type = 'SOMASI' or @letter_type = 'SP2' or @letter_type = 'SP1')
				--begin
				--	if exists
				--	(
				--		select	1
				--		from	WARNING_LETTER					wl
				--				inner join dbo.AGREEMENT_MAIN amn on (amn.AGREEMENT_NO = wl.AGREEMENT_NO)
				--		where wl.CLIENT_NO = @client_no
				--			and wl.INSTALLMENT_NO = @installment_no
				--			and wl.LETTER_TYPE	= 'SP1'
				--			and LETTER_STATUS not in ('CANCEL', 'DELIVERED', 'ALREADY PAID')
				--	)
				--	begin
				--		select	@letter_no_sp1	= LETTER_NO
				--		from	dbo.WARNING_LETTER
				--		where CLIENT_NO		= @client_no
				--			and INSTALLMENT_NO	= @installment_no
				--			and LETTER_TYPE		= 'SP1'
				--			and LETTER_STATUS not in ('CANCEL', 'DELIVERED', 'ALREADY PAID') ;
				--	end ;
				--	else
				--	begin

				--		exec dbo.xsp_warning_letter_insert @p_code = ''
				--										,@p_branch_code = @branch_code
				--										,@p_branch_name = @branch_name
				--										,@p_letter_status = 'HOLD'
				--										,@p_letter_date = @mod_date
				--										,@p_letter_no = @letter_no_sp1 output
				--										,@p_letter_type = 'SP1'
				--										,@p_agreement_no = @agreement_no
				--										,@p_generate_type = 'EOD'
				--										,@p_client_no = @client_no
				--										--
				--										,@p_cre_date = @mod_date
				--										,@p_cre_by = @mod_by
				--										,@p_cre_ip_address = @mod_ip_address
				--										,@p_mod_date = @mod_date
				--										,@p_mod_by = @mod_by
				--										,@p_mod_ip_address = @mod_ip_address ;
				--	end ;
				--end ;

				--if (@letter_type = 'SOMASI' or @letter_type = 'SP2')
				--begin

				--	if exists
				--	(
				--		select	1
				--		from	WARNING_LETTER					wl
				--				inner join dbo.AGREEMENT_MAIN amn on (amn.AGREEMENT_NO = wl.AGREEMENT_NO)
				--		where wl.CLIENT_NO = @client_no
				--			and wl.INSTALLMENT_NO = @installment_no
				--			and wl.LETTER_TYPE	= 'SP2'
				--			and LETTER_STATUS not in ('CANCEL', 'DELIVERED', 'ALREADY PAID')
				--	)
				--	begin
				--		select	@letter_no_sp2	= LETTER_NO
				--		from	dbo.WARNING_LETTER
				--		where CLIENT_NO		= @client_no
				--			and INSTALLMENT_NO	= @installment_no
				--			and LETTER_TYPE		= 'SP2'
				--			and LETTER_STATUS not in ('CANCEL', 'DELIVERED', 'ALREADY PAID') ;
				--	end ;
				--	else
				--	begin

				--		exec dbo.xsp_warning_letter_insert @p_code = ''
				--										,@p_branch_code = @branch_code
				--										,@p_branch_name = @branch_name
				--										,@p_letter_status = 'HOLD'
				--										,@p_letter_date = @mod_date
				--										,@p_letter_no = @letter_no_sp2 output
				--										,@p_letter_type = 'SP2'
				--										,@p_agreement_no = @agreement_no
				--										,@p_generate_type = 'EOD'
				--										,@p_client_no = @client_no
				--										--
				--										,@p_cre_date = @mod_date
				--										,@p_cre_by = @mod_by
				--										,@p_cre_ip_address = @mod_ip_address
				--										,@p_mod_date = @mod_date
				--										,@p_mod_by = @mod_by
				--										,@p_mod_ip_address = @mod_ip_address ;

				--		update	dbo.WARNING_LETTER
				--		set PREVIOUS_LETTER_CODE = @letter_no_sp1
				--			--
				--			,MOD_DATE = @mod_date
				--			,MOD_BY = @mod_by
				--			,MOD_IP_ADDRESS = @mod_ip_address
				--		where LETTER_NO = @letter_no_sp2 ;
				--	end ;
				--end ;

				--if (@letter_type = 'SOMASI')
				--begin
				--	if not exists
				--	(
				--		select	1
				--		from	WARNING_LETTER					wl
				--				inner join dbo.AGREEMENT_MAIN amn on (amn.AGREEMENT_NO = wl.AGREEMENT_NO)
				--		where wl.CLIENT_NO = @client_no
				--			and wl.INSTALLMENT_NO = @installment_no
				--			and wl.LETTER_TYPE	= 'SOMASI'
				--			and LETTER_STATUS not in ('CANCEL', 'DELIVERED', 'ALREADY PAID')
				--	)
				--	begin
				--		exec dbo.xsp_warning_letter_insert @p_code = ''
				--										,@p_branch_code = @branch_code
				--										,@p_branch_name = @branch_name
				--										,@p_letter_status = 'HOLD'
				--										,@p_letter_date = @mod_date
				--										,@p_letter_no = @letter_no_somasi output
				--										,@p_letter_type = 'SOMASI'
				--										,@p_agreement_no = @agreement_no
				--										,@p_generate_type = 'EOD'
				--										,@p_client_no = @client_no
				--										--
				--										,@p_cre_date = @mod_date
				--										,@p_cre_by = @mod_by
				--										,@p_cre_ip_address = @mod_ip_address
				--										,@p_mod_date = @mod_date
				--										,@p_mod_by = @mod_by
				--										,@p_mod_ip_address = @mod_ip_address ;

				--		update	dbo.WARNING_LETTER
				--		set PREVIOUS_LETTER_CODE = @letter_no_sp2
				--			--
				--			,MOD_DATE = @mod_date
				--			,MOD_BY = @mod_by
				--			,MOD_IP_ADDRESS = @mod_ip_address
				--		where LETTER_NO = @letter_no_somasi ;
				--	end ;
				--end ;

				-- reset
				set @letter_no_sp1 = N'' ;
				set @letter_no_sp2 = N'' ;
				set @letter_no_somasi = N'' ;
				set @letter_type = '';
				set @overdue_days		= 0
				set @sp1_overdue_days	= 0
				set @sp2_overdue_days	= 0
				set @sp3_overdue_days	= 0

				fetch c_main
				into @client_no
					,@branch_code
					,@branch_name	

			end ;
			close c_main ;
			deallocate c_main ;
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
			if (error_message() like '%V;%' or error_message() like '%E;%')
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