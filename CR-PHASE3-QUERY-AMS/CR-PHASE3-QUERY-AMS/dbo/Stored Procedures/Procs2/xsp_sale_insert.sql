CREATE PROCEDURE [dbo].[xsp_sale_insert]
(
	@p_code						NVARCHAR(50) OUTPUT
	,@p_company_code			NVARCHAR(50)= 'DSF'
	,@p_sale_date				DATETIME
	,@p_description				NVARCHAR(4000)	= NULL
	,@p_branch_code				NVARCHAR(50)
	,@p_branch_name				NVARCHAR(250)	= NULL
	,@p_sale_amount_header	    DECIMAL(18, 2)	= 0
	,@p_remark					NVARCHAR(4000)	= NULL
	,@p_status					NVARCHAR(20)
	,@p_sell_type				NVARCHAR(50)
	,@p_auction_code			NVARCHAR(50)	= NULL
	,@p_buyer_name				NVARCHAR(250)	= NULL
	,@p_auction_period			NVARCHAR(50)	= NULL
	,@p_auction_notes			NVARCHAR(4000)	= NULL
	,@p_related_code_sell_req	nvarchar(50)	= NULL
    ,@p_claim_amount			decimal(18,2)	= 0
	--
	,@p_cre_date				datetime
	,@p_cre_by					nvarchar(15)
	,@p_cre_ip_address			nvarchar(15)
	,@p_mod_date				datetime
	,@p_mod_by					nvarchar(15)
	,@p_mod_ip_address			nvarchar(15)
)
as
begin
	declare @msg			nvarchar(max)
			,@year			nvarchar(4)
			,@month			nvarchar(2)
			,@code			nvarchar(50)
			-- Asqal 12-Oct-2022 ket : for WOM (+)
			,@is_valid		int 
			,@max_day		int
			,@doc_code		nvarchar(50)
			,@is_required	nvarchar(1)

	BEGIN TRY

	set @year = substring(cast(datepart(year, @p_cre_date) as nvarchar), 3, 2) ;
	set @month = replace(str(cast(datepart(month, @p_cre_date) as nvarchar), 2, 0), ' ', '0') ;

	--if (@p_sale_date > dbo.xfn_get_system_date() )
	--begin
	--	set @msg = 'Sell date must be less or equal than system date.';
	--	raiserror(@msg ,16,-1);	    
	--end

	exec dbo.xsp_get_next_unique_code_for_table @p_unique_code			 = @code output
												,@p_branch_code			 = @p_branch_code
												,@p_sys_document_code	 = ''
												,@p_custom_prefix		 = 'SL'
												,@p_year				 = @year
												,@p_month				 = @month
												,@p_table_name			 = 'SALE'
												,@p_run_number_length	 = 5
												,@p_delimiter			= '.'
												,@p_run_number_only		 = '0' ;

	
		insert into sale
		(
			code
			,company_code
			,sale_date
			,description
			,branch_code
			,branch_name
			,sale_amount
			,remark
			,status
			,sell_type
			,auction_code
			,buyer_name
			,auction_period
			,total_auction_recommended_price
			,total_asset_selling_price
			,total_book_value
			,gain_loss_selling_asset
			,total_profitability_asset
			,related_code_sell_req
			,auction_notes
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
		(	@code
			,@p_company_code
			,@p_sale_date
			,@p_description
			,@p_branch_code
			,@p_branch_name
			,@p_sale_amount_header
			,@p_remark
			,@p_status
			,@p_sell_type
			,@p_auction_code
			,@p_buyer_name
			,@p_auction_period
			,0
			,0
			,0
			,0
			,0
			,@p_related_code_sell_req
			,@p_auction_notes
			,@p_claim_amount
			--
			,@p_cre_date
			,@p_cre_by
			,@p_cre_ip_address
			,@p_mod_date
			,@p_mod_by
			,@p_mod_ip_address
		)set @p_code = @code ;

		--if(@p_sell_type = 'AUCTION')
		--begin
		--	declare curr_attachment cursor fast_forward read_only for
		--	select b.general_doc_code
		--			,b.is_required
		--	from dbo.master_selling_attachment_group a
		--	inner join dbo.master_selling_attachment_group_detail b on a.code = b.document_group_code
		--	where a.sell_type = 'AUCTION'
			
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
		--	    )
		--	    values
		--	    (
		--	    	@code
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
		--	    )
			
		--	    fetch next from curr_attachment 
		--		into @doc_code
		--			,@is_required
		--	end
			
		--	close curr_attachment
		--	deallocate curr_attachment
		--end
		--else if(@p_sell_type = 'MOCIL')
		--begin
		--	declare curr_attachment cursor fast_forward read_only for
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
		--	    )
		--	    values
		--	    (
		--	    	@code
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
		--	    )
			
		--	    fetch next from curr_attachment 
		--		into @doc_code
		--			,@is_required
		--	end
			
		--	close curr_attachment
		--	deallocate curr_attachment
		--end
		--else if (@p_sell_type = 'COP')
		--begin
		--	declare curr_attachment cursor fast_forward read_only for
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
		--	    )
		--	    values
		--	    (
		--	    	@code
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
		--	    )
			
		--	    fetch next from curr_attachment 
		--		into @doc_code
		--			,@is_required
		--	end
			
		--	close curr_attachment
		--	deallocate curr_attachment
		--end
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
