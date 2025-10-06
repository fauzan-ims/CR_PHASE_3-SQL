/*
	created : Nia, 12 Juli 2021
*/
CREATE PROCEDURE dbo.xsp_tax_history_calculate
(
	@p_trx_reff_no			nvarchar(50) --nomor referensi
	,@p_trx_amount			decimal(18, 2)
	,@p_trx_date			datetime
	,@p_reff_no				nvarchar(50) --entity no di isi jika corporate/personal
	,@p_tax_type			nvarchar(10) --type npwp
	,@p_tax_file_no			nvarchar(50) --nomor npwp
	,@p_cre_by				nvarchar(15)
	,@p_cre_date			datetime
	,@p_cre_ip_address		nvarchar(15)
	,@p_output_amount		decimal(18, 2) output
	,@p_output_percent		decimal(9, 6) output -- (+) Fadlan 05/13/2022 : 02:50 pm  Notes :  untuk mendapatkan avg percent
)
as
begin	
	declare @tax_file_no nvarchar(50);

	if @p_tax_type in ('P21', 'N21')
	begin
		set @p_tax_type = 'PERSONAL'
	end
	else if @p_tax_type in ('P23', 'N23')
	begin
		set @p_tax_type = 'CORPORATE'
	end
	else if @p_tax_type in ('N24')
	begin
		set @p_tax_type = 'COOPERATIVE'
	end

	if @p_tax_type not in ('PERSONAL', 'CORPORATE', 'COOPERATIVE')
	begin
		set @p_output_amount = 0
	end
	else
	begin
		declare	@annual_amount		decimal(18, 2)= 0
				,@tax_id			int
				,@tax_percent		decimal(9, 6)
				,@temp_tax_percent	decimal(9, 6) = 0
				,@temp_index_pct	int = 0
				,@amount_range		decimal(18, 2) = 0
				,@effective_date	datetime
				--
				,@amount			decimal(18,2)
				,@from_amount		decimal(18,2)
				,@to_amount			decimal(18,2)
				,@sisa				decimal(18,2)= 0
				,@trx_amount		decimal(18,2) = @p_trx_amount
				,@output_amount		decimal(18,2) = 0
		
		---jika tax_file_no nya kosong maka di group berdasarkan nomor entity
		if (@p_tax_file_no is null or @p_tax_file_no = '' ) --or @p_tax_type = 'PERSONAL' or @p_tax_type = 'CORPORATE' or @p_tax_type = 'COOPERATIVE')
		BEGIN	
			select	@annual_amount				= isnull(sum(payment_amount),0) + 1 
			from	dbo.withholding_tax_history
			where	datepart(year, payment_date) = datepart(year, dbo.xfn_get_system_date())
			and		tax_payer_reff_code			= @p_reff_no --nomor entity
		end
		else
        BEGIN		
        	-- get sum annual amount
			select	@annual_amount				= isnull(sum(payment_amount),0)
			from	dbo.withholding_tax_history
			where	datepart(year, payment_date) = datepart(year, dbo.xfn_get_system_date())
			and		tax_file_no					= @p_tax_file_no
													
        end

		select	top 1 @effective_date = mtd.effective_date
		from	dbo.master_tax_detail mtd
				inner join dbo.master_tax mt on (mt.code = mtd.tax_code)
		where	cast(effective_date as date)	<= cast(@p_cre_date as date)
		and		is_active	= '1'
		order by mtd.effective_date desc

		--hitung nilai amount yang sudah dan terjadi kedepan
		set	@amount  = @p_trx_amount + @annual_amount

		---cursor untuk menghitung pajak
		declare	c_pajak cursor fast_forward for
		select	case(isnull(@p_tax_file_no,''))
					when '' then mtd.without_tax_number_pct 
					else mtd.with_tax_number_pct
				end
                ,mtd.from_value_amount
				,mtd.to_value_amount
		from	dbo.master_tax_detail mtd
				inner join dbo.master_tax mt on (mt.code = mtd.tax_code)
		where	cast(effective_date as date)	= cast(@effective_date as date)
		and		is_active	= '1'
		and     mt.tax_file_type = @p_tax_type
		order by mtd.from_value_amount asc

		open	c_pajak
		fetch	c_pajak
		into	@tax_percent
				,@from_amount
				,@to_amount
		
		while	@@fetch_status = 0
		begin
			if (@annual_amount between @from_amount and @to_amount)
			begin
				if (@amount <= @to_amount)
				begin
					set	@amount_range  = @p_trx_amount * (@tax_percent/100)
					set @amount_range  = round(@amount_range,0) -- (+) 26/02/2019 11:09:29 AM Hari -	rounding nilai tax
					set	@output_amount = @output_amount + @amount_range
					set	@temp_tax_percent = @temp_tax_percent + @tax_percent -- (+) Fadlan 05/13/2022 : 02:48 pm  Notes :  untuk mendapatkan avg percent
					set	@temp_index_pct = @temp_index_pct + 1 -- (+) Fadlan 05/13/2022 : 02:48 pm  Notes :  untuk mendapatkan avg percent
					--break
				end
                else
                begin             
					--ambil sisa untuk rage tersebut
					set	@sisa			= @to_amount - (@annual_amount)
					set	@amount_range	= @sisa * (@tax_percent/100)
					set @amount_range	= round(@amount_range,0) -- (+) 26/02/2019 11:09:29 AM Hari -	rounding nilai tax
					set @output_amount	= @output_amount + @amount_range
					set	@annual_amount	= @annual_amount + @sisa + 1
					set	@p_trx_amount	= @p_trx_amount - @sisa
					set	@temp_tax_percent = @temp_tax_percent + @tax_percent -- (+) Fadlan 05/13/2022 : 02:49 pm  Notes :  untuk mendapatkan avg percent
					set	@temp_index_pct = @temp_index_pct + 1 -- (+) Fadlan 05/13/2022 : 02:49 pm  Notes :  untuk mendapatkan avg percent
                end
			end

			fetch	c_pajak
			into	@tax_percent
					,@from_amount
					,@to_amount
		end
		close		c_pajak
		deallocate	c_pajak

		set	@p_output_amount = @output_amount
		set @p_output_percent = @temp_tax_percent / @temp_index_pct -- (+) Fadlan 05/13/2022 : 02:49 pm  Notes :  untuk mendapatkan avg percent
			
	end
	
end	

