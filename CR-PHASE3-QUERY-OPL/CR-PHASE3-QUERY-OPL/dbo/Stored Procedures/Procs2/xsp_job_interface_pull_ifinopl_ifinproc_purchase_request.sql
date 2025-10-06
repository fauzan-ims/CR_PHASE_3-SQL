/*
exec xsp_job_interface_pull_ifinopl_ifinproc_purchase_request
*/
CREATE PROCEDURE dbo.xsp_job_interface_pull_ifinopl_ifinproc_purchase_request
as
	declare @msg			   nvarchar(max)
			,@row_to_process   int
			,@last_id_from_job bigint
			,@last_id		   bigint		= 0
			,@code_sys_job	   nvarchar(50)
			,@number_rows	   int			= 0
			,@is_active		   nvarchar(1)
			,@id_interface	   bigint
			,@code_interface   nvarchar(50)
			,@mod_date		   datetime		= getdate()
			,@mod_by		   nvarchar(15) = 'job'
			,@mod_ip_address   nvarchar(15) = '127.0.0.1'
			,@result_fa_code   nvarchar(50)
			,@result_fa_name   nvarchar(250)
			,@result_date	   datetime
			,@result_status	   nvarchar(10)
			,@current_mod_date datetime
			,@from_id		   bigint		= 0 
			,@fa_reff_no_01	   nvarchar(250)
			,@fa_reff_no_02	   nvarchar(250)
			,@fa_reff_no_03	   nvarchar(250) ;
	
	begin try
			
		select	@row_to_process		= row_to_process
				,@last_id_from_job	= last_id
				,@code_sys_job	    = code
				,@is_active			= is_active
		from	dbo.sys_job_tasklist
		where	sp_name = 'xsp_job_interface_pull_ifinopl_ifinproc_purchase_request' -- sesuai dengan nama sp ini
	
	if(@is_active <> '0')
	begin
		--get cashier received request
		declare curr_purchase_request cursor for

			select 		pipr.id
						,pipr.code  
						,pipr.result_fa_code
						,pipr.result_fa_name
						,pipr.result_date
						,pipr.request_status
						,pipr.fa_reff_no_01
						,pipr.fa_reff_no_02
						,pipr.fa_reff_no_03
			from		ifinproc.dbo.proc_interface_purchase_request pipr
						inner join dbo.opl_interface_purchase_request oipr on (oipr.code = pipr.code)
			where		pipr.request_status in ('POST', 'CANCEL')
						and oipr.request_status = 'HOLD'
			order by	id asc offset 0 rows fetch next @row_to_process rows only ;

		open curr_purchase_request
			
		fetch next from curr_purchase_request 
		into @id_interface
			 ,@code_interface 
			 ,@result_fa_code
			 ,@result_fa_name
			 ,@result_date
			 ,@result_status 
			 ,@fa_reff_no_01
			 ,@fa_reff_no_02
			 ,@fa_reff_no_03
		
		while @@fetch_status = 0
		begin
			begin try
				begin transaction

				if (@number_rows = 0)
				begin
					set @from_id = @id_interface ;
				end ;

				update	dbo.opl_interface_purchase_request
				set		request_status		= @result_status
						,result_fa_code		= @result_fa_code
						,result_fa_name		= @result_fa_name
						,result_date		= @result_date
						,fa_reff_no_01      = @fa_reff_no_01
						,fa_reff_no_02      = @fa_reff_no_02
						,fa_reff_no_03      = @fa_reff_no_03
						--
						,mod_date			= @mod_date
						,mod_by				= @mod_by
						,mod_ip_address		= @mod_ip_address
				where	code				= @code_interface

				set @number_rows =+ 1 ;
				set @last_id = @id_interface ;

				commit transaction
			end try
			begin catch
				rollback transaction 

				 --cek poin
				set @msg = error_message() ;
				/*insert into dbo.sys_job_tasklist_log*/
				set @current_mod_date = getdate() ;
			
				exec dbo.xsp_sys_job_tasklist_log_insert @p_job_tasklist_code	= @code_sys_job
														 ,@p_status				= N'Error'
														 ,@p_start_date			= @mod_date
														 ,@p_end_date			= @current_mod_date
														 ,@p_log_description	= @msg
														 ,@p_run_by				= @mod_by
														 ,@p_from_id			= @from_id 
														 ,@p_to_id				= @id_interface
														 ,@p_number_of_rows		= @number_rows
														 ,@p_cre_date			= @current_mod_date 
														 ,@p_cre_by				= @mod_by
														 ,@p_cre_ip_address		= @mod_ip_address
														 ,@p_mod_date			= @current_mod_date 
														 ,@p_mod_by				= @mod_by
														 ,@p_mod_ip_address		= @mod_ip_address  ;
			
				-- clear cursor when error
				close curr_purchase_request ;
				deallocate curr_purchase_request ;
			
				-- stop looping
				break ;
			end catch ;   
	
			fetch next from curr_purchase_request
			into @id_interface
				 ,@code_interface 
				 ,@result_fa_code
				 ,@result_fa_name
				 ,@result_date
				 ,@result_status 
				 ,@fa_reff_no_01
				 ,@fa_reff_no_02
				 ,@fa_reff_no_03

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

		--cek poin
		if (@last_id > 0)
		begin
			update	dbo.sys_job_tasklist
			set		last_id = @last_id
			where	code = @code_sys_job ;

			/*insert into dbo.sys_job_tasklist_log*/
			set @current_mod_date = getdate() ;
		
			exec dbo.xsp_sys_job_tasklist_log_insert @p_job_tasklist_code	= @code_sys_job
													 ,@p_status				= 'Success'
													 ,@p_start_date			= @mod_date
													 ,@p_end_date			= @current_mod_date
													 ,@p_log_description	= ''
													 ,@p_run_by				= @mod_by
													 ,@p_from_id			= @from_id
													 ,@p_to_id				= @last_id
													 ,@p_number_of_rows		= @number_rows
													 ,@p_cre_date			= @current_mod_date
													 ,@p_cre_by				= @mod_by
													 ,@p_cre_ip_address		= @mod_ip_address
													 ,@p_mod_date			= @current_mod_date
													 ,@p_mod_by				= @mod_by
													 ,@p_mod_ip_address		= @mod_ip_address
		end ;
	end
	end try
	Begin catch
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
