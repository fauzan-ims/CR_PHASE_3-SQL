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
			,@client_no					nvarchar(400)
			,@sp1_overdue_days			int
			,@sp2_overdue_days			int
			,@sp3_overdue_days			int
			,@letter_type				nvarchar(10)
			,@branch_code				nvarchar(50)
			,@branch_name				nvarchar(250)
			,@letter_no					nvarchar(50)
			--
			,@mod_date					datetime		= dbo.xfn_get_system_date()
			,@mod_by					nvarchar(15)	= N'EOD1'
			,@mod_ip_address			nvarchar(15)	= N'SYSTEM' ;

	begin try
		--jika as of date merupakan hari libur ( sabtu minggu / publik holiday)
		
		begin
			
			-- hapus yang belum di proses
			delete	dbo.warning_letter
			where	letter_status = 'HOLD' and generate_type = 'EOD'

			select  @sp1_overdue_days	= max(sp1_days)
					,@sp2_overdue_days	= max(sp2_days)
					,@sp3_overdue_days	= max(somasi_days)
			from	dbo.master_facility

			select	@branch_code = code
					,@branch_name	= name
			from	ifinsys.dbo.sys_branch 
			where	branch_type = 'HO'

			--cr phase 3, ambil dari invoice yang telat
			declare c_main cursor local fast_forward for
			select	inv.client_no
					,datediff(day,min(inv.invoice_due_date),@mod_date)
			from	dbo.invoice inv
			where	cast(inv.invoice_due_date as date) < cast(@mod_date as date)
			and		inv.invoice_status = 'POST'
			and		inv.client_no not in (select client_no from dbo.warning_letter where generate_type = 'EOD' and letter_status in ('HOLD','ON PROCESS'))
			and		inv.client_no not in (select client_no from dbo.warning_letter_delivery where generate_type = 'EOD' and delivery_status in ('HOLD','ON PROCESS'))
			group by inv.client_no

			open c_main ;
			fetch c_main
			into @client_no
				,@overdue_days

			while @@fetch_status = 0
			begin
				
				if (@overdue_days <= @sp1_overdue_days)
				begin
					set @letter_type = N'SP1' ;
				end ;
				else if (@overdue_days > @sp1_overdue_days and @overdue_days <= @sp2_overdue_days)
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
													,@p_letter_no = @letter_no output
													,@p_letter_type = @letter_type
													,@p_agreement_no = ''
													,@p_generate_type = 'EOD'
													,@p_client_no = @client_no
													--
													,@p_cre_date = @mod_date
													,@p_cre_by = @mod_by
													,@p_cre_ip_address = @mod_ip_address
													,@p_mod_date = @mod_date
													,@p_mod_by = @mod_by
													,@p_mod_ip_address = @mod_ip_address ;

				
				set @letter_no = N'' ;
				set @letter_type = '';

				fetch c_main
				into @client_no
					,@overdue_days

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