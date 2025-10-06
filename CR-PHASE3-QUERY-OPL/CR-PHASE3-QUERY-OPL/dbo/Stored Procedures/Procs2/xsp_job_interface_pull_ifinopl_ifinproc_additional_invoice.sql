CREATE PROCEDURE dbo.xsp_job_interface_pull_ifinopl_ifinproc_additional_invoice
as
declare @msg			   nvarchar(max)
		,@row_to_process   int
		,@last_id_from_job bigint
		,@last_id		   bigint		= 0
		,@code_sys_job	   nvarchar(50)
		,@number_rows	   int			= 0
		,@is_active		   nvarchar(1)
		,@request_code	   nvarchar(50)
		,@id_interface	   bigint
		,@mod_date		   datetime		= getdate()
		,@mod_by		   nvarchar(15) = 'job'
		,@mod_ip_address   nvarchar(15) = '127.0.0.1'
		,@current_mod_date datetime
		,@from_id		   bigint		= 0 ;
	
	begin try
		-- sesuai dengan nama sp ini
		select	@code_sys_job = code
				,@row_to_process = row_to_process
				,@last_id_from_job = last_id
				,@is_active = is_active
		from	dbo.sys_job_tasklist
		where	sp_name = 'xsp_job_interface_pull_ifinopl_ifinproc_additional_invoice' ;

		if (@is_active <> '0')
		begin
			declare curr_additional_invoice cursor for
			select		id
			from		ifinproc.dbo.ifinproc_interface_additional_invoice_request
			where		id			   > @last_id_from_job
						and job_status = 'HOLD'
			order by	id asc offset 0 rows fetch next @row_to_process rows only ;

			open curr_additional_invoice ;

			fetch next from curr_additional_invoice
			into @id_interface

			while @@fetch_status = 0
			begin
				begin try
					begin transaction ;

					if (@number_rows = 0)
					begin
						set @from_id = @id_interface ;
					end ;
					
					insert into dbo.opl_interface_additional_invoice_request
					(
						agreement_no
						,asset_no
						,branch_code
						,branch_name
						,invoice_type
						,invoice_date
						,invoice_name
						,client_no
						,client_name
						,client_address
						,client_area_phone_no
						,client_phone_no
						,client_npwp
						,currency_code
						,tax_scheme_code
						,tax_scheme_name
						,billing_no
						,description
						,quantity
						,billing_amount
						,discount_amount
						,ppn_pct
						,ppn_amount
						,pph_pct
						,pph_amount
						,total_amount
						,request_status
						,reff_code
						,reff_name
						,settle_date
						,job_status
						,failed_remarks
						--
						,cre_date
						,cre_by
						,cre_ip_address
						,mod_date
						,mod_by
						,mod_ip_address
					)
					select agreement_no
						  ,asset_no
						  ,branch_code
						  ,branch_name
						  ,invoice_type
						  ,invoice_date
						  ,invoice_name
						  ,client_no
						  ,client_name
						  ,client_address
						  ,client_area_phone_no
						  ,client_phone_no
						  ,client_npwp
						  ,currency_code
						  ,tax_scheme_code
						  ,tax_scheme_name
						  ,billing_no
						  ,description
						  ,quantity
						  ,billing_amount
						  ,discount_amount
						  ,ppn_pct
						  ,ppn_amount
						  ,pph_pct
						  ,pph_amount
						  ,total_amount
						  ,'HOLD'
						  ,reff_code
						  ,reff_name
						  ,settle_date
						  ,job_status
						  ,failed_remarks
						  --
						  ,@mod_date
						  ,@mod_by
						  ,@mod_ip_address
						  ,@mod_date
						  ,@mod_by
						  ,@mod_ip_address
					from ifinproc.dbo.IFINPROC_INTERFACE_ADDITIONAL_INVOICE_REQUEST
					where	id = @id_interface ;

					--select 
					--	 agreement_no
					--	 ,asset_no
					--	 ,branch_code
					--	 ,branch_name
					--	 ,invoice_type
					--	 ,invoice_date
					--	 ,invoice_name
					--	 ,client_no
					--	 ,client_name
					--	 ,client_address
					--	 ,client_area_phone_no
					--	 ,client_phone_no
					--	 ,client_npwp
					--	 ,currency
					--	 ,''
					--	 ,''
					--	 ,0
					--	 ,''
					--	 ,0
					--	 ,total_billing_amount
					--	 ,total_discount_amount
					--	 ,0
					--	 ,total_ppn_amount
					--	 ,0
					--	 ,total_pph_amount
					--	 ,total_amount
					--	 ,'HOLD'
					--	 ,reff_no
					--	 ,reff_name
					--	 ,settle_date
					--	 ,job_status
					--	 ,failed_remark
					--	 --
					--	 ,@mod_date
					--	 ,@mod_by
					--	 ,@mod_ip_address
					--	 ,@mod_date
					--	 ,@mod_by
					--	 ,@mod_ip_address
					--from ifinproc.dbo.ifinproc_interface_additional_invoice_request
					--where	id = @id_interface ;

					update	ifinproc.dbo.ifinproc_interface_additional_invoice_request
					set		job_status = 'POST'
					where	id = @id_interface ;

					set @number_rows = +1 ;
					set @last_id = @id_interface ;

					commit transaction ;
				end try
				begin catch
					rollback transaction ;

					set @msg = error_message() ;
					select @msg
					update dbo.opl_interface_master_item
					set		job_status		= 'FAILED'
							,failed_remarks	= @msg
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
					close curr_additional_invoice
					deallocate curr_additional_invoice

					--stop looping
					break ;
				end catch ;

				fetch next from curr_additional_invoice
				into @id_interface
			end ;

			begin -- close cursor
				if cursor_status('global', 'curr_additional_invoice') >= -1
				begin
					if cursor_status('global', 'curr_additional_invoice') > -1
					begin
						close curr_additional_invoice ;
					end ;

					deallocate curr_additional_invoice ;
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
