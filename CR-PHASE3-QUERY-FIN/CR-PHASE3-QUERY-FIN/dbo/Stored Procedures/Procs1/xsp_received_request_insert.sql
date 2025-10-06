CREATE PROCEDURE dbo.xsp_received_request_insert
(
	@p_code						  nvarchar(50) output
	,@p_branch_code				  nvarchar(50)
	,@p_branch_name				  nvarchar(250)
	,@p_received_source			  nvarchar(10)
	,@p_received_request_date	  datetime
	,@p_received_source_no		  nvarchar(50)
	,@p_received_status			  nvarchar(10)
	,@p_received_amount			  decimal(18, 2)
	,@p_received_remarks		  nvarchar(4000)
	,@p_received_transaction_code nvarchar(50)
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
	declare @year	nvarchar(4)
			,@month nvarchar(2)
			,@msg	nvarchar(max)
			,@code	nvarchar(50) ;

	begin try
		set @year = substring(cast(datepart(year, @p_cre_date) as nvarchar), 3, 2) ;
		set @month = replace(str(cast(datepart(month, @p_cre_date) as nvarchar), 2, 0), ' ', '0') ;

		exec dbo.xsp_get_next_unique_code_for_table @p_unique_code = @code output
														,@p_branch_code = @p_branch_code
														,@p_sys_document_code = N''
														,@p_custom_prefix = 'RRQ'
														,@p_year = @year
														,@p_month = @month
														,@p_table_name = 'RECEIVED_REQUEST'
														,@p_run_number_length = 6
														,@p_delimiter = '.'
														,@p_run_number_only = N'0' ;
		set @p_code = @code;
		insert into received_request
		(
			code
			,branch_code
			,branch_name
			,received_source
			,received_request_date
			,received_source_no
			,received_status
			,received_amount
			,received_remarks
			,received_transaction_code
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
			,@p_received_source
			,@p_received_request_date
			,@p_received_source_no
			,@p_received_status
			,@p_received_amount
			,@p_received_remarks
			,@p_received_transaction_code
			--
			,@p_cre_date
			,@p_cre_by
			,@p_cre_ip_address
			,@p_mod_date
			,@p_mod_by
			,@p_mod_ip_address
		) ;
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
