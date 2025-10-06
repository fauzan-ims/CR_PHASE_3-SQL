/*
exec xsp_job_eod_generate_billing
*/
-- Louis Handry 27/02/2023 20:44:35 -- 
CREATE PROCEDURE dbo.xsp_job_eod_generate_billing
AS
begin
	declare @msg					nvarchar(max)
			,@agreement_no			nvarchar(50)
			,@branch_code			nvarchar(50)
			,@branch_name			nvarchar(250)
			,@billing_generate_code nvarchar(50)
			,@as_of_date			datetime
			,@system_date			datetime = dbo.xfn_get_system_date()
			,@target_system_date	datetime = dbo.xfn_get_system_date()
			,@target				int = 0 
			,@count_not_holiday		int = 1 
			,@max_billing_date		nvarchar(250)
			,@no					int = 1
			,@billing_generate_day	int
			,@mod_date				datetime	 = getdate()
			,@mod_by				nvarchar(15) = N'EOD'
			,@mod_ip_address		nvarchar(15) = N'127.0.0.1' ;

	begin try
		begin
			select	@branch_code = value
					,@branch_name = description
			from	dbo.sys_global_param
			where	code = 'HO' ; 

			select	@billing_generate_day = value
			from	dbo.sys_global_param
			where	code = 'DDBBIL' ; 

			set @as_of_date = cast(dateadd(day, @billing_generate_day, dbo.xfn_get_system_date()) as date)

			--while diggunakan untuk mendapatkan berapa banyak hari kerja 
			begin
				while (cast(@target_system_date as date) < cast(@as_of_date as date))
				begin
					set @target_system_date = cast(dateadd(day, 1, @target_system_date) as date) ;

					if exists
					(
						select	1
						where	@target_system_date in
								(
									select	cast(holiday_date as date)
									from	ifinsys.dbo.sys_holiday
									where	is_active = '1'
								)
								or	datepart(DW, @target_system_date) in
								(
									1, 7
								)
					)
					begin
						set @target += 1 ;
					end ;
				end ;
			end ;

			--looping diggunakan untuk mendapatkan as of date berdasarkan banyak ny hari kerja dan as of date tidak sama dengan hari libur atau sab/ming
			begin
				while (
						  @no <= 7
						  and	@count_not_holiday <= @target
					  ) -- count not holyday < target
				begin
					set @as_of_date = cast(dateadd(day, 1, @as_of_date) as date) ;

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
									1, 7
								)
					)
					begin
						set @no += 1 ;
					end ;
					else if not exists
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
									1, 7
								)
					)
					begin
						break ;
					end ;
					else --jika bukan publik holiday / hari sab/ming
					begin
						set @count_not_holiday += 1 ;
					end ;
				end ;
			end ;

			if exists
			(
				select	1
				from	dbo.agreement_asset_amortization asa
						inner join agreement_asset ast on (asa.asset_no		 = ast.asset_no)
						inner join dbo.agreement_main am on (am.agreement_no = asa.agreement_no)
				where	asa.generate_code is null
						and cast(billing_date as date)		<= @as_of_date
						and ast.handover_status				= 'POST'
						and ast.asset_status				= 'RENTED'
						and am.client_no					= am.client_no	
						and asa.agreement_no				= asa.agreement_no
						and asa.asset_no					= asa.asset_no	
						and isnull(am.is_stop_billing, '0') <> '1'
			)
			begin
				exec dbo.xsp_billing_generate_insert @p_code			= @billing_generate_code output 
													 ,@p_branch_code	= @branch_code
													 ,@p_branch_name	= @branch_name
													 ,@p_date			= @system_date
													 ,@p_status			= N'HOLD'
													 ,@p_remark			= N'Automatic Generate Invoice By EOD'
													 ,@p_client_no		= N''
													 ,@p_client_name	= N''
													 ,@p_agreement_no	= N''
													 ,@p_asset_no		= N''
													 ,@p_as_off_date	= @as_of_date
													 ,@p_is_eod			= '1'
													 --
													 ,@p_cre_date		= @mod_date		
													 ,@p_cre_by			= @mod_by		
													 ,@p_cre_ip_address = @mod_ip_address
													 ,@p_mod_date		= @mod_date		
													 ,@p_mod_by			= @mod_by		
													 ,@p_mod_ip_address = @mod_ip_address

				exec dbo.xsp_billing_generate_post @p_code				= @billing_generate_code 
												   ,@p_mod_date			= @mod_date		
												   ,@p_mod_by			= @mod_by		
												   ,@p_mod_ip_address	= @mod_ip_address
			end ;
			
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
