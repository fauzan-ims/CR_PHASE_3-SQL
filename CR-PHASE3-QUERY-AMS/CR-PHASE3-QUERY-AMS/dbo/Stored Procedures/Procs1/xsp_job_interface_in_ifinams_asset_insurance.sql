CREATE procedure [dbo].[xsp_job_interface_in_ifinams_asset_insurance]
as
declare @msg					nvarchar(max)
		,@row_to_process		int
		,@last_id_from_job		bigint
		,@type_asset_code		nvarchar(50)
		,@id_interface			bigint
		,@code_sys_job			nvarchar(50)
		,@is_active				nvarchar(1)
		,@last_id				bigint		  = 0
		,@number_rows			int			  = 0
		,@mod_date				datetime	  = getdate()
		,@mod_by				nvarchar(15)  = N'job'
		,@mod_ip_address		nvarchar(15)  = N'127.0.0.1'
		,@from_id				bigint		  = 0
		,@current_mod_date		datetime
		,@is_success			nvarchar(1)	  = 0
		,@err_msg				nvarchar(4000)
		,@merk_code				nvarchar(50)
		,@model_code			nvarchar(50)
		,@request_code			nvarchar(50)
		,@type_code				nvarchar(50)
		,@item_code				nvarchar(50)
		,@purchase_price		decimal(18, 2)
		,@category_name			nvarchar(250)
		,@category_code			nvarchar(50)
		,@depre_cat_comm_code	nvarchar(50)
		,@depre_cat_fiscal_code nvarchar(50)
		,@use_life				int
		,@amt_threshold			decimal(18, 2)
		,@value_type			nvarchar(50)
		,@is_valid				int
		,@is_depre				nvarchar(1)
		,@code					nvarchar(50)
		,@item_group_code		nvarchar(50)
		,@category_code_header	nvarchar(50)
		,@unit_from				nvarchar(50)
		,@cover_note			nvarchar(50)
		,@cover_note_date		datetime
		,@cover_exp_date		datetime
		,@cover_file_name		nvarchar(250)
		,@cover_file_path		nvarchar(250)
		,@is_maintenance		nvarchar(1)
		,@model_code_main		nvarchar(50)
		,@stnk_no				nvarchar(50)
		,@stnk_date				datetime
		,@stnk_exp_date			datetime
		,@stck_no				nvarchar(50)
		,@stck_date				datetime
		,@stck_exp_date			datetime
		,@keur_no				nvarchar(50)
		,@keur_date				datetime
		,@keur_exp_date			datetime
		,@usefull				int
		,@rate					decimal(9, 6)
		,@posting_date			datetime ;	--(+) Ari 2024-03-26 ket : add posting date

select	@code_sys_job	   = code
		,@row_to_process   = row_to_process
		,@last_id_from_job = last_id
		,@is_active		   = is_active
from	dbo.sys_job_tasklist
where	sp_name = 'xsp_job_interface_in_ifinams_asset_insurance' ;	-- sesuai dengan nama sp ini

