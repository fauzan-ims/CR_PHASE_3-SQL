/*
exec xsp_job_interface_in_ifinfin_deposit_revenue
*/
CREATE PROCEDURE dbo.xsp_job_interface_in_ifinfin_deposit_revenue
as

	declare @msg				   nvarchar(max)
			,@row_to_process	   int
			,@last_id_from_job	   bigint
			,@id_interface		   bigint
			,@code_sys_job		   nvarchar(50)
			,@last_id			   bigint		 = 0
			,@number_rows		   int			 = 0
			,@is_active			   nvarchar(1)
			,@current_mod_date	   datetime
			,@mod_date			   datetime		 = getdate()
			,@mod_by			   nvarchar(15)	 = 'job'
			,@mod_ip_address	   nvarchar(15)	 = '127.0.0.1'
			,@from_id			   bigint		 = 0
			,@branch_code		   nvarchar(50)
			,@branch_name		   nvarchar(250)
			,@revenue_amount	   decimal(18, 2)
			,@revenue_remarks	   nvarchar(250)
			,@deposit_revenue_code nvarchar(50)
			,@deposit_code		   nvarchar(50)
			,@deposit_type		   nvarchar(15)
			,@agreement_no		   nvarchar(50)
			,@currency_code		   nvarchar(3)
			,@exch_rate			   decimal(18, 6)
			,@revenue_date		   datetime  

	select	@code_sys_job		= code
			,@row_to_process	= row_to_process
			,@last_id_from_job	= last_id
			,@is_active			= is_active
	from	dbo.sys_job_tasklist
	where	sp_name = 'xsp_job_interface_in_ifinfin_deposit_revenue' -- sesuai dengan nama sp ini

	if (@is_active = '1')
	begin
	--get cashier received request
	declare curr_deposit_revenue cursor for
	select		fidr.id
				,fidr.branch_code
				,fidr.branch_name
				,fidr.revenue_date
				,fidr.revenue_amount
				,fidr.revenue_remarks
				,fidr.agreement_no
				,fidr.currency_code
				,fidr.exch_rate
				,fidrd.deposit_code
				,fidrd.deposit_type
	from		dbo.fin_interface_deposit_revenue fidr
				inner join dbo.fin_interface_deposit_revenue_detail fidrd on (fidr.code = fidrd.deposit_revenue_code)
	where		job_status in
	(
		'HOLD', 'FAILED'
	)
	order by	id asc offset 0 rows fetch next @row_to_process rows only ;

	open curr_deposit_revenue
			
	fetch next from curr_deposit_revenue 
	into @id_interface 
		 ,@branch_code		  
		 ,@branch_name
		 ,@revenue_date
		 ,@revenue_amount	  
		 ,@revenue_remarks		  
		 ,@agreement_no		  
		 ,@currency_code		  
		 ,@exch_rate
		 ,@deposit_code
		 ,@deposit_type	  
		
	while @@fetch_status = 0
	begin
		begin try
			begin transaction
			if (@number_rows = 0)
			begin
				set @from_id = @id_interface
			end 

			exec dbo.xsp_deposit_revenue_insert @p_code				= @deposit_revenue_code output
												,@p_branch_code		= @branch_code		
												,@p_branch_name		= @branch_name		
												,@p_revenue_status	= 'HOLD'	
												,@p_revenue_date	= @revenue_date	
												,@p_revenue_amount	= @revenue_amount	
												,@p_revenue_remarks = @revenue_remarks 
												,@p_agreement_no	= @agreement_no	
												,@p_currency_code	= @currency_code	
												,@p_exch_rate		= @exch_rate
												--	
												,@p_cre_date		= @mod_date		
												,@p_cre_by			= @mod_by		
												,@p_cre_ip_address	= @mod_ip_address
												,@p_mod_date		= @mod_date		
												,@p_mod_by			= @mod_by		
												,@p_mod_ip_address	= @mod_ip_address
			 
			exec dbo.xsp_deposit_revenue_detail_insert @p_id					= 0
													   ,@p_deposit_revenue_code = @deposit_revenue_code
													   ,@p_deposit_code			= @deposit_code
													   ,@p_deposit_type			= @deposit_type
													   ,@p_deposit_amount		= @revenue_amount
													   --	
													   ,@p_cre_date				= @mod_date		
													   ,@p_cre_by				= @mod_by		
													   ,@p_cre_ip_address		= @mod_ip_address
													   ,@p_mod_date				= @mod_date		
													   ,@p_mod_by				= @mod_by		
													   ,@p_mod_ip_address		= @mod_ip_address 
			
			exec dbo.xsp_deposit_revenue_post @p_code			 = @deposit_revenue_code
											  --				 
											  ,@p_cre_date		 = @mod_date		
											  ,@p_cre_by		 = @mod_by		
											  ,@p_cre_ip_address = @mod_ip_address
											  ,@p_mod_date		 = @mod_date		
											  ,@p_mod_by		 = @mod_by		
											  ,@p_mod_ip_address = @mod_ip_address 
			

			update dbo.fin_interface_deposit_revenue
			set    job_status = 'POST'
			where  id		   = @id_interface
			
			set @number_rows =+ 1
			set @last_id = @id_interface ;

			commit transaction
		end try
		begin catch

			rollback transaction 
			
			set @msg = error_message(); 
			set @current_mod_date = getdate();

			update	dbo.fin_interface_deposit_revenue  --cek poin
			set		job_status = 'FAILED'
					,failed_remarks = @msg
			where	id = @id_interface --cek poin	

			print @msg

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

		end catch   
	
		fetch next from curr_deposit_revenue
		into @id_interface 
			 ,@branch_code		  
			 ,@branch_name
			 ,@revenue_date
			 ,@revenue_amount	  
			 ,@revenue_remarks		  
			 ,@agreement_no		  
			 ,@currency_code		  
			 ,@exch_rate
			 ,@deposit_code
			 ,@deposit_type	  

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

