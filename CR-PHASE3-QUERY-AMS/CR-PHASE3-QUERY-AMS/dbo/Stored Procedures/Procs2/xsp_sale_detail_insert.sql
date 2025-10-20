CREATE PROCEDURE dbo.xsp_sale_detail_insert
(
	@p_id						  BIGINT		 = 0 OUTPUT
	,@p_sale_code				  NVARCHAR(50)
	,@p_asset_code				  NVARCHAR(50)
	,@p_description				  NVARCHAR(4000) = ''
	,@p_total_income			  DECIMAL(18, 2) = 0
	,@p_total_expense			  DECIMAL(18, 2) = 0
	,@p_buyer_type				  NVARCHAR(15)	 = NULL
	,@p_buyer_name				  NVARCHAR(250)	 = ''
	,@p_buyer_area_phone		  NVARCHAR(4)	 = ''
	,@p_buyer_area_phone_no		  NVARCHAR(15)	 = ''
	,@p_buyer_address			  NVARCHAR(4000) = ''
	,@p_file_name				  NVARCHAR(250)	 = ''
	,@p_file_paths				  NVARCHAR(250)	 = ''
	,@p_ktp_no					  NVARCHAR(17)	 = ''
	,@p_sale_value				  DECIMAL(18, 2) = 0
	,@p_total_fee_amount		  DECIMAL(18, 2) = 0
	,@p_total_ppn_amount		  DECIMAL(18, 2) = 0
	,@p_total_pph_amount		  decimal(18, 2) = 0
	,@p_faktur_no				  nvarchar(20)	 = null
	,@p_borrowing_interest_amount decimal(18, 2) = 0
	,@p_faktur_date				  datetime		 = NULL
	,@p_claim_amount			  decimal(18,2)	 = 0
    
	--
	,@p_cre_date				  datetime
	,@p_cre_by					  nvarchar(15)
	,@p_cre_ip_address			  nvarchar(15)
	,@p_mod_date				  datetime
	,@p_mod_by					  nvarchar(15)
	,@p_mod_ip_address			  nvarchar(15)
)
as
begin
	declare @msg			   nvarchar(max)
			,@net_book_value   decimal(18, 2)
			,@code			   nvarchar(50)
			,@year			   nvarchar(4)
			,@month			   nvarchar(4)
			,@month_rom		   nvarchar(4)
			,@asset_no		   nvarchar(50)
			,@asset_no_new	   nvarchar(50)
			,@sell_type		   nvarchar(50)
			,@return_value1	   decimal(18, 2)
			,@return_value2	   decimal(18, 2)
			,@sp_name1		   nvarchar(250)  = N'xfn_get_amount_borrowing_asset'
			,@sp_name2		   nvarchar(250)  = N'xfn_get_expense_replacement_asset'
			,@sale_date		   datetime
			,@expense_amount   decimal(18, 2) = 0
			,@income_amount	   decimal(18, 2) = 0
			,@status_asset	   nvarchar(50)
			,@agreement_no	   nvarchar(50)
			,@borrowing_amount decimal(18, 2) = 0
			,@rv			   decimal(18, 2)
			,@sale_type			nvarchar(50)
			,@client_name		nvarchar(250)
			-- Asqal 12-Oct-2022 ket : for WOM (+)
			,@is_valid		int 
			,@max_day		int
			,@doc_code		nvarchar(50)
			,@is_required	nvarchar(1)
			,@sale_code		NVARCHAR(50)

	begin try
		set @year = year(@p_cre_date) ;
		set @month = replace(str(cast(datepart(month, @p_cre_date) as nvarchar), 2, 0), ' ', '0') ;

		select	@net_book_value		= net_book_value_comm
				,@status_asset		= status
				,@rv				= residual_value
				--,@expense_amount	= expense.expense_amount
				--,@income_amount		= income.income_amount
		from	dbo.asset ass
		--		outer apply
		--(
		--	select	sum(ael.expense_amount) 'expense_amount'
		--	from	dbo.asset_expense_ledger ael
		--	where	ael.asset_code = ass.code
		--)				  expense
		--		outer apply
		--(
		--	select	sum(ail.income_amount) 'income_amount'
		--	from	dbo.asset_income_ledger ail
		--	where	ail.asset_code = ass.code
		--) income
		where	code = @p_asset_code ;

		select	@sale_date	= sale_date
				,@sale_type = sell_type
				,@sale_code = CODE
		from	dbo.sale
		where	code = @p_sale_code ;
		--exec dbo.xsp_get_next_unique_code_for_table @p_unique_code = @code output
		--											,@p_branch_code = ''
		--											,@p_sys_document_code = ''
		--											,@p_custom_prefix = 'PASS'
		--											,@p_year = @year
		--											,@p_month = @month
		--											,@p_table_name = 'SALE_DETAIL'
		--											,@p_run_number_length = 5
		--											,@p_delimiter = '.'
		--											,@p_run_number_only = '0'
		--											,@p_specified_column = 'PJB_NO' ;

		--select @month_rom = dbo.xfn_convert_int_to_roman(@month)
		--select @month_rom
		--declare @unique_code nvarchar(50) ;
		--exec dbo.xsp_generate_auto_surat_no @p_unique_code = @unique_code output -- nvarchar(50)
		--									,@p_branch_code = N'' -- nvarchar(10)
		--									,@p_year = @year -- nvarchar(4)
		--									,@p_month = @month_rom -- nvarchar(4)
		--									,@p_opl_code = N'DISP' -- nvarchar(250)
		--									,@p_jkn = N'PJB' -- nvarchar(250)
		--									,@p_run_number_length = 5 -- int
		--									,@p_delimiter = N'/' -- nvarchar(1)
		--									,@p_table_name = N'SALE_DETAIL' -- nvarchar(250)
		--									,@p_column_name = N'PJB_NO' -- nvarchar(250)

		--update	dbo.sale_detail
		--set		pjb_no = @unique_code
		--where	sale_code = @p_sale_code 
		--		and asset_code = @p_asset_code;

		--select	@sell_type = sell_type
		--from	sale
		--where	code = @p_sale_code ;

		--if @sell_type = 'COP'
		--begin
		--	if exists(select 1 from sale_detail where sale_code=@p_sale_code)
		--	begin
		--		select	@asset_no = ass.client_no
		--		from	sale_detail sd
		--				inner join asset ass on ass.code = sd.asset_code
		--		where	sale_code = @p_sale_code ;

		--		select	@asset_no_new = client_no
		--		from	asset
		--		where	code = @p_asset_code ;

		--		if @asset_no_new is not null
		--		begin
		--			if @asset_no<>@asset_no_new
		--			begin
		--				set @msg = 'Please choose asset with same client' ;
		--				raiserror(@msg, 16, -1) ;
		--			end ;
		--		end
		--		else
		--		begin
		--			set @msg = 'Please choose asset which have client' ;
		--			raiserror(@msg, 16, -1) ;
		--		end;
		--	end ;
		--end ;

		if @sale_type = 'CLAIM'
			set @p_sale_value = @p_claim_amount
		
		insert into sale_detail
		(
			sale_code
			,asset_code
			,description
			,net_book_value
			,gain_loss
			,sale_detail_status
			,total_income
			,total_expense
			,buyer_type
			,buyer_name
			,buyer_area_phone
			,buyer_area_phone_no
			,buyer_address
			,ktp_no
			,file_name
			,file_path
			,sell_request_amount
			,total_fee_amount
			,total_ppn_amount
			,total_pph_amount
			,faktur_no
			,borrowing_interest_amount
			,faktur_date
			,claim_amount
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
			@p_sale_code
			,@p_asset_code
			,@p_description
			,@net_book_value
			,@p_sale_value - @net_book_value
			,'HOLD'
			,@income_amount
			,@p_total_expense
			,@p_buyer_type
			,@p_buyer_name
			,@p_buyer_area_phone
			,@p_buyer_area_phone_no
			,@p_buyer_address
			,@p_ktp_no
			,@p_file_name
			,@p_file_paths
			,@p_sale_value
			,@p_total_fee_amount
			,@p_total_ppn_amount
			,@p_total_pph_amount
			,@p_faktur_no
			,0
			,@p_faktur_date
			,@p_claim_amount
			--
			,@p_cre_date
			,@p_cre_by
			,@p_cre_ip_address
			,@p_mod_date
			,@p_mod_by
			,@p_mod_ip_address
		) ;
		--if(@sale_type = 'AUCTION')
		--BEGIN
		--	DECLARE curr_attachment cursor fast_forward read_only for
		--	select b.general_doc_code
		--			,b.is_required
		--	from dbo.master_selling_attachment_group a
		--	inner join dbo.master_selling_attachment_group_detail b on a.code = b.document_group_code
		--	where a.sell_type = 'AUCTION'
			
		--	open curr_attachment
			
		--	fetch next from curr_attachment 
		--	into @doc_code
		--		,@is_required
			
		--	SELECT @doc_code
		--	while @@fetch_status = 0
		--	begin
		--	    insert into dbo.sale_attachement_group
		--	    (
		--	    	sale_code
		--	    	,document_code
		--	    	,value
		--	    	,file_name
		--	    	,file_path
		--	    	,doc_file
		--	    	,doc_no
		--			,is_required
		--	    	,cre_date
		--	    	,cre_by
		--	    	,cre_ip_address
		--	    	,mod_date
		--	    	,mod_by
		--	    	,mod_ip_address
		--			,ASSET_CODE
		--	    )
		--	    values
		--	    (
		--	    	@sale_code
		--			,@doc_code
		--			,''
		--			,null
		--			,null
		--			,null
		--			,null
		--			,@is_required
		--			,@p_cre_date
		--			,@p_cre_by
		--			,@p_cre_ip_address
		--			,@p_mod_date
		--			,@p_mod_by
		--			,@p_mod_ip_address
		--			,@p_asset_code
		--	    )
			
		--	    fetch next from curr_attachment 
		--		into @doc_code
		--			,@is_required
		--	end
			
		--	close curr_attachment
		--	deallocate curr_attachment
		--end
		--else if(@sale_type = 'MOCIL')
		--BEGIN
		--	SELECT 'MOCIL'
		--	DECLARE curr_attachment cursor fast_forward read_only for
		--	select b.general_doc_code
		--			,b.is_required
		--	from dbo.master_selling_attachment_group a
		--	inner join dbo.master_selling_attachment_group_detail b on a.code = b.document_group_code
		--	where a.sell_type = 'MOCIL'
			
		--	open curr_attachment
			
		--	fetch next from curr_attachment 
		--	into @doc_code
		--		,@is_required
			
		--	while @@fetch_status = 0
		--	begin
		--	    insert into dbo.sale_attachement_group
		--	    (
		--	    	sale_code
		--	    	,document_code
		--	    	,value
		--	    	,file_name
		--	    	,file_path
		--	    	,doc_file
		--	    	,doc_no
		--			,is_required
		--	    	,cre_date
		--	    	,cre_by
		--	    	,cre_ip_address
		--	    	,mod_date
		--	    	,mod_by
		--	    	,mod_ip_address
		--			,ASSET_CODE
		--	    )
		--	    values
		--	    (
		--	    	@sale_code
		--			,@doc_code
		--			,''
		--			,null
		--			,null
		--			,null
		--			,null
		--			,@is_required
		--			,@p_cre_date
		--			,@p_cre_by
		--			,@p_cre_ip_address
		--			,@p_mod_date
		--			,@p_mod_by
		--			,@p_mod_ip_address
		--			,@p_asset_code
		--	    )
			
		--	    fetch next from curr_attachment 
		--		into @doc_code
		--			,@is_required
		--	end
			
		--	close curr_attachment
		--	deallocate curr_attachment
		--end
		--else if (@sale_type = 'COP')
		--BEGIN
		--	SELECT 'COP'
		--	DECLARE curr_attachment cursor fast_forward read_only for
		--	select b.general_doc_code
		--			,b.is_required
		--	from dbo.master_selling_attachment_group a
		--	inner join dbo.master_selling_attachment_group_detail b on a.code = b.document_group_code
		--	where a.sell_type = 'COP'
			
		--	open curr_attachment
			
		--	fetch next from curr_attachment 
		--	into @doc_code
		--		,@is_required
			
		--	while @@fetch_status = 0
		--	begin
		--	    insert into dbo.sale_attachement_group
		--	    (
		--	    	sale_code
		--	    	,document_code
		--	    	,value
		--	    	,file_name
		--	    	,file_path
		--	    	,doc_file
		--	    	,doc_no
		--			,is_required
		--	    	,cre_date
		--	    	,cre_by
		--	    	,cre_ip_address
		--	    	,mod_date
		--	    	,mod_by
		--	    	,mod_ip_address
		--			,ASSET_CODE
		--	    )
		--	    values
		--	    (
		--	    	@sale_code
		--			,@doc_code
		--			,''
		--			,null
		--			,null
		--			,null
		--			,null
		--			,@is_required
		--			,@p_cre_date
		--			,@p_cre_by
		--			,@p_cre_ip_address
		--			,@p_mod_date
		--			,@p_mod_by
		--			,@p_mod_ip_address
		--			,@p_asset_code
		--	    )
			
		--	    fetch next from curr_attachment 
		--		into @doc_code
		--			,@is_required
		--	end
			
		--	close curr_attachment
		--	deallocate curr_attachment
		--END
		--else if (@sale_type = 'CLAIM')
		--BEGIN
		--	SELECT 'CLAIM'
		--	DECLARE curr_attachment cursor fast_forward read_only for
		--	select b.general_doc_code
		--			,b.is_required
		--	from dbo.master_selling_attachment_group a
		--	inner join dbo.master_selling_attachment_group_detail b on a.code = b.document_group_code
		--	where a.sell_type = 'CLAIM'
			
		--	open curr_attachment
			
		--	fetch next from curr_attachment 
		--	into @doc_code
		--		,@is_required
		--	SELECT @@fetch_status
		--	while @@fetch_status = 0
		--	begin
		--	    insert into dbo.sale_attachement_group
		--	    (
		--	    	sale_code
		--	    	,document_code
		--	    	,value
		--	    	,file_name
		--	    	,file_path
		--	    	,doc_file
		--	    	,doc_no
		--			,is_required
		--	    	,cre_date
		--	    	,cre_by
		--	    	,cre_ip_address
		--	    	,mod_date
		--	    	,mod_by
		--	    	,mod_ip_address
		--			,ASSET_CODE
		--	    )
		--	    values
		--	    (
		--	    	@sale_code
		--			,@doc_code
		--			,''
		--			,null
		--			,null
		--			,null
		--			,null
		--			,@is_required
		--			,@p_cre_date
		--			,@p_cre_by
		--			,@p_cre_ip_address
		--			,@p_mod_date
		--			,@p_mod_by
		--			,@p_mod_ip_address
		--			,@p_asset_code
		--	    )
			
		--	    fetch next from curr_attachment 
		--		into @doc_code
		--			,@is_required
		--	end
			
		--	close curr_attachment
		--	deallocate curr_attachment
		--end

		BEGIN
			SELECT @sale_type
			DECLARE curr_attachment cursor fast_forward read_only for
			select	b.general_doc_code
					,b.is_required
			from	dbo.master_selling_attachment_group a
			inner join dbo.master_selling_attachment_group_detail b on a.code = b.document_group_code
			where	a.sell_type = @sale_type
					--and b.is_required = '1'
					and a.is_active = '1'
			
			open curr_attachment
			
			fetch next from curr_attachment 
			into @doc_code
				,@is_required
			
			SELECT @doc_code
			while @@fetch_status = 0
			begin
			    insert into dbo.sale_attachement_group
			    (
			    	sale_code
			    	,document_code
			    	,value
			    	,file_name
			    	,file_path
			    	,doc_file
			    	,doc_no
					,is_required
			    	,cre_date
			    	,cre_by
			    	,cre_ip_address
			    	,mod_date
			    	,mod_by
			    	,mod_ip_address
					,ASSET_CODE
			    )
			    values
			    (
			    	@sale_code
					,@doc_code
					,''
					,null
					,null
					,null
					,null
					,@is_required
					,@p_cre_date
					,@p_cre_by
					,@p_cre_ip_address
					,@p_mod_date
					,@p_mod_by
					,@p_mod_ip_address
					,@p_asset_code
			    )
			
			    fetch next from curr_attachment 
				into @doc_code
					,@is_required
			end
			
			close curr_attachment
			deallocate curr_attachment
		end

		set @p_id = @@identity ;

		--select	@expense_amount	= sum(asl.expense_amount)
		--		,@income_amount	= sum(ail.income_amount)
		--from	dbo.sale_detail						sd
		--		inner join dbo.asset_expense_ledger asl on asl.asset_code = sd.asset_code
		--		inner join dbo.asset_income_ledger	ail on ail.asset_code = sd.asset_code
		--where	sd.id = @p_id ;

		if (@status_asset = 'REPLACEMENT')
		begin
			set @expense_amount = 0 ;
			set @income_amount = 0 ;
		end ;
		else
		begin
			select	@expense_amount = isnull(sum(expense_amount), 0)
			from	dbo.asset_expense_ledger
			where	asset_code = @p_asset_code ;

			select	@income_amount = isnull(sum(income_amount), 0)
			from	dbo.asset_income_ledger
			where	asset_code = @p_asset_code ;
		end ;

		--get borrowing untuk all agreement
		set @borrowing_amount = 0 ;

		declare curr_borrowing cursor fast_forward read_only for
		select	asat.agreement_no
		from	dbo.sale_detail						  sd
				inner join dbo.asset				  ass on (sd.asset_code		 = ass.code)
				left join ifinopl.dbo.agreement_asset asat on (asat.fa_code		 = ass.code)
				left join ifinopl.dbo.agreement_main  aman on (aman.agreement_no = asat.agreement_no)
		where	ass.code		 = @p_asset_code
				and sd.sale_code = @p_sale_code ;

		open curr_borrowing ;

		fetch next from curr_borrowing
		into @agreement_no ;

		while @@fetch_status = 0
		begin
			exec @return_value1 = @sp_name1 @p_asset_code
											,@sale_date
											,@agreement_no ;

			set @borrowing_amount = @borrowing_amount + @return_value1 ;

			fetch next from curr_borrowing
			into @agreement_no ;
		end ;

		close curr_borrowing ;
		deallocate curr_borrowing ;

		exec @return_value2 = @sp_name2 @p_asset_code ;

		update	dbo.sale_detail
		set		total_expense = isnull(@borrowing_amount, 0) + isnull(@return_value2, 0) + @expense_amount
				,gain_loss_profit = isnull(@income_amount, 0) + @rv - (isnull(@borrowing_amount, 0) + isnull(@return_value2, 0) + @expense_amount) + gain_loss
		where	id = @p_id ;

		--if(@sale_type = 'COP')
		begin
			select top 1 @client_name = b.client_name 
			from dbo.sale_detail a
			inner join dbo.asset b on a.asset_code = b.code
			where a.sale_code = @p_sale_code
			order by a.id desc

			--new 01/07/2025
			update dbo.SALE
			set customer_name = @client_name
			where code = @p_sale_code
		end

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
			set @msg = N'V' + N';' + @msg ;
		end ;
		else
		begin
			if (
				   error_message() like '%V;%'
				   or	error_message() like '%E;%'
			   )
			begin
				set @msg = error_message() ;
			end ;
			else
			begin
				set @msg = N'E;' + dbo.xfn_get_msg_err_generic() + N';' + error_message() ;
			end ;
		end ;

		raiserror(@msg, 16, -1) ;

		return ;
	end catch ;
end ;