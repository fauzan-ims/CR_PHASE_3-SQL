CREATE procedure dbo.xsp_document_main_insert
(
	@p_code					   nvarchar(50) output
	,@p_branch_code			   nvarchar(50)
	,@p_branch_name			   nvarchar(250)
	,@p_custody_branch_code	   nvarchar(50)
	,@p_custody_branch_name	   nvarchar(250)
	,@p_document_type		   nvarchar(20)
	,@p_asset_no			   nvarchar(50)
	,@p_asset_name			   nvarchar(250)
	,@p_locker_position		   nvarchar(50)
	,@p_locker_code			   nvarchar(50)
	,@p_drawer_code			   nvarchar(50)
	,@p_row_code			   nvarchar(50)
	,@p_document_status		   nvarchar(50)
	,@p_mutation_type		   nvarchar(50)
	,@p_mutation_location	   nvarchar(50)
	,@p_mutation_from		   nvarchar(250)
	,@p_mutation_to			   nvarchar(50)
	,@p_mutation_by			   nvarchar(50)
	,@p_mutation_date		   datetime
	,@p_mutation_return_date   datetime
	,@p_last_mutation_type	   nvarchar(20)
	,@p_last_mutation_date	   datetime
	,@p_last_locker_position   nvarchar(50)
	,@p_last_locker_code	   nvarchar(50)
	,@p_last_drawer_code	   nvarchar(50)
	,@p_last_row_code		   nvarchar(50)
	,@p_borrow_thirdparty_type nvarchar(20)
	,@p_first_receive_date	   datetime
	,@p_release_customer_date  datetime
	,@p_cre_date			   datetime
	,@p_cre_by				   nvarchar(15)
	,@p_cre_ip_address		   nvarchar(15)
	,@p_mod_date			   datetime
	,@p_mod_by				   nvarchar(15)
	,@p_mod_ip_address		   nvarchar(15)
)
as
begin
	declare @msg	nvarchar(max)
			,@year	nvarchar(2)
			,@month nvarchar(2)
			,@code	nvarchar(50) ;

	begin try
		set @year = substring(cast(datepart(year, @p_cre_date) as nvarchar), 3, 2) ;
		set @month = replace(str(cast(datepart(month, @p_cre_date) as nvarchar), 2, 0), ' ', '0') ;

		exec dbo.xsp_get_next_unique_code_for_table @p_unique_code = @p_code output
													,@p_branch_code = @p_branch_code
													,@p_sys_document_code = N''
													,@p_custom_prefix = 'DCM'
													,@p_year = @year
													,@p_month = @month
													,@p_table_name = 'DOCUMENT_MAIN'
													,@p_run_number_length = 6
													,@p_delimiter = '.'
													,@p_run_number_only = N'0' ;

		insert into dbo.document_main
		(
			code
			,branch_code
			,branch_name
			,custody_branch_code
			,custody_branch_name
			,document_type
			,asset_no
			,asset_name
			,locker_position
			,locker_code
			,drawer_code
			,row_code
			,document_status
			,mutation_type
			,mutation_location
			,mutation_from
			,mutation_to
			,mutation_by
			,mutation_date
			,mutation_return_date
			,last_mutation_type
			,last_mutation_date
			,last_locker_position
			,last_locker_code
			,last_drawer_code
			,last_row_code
			,borrow_thirdparty_type
			,first_receive_date
			,release_customer_date
			--
			,cre_date
			,cre_by
			,cre_ip_address
			,mod_date
			,mod_by
			,mod_ip_address
		)
		values
		(	@p_code
			,@p_branch_code
			,@p_branch_name
			,@p_custody_branch_code
			,@p_custody_branch_name
			,@p_document_type 
			,@p_asset_no
			,@p_asset_name
			,@p_locker_position
			,@p_locker_code
			,@p_drawer_code
			,@p_row_code
			,@p_document_status
			,@p_mutation_type
			,@p_mutation_location
			,@p_mutation_from
			,@p_mutation_to
			,@p_mutation_by
			,@p_mutation_date
			,@p_mutation_return_date
			,@p_last_mutation_type
			,@p_last_mutation_date
			,@p_last_locker_position
			,@p_last_locker_code
			,@p_last_drawer_code
			,@p_last_row_code
			,@p_borrow_thirdparty_type
			,@p_first_receive_date
			,@p_release_customer_date
			--
			,@p_cre_date
			,@p_cre_by
			,@p_cre_ip_address
			,@p_mod_date
			,@p_mod_by
			,@p_mod_ip_address
		) ;

		set @code = @p_code ;
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
			if (
				   error_message() like '%V;%'
				   or	error_message() like '%E;%'
			   )
			begin
				set @msg = error_message() ;
			end ;
			else
			begin
				set @msg = 'E;' + dbo.xfn_get_msg_err_generic() + ';' + error_message() ;
			end ;
		end ;

		raiserror(@msg, 16, -1) ;

		return ;
	end catch ;
end ;
