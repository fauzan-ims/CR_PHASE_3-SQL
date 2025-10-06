CREATE PROCEDURE dbo.xsp_purchase_request_insert
(
	@p_code				 nvarchar(50) = '' output
	,@p_asset_no		 nvarchar(50) = ''
	,@p_branch_code		 nvarchar(50)
	,@p_branch_name		 nvarchar(250)
	,@p_request_date	 datetime
	,@p_request_status	 nvarchar(10)
	,@p_description		 nvarchar(4000)
	,@p_fa_category_code nvarchar(50)
	,@p_fa_category_name nvarchar(250)
	,@p_fa_merk_code	 nvarchar(50)
	,@p_fa_merk_name	 nvarchar(250)
	,@p_fa_model_code	 nvarchar(50)
	,@p_fa_model_name	 nvarchar(250)
	,@p_fa_type_code	 nvarchar(50)
	,@p_fa_type_name	 nvarchar(250)
	,@p_result_fa_code	 nvarchar(50)
	,@p_result_fa_name	 nvarchar(250)
	,@p_result_date		 datetime
	,@p_unit_from		 nvarchar(10)
	,@p_category_type	 nvarchar(50) =''
	--
	,@p_cre_date		 datetime
	,@p_cre_by			 nvarchar(15)
	,@p_cre_ip_address	 nvarchar(15)
	,@p_mod_date		 datetime
	,@p_mod_by			 nvarchar(15)
	,@p_mod_ip_address	 nvarchar(15)
)
as
begin
	declare @msg	nvarchar(max)
			,@year	nvarchar(2)
			,@month nvarchar(2)
			,@code	nvarchar(50) ;

	set @year = substring(cast(datepart(year, @p_cre_date) as nvarchar), 3, 2) ;
	set @month = replace(str(cast(datepart(month, @p_cre_date) as nvarchar), 2, 0), ' ', '0') ;

	exec dbo.xsp_get_next_unique_code_for_table @p_unique_code = @code output
												,@p_branch_code = @p_branch_code
												,@p_sys_document_code = ''
												,@p_custom_prefix = 'OPLPUR'
												,@p_year = @year
												,@p_month = @month
												,@p_table_name = 'PURCHASE_REQUEST'
												,@p_run_number_length = 6
												,@p_delimiter = '.'
												,@p_run_number_only = N'0' ;

	begin try
		insert into dbo.purchase_request
		(
			code
			,asset_no
			,branch_code
			,branch_name
			,request_date
			,request_status
			,description
			,fa_category_code
			,fa_category_name
			,fa_merk_code
			,fa_merk_name
			,fa_model_code
			,fa_model_name
			,fa_type_code
			,fa_type_name
			,result_fa_code
			,result_fa_name
			,result_date
			,unit_from
			,categori_type
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
			,@p_asset_no
			,@p_branch_code
			,@p_branch_name
			,@p_request_date
			,@p_request_status
			,@p_description
			,@p_fa_category_code
			,@p_fa_category_name
			,@p_fa_merk_code
			,@p_fa_merk_name
			,@p_fa_model_code
			,@p_fa_model_name
			,@p_fa_type_code
			,@p_fa_type_name
			,@p_result_fa_code
			,@p_result_fa_name
			,@p_result_date
			,@p_unit_from
			,@p_category_type
			--					 
			,@p_cre_date
			,@p_cre_by
			,@p_cre_ip_address
			,@p_mod_date
			,@p_mod_by
			,@p_mod_ip_address
		) ;

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

