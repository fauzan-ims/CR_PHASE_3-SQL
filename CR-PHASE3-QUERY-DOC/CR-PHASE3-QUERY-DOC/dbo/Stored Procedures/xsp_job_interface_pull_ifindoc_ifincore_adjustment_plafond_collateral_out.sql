-- Louis Selasa, 12 April 2022 09.40.04 -- 

CREATE PROCEDURE dbo.xsp_job_interface_pull_ifindoc_ifincore_adjustment_plafond_collateral_out
as
declare @msg			   nvarchar(max)
		,@id_interface	   bigint --cursor
		,@row_to_process   int
		,@last_id		   bigint		= 0
		,@last_id_from_job bigint
		,@code_sys_job	   nvarchar(50)
		,@number_rows	   int			= 0
		,@is_active		   nvarchar(1)
		,@plafond_code	   nvarchar(50)
		,@current_mod_date datetime
		,@from_id		   bigint		= 0
		,@mod_date		   datetime		= getdate()
		,@mod_by		   nvarchar(50) = 'Admin'
		,@mode_address	   nvarchar(50) = '127.0.0' ;

select	@row_to_process = row_to_process
		,@last_id_from_job = last_id
		,@code_sys_job = code
		,@is_active = is_active
from	dbo.sys_job_tasklist
where	sp_name = 'xsp_job_interface_pull_ifindoc_ifincore_adjustment_plafond_collateral_out' ;

if (@is_active = '1')
begin

	--module core interface plafond main out
	declare cur_adjustment_plafond_collateral_out cursor for
	select		id
	from		ifincore.dbo.core_interface_adjustment_plafond_collateral_out
	where		id > @last_id_from_job
	order by	id asc offset 0 rows fetch next @row_to_process rows only ;

	open cur_adjustment_plafond_collateral_out ;

	fetch next from cur_adjustment_plafond_collateral_out
	into @id_interface ;

	while @@fetch_status = 0
	begin
		begin try
			begin transaction ;

			if (@number_rows = 0)
			begin
				set @from_id = @id_interface ;
			end ;

			insert into dbo.doc_interface_adjustment_plafond_collateral_out
			(
				collateral_no
				,plafond_code
				,collateral_type_code
				,collateral_name
				,collateral_condition
				,market_value
				,collateral_value
				,doc_collateral_no
				,collateral_year
				,job_status
				,failed_remark
				--
				,cre_date
				,cre_by
				,cre_ip_address
				,mod_date
				,mod_by
				,mod_ip_address
			)
			select	collateral_no
					,plafond_code
					,collateral_type_code
					,collateral_name
					,collateral_condition
					,market_value
					,collateral_value
					,doc_collateral_no
					,collateral_year
					,'HOLD'
					,''
					--
					,@mod_date
					,@mod_by
					,@mode_address
					,@mod_date
					,@mod_by
					,@mode_address
			from	ifincore.dbo.core_interface_adjustment_plafond_collateral_out
			where	id = @id_interface ;

			set @number_rows = +1 ;
			set @last_id = @id_interface ;

			commit transaction  ;
		end try
		begin catch
			rollback transaction  ;

			set @msg = error_message() ;
			/*insert into dbo.sys_job_tasklist_log*/
			set @current_mod_date = getdate() ;

			exec dbo.xsp_sys_job_tasklist_log_insert @p_job_tasklist_code = @code_sys_job
													 ,@p_status = 'Error'
													 ,@p_start_date = @mod_date
													 ,@p_end_date = @current_mod_date --cek poin
													 ,@p_log_description = @msg
													 ,@p_run_by = @mod_by
													 ,@p_from_id = @from_id --cek poin
													 ,@p_to_id = @id_interface --cek poin
													 ,@p_number_of_rows = @number_rows --cek poin
													 ,@p_cre_date = @current_mod_date --cek poin
													 ,@p_cre_by = @mod_by
													 ,@p_cre_ip_address = @mode_address
													 ,@p_mod_date = @current_mod_date --cek poin
													 ,@p_mod_by = @mod_by
													 ,@p_mod_ip_address = @mode_address ;

			--clear cursor when error
			close cur_adjustment_plafond_collateral_out ;
			deallocate cur_adjustment_plafond_collateral_out ;

			--stop looping
			break ;
		end catch ;

		fetch next from cur_adjustment_plafond_collateral_out
		into @id_interface ;
	end ;

	begin -- close cursor
		if cursor_status('global', 'cur_adjustment_plafond_collateral_out') >= -1
		begin
			if cursor_status('global', 'cur_adjustment_plafond_collateral_out') > -1
			begin
				close cur_adjustment_plafond_collateral_out ;
			end ;

			deallocate cur_adjustment_plafond_collateral_out ;
		end ;
	end ;

	if (@last_id > 0)
	begin
		update	dbo.sys_job_tasklist
		set		last_id = @last_id
		where	code = @code_sys_job ;

		/*insert into dbo.sys_job_tasklist_log*/
		set @current_mod_date = getdate() ;

		exec dbo.xsp_sys_job_tasklist_log_insert @p_job_tasklist_code = @code_sys_job
												 ,@p_status = 'Success'
												 ,@p_start_date = @mod_date
												 ,@p_end_date = @current_mod_date --cek poin
												 ,@p_log_description = ''
												 ,@p_run_by = @mod_by
												 ,@p_from_id = @last_id --cek poin
												 ,@p_to_id = @last_id --cek poin
												 ,@p_number_of_rows = @number_rows --cek poin
												 ,@p_cre_date = @current_mod_date --cek poin
												 ,@p_cre_by = @mod_by
												 ,@p_cre_ip_address = @mode_address
												 ,@p_mod_date = @current_mod_date --cek poin
												 ,@p_mod_by = @mod_by
												 ,@p_mod_ip_address = @mode_address ;
	end ;
end ;
