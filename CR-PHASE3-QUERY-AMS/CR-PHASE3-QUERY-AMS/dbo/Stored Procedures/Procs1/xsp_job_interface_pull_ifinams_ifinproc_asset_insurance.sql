CREATE PROCEDURE dbo.xsp_job_interface_pull_ifinams_ifinproc_asset_insurance
as
declare @msg				nvarchar(max)
		,@row_to_process	int
		,@last_id_from_job	bigint
		,@last_id			bigint			= 0
		,@code_sys_job		nvarchar(50)
		,@number_rows		int				= 0
		,@is_active			nvarchar(1)
		,@id_interface		bigint
		,@mod_date			datetime		= getdate()
		,@mod_by			nvarchar(15)	= 'job'
		,@mod_ip_address	nvarchar(15)	= '127.0.0.1'
		,@current_mod_date	datetime
		,@from_id			bigint			= 0
		,@request_code		nvarchar(50)
		,@type_code			nvarchar(50)
		,@merk_code			nvarchar(50)	= null
		,@model_code		nvarchar(50)	= null
		,@type_item_code	nvarchar(50)	= null
		,@merk_name			nvarchar(250)	= null
		,@model_name		nvarchar(250)	= null 
		,@type_item_name	nvarchar(250)	= null
		,@engine_no			nvarchar(50)
		,@plat_no			nvarchar(50)
		,@chasis_no			nvarchar(50)
		,@chasis_no_mchn	nvarchar(50)
		,@engine_no_mchn	nvarchar(50)
		,@invoice_no_he		nvarchar(50)
		,@engine_no_he		nvarchar(50)
		,@chasis_no_he		nvarchar(50)
		,@invoice_no_mchn	nvarchar(50)
		,@serial_no_elct	nvarchar(50)
		,@domain_elct		nvarchar(50)
		,@imei_elct			nvarchar(50)
		,@bpkb_no			nvarchar(50)
		,@posting_date		datetime -- (+) Ari 2024-03-26 ket : add posting date

-- sesuai dengan nama sp ini
select	@code_sys_job = code
		,@row_to_process = row_to_process
		,@last_id_from_job = last_id
		,@is_active = is_active
from	dbo.sys_job_tasklist
where	sp_name = 'xsp_job_interface_pull_ifinams_ifinproc_asset_insurance' ;

if (@is_active <> '0')
begin
	--get cashier received request
	declare curr_asset cursor for
	--select		id
	--from		ifinproc.dbo.ifinproc_interface_asset_insurance
	--where		id			   > @last_id_from_job
	--			and job_status = 'POST'
	--			and isnull(asset_code,'') <> ''
	select		id												--(+) Raffy 2024/10/21 mengambil berdasarkan asset code yang sudah terisi, bukan berdasarkan ID 
	from		ifinproc.dbo.ifinproc_interface_asset_insurance
	where		--id			   > @last_id_from_job
				job_status = 'POST'
				and isnull(asset_code,'') <> ''
				AND ASSET_NO NOT IN (SELECT ASSET_NO FROM ifinams.dbo.IFINAMS_INTERFACE_ASSET_INSURANCE)
				AND ASSET_CODE NOT IN (SELECT ASSET_CODE FROM ifinams.dbo.IFINAMS_INTERFACE_ASSET_INSURANCE)
	order by	id asc offset 0 rows fetch next @row_to_process rows only ;

	open curr_asset ;

	fetch next from curr_asset
	into @id_interface

	while @@fetch_status = 0
	begin
		begin try
			begin transaction ;

			if (@number_rows = 0)
			begin
				set @from_id = @id_interface ;
			end ;

			insert into dbo.ifinams_interface_asset_insurance
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
				,job_status
				,failed_remark
				,asset_code
				,cre_date
				,cre_by
				,cre_ip_address
				,mod_date
				,mod_by
				,mod_ip_address
			)
			select asset_no
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
				  ,'HOLD'
				  ,''
				  ,asset_code
				  --
				  ,@mod_date
				  ,@mod_by
				  ,@mod_ip_address
				  ,@mod_date
				  ,@mod_by
				  ,@mod_ip_address
			from ifinproc.dbo.ifinproc_interface_asset_insurance
			where id = @id_interface

			
			update	ifinproc.dbo.ifinproc_interface_asset_insurance
			set		job_status = 'POST'
			where	id = @id_interface ;

			set @number_rows = +1 ;
			set @last_id = @id_interface ;

			commit transaction ;
		end try
		begin catch
			rollback transaction ;

			set @msg = error_message() ;

			update ifinproc.dbo.ifinproc_interface_asset_insurance
			set		job_status		= 'FAILED'
					,failed_remark	= @msg
			where	id				= @id_interface
	
			set @current_mod_date = getdate() ;
			/*insert into dbo.sys_job_tasklist_log*/
			exec dbo.xsp_sys_job_tasklist_log_insert @p_job_tasklist_code	= @code_sys_job
													 ,@p_status				= N'Error'
													 ,@p_start_date			= @mod_date
													 ,@p_end_date			= @current_mod_date --cek poin
													 ,@p_log_description	= @msg
													 ,@p_run_by				= 'job'
													 ,@p_from_id			= @from_id --cek poin
													 ,@p_to_id				= @id_interface --cek poin
													 ,@p_number_of_rows		= @number_rows --cek poin
													 ,@p_cre_date			= @current_mod_date --cek poin
													 ,@p_cre_by				= N'job'
													 ,@p_cre_ip_address		= N'127.0.0.1'
													 ,@p_mod_date			= @current_mod_date --cek poin
													 ,@p_mod_by				= N'job'
													 ,@p_mod_ip_address		= N'127.0.0.1' ;

			--clear cursor when error
			close curr_asset
			deallocate curr_asset

			--stop looping
			break ;
		end catch ;

		fetch next from curr_asset
		into @id_interface
			
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
		exec dbo.xsp_sys_job_tasklist_log_insert @p_job_tasklist_code	= @code_sys_job
												 ,@p_status				= 'Success'
												 ,@p_start_date			= @mod_date
												 ,@p_end_date			= @current_mod_date --cek poin
												 ,@p_log_description	= ''
												 ,@p_run_by				= 'job'
												 ,@p_from_id			= @from_id --cek poin
												 ,@p_to_id				= @last_id --cek poin
												 ,@p_number_of_rows		= @number_rows --cek poin
												 ,@p_cre_date			= @current_mod_date --cek poin
												 ,@p_cre_by				= 'job'
												 ,@p_cre_ip_address		= '127.0.0.1'
												 ,@p_mod_date			= @current_mod_date --cek poin
												 ,@p_mod_by				= 'job'
												 ,@p_mod_ip_address		= '127.0.0.1' ;
	end ;
end ;
