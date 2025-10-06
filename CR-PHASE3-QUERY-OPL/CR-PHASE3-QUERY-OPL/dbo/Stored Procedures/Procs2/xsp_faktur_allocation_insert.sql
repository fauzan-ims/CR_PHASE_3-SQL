CREATE PROCEDURE dbo.xsp_faktur_allocation_insert
(
	@p_code			   nvarchar(50) output
	,@p_branch_code	   nvarchar(50)
	,@p_branch_name	   nvarchar(250)
	,@p_date		   datetime
	,@p_status		   nvarchar(10)
	,@p_remark		   nvarchar(4000)
	,@p_as_of_date	   datetime
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
	declare @msg			  nvarchar(max)
			,@year			  nvarchar(2)
			,@month			  nvarchar(2)
			,@code			  nvarchar(50)

	if (@p_date > dbo.xfn_get_system_date())
	begin
		set @msg = 'Date must bee less than System Date.'
		raiserror(@msg, 16, -1) ;
	end

	 --validasi hanya boleh 1 transaksi yang pending	
	if exists (select 1 from dbo.faktur_allocation where status IN('HOLD','ON PROCESS')) -- ( + ) Dicky Ramadhan - 07/11/2023 - ERR.2307.000387 -- AND branch_code = @p_branch_code and code <> @p_code)

	begin
		set @msg = 'Please complete pending Faktur Allocation transaction.'
		raiserror(@msg, 16, -1) ;
	end
	
	begin try

	set @year = substring(cast(datepart(year, @p_cre_date) as nvarchar), 3, 2) ;
	set @month = replace(str(cast(datepart(month, @p_cre_date) as nvarchar), 2, 0), ' ', '0') ;

	exec dbo.xsp_get_next_unique_code_for_table @p_unique_code = @code output
												,@p_branch_code = @p_branch_code
												,@p_sys_document_code = N''
												,@p_custom_prefix = N'FA'
												,@p_year = @year
												,@p_month = @month
												,@p_table_name = N'FAKTUR_ALLOCATION'
												,@p_run_number_length = 6
												,@p_delimiter = '.'
												,@p_run_number_only = N'0'


		insert into faktur_allocation
		(
			code
			,branch_code
			,branch_name
			,date
			,status
			,remark
			,as_of_date
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
			,@p_date
			,@p_status
			,@p_remark
			,@p_as_of_date
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
