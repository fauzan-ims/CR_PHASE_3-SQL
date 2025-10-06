CREATE PROCEDURE dbo.xsp_supplier_selection_detail_update_tax
(
	 @p_id					bigint
	,@p_tax_code			nvarchar(50)
	,@p_tax_name			nvarchar(250)
	,@p_ppn_amount			decimal(9,6)
	,@p_pph_amount			decimal(9,6)
		--
	,@p_mod_date			datetime
	,@p_mod_by				nvarchar(15)
	,@p_mod_ip_address		nvarchar(15)
)
as
begin
	declare @msg			nvarchar(max)


	begin try


    
		update	dbo.sale_detail_fee
		set		master_tax_code				= @p_tax_code
				,master_tax_description		= @p_tax_name
				,ppn_amount					= @p_ppn_amount
				,pph_amount					= @p_pph_amount
				--
				,mod_date					= @p_mod_date
				,mod_by						= @p_mod_by
				,mod_ip_address				= @p_mod_ip_address
		where	id	= @p_id

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
