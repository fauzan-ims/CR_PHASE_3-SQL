CREATE PROCEDURE dbo.xsp_asset_depreciation_schedule_commercial_generate_backup
(
	@p_code						nvarchar(50)
	--
	,@p_mod_date				datetime
	,@p_mod_by					nvarchar(15)
	,@p_mod_ip_address			nvarchar(15)
)
as
begin
	declare @msg					nvarchar(max) 
			,@date					datetime
			,@original_price		decimal(18,2)
			,@code					nvarchar(50)
			,@usefull				int
			,@depre_amount			decimal(18,2)
			,@accum_depre_amount	decimal(18, 2) = 0
			,@net_book_value		decimal(18,2)
			,@purchase_date			date
			,@depre_code			nvarchar(50)
			,@counter				int
			,@depre_amount_final	decimal(18,2)
			,@residual_value		decimal(18,2)
			,@rate					decimal(9,6)
			,@method_type			nvarchar(10)
			,@year					bigint
			,@depretiation			int
			,@end_date_depre		datetime
			,@base_amount			decimal(18,2)
			,@flag					int = 0;

	begin try
		
		delete	dbo.asset_depreciation_schedule_commercial
		where	asset_code = @p_code
		and		transaction_code = ''

		select	@original_price		= ass.purchase_price --original_price -- Arga 06-Oct-2022 ket : for WOM (-/+)
				,@purchase_date		= purchase_date
				,@depre_code		= depre_category_comm_code
				,@usefull			= mdcc.usefull * 12 
				,@residual_value	= ass.residual_value
				,@rate				= mdcc.rate
				,@method_type		= mdcc.method_type
				,@base_amount		= ass.purchase_price
				,@end_date_depre	= eomonth(dateadd(month,mdcc.usefull*12,ass.purchase_date))
		from	 dbo.XXX_ASSET_20241001 ass
				left join dbo.master_depre_category_commercial mdcc on (mdcc.code = ass.depre_category_comm_code and ass.company_code = mdcc.company_code)
		where	 ass.code = @p_code

		update	dbo.asset
		set		net_book_value_comm			= @original_price
				--
				,mod_date					= @p_mod_date
				,mod_by						= @p_mod_by
				,mod_ip_address				= @p_mod_ip_address
		where	code						= @p_code ;

		set @counter = 1 ;
		--set @original_price = @original_price - @residual_value
		set @original_price = @original_price
		
		if(@residual_value <> 0)
		begin
			if (@method_type = 'SL' and @usefull > 0)
			begin
				set @depre_amount = round(isnull(((@original_price - @residual_value) / (@usefull)),0),0)
				set @net_book_value = @original_price - @depre_amount
				
				while (@counter <= @usefull)
				begin
					set @date = eomonth(dateadd(month, @counter-1, @purchase_date))

					if (@counter = 1)
					begin
						set @net_book_value = @net_book_value
					end
					else
					begin
						set @net_book_value = @net_book_value - @depre_amount
					end

					if(@counter = (@usefull-1))
					begin
						set @depre_amount_final = @net_book_value
					end

					if (@counter = @usefull)
					begin
						set @depre_amount = round((@original_price - @residual_value) - @accum_depre_amount ,0)
						set @net_book_value = @depre_amount_final - @depre_amount
					end

					set @accum_depre_amount += @depre_amount
			
					exec dbo.xsp_asset_depreciation_schedule_commercial_insert @p_id					 = 0
																				,@p_asset_code			 = @p_code
																				,@p_depreciation_date	 = @date
																				,@p_original_price		 = @original_price
																				,@p_depreciation_amount	 = @depre_amount
																				,@p_accum_depre_amount	 = @accum_depre_amount
																				,@p_net_book_value		 = @net_book_value
																				,@p_transaction_code	 = ''
																				,@p_cre_date			 = @p_mod_date
																				,@p_cre_by				 = @p_mod_by
																				,@p_cre_ip_address		 = @p_mod_ip_address
																				,@p_mod_date			 = @p_mod_date
																				,@p_mod_by				 = @p_mod_by
																				,@p_mod_ip_address		 = @p_mod_ip_address
			
					set @counter = @counter + 1 ;
				end
		
			end
			else if(@method_type = 'RB' and @usefull > 0)
			begin
			set @original_price = ((@original_price - @residual_value) * @rate) / 100.00
			
			set @year = year(@purchase_date)

			while (@counter <= @usefull)
			begin
				
				set @date = eomonth(dateadd(month, @counter-1, @purchase_date))
								
				if @year = year(@date)
				begin
				    set @original_price = @original_price
					set @depre_amount = round(isnull((@original_price / 12),0), 0)
				end
				else
				begin
				    set @original_price = ((@net_book_value - @residual_value) * @rate) / 100.00
					set @depre_amount = round(isnull((@original_price / 12),0), 0)
				end
				
				if year(@date) = year(@end_date_depre)
				begin
					if @flag = 0
					begin
						set @depretiation = datediff(month, @date, @end_date_depre)
						set @original_price = @net_book_value - @residual_value
						set @depre_amount = round(isnull((@original_price / @depretiation),0), 0)
						set @depre_amount_final = @depre_amount
					end

					--if @flag = 1
					--	set @depre_amount = @depre_amount_final

					--set @flag = 1
				end
				
				if (@counter = 1)
				begin
					set @net_book_value = @base_amount - @depre_amount
				end
				else
				begin
					set @net_book_value -= @depre_amount
				end

				if(@counter = (@usefull-1))
				begin
					set @depre_amount_final = @net_book_value
				end

				if (@counter = @usefull)
				begin
					set @depre_amount = @depre_amount_final
					--set @net_book_value = @depre_amount - @depre_amount
				end

				set @accum_depre_amount += @depre_amount

				exec dbo.xsp_asset_depreciation_schedule_commercial_insert @p_id					 = 0
																			,@p_asset_code			 = @p_code
																			,@p_depreciation_date	 = @date
																			,@p_original_price		 = @original_price
																			,@p_depreciation_amount	 = @depre_amount
																			,@p_accum_depre_amount	 = @accum_depre_amount
																			,@p_net_book_value		 = @net_book_value
																			,@p_transaction_code	 = ''
																			,@p_cre_date			 = @p_mod_date
																			,@p_cre_by				 = @p_mod_by
																			,@p_cre_ip_address		 = @p_mod_ip_address
																			,@p_mod_date			 = @p_mod_date
																			,@p_mod_by				 = @p_mod_by
																			,@p_mod_ip_address		 = @p_mod_ip_address
				
				set @counter = @counter + 1 ;
				set @year = year(@date)

			end
			end
		end
		else
		begin
			if (@method_type = 'SL' and @usefull > 0)
			begin
				set @depre_amount = round(isnull(((@original_price - @residual_value) / (@usefull)),0),0)
				set @net_book_value = @original_price - @depre_amount
				
				while (@counter <= @usefull)
				begin
					set @date = eomonth(dateadd(month, @counter-1, @purchase_date))

					if (@counter = 1)
					begin
						set @net_book_value = @net_book_value
					end
					else
					begin
						set @net_book_value = @net_book_value - @depre_amount
					end

					if(@counter = (@usefull-1))
					begin
						set @depre_amount_final = @net_book_value
					end

					if (@counter = @usefull)
					begin
						set @depre_amount =  @depre_amount_final
						set @net_book_value = @depre_amount - @depre_amount
					end

					set @accum_depre_amount += @depre_amount
				
					exec dbo.xsp_asset_depreciation_schedule_commercial_insert @p_id					 = 0
																				,@p_asset_code			 = @p_code
																				,@p_depreciation_date	 = @date
																				,@p_original_price		 = @original_price
																				,@p_depreciation_amount	 = @depre_amount
																				,@p_accum_depre_amount	 = @accum_depre_amount
																				,@p_net_book_value		 = @net_book_value
																				,@p_transaction_code	 = ''
																				,@p_cre_date			 = @p_mod_date
																				,@p_cre_by				 = @p_mod_by
																				,@p_cre_ip_address		 = @p_mod_ip_address
																				,@p_mod_date			 = @p_mod_date
																				,@p_mod_by				 = @p_mod_by
																				,@p_mod_ip_address		 = @p_mod_ip_address
				
					set @counter = @counter + 1 ;
				end
		
			end
			else if(@method_type = 'RB' and @usefull > 0)
			begin
				set @original_price = ((@original_price - @residual_value) * @rate) / 100.00
				
				set @year = year(@purchase_date)

				while (@counter <= @usefull)
				begin
					
					set @date = eomonth(dateadd(month, @counter-1, @purchase_date))
									
					if @year = year(@date)
					begin
					    set @original_price = @original_price
						set @depre_amount = round(isnull((@original_price / 12),0), 0)
					end
					else
					begin
					    set @original_price = ((@net_book_value - @residual_value) * @rate) / 100.00
						set @depre_amount = round(isnull((@original_price / 12),0), 0)
					end
					
					if year(@date) = year(@end_date_depre)
					begin
						if @flag = 0
						begin
							set @depretiation = datediff(month, @date, @end_date_depre)
							set @original_price = @net_book_value - @residual_value
							set @depre_amount = round(isnull((@original_price / @depretiation),0), 0)
							set @depre_amount_final = @depre_amount
						end

						--if @flag = 1
						--	set @depre_amount = @depre_amount_final

						--set @flag = 1
					end
					
					if (@counter = 1)
					begin
						set @net_book_value = @base_amount - @depre_amount
					end
					else
					begin
						set @net_book_value -= @depre_amount
					end

					if(@counter = (@usefull-1))
					begin
						set @depre_amount_final = @net_book_value
					end

					if (@counter = @usefull)
					begin
						set @depre_amount = @depre_amount_final
						--set @net_book_value = @depre_amount - @depre_amount
					end

					set @accum_depre_amount += @depre_amount

					exec dbo.xsp_asset_depreciation_schedule_commercial_insert @p_id					 = 0
																				,@p_asset_code			 = @p_code
																				,@p_depreciation_date	 = @date
																				,@p_original_price		 = @original_price
																				,@p_depreciation_amount	 = @depre_amount
																				,@p_accum_depre_amount	 = @accum_depre_amount
																				,@p_net_book_value		 = @net_book_value
																				,@p_transaction_code	 = ''
																				,@p_cre_date			 = @p_mod_date
																				,@p_cre_by				 = @p_mod_by
																				,@p_cre_ip_address		 = @p_mod_ip_address
																				,@p_mod_date			 = @p_mod_date
																				,@p_mod_by				 = @p_mod_by
																				,@p_mod_ip_address		 = @p_mod_ip_address
					
					set @counter = @counter + 1 ;
					set @year = year(@date)

				end
			end
		end

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
