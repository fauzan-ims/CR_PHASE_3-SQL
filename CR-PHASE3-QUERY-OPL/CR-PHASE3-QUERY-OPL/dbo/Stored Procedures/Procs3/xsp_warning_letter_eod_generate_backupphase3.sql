/*
exec xsp_warning_letter_eod_generate
*/
-- Louis Senin, 20 Februari 2023 10.54.06 -- 
CREATE PROCEDURE dbo.xsp_warning_letter_eod_generate_backupphase3
as
begin

	declare @msg							nvarchar(max)
			--
			,@overdue_days					int
			,@facility_code					nvarchar(50)
			,@agreement_no					nvarchar(50)
			,@sp1_overdue_days				int
			,@sp2_overdue_days				int
			,@sp3_overdue_days				int
            ,@letter_type					nvarchar (10)
			,@branch_code					nvarchar(50)
			,@branch_name					nvarchar(250)
			,@letter_no_sp1					nvarchar(50)
			,@letter_no_sp2					nvarchar(50)
			,@letter_no_somasi				nvarchar(50)
			,@installment_no				int
			,@previews_installment_no		int
			,@as_of_date				    datetime
			,@no						    int				= 1
			--
			,@mod_date						datetime		= dbo.xfn_get_system_date()
			,@mod_by						nvarchar(15)	= 'EOD'
			,@mod_ip_address				nvarchar(15)	= 'SYSTEM'

	begin try
		--jika as of date merupakan hari libur ( sabtu minggu / publik holiday)
		if not exists
		(
			select	1
			where	@mod_date in
					(
						select	cast(holiday_date as date)
						from	ifinsys.dbo.sys_holiday
						where	is_active = '1'
					)
					or	datepart(DW, @mod_date) in
					(
						1, 7 -- angka 1 adalah hari minggu, angka 7 adalah sabtu
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
			select	sp1_days
			from	master_facility
			union
			select	sp2_days
			from	master_facility
			union
			select	somasi_days
			from	master_facility ;

			while (@no <= 7)
			begin
				set @as_of_date = cast(dateadd(day, (@no * -1), dbo.xfn_get_system_date()) as date) ;

				--jika as of date merupakan hari libur ( sabtu minggu / publik holiday)
				if exists
				(
					select	1
					where	@as_of_date in
							(
								select	cast(holiday_date as date)
								from	ifinsys.dbo.sys_holiday
								where	is_active = '1'
							)
							or	datepart(DW, @as_of_date) in
				(
					1, 7 -- angka 1 adalah hari minggu, angka 7 adalah sabtu
				)
				)
				begin
					insert into @temp_table
					(
						sp_day
					)
					select	sp1_days + @no
					from	master_facility
					union
					select	sp2_days + @no
					from	master_facility
					union
					select	somasi_days + @no
					from	master_facility ;

					set @no += 1 ;
				end ;
				--jika bukan publik holiday / hari sab/ming
				else
				begin
					break ;
				end ;
			end ; 
			
			declare c_main cursor local fast_forward for

			select	ai.ovd_days
					,ai.agreement_no
					,am.branch_code
					,am.branch_name
					,mf.sp1_days
					,mf.sp2_days
					,mf.somasi_days
					,ai.last_paid_period + 1
			from	dbo.agreement_information ai
					inner join dbo.agreement_main am on (am.agreement_no = ai.agreement_no)
					inner join dbo.master_facility mf on (mf.code		 = am.facility_code)
			where	ai.ovd_days in (select sp_day from @temp_table) 
					and am.agreement_status = 'GO LIVE'
					and ovd_days > 0

			open	c_main
			fetch	c_main
			into	@overdue_days				
					 ,@agreement_no	
					 ,@branch_code
					 ,@branch_name	
					 ,@sp1_overdue_days			
					 ,@sp2_overdue_days			
					 ,@sp3_overdue_days		
					 ,@installment_no	

			while @@fetch_status = 0
			begin
			 
				if (@overdue_days >= @sp1_overdue_days and @overdue_days < @sp2_overdue_days)
				begin
					set @letter_type ='SP1'
				end
				else if (@overdue_days >= @sp2_overdue_days and @overdue_days < @sp3_overdue_days)
				begin
					set @letter_type ='SP2'
				end
				else if (@overdue_days >= @sp3_overdue_days)
				begin
					set @letter_type ='SOMASI'
				end 

				if (@letter_type ='SOMASI' or @letter_type ='SP2' or @letter_type ='SP1' )
				begin 
					if exists
					(
						select	1
						from	warning_letter wl
								inner join dbo.agreement_main amn on (amn.agreement_no = wl.agreement_no)
						where	wl.agreement_no		  = @agreement_no
								and wl.installment_no = @installment_no
								and wl.letter_type	  = 'SP1'
								and letter_status not in
					(
						'CANCEL', 'DELIVERED', 'ALREADY PAID'
					)
					)
					begin
						select	@letter_no_sp1 = letter_no
						from	dbo.warning_letter
						where	agreement_no	   = @agreement_no
								and installment_no = @installment_no
								and letter_type	   = 'SP1'
								and letter_status not in
						(
							'CANCEL', 'DELIVERED', 'ALREADY PAID'
						) ;
					end ;
					else
					begin
				 
						exec dbo.xsp_warning_letter_insert @p_code				= ''
														   ,@p_branch_code		= @branch_code
														   ,@p_branch_name		= @branch_name
														   ,@p_letter_status	= 'HOLD'
														   ,@p_letter_date		= @mod_date
														   ,@p_letter_no		= @letter_no_sp1 output
														   ,@p_letter_type		= 'SP1'
														   ,@p_agreement_no		= @agreement_no
														   ,@p_generate_type	= 'EOD'
														   --
														   ,@p_cre_date			= @mod_date
														   ,@p_cre_by			= @mod_by
														   ,@p_cre_ip_address	= @mod_ip_address
														   ,@p_mod_date			= @mod_date
														   ,@p_mod_by			= @mod_by
														   ,@p_mod_ip_address	= @mod_ip_address 
				end
			end

			if (@letter_type ='SOMASI' or @letter_type ='SP2')
			begin
			
				if exists
				(
					select	1
					from	warning_letter wl
							inner join dbo.agreement_main amn on (amn.agreement_no = wl.agreement_no)
					where	wl.agreement_no		  = @agreement_no
							and wl.installment_no = @installment_no
							and wl.letter_type	  = 'SP2'
							and letter_status not in
				(
					'CANCEL', 'DELIVERED', 'ALREADY PAID'
				)
				)
				begin
					select	@letter_no_sp2 = letter_no
					from	dbo.warning_letter
					where	agreement_no	   = @agreement_no
							and installment_no = @installment_no
							and letter_type	   = 'SP2'
							and letter_status not in
					(
						'CANCEL', 'DELIVERED', 'ALREADY PAID'
					) ;
				end ;
				else
				begin
                    
					exec dbo.xsp_warning_letter_insert @p_code				= ''
														,@p_branch_code		= @branch_code
														,@p_branch_name		= @branch_name
														,@p_letter_status	= 'HOLD'
														,@p_letter_date		= @mod_date
														,@p_letter_no		= @letter_no_sp2 output
														,@p_letter_type		= 'SP2'
														,@p_agreement_no	= @agreement_no
														,@p_generate_type	= 'EOD'
														--
														,@p_cre_date		= @mod_date
														,@p_cre_by			= @mod_by
														,@p_cre_ip_address	= @mod_ip_address
														,@p_mod_date		= @mod_date
														,@p_mod_by			= @mod_by
														,@p_mod_ip_address	= @mod_ip_address 

					update	dbo.warning_letter
					set		previous_letter_code = @letter_no_sp1
							--
							,mod_date			 = @mod_date
							,mod_by				 = @mod_by
							,mod_ip_address		 = @mod_ip_address
					where	letter_no			 = @letter_no_sp2 ;
				end
			end

			if (@letter_type ='SOMASI')
			begin
				if not exists 
				(
					select 1 from warning_letter wl
					inner join dbo.agreement_main amn on (amn.agreement_no = wl.agreement_no)
					where wl.agreement_no = @agreement_no 
						and wl.installment_no = @installment_no
						and wl.letter_type = 'SOMASI'
						and letter_status not in ('CANCEL','DELIVERED','ALREADY PAID')
				)
				begin  
					exec dbo.xsp_warning_letter_insert @p_code				= ''
														,@p_branch_code		= @branch_code
														,@p_branch_name		= @branch_name
														,@p_letter_status	= 'HOLD'
														,@p_letter_date		= @mod_date
														,@p_letter_no		= @letter_no_somasi output
														,@p_letter_type		= 'SOMASI'
														,@p_agreement_no	= @agreement_no
														,@p_generate_type	= 'EOD'
														--
														,@p_cre_date		= @mod_date
														,@p_cre_by			= @mod_by
														,@p_cre_ip_address	= @mod_ip_address
														,@p_mod_date		= @mod_date
														,@p_mod_by			= @mod_by
														,@p_mod_ip_address	= @mod_ip_address 
 
					update	dbo.warning_letter
					set		previous_letter_code	= @letter_no_sp2
					--
							,mod_date				= @mod_date
							,mod_by					= @mod_by
							,mod_ip_address			= @mod_ip_address 
					where	letter_no				= @letter_no_somasi
				end
			end
                    
				-- reset
				set @letter_no_sp1 = ''
				set @letter_no_sp2 = ''
				set @letter_no_somasi = ''

				fetch	c_main
				into	@overdue_days				
						 ,@agreement_no	
						 ,@branch_code
						 ,@branch_name	
						 ,@sp1_overdue_days			
						 ,@sp2_overdue_days			
						 ,@sp3_overdue_days
						 ,@installment_no

			end
			close c_main
			deallocate c_main
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

end   
