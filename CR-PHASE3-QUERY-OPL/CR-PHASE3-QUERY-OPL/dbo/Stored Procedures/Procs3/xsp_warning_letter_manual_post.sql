CREATE PROCEDURE dbo.xsp_warning_letter_manual_post
(
	@p_code			   nvarchar(50)
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
	declare @msg					nvarchar(max)
			,@letter_type			nvarchar(20)
			--,@agreement_no		nvarchar(50)
			,@branch_code			nvarchar(50)
			--,@installment_no		int
			,@letter_date			datetime
			,@p_letter_no			nvarchar(50)
			,@branch_name			nvarchar(50)
			,@log_remarks			nvarchar(4000)
			,@letter_remarks		nvarchar(4000)
			,@letter_no_sp1			nvarchar(50)
			,@letter_no_sp2			nvarchar(50)
			,@letter_no_sp3			nvarchar(50)
			,@client_no				nvarchar(50)
			,@delivery_code			nvarchar(50)
			,@letter_no_ondelivery	nvarchar(50)

	begin try
		select	@letter_type		= letter_type
				--,@agreement_no	= wl.agreement_no
				,@branch_code		= wl.branch_code
				,@branch_name		= wl.branch_name
				,@letter_remarks	= letter_remarks
				,@letter_date		= wl.letter_date
				,@client_no			= wl.client_no
		from	warning_letter wl
				--inner join dbo.agreement_main amn on (amn.agreement_no = wl.agreement_no)
		where	code = @p_code ;

		----installment_no
		--select	@installment_no = last_paid_period + 1
		--from	dbo.agreement_information
		--where	agreement_no = @agreement_no ;

		if (cast(@letter_date as date) <> cast(dbo.xfn_get_system_date() as date))
		begin
			set @msg = dbo.xfn_get_msg_err_must_be_equal_to('Letter Date', 'System Date') ;
			raiserror(@msg, 16, -1) ;
		end ;
		--SELECT 'client', @client_no
		--if exists
		--(
		--	select	1
		--	from	dbo.warning_letter
		--	where	code			  <> @p_code
		--			and letter_status <> 'CANCEL'
		--			and agreement_no  = @agreement_no
		--			and letter_type	  = @letter_type
		--)
		--begin
		--	set @msg = N'SP already exists' ;

		--	raiserror(@msg, 16, -1) ;
		--end ;

		if exists (
						select 1
						from	dbo.warning_letter wl
								inner join dbo.warning_letter_delivery wld on wld.code = wl.delivery_code
						where	wl.client_no = @client_no
						and		wl.generate_type = 'MANUAL'
						and		wld.delivery_status in ('HOLD','ON PROCESS')
					)
		begin
			select	top 1 @delivery_code = wl.delivery_code
					,@letter_no_ondelivery = wl.letter_no
			from	dbo.warning_letter wl
					inner join dbo.warning_letter_delivery wld on wld.code = wl.delivery_code
			where	wl.client_no = @client_no
			and		wl.generate_type = 'MANUAL'
			and		wld.delivery_status in ('HOLD','ON PROCESS')
		
		    set @msg = 'Please Done Delivery Settlement For SP No. ' + @letter_no_ondelivery + ' On Delivery Settlement No. ' + @delivery_code;
			raiserror(@msg, 16, -1) ;
		end


		if exists
		(
			select	1
			from	dbo.warning_letter
			where	code			  = @p_code
					and letter_status <> 'REQUEST'
		)
		begin
			set @msg = dbo.xfn_get_msg_err_data_already_proceed() ;
			raiserror(@msg, 16, -1) ;
		end ;
		else
		begin
			--if (
			--	   @letter_type = 'SOMASI'
			--	   or	@letter_type = 'SP2'
			--   )
			--begin
			--	if exists
			--	(
			--		select	1
			--		from	warning_letter wl
			--				inner join dbo.agreement_main amn on (amn.agreement_no = wl.agreement_no)
			--		where	wl.agreement_no		  = @agreement_no
			--				and wl.installment_no < @installment_no
			--				and wl.letter_type	  = 'SP1'
			--				and letter_status not in
			--	(
			--		'CANCEL', 'REQUEST', 'DELIVERED', 'ALREADY PAID'
			--	)
			--	)
			--	begin
			--		select	@letter_no_sp1 = letter_no
			--		from	dbo.warning_letter
			--		where	agreement_no	   = @agreement_no
			--				and installment_no < @installment_no
			--				and letter_type	   = 'SP1'
			--				and letter_status not in
			--		(
			--			'CANCEL', 'REQUEST', 'DELIVERED', 'ALREADY PAID'
			--		) ;
			--	end ;
			--	else
			--	begin

			--		-- Cek SP1 sudah ada apa belum  
			--		if not exists
			--		(
			--			select	1
			--			from	warning_letter wl
			--			where	wl.agreement_no		  = @agreement_no
			--					and wl.installment_no = @installment_no
			--					and wl.letter_type	  = 'SP1'
			--					and letter_status	  <> 'CANCEL'
			--		)
			--		begin
			--			exec dbo.xsp_warning_letter_insert @p_code				= ''
			--											   ,@p_branch_code		= @branch_code
			--											   ,@p_branch_name		= @branch_name
			--											   ,@p_letter_status	= 'HOLD'
			--											   ,@p_letter_date		= @letter_date
			--											   ,@p_letter_no		= @letter_no_sp1 output
			--											   ,@p_letter_type		= 'SP1'
			--											   ,@p_agreement_no		= @agreement_no
			--											   ,@p_generate_type	= 'MANUAL'
			--											   ,@p_cre_date			= @p_cre_date
			--											   ,@p_cre_by			= @p_cre_by
			--											   ,@p_cre_ip_address	= @p_cre_ip_address
			--											   ,@p_mod_date			= @p_mod_date
			--											   ,@p_mod_by			= @p_mod_by
			--											   ,@p_mod_ip_address	= @p_mod_ip_address
			--											   ,@p_client_no		= @client_no;
						
			--		end ;

			--		-- Cek SP1 masih Request
			--		if exists
			--		(
			--			select	1
			--			from	warning_letter wl
			--					inner join dbo.agreement_main amn on (amn.agreement_no = wl.agreement_no)
			--			where	wl.agreement_no		  = @agreement_no
			--					and wl.installment_no = @installment_no
			--					and wl.letter_type	  = 'SP1'
			--					and letter_status	  = 'REQUEST'
			--		)
			--		begin
			--			update	dbo.warning_letter
			--			set		letter_status = 'HOLD'
			--			where	agreement_no	   = @agreement_no
			--					and installment_no = @installment_no
			--					and letter_type	   = 'SP1'
			--					and letter_status  = 'REQUEST' ;
			--		end ;

			--		select	@letter_no_sp1 = letter_no
			--		from	dbo.warning_letter
			--		where	agreement_no	   = @agreement_no
			--				and installment_no = @installment_no
			--				and letter_type	   = 'SP1' ;
			--	end ;

			--	update	dbo.warning_letter
			--	set		previous_letter_code	= @letter_no_sp1
			--			,mod_date				= @p_mod_date
			--			,mod_by					= @p_mod_by
			--			,mod_ip_address			= @p_mod_ip_address
			--	where	agreement_no			= @agreement_no
			--			and installment_no		= @installment_no
			--			and letter_type			= 'SP2' ;
			--end ;

			--if (@letter_type = 'SP3')
			--begin
			--	if exists
			--	(
			--		select	1
			--		from	warning_letter wl
			--				inner join dbo.agreement_main amn on (amn.agreement_no = wl.agreement_no)
			--		where	wl.agreement_no		  = @agreement_no
			--				and wl.installment_no < @installment_no
			--				and wl.letter_type	  = 'SP2'
			--				and letter_status not in
			--	(
			--		'CANCEL', 'REQUEST', 'DELIVERED', 'ALREADY PAID'
			--	)
			--	)
			--	begin
			--		select	@letter_no_sp2 = letter_no
			--		from	dbo.warning_letter
			--		where	agreement_no	   = @agreement_no
			--				and installment_no < @installment_no
			--				and letter_type	   = 'SP2'
			--				and letter_status not in
			--		(
			--			'CANCEL', 'REQUEST', 'DELIVERED', 'ALREADY PAID'
			--		) ;
			--	end ;
			--	else
			--	begin

			--		-- Cek SP2 sudah ada apa belum  
			--		if not exists
			--		(
			--			select	1
			--			from	warning_letter wl
			--					inner join dbo.agreement_main amn on (amn.agreement_no = wl.agreement_no)
			--			where	wl.agreement_no		  = @agreement_no
			--					and wl.installment_no = @installment_no
			--					and wl.letter_type	  = 'SP2'
			--					and letter_status	  <> 'CANCEL'
			--		)
			--		begin

			--			exec dbo.xsp_warning_letter_insert @p_code				= ''
			--											   ,@p_branch_code		= @branch_code
			--											   ,@p_branch_name		= @branch_name
			--											   ,@p_letter_status	= 'HOLD'
			--											   ,@p_letter_date		= @letter_date
			--											   ,@p_letter_no		= @letter_no_sp2 output
			--											   ,@p_letter_type		= 'SP2'
			--											   ,@p_agreement_no		= @agreement_no
			--											   ,@p_generate_type	= 'MANUAL'
			--											   ,@p_cre_date			= @p_cre_date
			--											   ,@p_cre_by			= @p_cre_by
			--											   ,@p_cre_ip_address	= @p_cre_ip_address
			--											   ,@p_mod_date			= @p_mod_date
			--											   ,@p_mod_by			= @p_mod_by
			--											   ,@p_mod_ip_address	= @p_mod_ip_address
			--											   ,@p_client_no		= @client_no;
						
			--		end ;

			--		-- Cek SP2 masih Request
			--		if exists
			--		(
			--			select	1
			--			from	warning_letter wl
			--					inner join dbo.agreement_main amn on (amn.agreement_no = wl.agreement_no)
			--			where	wl.agreement_no		  = @agreement_no
			--					and wl.installment_no = @installment_no
			--					and wl.letter_type	  = 'SP2'
			--					and letter_status	  = 'REQUEST'
			--		)
			--		begin
			--			update	dbo.warning_letter
			--			set		letter_status = 'HOLD'
			--			where	agreement_no	   = @agreement_no
			--					and installment_no = @installment_no
			--					and letter_type	   = 'SP2'
			--					and letter_status  = 'REQUEST' ;
			--		end ;

			--		select	@letter_no_sp2 = letter_no
			--		from	dbo.warning_letter
			--		where	agreement_no	   = @agreement_no
			--				and installment_no = @installment_no
			--				and letter_type	   = 'SP2' ;
			--	end ;

			--	update	dbo.warning_letter
			--	set		previous_letter_code = @letter_no_sp1
			--			,mod_date = @p_mod_date
			--			,mod_by = @p_mod_by
			--			,mod_ip_address = @p_mod_ip_address
			--	where	agreement_no	   = @agreement_no
			--			and installment_no = @installment_no
			--			and letter_type	   = 'SP2' ;

			--	update	dbo.warning_letter
			--	set		previous_letter_code = @letter_no_sp2
			--			,mod_date = @p_mod_date
			--			,mod_by = @p_mod_by
			--			,mod_ip_address = @p_mod_ip_address
			--	where	agreement_no	   = @agreement_no
			--			and installment_no = @installment_no
			--			and letter_type	   = 'SOMASI' ;
			--end ;

			update	dbo.warning_letter
			set		letter_status = 'HOLD'
					,mod_date = @p_mod_date
					,mod_by = @p_mod_by
					,mod_ip_address = @p_mod_ip_address
			where	code = @p_code ;

			--set @log_remarks = N'Warning Letter ' + isnull(@letter_remarks, '') ;
			
			--exec dbo.xsp_agreement_log_insert @p_agreement_no		= @agreement_no
			--								  ,@p_asset_no			= null
			--								  ,@p_log_source_no		= @p_code
			--								  ,@p_log_date			= @p_cre_date
			--								  ,@p_log_remarks		= @log_remarks
			--								  ,@p_cre_date			= @p_mod_date
			--								  ,@p_cre_by			= @p_mod_by
			--								  ,@p_cre_ip_address	= @p_mod_ip_address
			--								  ,@p_mod_date			= @p_mod_date
			--								  ,@p_mod_by			= @p_mod_by
			--								  ,@p_mod_ip_address	= @p_mod_ip_address  
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
end ;

