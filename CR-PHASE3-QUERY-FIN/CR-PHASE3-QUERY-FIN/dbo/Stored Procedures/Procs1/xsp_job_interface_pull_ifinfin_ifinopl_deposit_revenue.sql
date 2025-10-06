/*
exec xsp_job_interface_pull_ifinfin_ifinopl_deposit_revenue
*/
CREATE PROCEDURE dbo.xsp_job_interface_pull_ifinfin_ifinopl_deposit_revenue
as

	declare @msg							nvarchar(max)
			,@row_to_process				int
			,@last_id_from_job				bigint
			,@last_id						bigint		 = 0
			,@code_sys_job					nvarchar(50)
			,@number_rows					int			 = 0
			,@is_active						nvarchar(1)
			,@id_interface					bigint
			,@mod_date						datetime	 = getdate()
			,@mod_by						nvarchar(15) = 'job'
			,@mod_ip_address				nvarchar(15) = '127.0.0.1'
			,@deposit_revenue_code nvarchar(50) 
			,@current_mod_date				datetime
			,@from_id						bigint			= 0; 
			
	select	@row_to_process		= row_to_process
			,@last_id_from_job	= last_id
			,@code_sys_job	    = code
			,@is_active = is_active
	from	dbo.sys_job_tasklist
	where	sp_name = 'xsp_job_interface_pull_ifinfin_ifinopl_deposit_revenue' -- sesuai dengan nama sp ini
	
if(@is_active <> '0')
begin
	--get cashier received request
	declare curr_deposit_revenue cursor for
		select 		id
					,code
		from		ifinopl.dbo.opl_interface_deposit_revenue
		where		id > @last_id_from_job
		order by	id asc offset 0 rows fetch next @row_to_process rows only ;

	open curr_deposit_revenue
			
	fetch next from curr_deposit_revenue 
	into @id_interface
		 ,@deposit_revenue_code
		
	while @@fetch_status = 0
	begin
		begin try
			begin transaction
			if (@number_rows = 0)
			begin
				set @from_id = @id_interface
			end

			insert into dbo.fin_interface_deposit_revenue
			(
				code
				,branch_code
				,branch_name
				,revenue_status
				,revenue_date
				,revenue_amount
				,revenue_remarks
				,agreement_no
				,currency_code
				,exch_rate
				,job_status
				--
				,cre_date
				,cre_by
				,cre_ip_address
				,mod_date
				,mod_by
				,mod_ip_address
			)
			select	code
					,branch_code
					,branch_name
					,revenue_status
					,revenue_date
					,revenue_amount
					,revenue_remarks
					,agreement_no
					,currency_code
					,exch_rate
					,'HOLD'
					--
					,@mod_date
					,@mod_by
					,@mod_ip_address
					,@mod_date
					,@mod_by
					,@mod_ip_address
			from	ifinopl.dbo.opl_interface_deposit_revenue
			where	id = @id_interface ;

			insert into dbo.fin_interface_deposit_revenue_detail
			(
				deposit_revenue_code
				,deposit_code
				,deposit_type
				,deposit_amount
				,revenue_amount
				--
				,cre_date
				,cre_by
				,cre_ip_address
				,mod_date
				,mod_by
				,mod_ip_address
			)
			select	deposit_revenue_code
					,deposit_code
					,deposit_type
					,deposit_amount
					,revenue_amount
					--
					,@mod_date
					,@mod_by
					,@mod_ip_address
					,@mod_date
					,@mod_by
					,@mod_ip_address
			from	ifinopl.dbo.opl_interface_deposit_revenue_detail crrd
			where	crrd.deposit_revenue_code = @deposit_revenue_code ;
			
			set @number_rows =+ 1
			set @last_id = @id_interface ;

			commit transaction
		end try
		begin catch
			rollback transaction 

			set @msg = error_message();

			update dbo.fin_interface_deposit_revenue
			set		job_status		= 'FAILED'
					,failed_remarks	= @msg
			where	id				= @id_interface

			set @current_mod_date = getdate();
			/*insert into dbo.sys_job_tasklist_log*/
			exec dbo.xsp_sys_job_tasklist_log_insert @p_job_tasklist_code	= @code_sys_job
													 ,@p_status				= N'Error'
													 ,@p_start_date			= @mod_date
													 ,@p_end_date			= @current_mod_date --cek poin
													 ,@p_log_description	= @msg
													 ,@p_run_by				= 'job'
													 ,@p_from_id			= @from_id  --cek poin
													 ,@p_to_id				= @id_interface --cek poin
													 ,@p_number_of_rows		= @number_rows --cek poin
													 ,@p_cre_date			= @current_mod_date--cek poin
													 ,@p_cre_by				= N'job'
													 ,@p_cre_ip_address		= N'127.0.0.1'
													 ,@p_mod_date			= @current_mod_date--cek poin
													 ,@p_mod_by				= N'job'
													 ,@p_mod_ip_address		= N'127.0.0.1'  ;


			--clear cursor when error
			close curr_deposit_revenue
			deallocate curr_deposit_revenue

			--stop looping
			break ;
		end catch ;   
	
		fetch next from curr_deposit_revenue
		into @id_interface
			 ,@deposit_revenue_code

	end ;
		
	begin -- close cursor
		if cursor_status('global', 'curr_deposit_revenue') >= -1
		begin
			if cursor_status('global', 'curr_deposit_revenue') > -1
			begin
				close curr_deposit_revenue ;
			end ;

			deallocate curr_deposit_revenue ;
		end ;
	end ;

	if (@last_id > 0)--cek poin
		begin
			set @current_mod_date = getdate();

			update dbo.sys_job_tasklist 
			set last_id = @last_id 
			where code = @code_sys_job
		
			/*insert into dbo.sys_job_tasklist_log*/
			exec dbo.xsp_sys_job_tasklist_log_insert @p_job_tasklist_code	= @code_sys_job
													, @p_status				= 'Success'
													, @p_start_date			= @mod_date
													, @p_end_date			= @current_mod_date --cek poin
													, @p_log_description	= ''
													, @p_run_by				= 'job'
													, @p_from_id			= @from_id --cek poin
													, @p_to_id				= @last_id --cek poin
													, @p_number_of_rows		= @number_rows --cek poin
													, @p_cre_date			= @current_mod_date --cek poin
													, @p_cre_by				= 'job'
													, @p_cre_ip_address		= '127.0.0.1'
													, @p_mod_date			= @current_mod_date --cek poin
													, @p_mod_by				= 'job'
													, @p_mod_ip_address		= '127.0.0.1'
					    
		end
	end