if (@is_active = '1')
begin
	--get approval request
	declare curr_asset cursor for
	select		id
	from		dbo.ifinams_interface_asset_insurance
	where		job_status in
	(
		'HOLD', 'FAILED'
	)
	order by	id asc offset 0 rows fetch next @row_to_process rows only ;

	open curr_asset ;

	fetch next from curr_asset
	into @id_interface ;

	while @@fetch_status = 0
	begin
		begin try
			set @is_success = N'0' ;

			begin transaction ;

			if (@number_rows = 0)
			begin
				set @from_id = @id_interface ;
			end ;

			insert into dbo.asset_insurance
			(
				asset_no
				,main_coverage_code
				,main_coverage_description
				,region_code
				,region_description
				,main_coverage_premium_amount
				,is_use_tpl
				,tpl_coverage_code
				,tpl_coverage_description
				,tpl_premium_amount
				,is_use_pll
				,pll_coverage_code
				,pll_coverage_description
				,pll_premium_amount
				,is_use_pa_passenger
				,pa_passenger_amount
				,pa_passenger_seat
				,pa_passenger_premium_amount
				,is_use_pa_driver
				,pa_driver_amount
				,pa_driver_premium_amount
				,is_use_srcc
				,srcc_premium_amount
				,is_use_ts
				,ts_premium_amount
				,is_use_flood
				,flood_premium_amount
				,is_use_earthquake
				,earthquake_premium_amount
				,is_commercial_use
				,commercial_premium_amount
				,is_authorize_workshop
				,authorize_workshop_premium_amount
				,total_premium_amount
				,is_tbod
				,tbod_premium_amount
				,asset_code
				--
				,cre_date
				,cre_by
				,cre_ip_address
				,mod_date
				,mod_by
				,mod_ip_address
			)
			select	asset_no
					,main_coverage_code
					,main_coverage_description
					,region_code
					,region_description
					,main_coverage_premium_amount
					,is_use_tpl
					,tpl_coverage_code
					,tpl_coverage_description
					,tpl_premium_amount
					,is_use_pll
					,pll_coverage_code
					,pll_coverage_description
					,pll_premium_amount
					,is_use_pa_passenger
					,pa_passenger_amount
					,pa_passenger_seat
					,pa_passenger_premium_amount
					,is_use_pa_driver
					,pa_driver_amount
					,pa_driver_premium_amount
					,is_use_srcc
					,srcc_premium_amount
					,is_use_ts
					,ts_premium_amount
					,is_use_flood
					,flood_premium_amount
					,is_use_earthquake
					,earthquake_premium_amount
					,is_commercial_use
					,commercial_premium_amount
					,is_authorize_workshop
					,authorize_workshop_premium_amount
					,total_premium_amount
					,is_tbod
					,tbod_premium_amount
					,asset_code
					--
					,@mod_date
					,@mod_by
					,@mod_ip_address
					,@mod_date
					,@mod_by
					,@mod_ip_address
			from	dbo.ifinams_interface_asset_insurance
			where	id = @id_interface ;

			set @number_rows = +1 ;
			set @last_id = @id_interface ;

			update	dbo.ifinams_interface_asset_insurance	--cek poin
			set		job_status = 'POST'
			where	id = @id_interface ;

			commit transaction ;

			set @is_success = N'1' ;
		end try
		begin catch
			rollback transaction ;

			set @is_success = N'0' ;
			set @msg = error_message() ;
			set @current_mod_date = getdate() ;

			update	dbo.ifinams_interface_asset_insurance	--cek poin
			set		job_status = 'FAILED'
					,FAILED_REMARK = @msg
			where	id = @id_interface ;

			--cek poin	

			/*insert into dbo.sys_job_tasklist_log*/
			exec dbo.xsp_sys_job_tasklist_log_insert @p_job_tasklist_code = @code_sys_job
													 ,@p_status = N'Error'
													 ,@p_start_date = @mod_date
													 ,@p_end_date = @current_mod_date	--cek poin
													 ,@p_log_description = @msg
													 ,@p_run_by = 'job'
													 ,@p_from_id = @from_id				--cek poin
													 ,@p_to_id = @id_interface			--cek poin
													 ,@p_number_of_rows = @number_rows	--cek poin
													 ,@p_cre_date = @current_mod_date	--cek poin
													 ,@p_cre_by = N'job'
													 ,@p_cre_ip_address = N'127.0.0.1'
													 ,@p_mod_date = @current_mod_date	--cek poin
													 ,@p_mod_by = N'job'
													 ,@p_mod_ip_address = N'127.0.0.1' ;
		end catch ;

		fetch next from curr_asset
		into @id_interface ;
	end ;

	begin -- close cursor
		if cursor_status('global', 'curr_asset') >= -1
		begin
			if cursor_status('global', 'curr_asset') > -1
			begin
				close curr_asset ;
			end ;

			deallocate curr_asset ;
		end ;
	end ;

	if (@last_id > 0) --cek poin
	begin
		set @current_mod_date = getdate() ;

		update	dbo.sys_job_tasklist
		set		last_id = @last_id
		where	code = @code_sys_job ;

		/*insert into dbo.sys_job_tasklist_log*/
		exec dbo.xsp_sys_job_tasklist_log_insert @p_job_tasklist_code = @code_sys_job
												 ,@p_status = 'Success'
												 ,@p_start_date = @mod_date
												 ,@p_end_date = @current_mod_date	--cek poin
												 ,@p_log_description = ''
												 ,@p_run_by = 'job'
												 ,@p_from_id = @from_id				--cek poin
												 ,@p_to_id = @last_id				--cek poin
												 ,@p_number_of_rows = @number_rows	--cek poin
												 ,@p_cre_date = @current_mod_date	--cek poin
												 ,@p_cre_by = 'job'
												 ,@p_cre_ip_address = '127.0.0.1'
												 ,@p_mod_date = @current_mod_date	--cek poin
												 ,@p_mod_by = 'job'
												 ,@p_mod_ip_address = '127.0.0.1' ;
	end ;
end ;
