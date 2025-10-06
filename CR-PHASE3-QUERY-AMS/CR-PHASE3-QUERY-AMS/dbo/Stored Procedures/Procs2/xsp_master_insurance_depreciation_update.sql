CREATE PROCEDURE dbo.xsp_master_insurance_depreciation_update
(
	@p_id						 bigint
	,@p_insurance_code			 nvarchar(50)
	,@p_collateral_type_code	 nvarchar(50)
	,@p_depreciation_code		 nvarchar(50)
	,@p_is_default				 nvarchar(1)
	--
	,@p_mod_date				 datetime
	,@p_mod_by					 nvarchar(15)
	,@p_mod_ip_address			 nvarchar(15)
)
as
begin
	declare @msg nvarchar(max) ;

	if @p_is_default = 'T'
		set @p_is_default = '1' ;
	else
		set @p_is_default = '0' ;

	begin TRY
		if exists (select 1 from master_insurance_depreciation where id	<> @p_id and insurance_code = @p_insurance_code AND depreciation_code = @p_depreciation_code AND collateral_type_code = @p_collateral_type_code)
		begin
			SET @msg = 'Depreciation Name already exist';
			raiserror(@msg, 16, -1) ;
		END

		if @p_is_default = '1'
		begin
			update dbo.master_insurance_depreciation
			set is_default = 0
			where insurance_code = @p_insurance_code
			and is_default = 1
		end
        
		update	master_insurance_depreciation
		set		insurance_code				= @p_insurance_code
				,collateral_type_code		= @p_collateral_type_code
				,depreciation_code			= @p_depreciation_code
				,is_default					= @p_is_default
				--
				,mod_date					= @p_mod_date
				,mod_by						= @p_mod_by
				,mod_ip_address				= @p_mod_ip_address
		where	id							= @p_id ;
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




