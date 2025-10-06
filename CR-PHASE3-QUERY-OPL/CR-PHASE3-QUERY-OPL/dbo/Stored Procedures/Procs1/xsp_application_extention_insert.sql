--Created by, Rian at 22/05/2023 

CREATE PROCEDURE dbo.xsp_application_extention_insert
(
	@p_id						bigint	= 0  output
	,@p_application_no			nvarchar(50)
	,@p_main_contract_status	nvarchar(50)
	,@p_main_contract_no		nvarchar(50)  = ''
	,@p_main_contract_file_name nvarchar(250) = ''
	,@p_main_contract_file_path nvarchar(250) = ''
	,@p_main_contract_date		datetime	  = null
	,@p_client_no				nvarchar(50)
	,@p_remarks					nvarchar(4000)
	,@p_is_standart			    nvarchar(1)	  = ''
	--
	,@p_cre_date				datetime
	,@p_cre_by					nvarchar(15)
	,@p_cre_ip_address			nvarchar(15)
	,@p_mod_date				datetime
	,@p_mod_by					nvarchar(15)
	,@p_mod_ip_address			nvarchar(15)
)
as
begin
	declare @code				 nvarchar(50)
			,@year				 nvarchar(4)
			,@month				 nvarchar(2)
			,@opl_code			 nvarchar(250)
			,@msg				 nvarchar(max)
			,@is_use_maintenance nvarchar(1)
			,@is_use_replacement nvarchar(1) ;

	begin try

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

		
		if (isnull(@p_main_contract_no, '') = '')
		begin
		
			set @year = cast(datepart(year, @p_mod_date) as nvarchar)
			set @month = replace(str(cast(datepart(month, @p_mod_date) as nvarchar), 2, 0), ' ', '0') ;

			exec dbo.xsp_generate_application_no @p_unique_code = @code output
												 ,@p_branch_code = N''
												 ,@p_year = @year
												 ,@p_month = @month
												 ,@p_opl_code = @opl_code
												 ,@p_run_number_length = 4--sepria(11-03-2025: update @p_run_number_length jadi 4 digit, karna udah mentok di 999)
												 ,@p_delimiter = N'/'
												 ,@p_type = N'MASTER CONTRACT'
		end 
		else
		begin
			set	@code	= @p_main_contract_no

			select	@p_main_contract_file_name = main_contract_file_name
					,@p_main_contract_file_path = main_contract_file_path
					,@p_is_standart = is_standart
					,@p_main_contract_date = main_contract_date
			from	dbo.main_contract_main
			where	main_contract_no = @p_main_contract_no ;
		end

		if (@code is null)
		begin
			set @msg = 'Failed generate Main Contract No';
			raiserror(@msg, 16, 1) ;
		end ;
		
		-- Louis Jumat, 03 Mei 2024 14.54.13 -- insert ke master contract main
		begin
			if not exists (select 1 from dbo.main_contract_main where main_contract_no = @p_main_contract_no)
			begin
				exec dbo.xsp_main_contract_main_insert @p_main_contract_no			= @code
													   ,@p_main_contract_file_name	= @p_main_contract_file_name
													   ,@p_main_contract_file_path	= @p_main_contract_file_path
													   ,@p_client_no				= @p_client_no
													   ,@p_remarks					= @p_remarks
													   ,@p_is_standart				= @p_is_standart
													   ,@p_main_contract_date		= @p_main_contract_date
													   ,@p_cre_date					= @p_cre_date
													   ,@p_cre_by					= @p_cre_by
													   ,@p_cre_ip_address			= @p_cre_ip_address
													   ,@p_mod_date					= @p_mod_date
													   ,@p_mod_by					= @p_mod_by
													   ,@p_mod_ip_address			= @p_mod_ip_address
			end
		end
	
		-- insert ke tabel application extention
		insert into dbo.application_extention
		(
			application_no
			,main_contract_status
			,main_contract_no
			,main_contract_file_name
			,main_contract_file_path
			,main_contract_date
			,client_no
			,remarks
			,is_valid
			,is_standart
			--
			,cre_date
			,cre_by
			,cre_ip_address
			,mod_date
			,mod_by
			,mod_ip_address
		)
		values
		(	@p_application_no
			,@p_main_contract_status
			,@code
			,@p_main_contract_file_name
			,@p_main_contract_file_path
			,@p_main_contract_date
			,@p_client_no
			,@p_remarks
			,'0'
			,@p_is_standart
			--
			,@p_cre_date
			,@p_cre_by
			,@p_cre_ip_address
			,@p_mod_date
			,@p_mod_by
			,@p_mod_ip_address
		) ;
		
			-- sepria phase 3. 06102025: generate ulang agar settingan yang terbaru bisa di ambil
			delete dbo.application_doc where application_no = @p_application_no

			exec dbo.xsp_application_doc_generate @p_application_no = @p_application_no,             -- nvarchar(50)
			                                      @p_cre_date = @p_mod_date, -- datetime
			                                      @p_cre_by = @p_mod_by,                     -- nvarchar(15)
			                                      @p_cre_ip_address = @p_mod_ip_address,             -- nvarchar(15)
			                                      @p_mod_date = @p_mod_date, -- datetime
			                                      @p_mod_by = @p_mod_by,                     -- nvarchar(15)
			                                      @p_mod_ip_address = @p_mod_ip_address              -- nvarchar(15)

		set @p_id = @@identity ;
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
