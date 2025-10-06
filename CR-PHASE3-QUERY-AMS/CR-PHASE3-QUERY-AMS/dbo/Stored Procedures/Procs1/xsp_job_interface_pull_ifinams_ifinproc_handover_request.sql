CREATE PROCEDURE [dbo].[xsp_job_interface_pull_ifinams_ifinproc_handover_request]
as
declare @msg					nvarchar(max)
		,@row_to_process		int
		,@last_id_from_job		bigint
		,@last_id				bigint		= 0
		,@code_sys_job			nvarchar(50)
		,@number_rows			int			= 0
		,@is_active				nvarchar(1)
		,@id_interface			bigint
		,@mod_date				datetime		= getdate()
		,@mod_by				nvarchar(15) = 'job'
		,@mod_ip_address		nvarchar(15) = '127.0.0.1' 
		,@current_mod_date		datetime
		,@from_id				bigint			= 0
		,@fa_code				nvarchar(50)
		,@agreement_no			nvarchar(50)
		,@agreement_external_no	nvarchar(50)
		,@client_no				nvarchar(50)
		,@client_name			nvarchar(250)
		,@asset_no				nvarchar(50)
		
	-- sesuai dengan nama sp ini
	select	@row_to_process = row_to_process
			,@last_id_from_job = last_id
			,@code_sys_job = code
			,@is_active = is_active
	from	dbo.sys_job_tasklist
	where	sp_name = 'xsp_job_interface_pull_ifinams_ifinproc_handover_request' ;

	if(@is_active <> '0')
	begin
	--get cashier received request
	declare curr_handover_asset cursor for
	select		id
				,fa_code
	from		ifinproc.dbo.ifinproc_interface_handover_request
	where		id > @last_id_from_job
				and job_status = 'HOLD'
	order by	id asc offset 0 rows fetch next @row_to_process rows only ;

	open curr_handover_asset ;

	fetch next from curr_handover_asset
	into @id_interface
		,@fa_code

	while @@fetch_status = 0
	begin
		begin try
			begin transaction 

			if (@number_rows = 0)
			begin
				set @from_id = @id_interface
			end

			select	@agreement_no			= agreement_no
					,@agreement_external_no	= agreement_external_no
					,@asset_no				= asset_no
					,@client_no				= client_no
					,@client_name			= client_name 
			from dbo.asset
			where code = @fa_code

			insert into dbo.ams_interface_handover_asset
			(
				code
				,branch_code
				,branch_name
				,status
				,transaction_date
				,type
				,remark
				,fa_code
				,fa_name
				,handover_from
				,handover_to
				,handover_address
				,handover_phone_area
				,handover_phone_no
				,handover_eta_date
				,unit_condition
				,reff_no
				,reff_name
				,handover_code
				,handover_bast_date
				,handover_remark
				,handover_status
				,asset_status
				,agreement_external_no
				,agreement_no
				,asset_no
				,client_no
				,client_name
				,bbn_location
				--
				,cre_date
				,cre_by
				,cre_ip_address
				,mod_date
				,mod_by
				,mod_ip_address
			)
			select 
					code
				  ,branch_code
				  ,branch_name
				  ,status
				  ,transaction_date
				  ,type
				  ,remark
				  ,fa_code
				  ,fa_name
				  ,handover_from
				  ,handover_to
				  ,handover_address
				  ,handover_phone_area
				  ,handover_phone_no
				  ,handover_eta_date
				  ,unit_condition
				  ,reff_no
				  ,reff_name
				  ,handover_code
				  ,handover_bast_date
				  ,handover_remark
				  ,handover_status
				  ,asset_status
				  ,@agreement_external_no
				  ,@agreement_no
				  ,@asset_no
				  ,@client_no
				  ,@client_name
				  ,''
				  --
				  ,@mod_date
				  ,@mod_by
				  ,@mod_ip_address
				  ,@mod_date
				  ,@mod_by
				  ,@mod_ip_address
			from ifinproc.dbo.ifinproc_interface_handover_request
			where	id = @id_interface ;

			set @number_rows = +1 ;
			set @last_id = @id_interface ;

			commit transaction ;
		end try
		begin catch
			rollback transaction ;

			set @msg = error_message();

			update dbo.ams_interface_handover_asset
			set		job_status		= 'FAILED'
					,failed_remarks	= @msg
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
			close curr_handover_asset ;
			deallocate curr_handover_asset ;

			-- stop looping
			break ;
		end catch ;

		fetch next from curr_handover_asset
		into @id_interface
			,@fa_code
	end ;

	begin -- close cursor
		if cursor_status('global', 'curr_handover_asset') >= -1
		begin
			if cursor_status('global', 'curr_handover_asset') > -1
			begin
				close curr_handover_asset ;
			end ;

			deallocate curr_handover_asset ;
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
