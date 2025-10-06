CREATE PROCEDURE dbo.xsp_job_interface_in_ifindoc_collateral_replaced
as
declare @msg			   nvarchar(max)
		,@id_interface	   bigint --cursor
		,@row_to_process   int
		,@code_sys_job	   nvarchar(50)
		,@last_id		   bigint		= 0
		,@last_id_from_job bigint
		,@number_rows	   int			= 0
		,@row_count		   int			= 0
		,@is_active		   nvarchar(1)
		,@code			   nvarchar(50)
		,@from_id		   bigint		= 0
		,@current_mod_date datetime
		,@mod_date		   datetime		= getdate()
		,@mod_by		   nvarchar(50) = 'Job'
		,@mod_ip_address   nvarchar(50) = '127.0.0.1' ;

select	@row_to_process		 = row_to_process
		,@last_id_from_job	 = last_id
		,@code_sys_job		 = code
		,@is_active			 = is_active
from	dbo.sys_job_tasklist
where	sp_name				 = 'xsp_job_interface_in_ifindoc_collateral_replaced' ;

if (@is_active = '1')
begin
	declare curr_ifindoccollateralreplaced cursor for
		select		code
		from		dbo.doc_interface_collateral_switch
		where		job_status in ( 'HOLD', 'FAILED' )
		order by	code asc offset 0 rows fetch next @row_to_process rows only;

	open curr_ifindoccollateralreplaced ;

	fetch next from curr_ifindoccollateralreplaced
	into @code ;

	while @@fetch_status = 0
	begin
		begin try
			begin transaction ;

			-- update collateral yang di release
			update	dbo.agreement_collateral
			set		collateral_status	 = 'RELEASED'
					,cre_date			 = @mod_date
					,cre_by				 = @mod_by
					,cre_ip_address		 = @mod_ip_address
					,mod_date			 = @mod_date
					,mod_by				 = @mod_by
					,mod_ip_address		 = @mod_ip_address
			where	collateral_no in
					(
						select	collateral_no
						from	dbo.doc_interface_collateral_switch_released
						where	interface_collateral_switch_code = @code

					) ;

			-- insert collateral penganti
			insert into dbo.agreement_collateral
			(
				collateral_no
				,collateral_external_no
				,agreement_no
				,collateral_type
				,collateral_name
				,collateral_description
				,collateral_condition
				,collateral_status
				,collateral_value_amount
				,market_value_amount
				,doc_collateral_no
				,is_main_collateral
				,cre_date
				,cre_by
				,cre_ip_address
				,mod_date
				,mod_by
				,mod_ip_address
			)
			select 
				sr.replaced_collateral_no
				,collaterall_no
				,cs.agreement_no
				,collateral_type
				,collateral_name
				,collateral_description
				,collateral_condition
				,'AVAILABLE'
				,collateral_value_amount
				,market_value_amount
				,doc_collateral_no
				,''
				,@mod_date
				,@mod_by
				,@mod_ip_address
				,@mod_date
				,@mod_by
				,@mod_ip_address
			from dbo.doc_interface_collateral_switch_replaced sr
			inner join dbo.doc_interface_collateral_switch cs on (cs.code = sr.interface_collateral_switch_code)
			where	interface_collateral_switch_code = @code 

			-- insert pending document untuk collateral penganti
			insert into dbo.document_pending
			(
				code
				,branch_code
				,branch_name
				,initial_branch_code
				,initial_branch_name
				,document_type
				,document_status
				,client_no
				,client_name
				,plafond_no
				,agreement_no
				,collateral_no
				,collateral_name
				,plafond_collateral_no
				,plafond_collateral_name
				,asset_no
				,asset_name
				,entry_date
				,cre_date
				,cre_by
				,cre_ip_address
				,mod_date
				,mod_by
				,mod_ip_address
			)
			select
				  csr.replaced_collateral_no
				  ,cs.branch_code
				  ,cs.branch_name
				  ,am.branch_code
				  ,am.branch_name
				  ,'AGREEMENT COLLATERAL'
				  ,'HOLD'
				  ,am.client_no
				  ,am.client_name
				  ,null
				  ,cs.agreement_no
				  ,csr.collaterall_no
				  ,csr.collateral_name
				  ,null
				  ,null
				  ,null
				  ,null
				  ,@mod_date
				  ,@mod_date
				  ,@mod_by
				  ,@mod_ip_address
				  ,@mod_date
				  ,@mod_by
				  ,@mod_ip_address
			from dbo.doc_interface_collateral_switch_replaced csr
			inner join dbo.doc_interface_collateral_switch cs on (csr.interface_collateral_switch_code = cs.code)
			inner join dbo.agreement_main am on (am.agreement_no = cs.agreement_no)
			where interface_collateral_switch_code = @code

			insert into dbo.document_pending_detail
			(
				document_pending_code
				,document_name
				,document_description
				,file_name
				,paths
				,expired_date
				,cre_date
				,cre_by
				,cre_ip_address
				,mod_date
				,mod_by
				,mod_ip_address
			)
			select
				  csr.replaced_collateral_no
				  ,srd.document_code
				  ,srd.document_code
				  ,filename
				  ,paths
				  ,expired_date
				  ,@mod_date
				  ,@mod_by
				  ,@mod_ip_address
				  ,@mod_date
				  ,@mod_by
				  ,@mod_ip_address 
			from dbo.doc_interface_collateral_switch_replaced_doc srd
			inner join dbo.doc_interface_collateral_switch_replaced csr on (csr.replaced_collateral_no = srd.replaced_collateral_no)
			where csr.interface_collateral_switch_code = @code

			set @number_rows = +1 ;
			set @last_id = @id_interface ;

			--cek poin
			update	dbo.doc_interface_collateral_switch
			set		job_status		 = 'POST'
					,failed_remark	 = null
			where	code			 = @code ;

			commit transaction ;
		end try
		begin catch
			rollback transaction ;

			set @msg = error_message() ;

			update	dbo.doc_interface_collateral_switch --cek poin
			set		job_status		 = 'FAILED'
					,failed_remark	 = @msg
			where	code			 = @code ;

			--cek poin	
			print @msg

			/*insert into dbo.sys_job_tasklist_log*/
			set @current_mod_date = getdate() ;

			exec dbo.xsp_sys_job_tasklist_log_insert @p_job_tasklist_code		 = @code_sys_job
													 ,@p_status					 = N'Error'
													 ,@p_start_date				 = @mod_date
													 ,@p_end_date				 = @current_mod_date --cek poin
													 ,@p_log_description		 = @msg
													 ,@p_run_by					 = @mod_by
													 ,@p_from_id				 = @from_id --cek poin
													 ,@p_to_id					 = @id_interface --cek poin
													 ,@p_number_of_rows			 = @number_rows --cek poin
													 ,@p_cre_date				 = @current_mod_date --cek poin
													 ,@p_cre_by					 = @mod_by
													 ,@p_cre_ip_address			 = @mod_ip_address
													 ,@p_mod_date				 = @current_mod_date --cek poin
													 ,@p_mod_by					 = @mod_by
													 ,@p_mod_ip_address			 = @mod_ip_address ;
		end catch ;

		fetch next from curr_ifindoccollateralreplaced
		into @code ;
	end ;

	begin -- close cursor
		if cursor_status('global', 'curr_ifindoccollateralreplaced') >= -1
		begin
			if cursor_status('global', 'curr_ifindoccollateralreplaced') > -1
			begin
				close curr_ifindoccollateralreplaced ;
			end ;

			deallocate curr_ifindoccollateralreplaced ;
		end ;
	end ;

	if (@last_id > 0) --cek poin
	begin
		update	dbo.sys_job_tasklist
		set		last_id	 = @last_id
		where	code	 = @code_sys_job ;

		/*insert into dbo.sys_job_tasklist_log*/
		set @current_mod_date = getdate() ;

		exec dbo.xsp_sys_job_tasklist_log_insert @p_job_tasklist_code			 = @code_sys_job
												 ,@p_status						 = 'Success'
												 ,@p_start_date					 = @mod_date
												 ,@p_end_date					 = @current_mod_date --cek poin
												 ,@p_log_description			 = @msg
												 ,@p_run_by						 = @mod_by
												 ,@p_from_id					 = @from_id --cek poin
												 ,@p_to_id						 = @id_interface --cek poin
												 ,@p_number_of_rows				 = @number_rows --cek poin
												 ,@p_cre_date					 = @current_mod_date --cek poin
												 ,@p_cre_by						 = @mod_by
												 ,@p_cre_ip_address				 = @mod_ip_address
												 ,@p_mod_date					 = @current_mod_date --cek poin
												 ,@p_mod_by						 = @mod_by
												 ,@p_mod_ip_address				 = @mod_ip_address ;
	end ;
end ;
