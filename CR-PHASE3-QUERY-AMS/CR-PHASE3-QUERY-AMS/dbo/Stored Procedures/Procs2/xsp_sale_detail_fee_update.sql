CREATE PROCEDURE dbo.xsp_sale_detail_fee_update
(
	@p_id			   bigint
	,@p_sale_detail_id bigint
	,@p_fee_amount	   decimal(18, 2)
	,@p_ppn_amount	   decimal(18,2) -- (+) Ari 2024-01-08
	--
	,@p_mod_date	   datetime
	,@p_mod_by		   nvarchar(15)
	,@p_mod_ip_address nvarchar(15)
)
as
begin
	declare @msg nvarchar(max)
			,@fee_amount		decimal(18,2)
			,@pph_amount		decimal(18,2)
			,@ppn_amount		decimal(18,2)
			,@ppn_total			decimal(18,2)
			,@pph_total			decimal(18,2)
			,@total_depre		decimal(18,2)
			,@purchase_price	decimal(18,2)
			,@sale_value		decimal(18,2)
			,@ppn			    decimal(9,6)
			,@pph			    decimal(9,6)
			,@ppn_sold_pct		decimal(18, 2) = 0
			,@netbook			decimal(18, 2) = 0
			-- (+) Ari 2024-01-08
			,@fee_amount_before	decimal(18,2) = 0
			,@ppn_before		decimal(18,2)
			,@pph_before		decimal(18,2)
			,@val_ppn			decimal(18,2)

	begin try

		select	@ppn = master_tax_ppn_pct
				,@pph = master_tax_pph_pct
				,@ppn_before = ppn_amount -- (+) Ari 2024-01-08
				,@fee_amount_before = fee_amount
		from	dbo.sale_detail_fee
		where	id = @p_id

		--set @pph_total = round(isnull(@p_fee_amount * @pph / 100.00 ,0),0) ;
		--set @ppn_total = round(isnull(@p_fee_amount * @ppn/ 100.00,0),0) ;

		set @val_ppn = round(isnull(@p_fee_amount,0) * (isnull(@ppn,0)/100),0)

		--(+) Ari 2024-01-08 ket : validasi
		if(right(@p_fee_amount,2) <> '00' )  
		begin  
			set @msg = 'The Comma at the end cannot be anything other than 0'  
			raiserror(@msg, 16, -1)  
		end 
		else if(isnull(@fee_amount_before,0) = 0 and isnull(@ppn,0) = 0 and isnull(@pph,0) = 0)  
		begin  
			set @ppn_total = round(isnull(@p_fee_amount * @ppn/ 100.00,0),0);
			set @pph_total = round(isnull(@p_fee_amount * @pph / 100.00,0),0);  
		end 
		else if(isnull(@fee_amount_before,0) <> isnull(@p_fee_amount,0))
		begin
			set @ppn_total = round(isnull(@p_fee_amount * @ppn/ 100.00,0),0) ;
			set @pph_total = round(isnull(@p_fee_amount * @pph / 100.00,0),0);  
		end
		else
		begin  
			if((isnull(@ppn,0) = 0 and isnull(@p_ppn_amount,0) <> 0))
			begin
				set @msg = 'Cannot set PPN amount because PPN PCT = 0'  
				raiserror(@msg, 16, -1)  
			end
			else if(@p_ppn_amount > @p_fee_amount)  
			begin  
				set @msg = 'PPN cannot bigger than Fee Amount ' + convert(nvarchar(50),@p_fee_amount)  
				raiserror(@msg, 16, -1)  
			end
			else if ((@p_ppn_amount <= 0 and isnull(@ppn,0) <> 0))  
			begin  
				set @msg = 'PPN cannot less than and must be greater than 0'  
				raiserror(@msg, 16, -1)  
			end
			else if ((@p_ppn_amount <= 0 and isnull(@ppn,0) <> 0) and (@pph_before <= 0 and isnull(@pph,0) <> 0))  
			begin  
				set @msg = 'PPN & PPH cannot less than and must be greater than 0'  
				raiserror(@msg, 16, -1)  
			end
			else if(@p_ppn_amount > (@val_ppn + 100)) -- (+) Ari ket : kenapa 100 ? request kak sepria   
			begin 
				set @msg = 'PPN cannot bigger than ' + convert(nvarchar(50),(@val_ppn + 100))  
				raiserror(@msg, 16, -1)  
			end  
			else if(@p_ppn_amount < (@val_ppn - 100))  
			begin  
				set @msg = 'PPN cannot less than ' + convert(nvarchar(50),(@val_ppn - 100))  
				raiserror(@msg, 16, -1)  
			end  
			else if(@p_fee_amount <= 0 and isnull(@pph,0) <> 0)  
			begin  
				set @msg = 'PPH cannot less than and must be greater than 0'  
				raiserror(@msg, 16, -1)  
			end    
			else if(right(@p_ppn_amount,2) <> '00' )  
			begin  
				set @msg = 'The Comma at the end cannot be anything other than 0'  
				raiserror(@msg, 16, -1)  
			end 
			else
			begin
				set @ppn_total = @p_ppn_amount
				set @pph_total = round(isnull(@p_fee_amount * @pph / 100.00,0),0) ;
			end
		end 
		--(+) Ari 2024-01-08

		update	sale_detail_fee
		set		sale_detail_id	= @p_sale_detail_id
				,fee_amount		= @p_fee_amount
				,ppn_amount		= @ppn_total
				,pph_amount		= @pph_total
				--
				,mod_date		= @p_mod_date
				,mod_by			= @p_mod_by
				,mod_ip_address = @p_mod_ip_address
		where	id = @p_id ;

		select	@fee_amount		= isnull(sum(fee_amount),0) + isnull(sum(ppn_amount),0) - isnull(sum(pph_amount),0) 
				,@pph_amount	= isnull(sum(pph_amount),0)
				,@ppn_amount	= isnull(sum(ppn_amount),0)
		from dbo.sale_detail_fee
		where sale_detail_id = @p_sale_detail_id

		select	@total_depre		= isnull(ass.total_depre_comm,0)
				,@purchase_price	= isnull(ass.purchase_price,0)
				,@sale_value		= isnull(sd.sell_request_amount,0)
				,@netbook			= isnull(ass.net_book_value_comm,0)
		from dbo.sale_detail_fee sde
		left join dbo.sale_detail sd on (sd.id = sde.sale_detail_id)
		left join dbo.asset ass on (ass.code = sd.asset_code)
		where sde.id = @p_id

		--PPN
		select	@ppn_sold_pct = value
		from	dbo.sys_global_param
		where	code = 'PPNSOLD' ;
		
		update	dbo.sale_detail
		set		total_fee_amount	= @fee_amount
				,total_pph_amount	= @pph_amount
				--,total_ppn_amount	= @ppn_amount
				,total_ppn_amount	= @p_ppn_amount -- (+) Ari 2024-01-08
				,gain_loss			= round(isnull(sold_amount - (sold_amount * @ppn_sold_pct) / (100  + @ppn_sold_pct) - @netbook, 0),0) 
				--,gain_loss		= isnull(total_income,0) - isnull(total_expense,0) - (isnull(sold_amount,0) - isnull(net_book_value,0)) - @fee_amount --@sale_value - (isnull(@purchase_price,0) - isnull(@total_depre,0))
				--,net_receive		= round((sold_amount - (@p_fee_amount + @ppn_total - @pph_total)),0)
				,net_receive		= round((sold_amount - (@p_fee_amount + @p_ppn_amount - @pph_total)),0) -- (+) Ari 2024-01-08
				--
				,mod_date			= @p_mod_date
				,mod_by				= @p_mod_by
				,mod_ip_address		= @p_mod_ip_address
		where	id = @p_sale_detail_id
		
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
			set @msg = N'E;' + dbo.xfn_get_msg_err_generic() + N';' + error_message() ;
		end ;

		raiserror(@msg, 16, -1) ;

		return ;
	end catch ;
end ;
