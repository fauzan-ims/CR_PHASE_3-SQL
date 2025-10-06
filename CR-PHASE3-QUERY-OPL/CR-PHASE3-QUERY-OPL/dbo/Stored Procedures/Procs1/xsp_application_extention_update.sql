--created by, Rian at 22/05/2023 

CREATE PROCEDURE dbo.xsp_application_extention_update
(
	@p_id						bigint
	,@p_application_no			nvarchar(50)
	,@p_main_contract_status	nvarchar(50)
	,@p_main_contract_no		nvarchar(50)   = ''
	,@p_main_contract_file_name nvarchar(250)  = ''
	,@p_main_contract_file_path nvarchar(250)  = ''
	,@p_memo_file_name			nvarchar(250)  = null
	,@p_memo_file_path			nvarchar(250)  = null
	,@p_main_contract_date		datetime	   = null
	,@p_remarks					nvarchar(4000) 
	,@p_is_standart				nvarchar(1)	   = ''
	--
	,@p_mod_date				datetime
	,@p_mod_by					nvarchar(15)
	,@p_mod_ip_address			nvarchar(15)
)
as
begin
	declare @code						nvarchar(50)
			,@clien_no					nvarchar(50)
			,@year						nvarchar(4)
			,@month						nvarchar(2)
			,@opl_code					nvarchar(250)
			,@contract_status			nvarchar(50)
			,@msg						nvarchar(max)
			,@is_use_maintenance		nvarchar(1)
			,@is_use_replacement		nvarchar(1)
			,@client_no					nvarchar(50)
			,@temp_main_contract_no		nvarchar(50)
			,@old_main_contrac_no		nvarchar(50) 
			,@old_main_contract_status	nvarchar(50)

	begin try 

		--select	@clien_no	= client_code
		--from	dbo.application_main
		--where	application_no = @p_application_no ;

		--set	@opl_code = @clien_no + ' - OPL'
		select	@old_main_contract_status = main_contract_status
				,@old_main_contrac_no = main_contract_no
		from	dbo.application_extention
		where	application_no = @p_application_no ;

		if (
			   @old_main_contract_status = 'NEW'
			   --and	@p_main_contract_status = 'EXISTING'
		   )
		begin
			if exists
			(
				select	1
				from	dbo.application_extention
				where	main_contract_no   = @old_main_contrac_no
						and application_no <> @p_application_no
			)
			begin
				set @msg = N'Main Contract No : ' + @old_main_contrac_no + N' already Used' ;

				raiserror(@msg, 16, -1) ;
			end ;
		end ;

		if (@p_is_standart = '1')
		begin
			set @p_memo_file_name = null ;
			set @p_memo_file_path = null ;
		end ;
		else
		begin
			select	@p_memo_file_name = memo_file_name
					,@p_memo_file_path = memo_file_path
			from	dbo.application_extention
			where	application_no			 = @p_application_no 
		end ;

		select	top 1
				@is_use_maintenance = is_use_maintenance
				,@is_use_replacement = is_use_replacement
		from	dbo.application_asset
		where	application_no = @p_application_no ;

		if (
			   @is_use_maintenance = '1'
			   and	@is_use_replacement = '0'
		   )
		begin
			set @opl_code = N'OPL-AGR/FWR' ;
		end ;
		else if (@is_use_maintenance = '1')
		begin
			set @opl_code = N'OPL-AGR/FM' ;
		end ;
		else if (@is_use_maintenance = '0')
		begin
			set @opl_code = N'OPL-AGR/NM' ;
		end ;

		if (@p_main_contract_status = 'NEW')
		begin 
			if (@p_is_standart = '1')
			begin
				set @p_memo_file_name = null ;
				set @p_memo_file_path = null ;
			end ;

			if exists
			(
				select	1
				from	dbo.application_extention
				where	application_no			 = @p_application_no
						and main_contract_status = @p_main_contract_status
			)
			begin  
				update	dbo.application_extention
				set		main_contract_file_name		= @p_main_contract_file_name
						,main_contract_file_path	= @p_main_contract_file_path
						,memo_file_name				= @p_memo_file_name
						,memo_file_path				= @p_memo_file_path
						,main_contract_date			= @p_main_contract_date
						,remarks					= @p_remarks
						,is_standart				= @p_is_standart
						--
						,mod_date					= @p_mod_date
						,mod_by						= @p_mod_by
						,mod_ip_address				= @p_mod_ip_address
				where	application_no				= @p_application_no
				and		id							= @p_id
			end
			else
			begin
				set @year = cast(datepart(year, @p_mod_date) as nvarchar)
				set @month = replace(str(cast(datepart(month, @p_mod_date) as nvarchar), 2, 0), ' ', '0') ;

				exec dbo.xsp_generate_application_no @p_unique_code			= @code output
													 ,@p_branch_code		= N''
													 ,@p_year				= @year
													 ,@p_month				= @month
													 ,@p_opl_code			= @opl_code
													 ,@p_run_number_length	= 3
													 ,@p_delimiter			= N'/'
													 ,@p_type				= N'MASTER CONTRACT'	

				update	dbo.application_extention
				set		main_contract_status		= @p_main_contract_status
						,main_contract_no			= @code
						,main_contract_file_name	= @p_main_contract_file_name
						,main_contract_file_path	= @p_main_contract_file_path
						,memo_file_name				= @p_memo_file_name
						,memo_file_path				= @p_memo_file_path
						,main_contract_date			= @p_main_contract_date
						,remarks					= @p_remarks
						,is_standart				= @p_is_standart
						--
						,mod_date					= @p_mod_date
						,mod_by						= @p_mod_by
						,mod_ip_address				= @p_mod_ip_address
				where	application_no				= @p_application_no
				and		id							= @p_id
			end
		end
		else
		begin
			if exists
			(
				select	1
				from	dbo.application_extention
				where	application_no			 = @p_application_no
						and main_contract_status = 'NEW'
			)
			begin
				select	@temp_main_contract_no = main_contract_no
				from	dbo.application_extention
				where	application_no = @p_application_no ;

				delete	dbo.main_contract_main
				where	main_contract_no = @temp_main_contract_no ;
			end ;

			select	@p_main_contract_file_name = main_contract_file_name
					,@p_main_contract_file_path = main_contract_file_path
					,@p_is_standart = is_standart
					,@p_main_contract_date = main_contract_date
			from	dbo.main_contract_main
			where	main_contract_no = @p_main_contract_no ;

			update	dbo.application_extention
			set		main_contract_status		= @p_main_contract_status
					,main_contract_no			= @p_main_contract_no
					,main_contract_file_name	= @p_main_contract_file_name
					,main_contract_file_path	= @p_main_contract_file_path
					,memo_file_name				= @p_memo_file_name
					,memo_file_path				= @p_memo_file_path
					,main_contract_date			= @p_main_contract_date
					,remarks					= @p_remarks
					,is_standart				= @p_is_standart
					--
					,mod_date					= @p_mod_date
					,mod_by						= @p_mod_by
					,mod_ip_address				= @p_mod_ip_address
			where	application_no				= @p_application_no
			and		id							= @p_id

			-- sepria phase 3. 06102025: update isian doc dari yang last valid master contract
			update	dbo.application_doc
			set		is_valid		= valid.is_valid
					,remarks		= valid.remarks
					,is_received	= valid.is_received
					,promise_date	= valid.promise_date
					,is_edit		= '0'
			from	dbo.application_doc apd
			outer apply (	select	promise_date
									,ap.is_received 
									,ap.remarks
									,ap.is_valid
							from	dbo.application_doc ap
							where	application_no in (select top 1 ax.application_no from dbo.application_extention ax 
														where  main_contract_no = @p_main_contract_no and is_valid = '1' order by mod_date desc)
							and		apd.document_code = ap.document_code 				
						) valid
				where apd.application_no = @p_application_no
			
		end

		select @p_main_contract_no = main_contract_no
				,@client_no = client_no
		from	dbo.application_extention
		where	application_no = @p_application_no ;

		if not exists (select 1 from dbo.main_contract_main where main_contract_no= @p_main_contract_no)
		begin
			exec dbo.xsp_main_contract_main_insert @p_main_contract_no			= @p_main_contract_no
												   ,@p_main_contract_file_name	= @p_main_contract_file_name
												   ,@p_main_contract_file_path	= @p_main_contract_file_path 
												   ,@p_client_no				= @client_no
												   ,@p_remarks					= @p_remarks
												   ,@p_is_standart				= @p_is_standart
												   ,@p_main_contract_date		= @p_main_contract_date
												   ,@p_cre_date					= @p_mod_date
												   ,@p_cre_by					= @p_mod_by
												   ,@p_cre_ip_address			= @p_mod_ip_address
												   ,@p_mod_date					= @p_mod_date
												   ,@p_mod_by					= @p_mod_by
												   ,@p_mod_ip_address			= @p_mod_ip_address
			
		end
		else
		begin
			update	dbo.main_contract_main
			set		main_contract_date = @p_main_contract_date
			where	main_contract_no = @p_main_contract_no ;
		end

		update	dbo.application_extention
		set		is_valid					= '0'
				--
				,mod_date					= @p_mod_date
				,mod_by						= @p_mod_by
				,mod_ip_address				= @p_mod_ip_address
		where	application_no				= @p_application_no
		and		id							= @p_id

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
END
