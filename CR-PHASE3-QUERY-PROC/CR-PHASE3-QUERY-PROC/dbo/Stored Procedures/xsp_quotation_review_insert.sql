CREATE PROCEDURE [dbo].[xsp_quotation_review_insert]
(
	 @p_code					nvarchar(50) output
	,@p_company_code			nvarchar(50)
	,@p_quotation_review_date	datetime
	,@p_expired_date			datetime
	,@p_branch_code				nvarchar(50)
	,@p_branch_name				nvarchar(250)
	,@p_division_code			nvarchar(50)
	,@p_division_name			nvarchar(250)
	,@p_department_code			nvarchar(50)
	,@p_department_name			nvarchar(250)
	,@p_requestor_code			nvarchar(50)
	,@p_requestor_name			nvarchar(250)
	,@p_status					nvarchar(20) = 'NEW'
	,@p_remark					nvarchar(4000)
	,@p_unit_from				nvarchar(60)
	,@p_date_flag				datetime
	,@p_item_code				nvarchar(50)
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
	declare @msg	nvarchar(max) 
			,@year	nvarchar(2)
			,@month nvarchar(2)
			,@code  nvarchar(50) ;

	begin try
		
		--if (@p_quotation_review_date > @p_expired_date)
		--begin
		--	set @msg = 'Tanggal jatuh harus lebih besar dari tanggal quotation!'
		--	raiserror (@msg, 16, 1);	
		--end
	
		set @year = substring(cast(datepart(year, @p_cre_date) as nvarchar), 3, 2) ;
		set @month = replace(str(cast(datepart(month, @p_cre_date) as nvarchar), 2, 0), ' ', '0') ;

		exec dbo.xsp_get_next_unique_code_for_table @p_unique_code			= @code output
													,@p_branch_code			= @p_company_code
													,@p_sys_document_code	= ''
													,@p_custom_prefix		= 'QTR'
													,@p_year				= @year
													,@p_month				= @month
													,@p_table_name			= 'QUOTATION_REVIEW'
													,@p_run_number_length	= 6
													,@p_delimiter			= '.'
													,@p_run_number_only		= '0' ;

	insert into quotation_review
	(
		 code
		,company_code
		,quotation_review_date
		,expired_date
		,branch_code
		,branch_name
		,division_code
		,division_name
		,department_code
		,department_name
		,requestor_code
		,requestor_name
		,status
		,date_flag
		,remark
		,unit_from
		,item_code
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
		 @code
		,@p_company_code
		,@p_quotation_review_date
		,@p_expired_date
		,@p_branch_code
		,@p_branch_name
		,@p_division_code
		,@p_division_name
		,@p_department_code
		,@p_department_name
		,@p_requestor_code
		,@p_requestor_name
		,@p_status
		,@p_date_flag
		,@p_remark
		,@p_unit_from
		,@p_item_code
		--
		,@p_cre_date
		,@p_cre_by
		,@p_cre_ip_address
		,@p_mod_date
		,@p_mod_by
		,@p_mod_ip_address
	);
	set @p_code = @code

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

