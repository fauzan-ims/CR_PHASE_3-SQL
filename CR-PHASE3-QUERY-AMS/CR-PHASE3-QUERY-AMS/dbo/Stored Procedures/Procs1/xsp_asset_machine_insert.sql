CREATE PROCEDURE dbo.xsp_asset_machine_insert
(
	@p_asset_code					nvarchar(50)
	,@p_merk_code					nvarchar(50)
	,@p_merk_name					nvarchar(250)
	,@p_type_item_code				nvarchar(50)
	,@p_type_item_name				nvarchar(250)
	,@p_model_code					nvarchar(50)
	,@p_model_name					nvarchar(250)
	,@p_built_year					nvarchar(4)
	,@p_chassis_no					nvarchar(50)
	,@p_engine_no					nvarchar(50)
	,@p_colour						nvarchar(50)
	,@p_serial_no					nvarchar(50)
	,@p_remark						nvarchar(4000)
	,@p_invoice_no					nvarchar(50)
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
	declare @msg nvarchar(max) ;

	begin try
		insert into asset_machine
		(
			asset_code
			,merk_code
			,merk_name
			,type_item_code
			,type_item_name
			,model_code
			,model_name
			,built_year
			,chassis_no
			,engine_no
			,colour
			,serial_no
			,remark
			,invoice_no
			--
			,cre_date
			,cre_by
			,cre_ip_address
			,mod_date
			,mod_by
			,mod_ip_address
		)
		values
		(	@p_asset_code
			,@p_merk_code
			,@p_merk_name
			,@p_type_item_code
			,@p_type_item_name
			,@p_model_code
			,@p_model_name
			,@p_built_year
			,@p_chassis_no
			,@p_engine_no
			,@p_colour
			,@p_serial_no
			,@p_remark
			,@p_invoice_no
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
