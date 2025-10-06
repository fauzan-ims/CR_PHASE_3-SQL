CREATE PROCEDURE dbo.xsp_master_upload_table_insert
(
	@p_code							nvarchar(50) output
	,@p_description					nvarchar(250)
	,@p_tabel_name					nvarchar(250)
	,@p_template_name				nvarchar(250)
	--,@p_sp_validate_name			nvarchar(250)
	,@p_sp_post_name				nvarchar(250)
	,@p_sp_cancel_name				nvarchar(250)
	,@p_sp_upload_name				nvarchar(250)
	--,@p_sp_getrows_name				nvarchar(250)
	,@p_is_active					nvarchar(1)
	--
	,@p_cre_date					datetime
	,@p_cre_by						nvarchar(15)
	,@p_cre_ip_address				nvarchar(15)
	,@p_mod_date					datetime
	,@p_mod_by						nvarchar(15)
	,@p_mod_ip_address				nvarchar(15)
)
as
begin

	declare @msg			nvarchar(max) 
			,@code			nvarchar(50)
			,@p_unique_code nvarchar(50)
			,@year			nvarchar(2)
			,@month			nvarchar(2);
	
	set @year = substring(cast(datepart(year, @p_cre_date) as nvarchar), 3, 2) ;
	set @month = replace(str(cast(datepart(month, @p_cre_date) as nvarchar), 2, 0), ' ', '0') ;

	exec dbo.xsp_get_next_unique_code_for_table @p_unique_code = @p_code output
												,@p_branch_code = ''
												,@p_sys_document_code = N''
												,@p_custom_prefix = 'MIF'
												,@p_year = @year
												,@p_month = @month
												,@p_table_name = 'MASTER_UPLOAD_TABLE'
												,@p_run_number_length = 6
												,@p_delimiter = '.'
												,@p_run_number_only = N'0' ;
		
		if @p_is_active = 'T'
		set @p_is_active = '1' ;
	else
		set @p_is_active = '0' ;

	begin try		
		
		if exists
		(
			select	1
			from	master_upload_table
			where	description = @p_description
			 
		)
		begin
			set @msg = 'Description already exist' ;

			raiserror(@msg, 16, -1) ;
		end ;

		insert into dbo.master_upload_table
		(
		    code
		    ,description
		    ,tabel_name
		    ,template_name
			,sp_upload_name
			,sp_getrows_name
		    ,sp_validate_name
		    ,sp_post_name
		    ,sp_cancel_name
		    ,is_active
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
			@p_code
		    ,upper(@p_description)
		    ,upper(@p_tabel_name)
		    ,upper(@p_template_name)
			,lower(@p_sp_upload_name)
			,'' --LOWER(@p_sp_getrows_name)
		    ,'' --LOWER(@p_sp_validate_name)
		    ,lower(@p_sp_post_name)
		    ,lower(@p_sp_cancel_name)
		    ,@p_is_active
			--
		    ,@p_cre_date
		    ,@p_cre_by
		    ,@p_cre_ip_address
		    ,@p_mod_date
		    ,@p_mod_by
		    ,@p_mod_ip_address
		)

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
