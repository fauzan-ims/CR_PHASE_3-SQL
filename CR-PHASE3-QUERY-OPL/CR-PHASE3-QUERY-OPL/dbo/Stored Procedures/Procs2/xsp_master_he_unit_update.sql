---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
CREATE PROCEDURE dbo.xsp_master_he_unit_update
(
	@p_code					nvarchar(50)
	,@p_he_category_code	nvarchar(50)
	,@p_he_subcategory_code nvarchar(50)
	,@p_he_merk_code		nvarchar(50)
	,@p_he_model_code		nvarchar(50)
	,@p_he_type_code		nvarchar(50)
	,@p_he_name				nvarchar(250)
	,@p_description			nvarchar(250)
	,@p_is_active			nvarchar(1)
	--
	,@p_mod_date			datetime
	,@p_mod_by				nvarchar(15)
	,@p_mod_ip_address		nvarchar(15)
)
as
begin
	declare @msg nvarchar(max) ;

	if @p_is_active = 'T'
		set @p_is_active = '1' ;

	if @p_is_active = 'F'
		set @p_is_active = '0' ;

	begin try
		if exists (select 1 from master_he_unit where description = @p_description and code <> @p_code)
		begin
			set @msg = 'Description already exist';
			raiserror(@msg, 16, -1) ;
		end 

		update	master_he_unit
		set		he_category_code		= @p_he_category_code
				,he_subcategory_code	= @p_he_subcategory_code
				,he_merk_code			= @p_he_merk_code
				,he_model_code			= @p_he_model_code
				,he_type_code			= @p_he_type_code
				,he_name				= upper(@p_he_name)
				,description			= upper(@p_description)
				,is_active				= @p_is_active
				--
				,mod_date				= @p_mod_date
				,mod_by						= @p_mod_by
				,mod_ip_address			= @p_mod_ip_address
		where	code					= @p_code ;
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


