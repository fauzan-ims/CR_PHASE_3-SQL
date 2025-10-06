CREATE PROCEDURE dbo.xsp_reconcile_main_insert
(
	@p_code						  nvarchar(50) output
	,@p_branch_code				  nvarchar(50)
	,@p_branch_name				  nvarchar(250)
	,@p_reconcile_status		  nvarchar(10)
	--,@p_reconcile_date			  datetime
	,@p_reconcile_from_value_date datetime
	,@p_reconcile_to_value_date	  datetime
	,@p_reconcile_remarks		  nvarchar(4000)
	,@p_branch_bank_code		  nvarchar(50)
	,@p_branch_bank_name		  nvarchar(250)
	,@p_bank_gl_link_code		  nvarchar(50)
	,@p_system_amount			  decimal(18, 2) = 0
	,@p_upload_amount			  decimal(18, 2) = 0
	,@p_file_name				  nvarchar(250)	= ''
	,@p_paths					  nvarchar(250)	= ''
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
	declare @msg			nvarchar(max)
			,@year			nvarchar(2)
			,@month			nvarchar(2)
			,@code			nvarchar(50);

	set @year = substring(cast(datepart(year, @p_cre_date) as nvarchar), 3, 2) ;
	set @month = replace(str(cast(datepart(month, @p_cre_date) as nvarchar), 2, 0), ' ', '0') ;

	declare @p_unique_code nvarchar(50) ;

	exec dbo.xsp_get_next_unique_code_for_table @p_unique_code = @code output
												,@p_branch_code = @p_branch_code
												,@p_sys_document_code = N''
												,@p_custom_prefix = 'RCM'
												,@p_year = @year
												,@p_month = @month
												,@p_table_name = 'RECONCILE_MAIN'
												,@p_run_number_length = 6
												,@p_delimiter = '.'
												,@p_run_number_only = N'0' ;

	begin try
		----29/12/2022 Diubah oleh M.Irvan Maulana
		--if exists(select 1 from dbo.reconcile_main where branch_bank_code = @p_branch_bank_code and reconcile_status = 'HOLD' ) 
		--begin
		--	set @msg = 'Bank already exist, please select another bank';
		--	raiserror(@msg ,16,-1)
		--end

		if (@p_reconcile_from_value_date > @p_reconcile_to_value_date) 
		begin
			set @msg = dbo.xfn_get_msg_err_must_be_lower_or_equal_than('From Date','To Date') ;
			raiserror(@msg ,16,-1)
		end

		insert into reconcile_main
		(
			code
			,branch_code
			,branch_name
			,reconcile_status
			,reconcile_date
			,reconcile_from_value_date
			,reconcile_to_value_date
			,reconcile_remarks
			,branch_bank_code
			,branch_bank_name
			,bank_gl_link_code
			,system_amount
			,upload_amount
			,file_name
			,paths
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
			,@p_branch_code
			,@p_branch_name
			,@p_reconcile_status
			,dbo.xfn_get_system_date()
			,@p_reconcile_from_value_date
			,@p_reconcile_to_value_date
			,@p_reconcile_remarks
			,@p_branch_bank_code
			,@p_branch_bank_name
			,@p_bank_gl_link_code
			,@p_system_amount
			,@p_upload_amount
			,@p_file_name
			,@p_paths
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
