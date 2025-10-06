CREATE PROCEDURE dbo.xsp_write_off_main_insert
(
	@p_code			   nvarchar(50) = '' output
	,@p_branch_code	   nvarchar(50)
	,@p_branch_name	   nvarchar(250)
	,@p_wo_date		   datetime
	,@p_wo_type		   nvarchar(10) 
	,@p_wo_remarks	   nvarchar(4000)
	,@p_agreement_no   nvarchar(50)
	--
	,@p_cre_date	   datetime
	,@p_cre_by		   nvarchar(15)
	,@p_cre_ip_address nvarchar(15)
	,@p_mod_date	   datetime
	,@p_mod_by		   nvarchar(15)
	,@p_mod_ip_address nvarchar(15)
)
as
begin
	declare @msg		   nvarchar(max)
			,@opl_status   nvarchar(15)
			,@wo_status	   nvarchar(15)
			,@year		   nvarchar(2)
			,@month		   nvarchar(2)
			,@code		   nvarchar(50)
			,@total_amount decimal(18, 2)
			,@system_date  date = cast(dbo.xfn_get_system_date() as date) ;

	set @year = substring(cast(datepart(year, @p_cre_date) as nvarchar), 3, 2) ;
	set @month = replace(str(cast(datepart(month, @p_cre_date) as nvarchar), 2, 0), ' ', '0') ;

	declare @p_unique_code nvarchar(50) ;

	exec dbo.xsp_get_next_unique_code_for_table @p_unique_code = @code output
												,@p_branch_code = @p_branch_code
												,@p_sys_document_code = N''
												,@p_custom_prefix = 'WOM'
												,@p_year = @year
												,@p_month = @month
												,@p_table_name = 'WRITE_OFF_MAIN'
												,@p_run_number_length = 6
												,@p_delimiter = '.'
												,@p_run_number_only = N'0' ;

	begin try

		if not exists
		(
			select	1
			from	dbo.agreement_main
			where	agreement_no			   = @p_agreement_no
					and isnull(opl_status, '') = ''
		)
		begin
			select	@opl_status = opl_status
			from	dbo.agreement_main
			where	agreement_no = @p_agreement_no ;

			set @msg = N'Agreement : ' + @p_agreement_no + N' already in use at ' + @opl_status ;

			raiserror(@msg, 16, 1) ;
		end ;

		if exists
		(
			select	1
			from	write_off_main
			where	agreement_no  = @p_agreement_no
					and wo_status not in ('CANCEL', 'REJECT', 'APPROVE', 'EXPIRED')
		)
		begin
			select	@wo_status = wo_status
			from	write_off_main
			where	agreement_no  = @p_agreement_no
					and wo_status not in ('CANCEL', 'REJECT', 'APPROVE', 'EXPIRED') ;

			set @msg = 'Agreement : ' + @p_agreement_no + ' already in transaction with Status : ' + @wo_status ;

			raiserror(@msg, 16, -1) ;
		end ;

		if (@p_wo_date > @system_date)
		begin
			set @msg = 'Date must be lower than System Date' ;

			raiserror(@msg, 16, -1) ;
		end ;

		insert into write_off_main
		(
			code
			,branch_code
			,branch_name
			,wo_status
			,wo_date
			,wo_type
			,wo_remarks
			,agreement_no
			--
			,cre_date
			,cre_by
			,cre_ip_address
			,mod_date
			,mod_by
			,mod_ip_address
		)
		values
		(	@code
			,@p_branch_code
			,@p_branch_name
			,'HOLD'
			,@p_wo_date
			,@p_wo_type
			,@p_wo_remarks
			,@p_agreement_no
			--
			,@p_cre_date
			,@p_cre_by
			,@p_cre_ip_address
			,@p_mod_date
			,@p_mod_by
			,@p_mod_ip_address
		) ;

		insert into dbo.write_off_detail
		(
			write_off_code
			,asset_no
			,is_take_assets
			--
			,cre_date
			,cre_by
			,cre_ip_address
			,mod_date
			,mod_by
			,mod_ip_address
		)
		select		@code
					,aa.asset_no
					,'0'
					--
					,@p_cre_date
					,@p_cre_by
					,@p_cre_ip_address
					,@p_mod_date
					,@p_mod_by
					,@p_mod_ip_address
		from		dbo.agreement_asset aa  
		where		aa.agreement_no = @p_agreement_no
					and aa.asset_status = 'RENTED'
		group by	aa.asset_no ;

		--insert to write_off_transaction
		exec dbo.xsp_wo_transaction_generate @p_wo_code			= @code
											 ,@p_agreement_no	= @p_agreement_no
											 ,@p_wo_date		= @p_wo_date
											 --
											 ,@p_cre_date		= @p_cre_date
											 ,@p_cre_by			= @p_cre_by
											 ,@p_cre_ip_address = @p_cre_ip_address
											 ,@p_mod_date		= @p_mod_date
											 ,@p_mod_by			= @p_mod_by
											 ,@p_mod_ip_address = @p_mod_ip_address ;

		--insert invoice agreement
		exec dbo.xsp_write_off_invoice_insert @p_write_off_code		= @code
											  ,@p_agreement_no		= @p_agreement_no
											  ,@p_write_off_date	= @p_wo_date
											  --
											  ,@p_cre_date			= @p_cre_date
											  ,@p_cre_by			= @p_cre_by
											  ,@p_cre_ip_address	= @p_cre_ip_address
											  ,@p_mod_date			= @p_mod_date
											  ,@p_mod_by			= @p_mod_by
											  ,@p_mod_ip_address	= @p_mod_ip_address ;
											 
		select	@total_amount = isnull(sum(isnull(transaction_amount, 0)), 0)
		from	dbo.write_off_transaction
		where	wo_code			   = @code
				and is_transaction = '0'
				and	transaction_code = 'OLWOA' ;

		update	dbo.write_off_main
		set		wo_amount		   = @total_amount
				--
				,@p_mod_date	   = @p_mod_date
				,@p_mod_by		   = @p_mod_by
				,@p_mod_ip_address = @p_mod_ip_address 
		where	code			   = @code ;
		

		-- update lms status
		exec dbo.xsp_agreement_main_update_opl_status @p_agreement_no = @p_agreement_no
													  ,@p_status = N'WO' ;

		set @p_code = @code ;
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
end ;
