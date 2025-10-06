---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
CREATE procedure [dbo].[xsp_master_he_unit_insert]
(
	@p_code					nvarchar(50) OUTPUT
	,@p_he_category_code	nvarchar(50)
	,@p_he_subcategory_code nvarchar(50)
	,@p_he_merk_code		nvarchar(50)
	,@p_he_model_code		nvarchar(50)
	,@p_he_type_code		nvarchar(50)
	,@p_he_name				nvarchar(250) = NULL
	,@p_description			nvarchar(250)
	,@p_is_active			nvarchar(1)
	--
	,@p_cre_date			datetime
	,@p_cre_by				nvarchar(15)
	,@p_cre_ip_address		nvarchar(15)
	,@p_mod_date			datetime
	,@p_mod_by				nvarchar(15)
	,@p_mod_ip_address		nvarchar(15)
)
as
begin
	declare @msg	nvarchar(max)
			,@year	nvarchar(2)
			,@month nvarchar(2)
			,@code	nvarchar(50) ;

	set @year = substring(cast(datepart(year, @p_cre_date) as nvarchar), 3, 2) ;
	set @month = replace(str(cast(datepart(month, @p_cre_date) as nvarchar), 2, 0), ' ', '0') ;

	exec dbo.xsp_get_next_unique_code_for_table @p_unique_code = @p_code output
												                 ,@p_branch_code = N''
												                 ,@p_sys_document_code = N''
												                 ,@p_custom_prefix = 'UH'
												                 ,@p_year = @year
												                 ,@p_month = @month
												                 ,@p_table_name = 'MASTER_HE_UNIT'
												                 ,@p_run_number_length = 8
												                 ,@p_delimiter = '.'
												                 ,@p_run_number_only = N'0' ;

	if @p_is_active = 'T'
		set @p_is_active = '1' ;

	if @p_is_active = 'F'
		set @p_is_active = '0' ;

	begin try
		if exists (select 1 from master_he_unit where description = @p_description)
		begin
			set @msg = 'Description already exist';
			raiserror(@msg, 16, -1) ;
		end 

		insert into master_he_unit
		(
			code
			,he_category_code
			,he_subcategory_code
			,he_merk_code
			,he_model_code
			,he_type_code
			,he_name
			,description
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
		(	upper(@p_code)
			,@p_he_category_code
			,@p_he_subcategory_code
			,@p_he_merk_code
			,@p_he_model_code
			,@p_he_type_code
			,@p_he_name
			,upper(@p_description)
			,@p_is_active
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
		declare  @error int
		set  @error = @@error
	 
		if ( @error = 2627)
		begin
			set @msg = dbo.xfn_get_msg_err_code_already_exist();
		end ;
		else if ( @error = 547)
		begin
			set @msg = dbo.xfn_get_msg_err_code_already_used();
		end ;

		if (len(@msg) <> 0)
		begin
			set @msg = 'V' + ';' + @msg ;
		end ;
		else
		begin
			set @msg = 'E;' + dbo.xfn_get_msg_err_generic() + ';' + error_message();
		end ;

		raiserror(@msg, 16, -1) ;

		return ; 
	end catch ;
end ;


