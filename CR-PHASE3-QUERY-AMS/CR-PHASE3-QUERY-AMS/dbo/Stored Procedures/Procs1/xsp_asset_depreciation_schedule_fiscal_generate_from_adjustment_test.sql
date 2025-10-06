CREATE PROCEDURE dbo.xsp_asset_depreciation_schedule_fiscal_generate_from_adjustment_test
(
	@p_code						nvarchar(50)
	--
	,@p_mod_date				datetime
	,@p_mod_by					nvarchar(15)
	,@p_mod_ip_address			nvarchar(15)
)
as
begin

	DECLARE @msg						NVARCHAR(MAX) 
			,@date						DATETIME
			,@original_price			DECIMAL(18,2)
			,@code						NVARCHAR(50)
			,@os_usefull				INT
			,@usefull					INT
			,@depre_amount				DECIMAL(18,2)
			,@net_book_value			DECIMAL(18,2)
			,@purchase_date				DATE
			,@depre_code				NVARCHAR(50)
			,@counter					INT
			,@method_type				NVARCHAR(50)
			,@residual_value			DECIMAL(18,2)
			,@year						BIGINT
			,@cre_date					DATE
			,@depretiation				INT
			,@end_date_depre			DATE
			,@rate						DECIMAL(18,6)
			,@depre_amount_final		DECIMAL(18,2)
			,@adjustment_date			DATETIME
			,@asset_code				NVARCHAR(50)
			,@new_netbook_value_fiscal	DECIMAL(18, 2)
			,@total_adjustment			DECIMAL(18, 2)
			,@new_original_price		DECIMAL(18, 2)
			,@accum_depre_amount		DECIMAL(18, 2) = 0
			,@base_amount				DECIMAL(18,2)
			,@flag						INT = 0
			,@adjust_type				NVARCHAR(50)
			,@depre_period_fiscal		NVARCHAR(50)
			,@depre_id					BIGINT
			,@count_data				INT
			,@sisa						DECIMAL(18,2)
			,@sisa_bulan				INT
			,@count_data_depre			INT
            ,@selisih					int

	begin try
		
		SELECT	@original_price				= ( ass.purchase_price + adj.total_adjustment )--adj.new_netbook_value_fiscal
				,@new_netbook_value_fiscal	= ass.net_book_value_fiscal + adj.total_adjustment--adj.new_netbook_value_fiscal
				,@total_adjustment			= ISNULL(adj.total_adjustment, 0)
				,@adjustment_date			= adj.date--adj.new_purchase_date
				,@purchase_date				= adj.new_purchase_date
				,@depre_code				= depre_category_comm_code
				,@new_original_price		= ISNULL(ass.original_price, 0) + ISNULL(adj.total_adjustment, 0)
				,@os_usefull				= mdcf.usefull * 12 
				,@method_type				= mdcf.method_type
				,@adjust_type				= adj.adjustment_type
				,@asset_code				= adj.asset_code
				,@rate						= mdcf.rate
				,@depre_period_fiscal		= ass.depre_period_fiscal
				,@residual_value			= mdcf.residual_value--ass.residual_value
				,@base_amount				= adj.new_netbook_value_fiscal
				,@end_date_depre			= EOMONTH(DATEADD(MONTH,mdcf.usefull*12,ass.purchase_date))
		FROM	 dbo.asset ass
				INNER JOIN dbo.adjustment adj ON (ass.code = adj.asset_code)
				INNER JOIN dbo.master_depre_category_fiscal mdcf ON (mdcf.code = ass.depre_category_fiscal_code AND mdcf.company_code = ass.company_code)
		WHERE	 adj.code = @p_code


		if @adjust_type = 'REVAL'
		begin
			select	@usefull = count(1)
			from	dbo.asset_depreciation_schedule_fiscal
			where	asset_code = @asset_code
			--and		transaction_code = ''
			and		depreciation_date >= @adjustment_date

			--cek jika data fiscal tidak sama dengan settingan dimaster
			select @count_data_depre = count(1) 
			from dbo.asset_depreciation_schedule_fiscal 
			where asset_code = @asset_code
			
			if(@count_data_depre <> @os_usefull)
			begin
				set @selisih = @os_usefull - @count_data_depre
				set @usefull = @usefull + @selisih
            end

			--ambil tanggal depre yang belom depre terkahir kapan
			select @purchase_date = min(depreciation_date)
			from dbo.asset_depreciation_schedule_fiscal
			where asset_code = @asset_code
			and convert(char(6),depreciation_date,112) > isnull(@depre_period_fiscal,convert(char(6),@purchase_date,112))
			--and concat(year(depreciation_date),'0', month(depreciation_date)) > @depre_period_fiscal

			--ambil total data yang sudah di depre
			--select @count_data = count(id) 
			--from dbo.asset_depreciation_schedule_fiscal
			--where asset_code = @asset_code
			--and depreciation_date < @purchase_date

			--set sisa bulan depre
			--set @usefull = @usefull - @count_data

			--select id data sebelum tanggal ke adjust
			select @depre_id = id 
					,@accum_depre_amount = accum_depre_amount
			from dbo.asset_depreciation_schedule_fiscal
			where asset_code = @asset_code
			and depreciation_date < @purchase_date

			--update NBV data sebelum diadjust dengan new NBV
			update	dbo.asset_depreciation_schedule_fiscal
			set		net_book_value = @new_netbook_value_fiscal
			where	id = @depre_id

			delete	dbo.asset_depreciation_schedule_fiscal
			where	asset_code = @asset_code
			and		transaction_code = ''
			and		depreciation_date >= @purchase_date
		end
		else
		begin
		    set @usefull = @os_usefull

			delete	dbo.asset_depreciation_schedule_fiscal
			where	asset_code = @asset_code		    
		end

		set @counter = 1 ;
		set @original_price = @original_price


		if (@method_type = 'SL' and	@usefull > 0)
		begin
			set @depre_amount = round(isnull(((@original_price - @residual_value) / (@usefull)), 0),0) ;
			set @net_book_value = @original_price

			while (@counter <= @usefull)
			begin
				set @date = eomonth(dateadd(month, @counter - 1, @purchase_date)) ;
				set @net_book_value = isnull(@net_book_value, 0) - isnull(@depre_amount, 0) ;
				
				--jika udah di data terakhir
				if (@counter = @usefull)
				begin
					--jika hasil terkahir tidak angka bulat
					-- set sisa = nbv - residual value
					set @sisa = @net_book_value - @residual_value
					-- set depre = depre + sisa dan set
					set @depre_amount = round(@depre_amount + @sisa,0)
					set @net_book_value = @residual_value
				end ;

				--set accum depre amount
				set @accum_depre_amount = @accum_depre_amount+ @depre_amount

				--insert ke asset depre commercial
				exec dbo.xsp_asset_depreciation_schedule_fiscal_insert @p_id					 = 0
																		,@p_asset_code			 = @asset_code
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
			end ;
		end ;
		else if (@method_type = 'RB' and @usefull > 0)
		begin

			--set harga NBV dikurang residual velue
			set @depre_amount = ROUND(((@new_netbook_value_fiscal - @residual_value) * @rate) / 1200.00,0) ;
			set @year = year(@purchase_date) ;

			while (@counter <= @usefull)
			begin
				set @date = eomonth(dateadd(month, @counter - 1, @purchase_date)) ;

				if @year <> year(@date)
				begin
					set @depre_amount = ROUND(((@new_netbook_value_fiscal - @residual_value) * @rate) / 1200.00,0) ;
				end 

				if year(@date) = year(@end_date_depre)
				begin
					if @flag = 0
					begin
						set @sisa_bulan = datediff(m,@date,@end_date_depre)
						set @depre_amount = ROUND(((@new_netbook_value_fiscal - @residual_value) / @sisa_bulan),0)
					end
				
					set @flag = 1 ;
				end ;

				set @new_netbook_value_fiscal = isnull(@new_netbook_value_fiscal, 0) - isnull(@depre_amount, 0) ;
				
				if (@counter = @usefull)
				begin
					--jika hasil terkahir tidak angka bulat
					-- set sisa = nbv - residual value
					set @sisa = @new_netbook_value_fiscal - @residual_value
					-- set depre = depre + sisa dan set
					set @depre_amount = ROUND(@depre_amount + @sisa,0)
					set @new_netbook_value_fiscal = @residual_value
				end ;

				set @accum_depre_amount = @accum_depre_amount + @depre_amount

				exec dbo.xsp_asset_depreciation_schedule_fiscal_insert @p_id					 = 0
																		,@p_asset_code			 = @asset_code
																		,@p_depreciation_date	 = @date
																		,@p_original_price		 = @original_price
																		,@p_depreciation_amount	 = @depre_amount
																		,@p_accum_depre_amount	 = @accum_depre_amount
																		,@p_net_book_value		 = @new_netbook_value_fiscal
																		,@p_transaction_code	 = ''
																		,@p_cre_date			 = @p_mod_date
																		,@p_cre_by				 = @p_mod_by
																		,@p_cre_ip_address		 = @p_mod_ip_address
																		,@p_mod_date			 = @p_mod_date
																		,@p_mod_by				 = @p_mod_by
																		,@p_mod_ip_address		 = @p_mod_ip_address


				set @counter = @counter + 1 ;
				set @year = year(@date) ;
			end ;
		end ;
		
		--if @adjust_type = 'REVAL'
		--begin
		--	update	dbo.asset
		--	set		net_book_value_fiscal		= isnull(@new_netbook_value_fiscal, 0)
		--			--
		--			,mod_date					= @p_mod_date
		--			,mod_by						= @p_mod_by
		--			,mod_ip_address				= @p_mod_ip_address
		--	where	code						= @asset_code ;
		--end
		--else
		--begin
		--    update	dbo.asset
		--	set		net_book_value_fiscal		= @new_original_price
		--			--
		--			,mod_date					= @p_mod_date
		--			,mod_by						= @p_mod_by
		--			,mod_ip_address				= @p_mod_ip_address
		--	where	code						= @asset_code ;
		--end


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
