CREATE PROCEDURE dbo.xsp_change_category_update
(
	@p_code									nvarchar(50)
	,@p_company_code						nvarchar(50)
	,@p_date								datetime
	,@p_asset_code							nvarchar(50)
	,@p_branch_code							nvarchar(50)
	,@p_branch_name							nvarchar(250)
	,@p_description							nvarchar(4000)	= ''
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
	,@p_mod_date							datetime
	,@p_mod_by								nvarchar(15)
	,@p_mod_ip_address						nvarchar(15)
)
as
begin
	declare @msg		nvarchar(max) 
			-- Asqal 12-Oct-2022 ket : for WOM (+)
			,@is_valid	int 
			,@max_day	int

	begin try

		update	change_category
		set		code								= @p_code
				,company_code						= @p_company_code
				,date								= @p_date
				,asset_code							= @p_asset_code
				,branch_code						= @p_branch_code
				,branch_name						= @p_branch_name
				,description						= @p_description
				,from_category_code					= @p_from_category_code
				,from_category_name					= @p_from_category_name
				,to_category_code					= @p_to_category_code
				,to_category_name					= @p_to_category_name
				,from_item_code						= @p_from_item_code
				,from_item_name						= @p_from_item_name
				,to_item_code						= @p_to_item_code
				,to_item_name						= @p_to_item_name
				,to_depre_category_fiscal_code		= @p_to_depre_category_fiscal_code
				,to_depre_category_comm_code		= @p_to_depre_category_comm_code
				,from_net_book_value_comm	  		= @p_from_net_book_value_comm	
				,to_net_book_value_comm		  		= @p_to_net_book_value_comm		
				,from_net_book_value_fiscal	  		= @p_from_net_book_value_fiscal	
				,to_net_book_value_fiscal	  		= @p_to_net_book_value_fiscal				
				,remarks							= @p_remarks
				,status								= @p_status
				,from_depre_category_fiscal_code	= @p_from_depre_category_fiscal_code
				,from_depre_category_comm_code		= @p_from_depre_category_comm_code
				--
				,mod_date							= @p_mod_date
				,mod_by								= @p_mod_by
				,mod_ip_address						= @p_mod_ip_address
		where	code = @p_code ;
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
