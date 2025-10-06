CREATE PROCEDURE dbo.xsp_job_interface_in_ifindoc_insurance_policy_main
as
declare @msg					nvarchar(max)
		,@row_to_process		int
		,@last_id_from_job		bigint
		,@id_interface			bigint
		,@code					nvarchar(50)
		,@module				nvarchar(50)
		,@doc_no				nvarchar(50)
		,@doc_name				nvarchar(250)
		,@doc_type				nvarchar(250)
		,@agreement_no			nvarchar(50)
		,@collateral_no			nvarchar(50)
		,@plafond_no			nvarchar(50)
		,@plafond_collateral_no nvarchar(50)
		,@policy_eff_date		datetime
		,@policy_exp_date		datetime
		,@file_name				nvarchar(250)
		,@paths					nvarchar(250)
		,@doc_file				varbinary(max)	= null 
		,@last_id				bigint		 = 0
		,@code_sys_job			nvarchar(50)
		,@number_rows			int			 = 0
		,@is_active				nvarchar(1)
		,@mod_date				datetime	 = getdate()
		,@mod_by				nvarchar(15) = 'job'
		,@mod_ip_address		nvarchar(15) = '127.0.0.1'
		,@from_id				bigint		 = 0
		,@current_mod_date		datetime ;

select	@code_sys_job = code
		,@row_to_process = row_to_process
		,@last_id_from_job = last_id
		,@is_active = is_active
from	dbo.sys_job_tasklist
where	sp_name = 'xsp_job_interface_in_ifindoc_insurance_policy_main' ; -- sesuai dengan nama sp ini

