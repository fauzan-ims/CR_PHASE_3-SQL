CREATE PROCEDURE dbo.xsp_change_category_insert
(
	@p_code									nvarchar(50)	output
	,@p_company_code						nvarchar(50)
	,@p_date								datetime
	,@p_asset_code							nvarchar(50)
	,@p_branch_code							nvarchar(50)
	,@p_branch_name							nvarchar(250)
	,@p_description							nvarchar(4000)		= ''
	,@p_from_category_code					nvarchar(50)		= ''
	,@p_from_category_name					nvarchar(50)		= ''
	,@p_to_category_code					nvarchar(50)		= ''
	,@p_to_category_name					nvarchar(50)		= ''
	,@p_from_item_code						nvarchar(50)		= ''
	,@p_from_item_name						nvarchar(50)		= ''
	,@p_to_item_code						nvarchar(50)		= ''
	,@p_to_item_name						nvarchar(50)		= ''
	,@p_to_depre_category_fiscal_code		nvarchar(50)		= ''
	,@p_to_depre_category_comm_code			nvarchar(50)		= ''
	,@p_from_depre_category_fiscal_code		nvarchar(50)		= ''
	,@p_from_depre_category_comm_code		nvarchar(50)		= ''
	,@p_from_net_book_value_comm			decimal(18, 2)
	,@p_to_net_book_value_comm				decimal(18, 2)
	,@p_from_net_book_value_fiscal			decimal(18, 2)
	,@p_to_net_book_value_fiscal			decimal(18, 2)
	,@p_remarks								nvarchar(4000)	= ''
	,@p_status								nvarchar(25)
	--
	,@p_cre_date							datetime
	,@p_cre_by								nvarchar(15)
	,@p_cre_ip_address						nvarchar(15)
	,@p_mod_date							datetime
	,@p_mod_by								nvarchar(15)
	,@p_mod_ip_address						nvarchar(15)
)
as
begin
	declare @msg				nvarchar(max)
			,@year				nvarchar(4)
			,@month				nvarchar(2)
			,@code				nvarchar(50) 
			-- Asqal 12-Oct-2022 ket : for WOM (+)
			,@is_valid			int 
			,@max_day			int
			,@purchase_price	decimal(18,2)

	begin try

	set @year = substring(cast(datepart(year, @p_cre_date) as nvarchar), 3, 2) ;
	set @month = replace(str(cast(datepart(month, @p_cre_date) as nvarchar), 2, 0), ' ', '0') ;

	select	@purchase_price = purchase_price
	from	dbo.asset
	where	code = @p_asset_code
	
	exec dbo.xsp_get_next_unique_code_for_table @p_unique_code			 = @code output
												,@p_branch_code			 = @p_branch_code
												,@p_sys_document_code	 = ''
												,@p_custom_prefix		 = 'CC'
												,@p_year				 = @year
												,@p_month				 = @month
												,@p_table_name			 = 'CHANGE_CATEGORY'
												,@p_run_number_length	 = 5
												,@p_delimiter			 = '.'
												,@p_run_number_only		 = '0' ;

	
		insert into change_category
		(
			code
			,company_code
			,date
			,asset_code
			,branch_code
			,branch_name
			,description
			,from_category_code
			,from_category_name
			,to_category_code
			,to_category_name
			,from_item_code
			,from_item_name
			,to_item_code
			,to_item_name
			,to_depre_category_fiscal_code
			,to_depre_category_comm_code
			,from_depre_category_fiscal_code
			,from_depre_category_comm_code
			,from_net_book_value_comm	  
			,to_net_book_value_comm		  
			,from_net_book_value_fiscal	  
			,to_net_book_value_fiscal	  		  			  
			,remarks
			,status
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
			,@p_date
			,@p_asset_code
			,@p_branch_code
			,@p_branch_name
			,@p_description
			,@p_from_category_code
			,@p_from_category_name
			,@p_to_category_code
			,@p_to_category_name
			,@p_from_item_code
			,@p_from_item_name
			,@p_to_item_code
			,@p_to_item_name
			,@p_to_depre_category_fiscal_code
			,@p_to_depre_category_comm_code
			,@p_from_depre_category_fiscal_code
			,@p_from_depre_category_comm_code
			,@p_from_net_book_value_comm	  
			,case @p_from_net_book_value_comm when 0 then 0 else @purchase_price end -- Arga 06-Nov-2022 ket : based on request WOM (-/+) --,@p_from_net_book_value_comm--,@p_to_net_book_value_comm		  
			,@p_from_net_book_value_fiscal	  
			,case @p_from_net_book_value_fiscal when 0 then 0 else @purchase_price end -- Arga 06-Nov-2022 ket : based on request WOM (-/+) --,@p_from_net_book_value_fiscal--,@p_to_net_book_value_fiscal					  			  
			,@p_remarks
			,@p_status
			--
			,@p_cre_date
			,@p_cre_by
			,@p_cre_ip_address
			,@p_mod_date
			,@p_mod_by
			,@p_mod_ip_address
		)
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
