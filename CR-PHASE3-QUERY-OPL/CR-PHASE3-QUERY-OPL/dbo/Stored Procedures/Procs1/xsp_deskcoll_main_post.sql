CREATE PROCEDURE dbo.xsp_deskcoll_main_post
(
	@p_id						BIGINT
	--
	,@p_mod_date				DATETIME
	,@p_mod_by					NVARCHAR(15)
	,@p_mod_ip_address			NVARCHAR(15)
)
AS
BEGIN

	DECLARE @msg							NVARCHAR(MAX)
			--
			,@result_promise_date			DATETIME 
			,@desk_date						DATETIME
            ,@agreement_no					NVARCHAR(50)
            ,@transaction_no				NVARCHAR(50)
			,@log_remarks					NVARCHAR(4000)
			,@result_remarks				NVARCHAR(4000)
			,@result_status					NVARCHAR(250)
			,@result_status_detail			NVARCHAR(250)
			,@source						NVARCHAR(50)
			,@deskcoll_staff				NVARCHAR(50)
			,@total_invoice_no				NVARCHAR(4000)
			,@status						NVARCHAR(50)
			,@client_no						NVARCHAR(50)
			,@result_code					NVARCHAR(50)
			,@next_fu_date					DATETIME
			,@date							DATETIME = dbo.xfn_get_system_date()
			,@total							INT			
			,@mod_by_name					NVARCHAR(250)

	BEGIN TRY
		
		select	@agreement_no			= isnull(agreement_no, '')
				,@result_promise_date	= result_promise_date
				,@desk_date				= desk_date
				,@result_status			= mdr.result_name
				,@result_status_detail	= mdrd.result_name
				,@deskcoll_staff		= mc.collector_name
				,@result_remarks		= dm.result_remarks
				,@status				= dm.desk_status
				,@client_no				= dm.client_no
				,@next_fu_date			= dm.next_fu_date
				,@result_code			= dm.result_code
		from	dbo.deskcoll_main dm
				left join dbo.master_deskcoll_result mdr on mdr.code = dm.result_code 
				left join dbo.master_deskcoll_result mdrd on mdrd.code = dm.result_detail_code 
				left join dbo.master_collector mc on dm.desk_collector_code = mc.code
		where	id = @p_id

		select @total_invoice_no =	stuff((
			  select	top 10  ', ' + replace(invoice_no,'.','/')
			  from		dbo.deskcoll_invoice
			  where		deskcoll_main_id = @p_id
						and isnull(result_code,'')=''
			  for xml path('')
		  ), 1, 1, ''
		 ) ;

		 select @total	= count(1) 
		 from	dbo.deskcoll_invoice
		 where	deskcoll_main_id = @p_id
				and isnull(result_code,'')=''
		
		if exists (select 1 from dbo.deskcoll_invoice where deskcoll_main_id = @p_id and isnull(result_code,'') = '')
		begin
			if(@total > 10)
			begin
				set @msg = 'Please complete result for invoice no : ' + isnull(@total_invoice_no, '') + ' etc.';
				raiserror(@msg ,16,-1)
			end
            else 
			begin
				set @msg = 'Please complete result for invoice no : ' + isnull(@total_invoice_no, '');
				raiserror(@msg ,16,-1)
			end
		end
		
		if (@result_promise_date < @desk_date)
		begin
		    set @msg = dbo.xfn_get_msg_err_must_be_greater_or_equal_than('Promise Date','Desk Date') ;
			raiserror(@msg, 16, -1) ;
		end
        
		if (@result_code = 'MD004')   -- jika janji bayar
		begin
			if(cast(@result_promise_date as date) <= cast(@next_fu_date as date))
			begin
				set @msg = 'Promise Date Must be Geater Than FU Date';
				raiserror(@msg, 16, 1) ;
			end

			if(cast(@result_promise_date as date) < cast(dbo.xfn_get_system_date() as date))
			begin
				set @msg = 'Promise Date Must Be Geater Than System Date';
				raiserror(@msg, 16, 1) ;
			end
            
			-- jika di invoice ada yg promise datenya < dari promise di header
			if exists (select 1 from dbo.deskcoll_invoice where deskcoll_main_id = @p_id and result_code = @result_code  and cast(promise_date as date) < cast(@result_promise_date as date)) 
			begin
				set @msg = 'Promise Date Cannot Be Less Than Promise Date At Invoice No: '
							+ (	select	top 1 inv.invoice_external_no 
								from	dbo.deskcoll_invoice  a
										inner join dbo.invoice inv on inv.invoice_no = a.invoice_no
								where	deskcoll_main_id = @p_id 
								and		result_code = @result_code  
								and		cast(promise_date as date) < cast(@result_promise_date as date))
				raiserror(@msg, 16, 1) ;
			end
		end

		--if exists (select 1 from dbo.deskcoll_main where id = @p_id and ISNULL(result_code,'') = '')
		--begin
		--	set @msg = 'Please save desk collection result first';
		--	raiserror(@msg ,16,-1)
		--end
        
		--if exists (select 1 from dbo.deskcoll_main where id = @p_id and desk_status <> 'HOLD')
		--BEGIN
		--    set @msg = dbo.xfn_get_msg_err_data_already_proceed();
		--	raiserror(@msg ,16,-1)
		--end
  --      else
  --      begin
		--	update	dbo.agreement_main
		--	set		payment_promise_date	= @result_promise_date
		--			--
		--			,mod_date				= @p_mod_date		
		--			,mod_by					= @p_mod_by			
		--			,mod_ip_address			= @p_mod_ip_address
		--	where	agreement_no			= @agreement_no
			
		--	update	dbo.deskcoll_main
		--	set		desk_status			= 'POST'
		--			--
		--			,mod_date			= @p_mod_date		
		--			,mod_by				= @p_mod_by			
		--			,mod_ip_address		= @p_mod_ip_address
		--	where	id					= @p_id

		--	update  dbo.task_main
		--	set		desk_status			= 'POST'
		--			--
		--			,mod_date			= @p_mod_date		
		--			,mod_by				= @p_mod_by			
		--			,mod_ip_address		= @p_mod_ip_address
		--	where	deskcoll_main_id	= @p_id

		--	-- 
		--	if(@result_promise_date is null)
		--	begin
		--		set @log_remarks = 'Desk Collection' + ' ' + isnull(@result_status,'') + ' ' + isnull(@result_status_detail,'') + ' ' +isnull(@result_remarks,'')
		--	end
		--	else
		--	begin
		--		set @log_remarks = 'Desk Collection' + ' ' + isnull(@result_status,'') + ' ' + isnull(@result_status_detail,'') + ' ' +isnull(@result_remarks,'') + ' ' + convert(nvarchar(50), @result_promise_date, 103)
		--	end
            
		--	set @source = 'Deskcoll' + ' ' + isnull(@deskcoll_staff,'')
		--	set @transaction_no = cast(@p_id as nvarchar(50))
		--end

	

		if (@status = 'HOLD')
		begin
			select @mod_by_name = name from ifinsys.dbo.sys_employee_main where code = @p_mod_by

			UPDATE	dbo.deskcoll_main
			set		desk_status			= 'POST'
					,posting_date		= @date
					,posting_by_code	= @p_mod_by
					,posting_by_name	= @mod_by_name
					--
					,mod_date		= @p_mod_date
					,mod_by			= @p_mod_by
					,mod_ip_address = @p_mod_ip_address
			where	id = @p_id ;

			update	dbo.task_main
			set		desk_status		= 'POST'
					--
					,mod_date		= @p_mod_date
					,mod_by			= @p_mod_by
					,mod_ip_address = @p_mod_ip_address
			where	deskcoll_main_id = @p_id ;

			
			insert into dbo.deskcoll_history
			(
				deskcoll_main_id
				,client_no
				,task_date
				,posting_date
				,result_code
				,promise_date
				,next_fu_date
				,remarks
				--
				,cre_date
				,cre_by
				,cre_ip_address
				,mod_date
				,mod_by
				,mod_ip_address
			)
			values
			(
				@p_id
				,@client_no
				,@desk_date
				,@p_mod_date
				,@result_code
				,@result_promise_date
				,@next_fu_date
				,@result_remarks
				--
				,@p_mod_date
				,@p_mod_by
				,@p_mod_ip_address
				,@p_mod_date
				,@p_mod_by
				,@p_mod_ip_address
			)
		end ;
		else
		begin
			set @msg = N'Data already proceed.' ;

			raiserror(@msg, 16, -1) ;
		end ;
        
	end try
	begin catch
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
end