CREATE PROCEDURE [dbo].[xsp_job_interface_pull_ifinproc_ifinopl_asset_insurance]
as
declare @msg			   nvarchar(max)
		,@row_to_process   int
		,@last_id_from_job bigint
		,@last_id		   bigint		= 0
		,@code_sys_job	   nvarchar(50)
		,@number_rows	   int			= 0
		,@is_active		   nvarchar(1)
		,@id_interface	   bigint
		,@mod_date		   datetime		= getdate()
		,@mod_by		   nvarchar(15) = 'job'
		,@mod_ip_address   nvarchar(15) = '127.0.0.1' 
		,@current_mod_date	datetime
		,@from_id			bigint			= 0
		
	-- sesuai dengan nama sp ini
	select	@row_to_process		= row_to_process
			,@last_id_from_job	= last_id
			,@code_sys_job		= code
			,@is_active			= is_active
	from	dbo.sys_job_tasklist
	where	sp_name = 'xsp_job_interface_pull_ifinproc_ifinopl_asset_insurance' ;

	if(@is_active <> '0')
	begin
	--get cashier received request
	declare curr_purchase_request cursor for
	select		id
	from		ifinopl.dbo.OPL_INTERFACE_ASSET_INSURANCE
	where		id > @last_id_from_job
	order by	id asc offset 0 rows fetch next @row_to_process rows only ;

	open curr_purchase_request ;

	fetch next from curr_purchase_request
	into @id_interface ;

	while @@fetch_status = 0
	begin
		begin try
			begin transaction 

			if (@number_rows = 0)
			begin
				set @from_id = @id_interface
			end

			insert into dbo.ifinproc_interface_asset_insurance
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
				,job_status
				,failed_remark
				--
				,cre_date
				,cre_by
				,cre_ip_address
				,mod_date
				,mod_by
				,mod_ip_address
				,is_tbod
				,tbod_premium_amount
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
				  ,'HOLD'
				  ,''
				  --
				  ,@mod_date
				  ,@mod_by
				  ,@mod_ip_address
				  ,@mod_date
				  ,@mod_by
				  ,@mod_ip_address
				  ,is_tbod
				  ,tbod_premium_amount 
			from ifinopl.dbo.opl_interface_asset_insurance
			where id = @id_interface

			set @number_rows = +1 ;
			set @last_id = @id_interface ;

			commit transaction ;
		end try
		begin catch
			rollback transaction ;

			set @msg = error_message();

			update dbo.ifinproc_interface_asset_insurance
			set		job_status		= 'FAILED'
					,failed_remark	= @msg
			where	id				= @id_interface

			/*insert into dbo.sys_job_tasklist_log*/
			set @current_mod_date = getdate();
			exec dbo.xsp_sys_job_tasklist_log_insert @p_job_tasklist_code		= @code_sys_job
														,@p_status				= 'Error'
														,@p_start_date			= @mod_date
														,@p_end_date			= @current_mod_date --cek poin
														,@p_log_description		= @msg
														,@p_run_by				= @mod_by
														,@p_from_id				= @from_id  --cek poin
														,@p_to_id				= @id_interface --cek poin
														,@p_number_of_rows		= @number_rows --cek poin
														,@p_cre_date			= @current_mod_date--cek poin
														,@p_cre_by				= @mod_by
														,@p_cre_ip_address		= @mod_ip_address
														,@p_mod_date			= @current_mod_date--cek poin
														,@p_mod_by				= @mod_by
														,@p_mod_ip_address		= @mod_ip_address  ;


			-- clear cursor when error
			close curr_purchase_request ;
			deallocate curr_purchase_request ;

			-- stop looping
			break ;
		end catch ;

		fetch next from curr_purchase_request
		into @id_interface ;
	end ;

	begin -- close cursor
		if cursor_status('global', 'curr_purchase_request') >= -1
		begin
			if cursor_status('global', 'curr_purchase_request') > -1
			begin
				close curr_purchase_request ;
			end ;

			deallocate curr_purchase_request ;
		end ;
	end ;

	if (@last_id > 0)
	begin
		update dbo.sys_job_tasklist 
		set last_id = @last_id 
		where code = @code_sys_job

		/*insert into dbo.sys_job_tasklist_log*/
		set @current_mod_date = getdate();
		exec dbo.xsp_sys_job_tasklist_log_insert @p_job_tasklist_code	= @code_sys_job
												, @p_status				= 'Success'
												, @p_start_date			= @mod_date
												, @p_end_date			= @current_mod_date --cek poin
												, @p_log_description	= ''
												, @p_run_by				= @mod_by
												, @p_from_id			= @last_id --cek poin
												, @p_to_id				= @last_id --cek poin
												, @p_number_of_rows		= @number_rows --cek poin
												, @p_cre_date			= @current_mod_date --cek poin
												, @p_cre_by				= @mod_by
												, @p_cre_ip_address		= @mod_ip_address
												, @p_mod_date			= @current_mod_date --cek poin
												, @p_mod_by				= @mod_by
												, @p_mod_ip_address		= @mod_ip_address
					    
	end
end
