

CREATE PROCEDURE dbo.xsp_agreement_asset_update_billing_contract_setting
(
	@p_agreement_no				nvarchar(50)
	,@p_asset_no				nvarchar(50)
	,@p_billing_to_name			nvarchar(250)   = null
	,@p_billing_to_area_no		nvarchar(4)		= null
	,@p_billing_to_phone_no		nvarchar(15)	= null
	,@p_billing_to_address		nvarchar(400)	= null
	,@p_billing_to_npwp			nvarchar(20)	= null
	,@p_billing_to_faktur_type	nvarchar(3) 
	,@p_deliver_to_name			nvarchar(250)	= null
	,@p_deliver_to_area_no		nvarchar(4)		= null
	,@p_deliver_to_phone_no		nvarchar(15)	= null
	,@p_deliver_to_address		nvarchar(4000)	= null
	,@p_npwp_name				nvarchar(250)
	,@p_npwp_address			nvarchar(4000)	= null
	,@p_pickup_phone_area_no	nvarchar(4)
	,@p_pickup_phone_no			nvarchar(15)
	,@p_pickup_name				nvarchar(250)
	,@p_pickup_address			nvarchar(4000)	= null
	,@p_email					nvarchar(250)
	,@p_is_auto_email			nvarchar(1)
	,@p_is_invoice_deduct_pph	nvarchar(1)
	,@p_is_receipt_deduct_pph	nvarchar(1)
    ,@p_client_nitku            nvarchar(50) = ''
	--
	,@p_mod_date				datetime
	,@p_mod_by					nvarchar(15)
	,@p_mod_ip_address			nvarchar(15)
)


as
begin
	declare	@msg						nvarchar(max)
			,@billing_to_name			nvarchar(250)
			,@billing_to_area_no		nvarchar(4)		
			,@billing_to_phone_no		nvarchar(15)	
			,@billing_to_address		nvarchar(400)
			,@billing_to_npwp			nvarchar(20)	
			,@npwp_name					nvarchar(250)
			,@npwp_address				nvarchar(4000)
			,@deliver_to_name			nvarchar(250)
			,@deliver_to_area_no		nvarchar(4)		
			,@deliver_to_phone_no		nvarchar(15)	
			,@deliver_to_address		nvarchar(4000)
			,@pickup_name				nvarchar(250)
			,@pickup_phone_area_no	nvarchar(4)
			,@pickup_phone_no			nvarchar(15)
			,@pickup_address			nvarchar(4000)
	begin try

		select	@billing_to_name			= billing_to_name
				,@billing_to_area_no		= billing_to_area_no
				,@billing_to_phone_no		= billing_to_phone_no
				,@billing_to_address		= billing_to_address
				,@billing_to_npwp			= billing_to_npwp
				,@npwp_address				= npwp_address
				,@deliver_to_name			= deliver_to_name
				,@deliver_to_area_no		= deliver_to_area_no
				,@deliver_to_phone_no		= deliver_to_phone_no
				,@deliver_to_address		= deliver_to_address
				,@pickup_name				= pickup_name
				,@pickup_phone_area_no		= pickup_phone_area_no
				,@pickup_phone_no			= pickup_phone_no
				,@pickup_address			= pickup_address
				,@npwp_name					= npwp_name
		from	dbo.agreement_asset
		where	agreement_no				= @p_agreement_no
		and		asset_no					= @p_asset_no
		
		if	@p_is_auto_email = 'T'
			set	@p_is_auto_email = '1'
		else
			set	@p_is_auto_email = '0'
			
		if	@p_is_invoice_deduct_pph = 'T'
			set	@p_is_invoice_deduct_pph = '1'
		else
			set	@p_is_invoice_deduct_pph = '0'
			
		if	@p_is_receipt_deduct_pph = 'T'
			set	@p_is_receipt_deduct_pph = '1'
		else
			set	@p_is_receipt_deduct_pph = '0'
			
		IF (len(@p_client_nitku) <> 6)
		begin 
			set @msg = 'NITKU Must be 6 Digits'
			raiserror (@msg,16,-1);
		end

		update	dbo.agreement_asset
		set		billing_to_name			= isnull(@p_billing_to_name, @billing_to_name)
				,billing_to_area_no		= isnull(@p_billing_to_area_no, @billing_to_area_no)
				,billing_to_phone_no	= isnull(@p_billing_to_phone_no, @billing_to_phone_no)
				,billing_to_address		= isnull(@p_billing_to_address, @billing_to_address)
				,billing_to_npwp		= isnull(@p_billing_to_npwp, @billing_to_npwp)
				,npwp_name				= upper(@p_npwp_name)
				,billing_to_faktur_type	= @p_billing_to_faktur_type
				,is_invoice_deduct_pph	= @p_is_invoice_deduct_pph
				,is_receipt_deduct_pph	= @p_is_receipt_deduct_pph
                --  fauzan 12-02-2025 
				,client_nitku	        = @p_client_nitku
				--
				,mod_date				= @p_mod_date
				,mod_by					= @p_mod_by
				,mod_ip_address			= @p_mod_ip_address
		where	billing_to_npwp			= isnull(@billing_to_npwp, @p_billing_to_npwp) 
				and npwp_name			= isnull(@npwp_name, @p_npwp_name)
				and agreement_no		= @p_agreement_no
				and asset_status		<> 'TERMINATE'

		update	dbo.agreement_asset 
		set		deliver_to_name				= isnull(@p_deliver_to_name, @deliver_to_name)
				,deliver_to_area_no			= isnull(@p_deliver_to_area_no, @deliver_to_area_no)
				,deliver_to_phone_no		= isnull(@p_deliver_to_phone_no, @deliver_to_phone_no)
				,deliver_to_address			= isnull(@p_deliver_to_address, @deliver_to_address)
				,billing_to_name			= isnull(@p_billing_to_name, @billing_to_name)
				,billing_to_area_no			= isnull(@p_billing_to_area_no, @billing_to_area_no)
				,billing_to_phone_no		= isnull(@p_billing_to_phone_no, @billing_to_phone_no)
				,billing_to_address			= isnull(@p_billing_to_address, @billing_to_address)
				,billing_to_npwp			= isnull(@p_billing_to_npwp, @billing_to_npwp)
				,billing_to_faktur_type		= @p_billing_to_faktur_type
				,npwp_name					= upper(@p_npwp_name)
				,npwp_address				= isnull(@p_npwp_address, @npwp_address)
				,pickup_name				= isnull(@p_pickup_name, @pickup_name)
				,pickup_phone_area_no		= isnull(@p_pickup_phone_area_no, @pickup_phone_area_no)
				,pickup_phone_no			= isnull(@p_pickup_phone_no, @pickup_phone_no)
				,pickup_address				= isnull(@p_pickup_address, @pickup_address)
				,email						= @p_email
				,is_auto_email				= @p_is_auto_email
                -- fauzan 12-02-2025 
				,client_nitku				= @p_client_nitku
				--
				,mod_date					= @p_mod_date
				,mod_by						= @p_mod_by
				,mod_ip_address				= @p_mod_ip_address
		where	agreement_no				= @p_agreement_no
		and		asset_no					= @p_asset_no


		-- Hari - 27.Sep.2023 10:57 AM --	3 field ini update base on agreement, karena all kontrak selalu sama
		update	dbo.agreement_asset 
		set		
				billing_to_faktur_type		= @p_billing_to_faktur_type
				,is_invoice_deduct_pph      = @p_is_invoice_deduct_pph
				,is_receipt_deduct_pph      = @p_is_receipt_deduct_pph
		where	agreement_no				= @p_agreement_no


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
