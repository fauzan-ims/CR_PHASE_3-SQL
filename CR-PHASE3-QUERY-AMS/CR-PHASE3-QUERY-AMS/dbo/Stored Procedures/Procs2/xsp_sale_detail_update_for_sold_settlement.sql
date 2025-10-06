CREATE PROCEDURE dbo.xsp_sale_detail_update_for_sold_settlement
(
	@p_id					bigint
	,@p_sale_remark			nvarchar(4000)
	,@p_is_sold				nvarchar(1)
	,@p_sale_date			datetime		= null
	,@p_sold_amount			decimal(18, 2)	= 0
	,@p_buyer_type			nvarchar(15)	= ''
	,@p_buyer_name			nvarchar(250)	= ''
	,@p_buyer_area_phone	nvarchar(4)		= ''
	,@p_buyer_area_phone_no nvarchar(15)	= ''
	,@p_buyer_address		nvarchar(4000)	= ''
	,@p_ktp_no				nvarchar(17)	= ''
	,@p_buyer_npwp			nvarchar(50)	= ''
	,@p_buyer_signer_name	nvarchar(50)	= ''
	,@p_faktur_no			NVARCHAR(50)	=''
	,@p_faktur_date			datetime		= null
	--
	,@p_mod_date			datetime
	,@p_mod_by				nvarchar(15)
	,@p_mod_ip_address		nvarchar(15)
)
as
begin
	declare @msg nvarchar(max) ;

	begin try
		declare @total_income				BIGINT
				,@total_expense				BIGINT
				,@total_fee					bigint--decimal(18, 2) = 0
				,@total_ppn					decimal(18, 2) = 0
				,@total_pph					decimal(18, 2) = 0
				,@ppn_sold_pct				decimal(18, 2) = 0
				,@ppn_asset					BIGINT
				,@net_receive				BIGINT
				,@gainloss					BIGINT
				,@gain_loss_profit			bigint = 0--decimal(18, 2) = 0
				,@netbook					decimal(18, 2) = 0
				,@sell_request				decimal(18, 2) = 0
				,@asset_code				nvarchar(50)
				,@is_sold					nvarchar(1)
				,@date						datetime
				,@sale_code					nvarchar(50)
				,@sale_type					nvarchar(50)
				,@buyer_type				nvarchar(50)
				,@return_value1				decimal(18,2)
				,@return_value2				decimal(18,2)
				,@sp_name1					nvarchar(250) = 'xfn_get_amount_borrowing_asset'
				,@sp_name2					nvarchar(250) = 'xfn_get_expense_replacement_asset'
				,@rv						decimal(18,2)
				,@status_asset				nvarchar(50)

		select	@asset_code		= asset_code
				,@netbook		= a.net_book_value_comm
				,@sell_request	= sd.sell_request_amount
				,@is_sold		= sd.is_sold
				,@sale_code		= sd.sale_code
				,@sale_type		= sal.sell_type
				,@buyer_type	= sd.buyer_type
				,@rv			= a.residual_value
				,@status_asset	= a.status
		from	dbo.sale_detail		 sd
				inner join dbo.sale sal on sal.code = sd.sale_code
				inner join dbo.asset a on sd.asset_code = a.code
		where	id = @p_id ;

		if(@p_buyer_type = 'CORPORATE')
		begin
			set @p_ktp_no = '';
		end
		else
		begin
			set @p_buyer_npwp = '';
			set @p_buyer_signer_name = '';
		end

		select @date = sale_date 
		from dbo.sale
		where code = @sale_code

		exec @return_value1 = @sp_name1 @asset_code,@date,null
		exec @return_value2 = @sp_name2 @asset_code ;

		if(@status_asset = 'REPLACEMENT')
		begin
			set @total_income = 0
			set @total_expense = 0
		end
		begin

			select	@total_income = isnull(sum(income_amount), 0)
			from	dbo.asset_income_ledger
			where	asset_code = @asset_code ;

			select	@total_expense = isnull(sum(expense_amount), 0) + isnull(@return_value1,0) + isnull(@return_value2,0)
			from	dbo.asset_expense_ledger
			where	asset_code = @asset_code ;
		end


		--PPN
		select	@ppn_sold_pct = value
		from	dbo.sys_global_param
		where	code = 'PPNSOLD' ;
 
		if (@sale_type <> 'CLAIM')
		begin
			if (@p_is_sold = '1')
			begin
				set @ppn_asset = (cast(@p_sold_amount as decimal(18,2)) * @ppn_sold_pct) / (100 + @ppn_sold_pct);
			end
			else
			begin
				set @ppn_asset = (cast(@sell_request as decimal(18,2)) * @ppn_sold_pct) / (100 + @ppn_sold_pct);
			end
			
		end;
		else
		begin
			set @ppn_asset = 0;
		end;
		if @p_is_sold = '1'
		BEGIN
			
			IF ((@p_sold_amount ) < @sell_request)
			begin
				set @msg = N'Sold Amount must be equal or greater than Sell Request Amount.' ;
				raiserror(@msg, 16, -1) ;
			end
		end

		if (@p_sale_date < @date)
		begin
			set @msg = 'Sale Date must be equal or greater than Sale Request Date.' ;
			raiserror(@msg, 16, -1) ;
		end

		select	@total_fee	= isnull(sum(fee_amount),0) + isnull(sum(ppn_amount),0) - isnull(sum(pph_amount),0)
				,@total_ppn = isnull(sum(ppn_amount),0)
				,@total_pph = isnull(sum(pph_amount),0)
		from	dbo.sale_detail_fee
		where	sale_detail_id = @p_id ;
		
		if(@p_is_sold = '1')
		begin
			--set @gainloss = @p_sold_amount / @ppn_asset - @netbook   ;
			set @gainloss = @p_sold_amount - @ppn_asset - @netbook   ;
		end
		else	
		begin
			--set @gainloss = @sell_request / @ppn_asset - @netbook
			set @gainloss = @sell_request - @ppn_asset - @netbook
		end

		set @net_receive = @p_sold_amount - @total_fee ;
		--set @net_receive = round(@net_receive,0)

		-- total income - expense  - gain loss sale
		set @gain_loss_profit = @total_income + @rv - @total_expense + (@p_sold_amount - @netbook - @ppn_asset)  - @total_fee ;
		set @gain_loss_profit = round(@gain_loss_profit,0)
		--set @ppn_asset = round(@ppn_asset,0)

		--Raffy 17/12/2023 Validasi jika ppn amount lebih dari 0 maka faktur no harus diisi
		if (@total_ppn > 0) AND (@p_is_sold <> '0') AND (@p_faktur_no = '')
		begin
			set @msg = 'Please Input Faktur No!' ;
			raiserror(@msg, 16, -1) ;
		end

		if  (@p_faktur_no <> '') AND (len(@p_faktur_no) != 16)
		begin
			set	@msg = 'Faktur Number Must be 16 Digits.'
			raiserror(@msg, 16, -1) ;
		end

		if (@total_ppn > 0) AND (@p_is_sold <> '0') AND ISNULL(@p_faktur_date, '') = ''
		begin
			set @msg = 'Please Input Faktur Date!' ;
			raiserror(@msg, 16, -1) ;
		END
        
		update	sale_detail
		set		sale_remark					= @p_sale_remark
				,is_sold					= @p_is_sold
				,sale_date					= @p_sale_date
				--
				,net_receive				= @net_receive
				,total_income				= @total_income
				,total_expense				= @total_expense
				,net_book_value				= @netbook
				,total_fee_amount			= isnull(@total_fee,0)
				,gain_loss					= @gainloss
				,ppn_asset					= @ppn_asset
				,total_ppn_amount			= isnull(@total_ppn,0)
				,total_pph_amount			= isnull(@total_pph,0)
				--
				,sold_amount				= @p_sold_amount
				,gain_loss_profit			= @gain_loss_profit
				,buyer_type					= @p_buyer_type
				,buyer_name					= @p_buyer_name
				,buyer_area_phone			= @p_buyer_area_phone
				,buyer_area_phone_no		= @p_buyer_area_phone_no
				,buyer_address				= @p_buyer_address
				,ktp_no						= @p_ktp_no
				,buyer_npwp					= @p_buyer_npwp
				,buyer_signer_name			= @p_buyer_signer_name
				,faktur_no					= @p_faktur_no
				,faktur_date				= @p_faktur_date
				--
				,mod_date					= @p_mod_date
				,mod_by						= @p_mod_by
				,mod_ip_address				= @p_mod_ip_address
		where	id = @p_id ;
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
			set @msg = N'V' + N';' + @msg ;
		end ;
		else
		begin
			if (
				   error_message() like '%V;%'
				   or	error_message() like '%E;%'
			   )
			begin
				set @msg = error_message() ;
			end ;
			else
			begin
				set @msg = N'E;' + dbo.xfn_get_msg_err_generic() + N';' + error_message() ;
			end ;
		end ;

		raiserror(@msg, 16, -1) ;

		return ;
	end catch ;
end ;
