CREATE PROCEDURE dbo.xsp_asset_depreciation_insert
(
	@p_id							   bigint = 0 output
	,@p_asset_code					   nvarchar(50)
	,@p_barcode						   nvarchar(50)
	,@p_depreciation_date			   datetime
	,@p_depreciation_commercial_amount decimal(18, 2)
	,@p_net_book_value_commercial	   decimal(18, 2)
	,@p_depreciation_fiscal_amount	   decimal(18, 2)
	,@p_net_book_value_fiscal		   decimal(18, 2)
	,@p_purchase_amount				   decimal(18, 2)
	,@p_status						   nvarchar(25)
	--
	,@p_cre_date					   datetime
	,@p_cre_by						   nvarchar(15)
	,@p_cre_ip_address				   nvarchar(15)
	,@p_mod_date					   datetime
	,@p_mod_by						   nvarchar(15)
	,@p_mod_ip_address				   nvarchar(15)
)
as
begin
	declare @msg				nvarchar(max) ;

	begin try
		
		insert into asset_depreciation
		(
			asset_code
			,barcode
			,depreciation_date
			,depreciation_commercial_amount
			,net_book_value_commercial
			,depreciation_fiscal_amount
			,net_book_value_fiscal
			,purchase_amount
			,status
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
			,@p_barcode
			,@p_depreciation_date
			,@p_depreciation_commercial_amount
			,@p_net_book_value_commercial
			,@p_depreciation_fiscal_amount
			,@p_net_book_value_fiscal
			,@p_purchase_amount
			,@p_status
			--
			,@p_cre_date
			,@p_cre_by
			,@p_cre_ip_address
			,@p_mod_date
			,@p_mod_by
			,@p_mod_ip_address
		) ;

		set @p_id = @@identity ;
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

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[xsp_asset_depreciation_insert] TO [ims-raffyanda]
    AS [dbo];

