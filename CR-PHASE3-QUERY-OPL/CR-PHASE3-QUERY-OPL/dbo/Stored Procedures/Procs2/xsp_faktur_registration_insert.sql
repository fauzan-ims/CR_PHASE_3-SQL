CREATE PROCEDURE dbo.xsp_faktur_registration_insert
(
	@p_code				  nvarchar(50) output
	,@p_branch_code		  nvarchar(50)
	,@p_branch_name		  nvarchar(250)
	,@p_status			  nvarchar(10)
	,@p_remark			  nvarchar(4000)
	--
	,@p_year			  nvarchar(4)=''
	,@p_faktur_prefix	  nvarchar(15)=''
	,@p_faktur_running_no nvarchar(35)=''
	,@p_faktur_postfix	  nvarchar(10)=''
	,@p_count			  int=0
	--
	,@p_cre_date		  datetime
	,@p_cre_by			  nvarchar(15)
	,@p_cre_ip_address	  nvarchar(15)
	,@p_mod_date		  datetime
	,@p_mod_by			  nvarchar(15)
	,@p_mod_ip_address	  nvarchar(15)
)
as
begin

	declare @code			nvarchar(50)
			,@year			nvarchar(4)
			,@month			nvarchar(2)
			,@msg			nvarchar(max) ;

	begin try
		
	set @year = substring(cast(datepart(year, @p_cre_date) as nvarchar), 3, 2) ;
	set @month = replace(str(cast(datepart(month, @p_cre_date) as nvarchar), 2, 0), ' ', '0') ;
	
	exec dbo.xsp_get_next_unique_code_for_table @p_unique_code = @code output
												,@p_branch_code = @p_branch_code
												,@p_sys_document_code = N''
												,@p_custom_prefix = 'FRG'
												,@p_year = @year 
												,@p_month = @month 
												,@p_table_name = 'FAKTUR_REGISTRATION' 
												,@p_run_number_length = 6 
												,@p_delimiter = '.'
												,@p_run_number_only = N'0'

		insert into faktur_registration
		(
			code
			,branch_code
			,branch_name
			,status
			,remark
			,year
			,faktur_prefix
			,faktur_running_no
			,faktur_postfix
			,count
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
			,@p_status
			,@p_remark
			,@p_year
			,@p_faktur_prefix
			,@p_faktur_running_no
			,@p_faktur_postfix
			,@p_count
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
	Begin catch
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
