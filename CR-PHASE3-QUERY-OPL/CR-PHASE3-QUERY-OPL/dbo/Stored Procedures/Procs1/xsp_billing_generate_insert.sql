CREATE PROCEDURE dbo.xsp_billing_generate_insert
(
	@p_code			   nvarchar(50) output
	,@p_branch_code	   nvarchar(50)
	,@p_branch_name	   nvarchar(250)
	,@p_date		   datetime
	,@p_status		   nvarchar(10)
	,@p_remark		   nvarchar(4000)
	,@p_client_no	   nvarchar(50)	 = ''
	,@p_client_name	   nvarchar(250) = ''
	,@p_agreement_no   nvarchar(50)	 = ''
	,@p_asset_no	   nvarchar(50)	 = ''
	,@p_as_off_date	   datetime
	,@p_is_eod		   nvarchar(1)	 = '0'
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
	declare @code	nvarchar(50)
			,@year	nvarchar(4)
			,@month nvarchar(2)
			,@msg	nvarchar(max) ;

	begin try
		set @year = substring(cast(datepart(year, @p_cre_date) as nvarchar), 3, 2) ;
		set @month = replace(str(cast(datepart(month, @p_cre_date) as nvarchar), 2, 0), ' ', '0') ;

		exec dbo.xsp_get_next_unique_code_for_table @p_unique_code = @code output
													,@p_branch_code = @p_branch_code
													,@p_sys_document_code = N''
													,@p_custom_prefix = N'GIN'
													,@p_year = @year
													,@p_month = @month
													,@p_table_name = N'BILLING_GENERATE'
													,@p_run_number_length = 6
													,@p_delimiter = '.'
													,@p_run_number_only = N'0' ;
													 
		if exists
		(
			select	1
			from	billing_generate
			where	isnull(agreement_no, '')  = @p_agreement_no
					and isnull(asset_no, '')  = @p_asset_no
					and isnull(client_no, '') = @p_client_no
					and branch_code			  = @p_branch_code
					and IS_EOD				  = @p_is_eod
					and status				  = 'HOLD'
		)
		begin
			set @msg = N'Combination already exist' ;

			raiserror(@msg, 16, -1) ;
		end ; 

		insert into billing_generate
		(
			code
			,branch_code
			,branch_name
			,date
			,status
			,remark
			,client_no
			,client_name
			,agreement_no
			,asset_no
			,as_off_date
			,is_eod
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
			,@p_branch_code
			,@p_branch_name
			,@p_date
			,@p_status
			,@p_remark
			,@p_client_no
			,@p_client_name
			,@p_agreement_no
			,@p_asset_no
			,@p_as_off_date
			,@p_is_eod
			--
			,@p_cre_date
			,@p_cre_by
			,@p_cre_ip_address
			,@p_mod_date
			,@p_mod_by
			,@p_mod_ip_address
		) ;

		-- generate billing detail
		exec dbo.xsp_billing_generate_detail_generate @p_code			 = @code
													  ,@p_as_off_date	 = @p_as_off_date
													  ,@p_client_no		 = @p_client_no
													  ,@p_agreement_no	 = @p_agreement_no
													  ,@p_asset_no		 = @p_asset_no
													  --
													  ,@p_mod_date		 = @p_cre_date
													  ,@p_mod_by		 = @p_cre_by
													  ,@p_mod_ip_address = @p_cre_ip_address ;

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