if (@is_active = '1')
begin 
	--get cashier received request
	declare curr_insurance_policy_main cursor for
	select		id
				,module
				,doc_no
				,doc_name
				,doc_type
				,agreement_no
				,collateral_no
				,plafond_no
				,plafond_collateral_no
				,policy_eff_date
				,policy_exp_date
				,file_name
				,paths
				,doc_file
	from		dbo.doc_interface_insurance_policy_main diipm
	where		job_status in
	(
		'HOLD', 'FAILED'
	)
				and exists
	(
		select	1
		from	dbo.document_main
		where	diipm.agreement_no				= isnull(agreement_no, '')
				and diipm.collateral_no			= isnull(collateral_no, '')
				and diipm.plafond_no			= isnull(plafond_no, '')
				and diipm.plafond_collateral_no = isnull(plafond_collateral_no, '')
	)
	order by	id asc offset 0 rows fetch next @row_to_process rows only ;

	open curr_insurance_policy_main ;

	fetch next from curr_insurance_policy_main
	into @id_interface
		 ,@module
		 ,@doc_no
		 ,@doc_name
		 ,@doc_type
		 ,@agreement_no
		 ,@collateral_no
		 ,@plafond_no
		 ,@plafond_collateral_no
		 ,@policy_eff_date
		 ,@policy_exp_date
		 ,@file_name
		 ,@paths 
		 ,@doc_file ;

	while @@fetch_status = 0
	begin
		begin try
			begin transaction ;

			if (@number_rows = 0)
			begin
				set @from_id = @id_interface ;
			end ;

			if exists
			(
				select	1
				from	dbo.document_main
				where	document_type	 = @doc_type
						and agreement_no = @agreement_no
			)
			begin
				select	@code = code
				from	dbo.document_main
				where	document_type	 = @doc_type
						and agreement_no = @agreement_no ;
			end ;

			if exists
			(
				select	1
				from	dbo.document_main
				where	document_type	  = @doc_type
						and collateral_no = @collateral_no
			)
			begin
				select	@code = code
				from	dbo.document_main
				where	document_type	  = @doc_type
						and collateral_no = @collateral_no ;
			end ;

			if exists
			(
				select	1
				from	dbo.document_main
				where	document_type  = @doc_type
						and plafond_no = @plafond_no
			)
			begin
				select	@code = code
				from	dbo.document_main
				where	document_type  = @doc_type
						and plafond_no = @plafond_no ;
			end ;

			if exists
			(
				select	1
				from	dbo.document_main
				where	document_type			  = @doc_type
						and plafond_collateral_no = @plafond_collateral_no
			)
			begin
				select	@code = code
				from	dbo.document_main
				where	document_type			  = @doc_type
						and plafond_collateral_no = @plafond_collateral_no ;
			end ; 

			if exists
			(
				select	1
				from	dbo.document_detail
				where	module		 = @module
						and doc_no	 = @doc_no
						and doc_name = @doc_name
			)
			begin
				update	dbo.document_detail
				set		document_name		  = @doc_name
						,document_type		  = @doc_type
						,document_description = 'POLICY INSURANCE'
						,file_name			  = @file_name
						,paths				  = @paths
						,doc_file			  = @doc_file
						,document_date		  = @policy_eff_date
						,expired_date		  = @policy_exp_date
						,is_temporary		  = '0'
						,is_manual			  = '1'
						,mod_date			  = @mod_date
						,mod_by				  = @mod_by
						,mod_ip_address		  = @mod_ip_address
				where	doc_no				  = @doc_no ;
			end ;
			else
			begin
            
				if(isnull(@code,'') <> '')
				begin

					insert into dbo.document_detail
					(
						document_code
						,document_name
						,document_type
						,document_date
						,document_description
						,module
						,doc_no
						,doc_name
						,file_name
						,paths
						,doc_file
						,expired_date
						,is_temporary
						,is_manual
						--
						,cre_date
						,cre_by
						,cre_ip_address
						,mod_date
						,mod_by
						,mod_ip_address
					)
					select	@code
							,doc_name
							,doc_type
							,policy_eff_date
							,'POLICY INSURANCE'
							,module
							,doc_no
							,doc_name
							,file_name
							,paths
							,doc_file
							,policy_exp_date
							,'0'
							,'1'
							--
							,@mod_date
							,@mod_by
							,@mod_ip_address
							,@mod_date
							,@mod_by
							,@mod_ip_address
					from	dbo.doc_interface_insurance_policy_main
					where	id = @id_interface ;

                end

			end ;

			set @number_rows = +1 ;
			set @last_id = @id_interface ;

			update	dbo.doc_interface_insurance_policy_main --cek poin
			set		job_status = 'POST'
					,failed_remarks = null
			where	id = @id_interface ;

			commit transaction ;
		end try
		begin catch
			rollback transaction ;

			set @msg = error_message() ;
			set @current_mod_date = getdate() ;

			update	dbo.doc_interface_insurance_policy_main --cek poin
			set		job_status = 'FAILED'
					,failed_remarks = @msg
			where	id = @id_interface ;
			 
			print @msg
			--cek poin	

			/*insert into dbo.sys_job_tasklist_log*/
			exec dbo.xsp_sys_job_tasklist_log_insert @p_job_tasklist_code = @code_sys_job
													 ,@p_status = N'Error'
													 ,@p_start_date = @mod_date
													 ,@p_end_date = @current_mod_date --cek poin
													 ,@p_log_description = @msg
													 ,@p_run_by = 'job'
													 ,@p_from_id = @from_id --cek poin
													 ,@p_to_id = @id_interface --cek poin
													 ,@p_number_of_rows = @number_rows --cek poin
													 ,@p_cre_date = @current_mod_date --cek poin
													 ,@p_cre_by = N'job'
													 ,@p_cre_ip_address = N'127.0.0.1'
													 ,@p_mod_date = @current_mod_date --cek poin
													 ,@p_mod_by = N'job'
													 ,@p_mod_ip_address = N'127.0.0.1' ;
		end catch ;

		fetch next from curr_insurance_policy_main
		into @id_interface
			 ,@module
			 ,@doc_no
			 ,@doc_name
			 ,@doc_type
			 ,@agreement_no
			 ,@collateral_no
			 ,@plafond_no
			 ,@plafond_collateral_no
			 ,@policy_eff_date
			 ,@policy_exp_date
			 ,@file_name
			 ,@paths 
			 ,@doc_file ;
	end ;

	begin -- close cursor
		if cursor_status('global', 'curr_insurance_policy_main') >= -1
		begin
			if cursor_status('global', 'curr_insurance_policy_main') > -1
			begin
				close curr_insurance_policy_main ;
			end ;

			deallocate curr_insurance_policy_main ;
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
												 ,@p_end_date = @current_mod_date --cek poin
												 ,@p_log_description = ''
												 ,@p_run_by = 'job'
												 ,@p_from_id = @from_id --cek poin
												 ,@p_to_id = @last_id --cek poin
												 ,@p_number_of_rows = @number_rows --cek poin
												 ,@p_cre_date = @current_mod_date --cek poin
												 ,@p_cre_by = 'job'
												 ,@p_cre_ip_address = '127.0.0.1'
												 ,@p_mod_date = @current_mod_date --cek poin
												 ,@p_mod_by = 'job'
												 ,@p_mod_ip_address = '127.0.0.1' ;
	end ;
end ;



