
-- Stored Procedure

-- ini dari prod
CREATE PROCEDURE [dbo].[xsp_asset_depreciation_schedule_commercial_generate_from_adjustment]
(
	@p_code			   nvarchar(50)
	,@p_asset_code	   nvarchar(50)
	--
	,@p_mod_date	   datetime
	,@p_mod_by		   nvarchar(15)
	,@p_mod_ip_address nvarchar(15)
)
as
begin
	declare @msg						nvarchar(max)
			,@date						datetime
			,@original_price			decimal(18, 2)
			,@sum_depre_amount			decimal(18, 2)
			,@new_original_price		decimal(18, 2)
			,@code						nvarchar(50)
			,@os_usefull				int
			,@depre_amount				decimal(18, 2)
			,@accum_depre_amount		bigint--decimal(18, 2) = 0
			,@net_book_value			decimal(18, 2)
			,@purchase_date				date
			,@depre_code				nvarchar(50)
			,@due_usefull				int
			,@stop						int			= 0
			,@depre_amount_final		decimal(18, 2)
			,@total_adjustment			decimal(18, 2)
			,@new_netbook_value_comm	decimal(18, 2)
			,@adjustment_date			datetime
			,@adjustment_date_final		datetime
			,@usefull					int
			,@rate						decimal(9, 6)
			,@method_type				nvarchar(10)
			,@year						bigint
			,@depretiation				int
			,@end_date_depre			datetime
			,@base_amount				decimal(18, 2)
			,@flag						int			= 0
			,@counter					int
			,@residual_value			decimal(18, 2)
			,@adjust_type				nvarchar(50)
			,@depre_id					bigint
			,@sisa						decimal(18,2)
			,@accum_depre				decimal(18,2)
			,@sisa_bulan				int
            ,@asset_purchase_date		datetime
            ,@is_from_proc				nvarchar(1)
			,@depre_amount_last			decimal(18,2)
			,@new_netbook_value_last	decimal(18,2)
			,@original_price_last		decimal(18,2)
			,@depre_amount1				decimal(18,2)
			,@net_book_value1			decimal(18,2)
			,@new_netbook_value_comm1	decimal(18,2)
			,@date1						datetime
			,@jumlah_telah_lewat		int

	begin try

		select	@original_price			 = (ass.purchase_price + adj.total_adjustment)--adj.new_netbook_value_comm
				,@new_netbook_value_comm = ass.net_book_value_comm + adj.total_adjustment --adj.new_netbook_value_comm
				,@total_adjustment		 = isnull(adj.total_adjustment, 0)
				,@adjustment_date		 = adj.new_purchase_date
				,@purchase_date			 = adj.new_purchase_date
				,@depre_code			 = depre_category_comm_code
				,@new_original_price	 = isnull(ass.original_price, 0) + isnull(adj.total_adjustment, 0)
				,@os_usefull			 = mdcc.usefull * 12
				,@method_type			 = mdcc.method_type
				,@adjust_type			 = adj.adjustment_type
				,@residual_value		 = cast((100 - (mdcc.usefull * mdcc.rate)) / 100 * (isnull(ass.purchase_price,0) + isnull(adj.total_adjustment,0)) as bigint) --ass.residual_value
				,@end_date_depre		 = eomonth(dateadd(month,mdcc.usefull*12,ass.purchase_date))
				,@asset_purchase_date	 = ass.purchase_date
				,@is_from_proc			= adj.is_from_proc
		from	dbo.asset									   ass
				inner join dbo.adjustment					   adj on (ass.code					 = adj.asset_code)
				left join dbo.master_depre_category_commercial mdcc on (
																		   mdcc.code			 = ass.depre_category_comm_code
																		   and mdcc.company_code = ass.company_code
																	   )
		where	adj.code = @p_code ;


		if @adjust_type = 'REVAL'
		begin
			--ambil data total bulan
			select	@usefull = count(1)
			from	dbo.asset_depreciation_schedule_commercial
			where	asset_code			  = @p_asset_code
					and transaction_code  = ''
					and convert(char(6),depreciation_date,112) >= convert(char(6),@adjustment_date,112)

			--ambil tanggal depre yang belom depre terkahir kapan
			select	@purchase_date = min(depreciation_date)
			from	dbo.asset_depreciation_schedule_commercial
			where	asset_code			 = @p_asset_code
					and transaction_code = ''
					and convert(char(6),depreciation_date,112) >= convert(char(6),@adjustment_date,112)

			--jika belom pernah ke depre
			set @purchase_date = isnull(@purchase_date, @asset_purchase_date)

			--select id dan nilai accum dari data sebelum tanggal ke adjust
			select @depre_id					= isnull(id,0)
					,@accum_depre_amount		= isnull(accum_depre_amount,0)
					,@depre_amount_last			= isnull(depreciation_amount,0)
					,@new_netbook_value_last	= isnull(net_book_value,0)
					,@original_price_last		= isnull(original_price,0)
			from	dbo.asset_depreciation_schedule_commercial
			where	asset_code = @p_asset_code
			and		cast(depreciation_date as date) < cast(@purchase_date as date)

			if(isnull(@is_from_proc,0) = '0')
			begin

			    --update nbv data sebelum diadjust dengan new nbv
				update	dbo.asset_depreciation_schedule_commercial
				set		net_book_value = @new_netbook_value_comm
				where	id = @depre_id
			end
            else
            begin
                	select	@jumlah_telah_lewat = count(1)
					from	dbo.asset_depreciation_schedule_commercial
					where	asset_code = @p_asset_code
					and		depreciation_date < dbo.fn_get_system_date()
            end

			--delete data yang gk didepre
			delete	dbo.asset_depreciation_schedule_commercial
			where	asset_code			  = @p_asset_code
					and transaction_code  = ''
					and convert(char(6),depreciation_date,112) >= convert(char(6),@adjustment_date,112)

		end ;
		else
		begin
			set @usefull = @os_usefull ;

			delete	dbo.asset_depreciation_schedule_commercial
			where	asset_code = @p_asset_code ;
		end ;

		set @counter = 1 ;
		set @original_price = isnull(@original_price, 0);

	SELECT MONTH(@adjustment_date), month(dbo.fn_get_system_date()),@is_from_proc

	SELECT dbo.fn_get_system_date()

		-- cr priority sepria 28082025:jika adjustment terjadi dari final yang sama, maka selisih dari grn date ke tanggal sistem di masukin 1 row sendiri.
		if(isnull(@is_from_proc,0) = '1' and month(@adjustment_date) <> month(dbo.fn_get_system_date()))
		begin

			set @original_price_last = isnull(@original_price_last,@original_price)

			if isnull(@jumlah_telah_lewat,0) = 0 set @jumlah_telah_lewat = 1

			set @depre_amount1 = (round(isnull(((@new_netbook_value_comm - @residual_value) / (@os_usefull)), 0),0) - isnull(@depre_amount_last,0)) * @jumlah_telah_lewat
			set @date1 = eomonth(dbo.fn_get_system_date());
			set @accum_depre_amount = isnull(@accum_depre_amount,0) + @depre_amount1
			set @net_book_value1 = @original_price_last - @accum_depre_amount

			exec dbo.xsp_asset_depreciation_schedule_commercial_insert @p_id					 = 0
																		,@p_asset_code			 = @p_asset_code
																		,@p_depreciation_date	 = @date1
																		,@p_original_price		 = @original_price_last
																		,@p_depreciation_amount	 = @depre_amount1
																		,@p_accum_depre_amount	 = @accum_depre_amount
																		,@p_net_book_value		 = @net_book_value1
																		,@p_transaction_code	 = ''
																		,@p_cre_date			 = @p_mod_date
																		,@p_cre_by				 = @p_mod_by
																		,@p_cre_ip_address		 = @p_mod_ip_address
																		,@p_mod_date			 = @p_mod_date
																		,@p_mod_by				 = @p_mod_by
																		,@p_mod_ip_address		 = @p_mod_ip_address

			if (@method_type = 'SL' and	@usefull > 0)
			begin

				set @depre_amount = round(isnull(((@new_netbook_value_comm - @residual_value) / (@os_usefull)), 0),0) ;
				set @net_book_value = @original_price - @accum_depre_amount

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
					set @accum_depre_amount = isnull(@accum_depre_amount,0) + @depre_amount

					--insert ke asset depre commercial
					EXEC dbo.xsp_asset_depreciation_schedule_commercial_insert @p_id					 = 0
																				,@p_asset_code			 = @p_asset_code
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
				--set harga nbv dikurang residual velue
				set @depre_amount = round(((@new_netbook_value_comm - @residual_value) * @rate) / 1200.00,0) ;
				set @year = year(@purchase_date) ;

				while (@counter <= @usefull)
				begin
					set @date = eomonth(dateadd(month, @counter - 1, @purchase_date)) ;

					if @year <> year(@date)
					begin
						set @depre_amount = ((@new_netbook_value_comm - @residual_value) * @rate) / 1200.00 ;
					end ;

					if year(@date) = year(@end_date_depre)
					begin
						if @flag = 0
						begin
							set @sisa_bulan = datediff(m,@date,@end_date_depre)
							set @depre_amount = round((@new_netbook_value_comm - @residual_value) / @sisa_bulan,0)
						end

						set @flag = 1 ;
					end ;

					set @new_netbook_value_comm = isnull(@new_netbook_value_comm, 0) - isnull(@depre_amount, 0) ;

					if (@counter = @usefull)
					begin
						--jika hasil terkahir tidak angka bulat
						-- set sisa = nbv - residual value
						set @sisa = @new_netbook_value_comm - @residual_value
						-- set depre = depre + sisa dan set
						set @depre_amount = round(@depre_amount + @sisa,0)
						set @new_netbook_value_comm = @residual_value
					end ;

					set @accum_depre_amount = @accum_depre_amount + @depre_amount

					exec dbo.xsp_asset_depreciation_schedule_commercial_insert @p_id					 = 0
																				,@p_asset_code			 = @p_code
																				,@p_depreciation_date	 = @date
																				,@p_original_price		 = @original_price
																				,@p_depreciation_amount	 = @depre_amount
																				,@p_accum_depre_amount	 = @accum_depre_amount
																				,@p_net_book_value		 = @new_netbook_value_comm
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
		end
		else
		begin

			if (@method_type = 'SL' and	@usefull > 0)
			begin


				set @depre_amount = round(isnull(((@new_netbook_value_comm - @residual_value) / (@usefull)), 0),0) ;
				set @net_book_value = @new_netbook_value_comm

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
					set @accum_depre_amount = isnull(@accum_depre_amount,0) + @depre_amount

					--insert ke asset depre commercial
					EXEC dbo.xsp_asset_depreciation_schedule_commercial_insert @p_id					 = 0
																				,@p_asset_code			 = @p_asset_code
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
				set @depre_amount = ROUND(((@new_netbook_value_comm - @residual_value) * @rate) / 1200.00,0) ;
				set @year = year(@purchase_date) ;

				while (@counter <= @usefull)
				begin
					set @date = eomonth(dateadd(month, @counter - 1, @purchase_date)) ;

					if @year <> year(@date)
					begin
						set @depre_amount = ((@new_netbook_value_comm - @residual_value) * @rate) / 1200.00 ;
					end ;

					if year(@date) = year(@end_date_depre)
					begin
						if @flag = 0
						begin
							set @sisa_bulan = datediff(m,@date,@end_date_depre)

							SELECT @sisa_bulan

							set @depre_amount = ROUND((@new_netbook_value_comm - @residual_value) / @sisa_bulan,0)
						end

						set @flag = 1 ;
					end ;

					set @new_netbook_value_comm = isnull(@new_netbook_value_comm, 0) - isnull(@depre_amount, 0) ;

					if (@counter = @usefull)
					begin
						--jika hasil terkahir tidak angka bulat
						-- set sisa = nbv - residual value
						set @sisa = @new_netbook_value_comm - @residual_value
						-- set depre = depre + sisa dan set
						set @depre_amount = ROUND(@depre_amount + @sisa,0)
						set @new_netbook_value_comm = @residual_value
					end ;

					set @accum_depre_amount = @accum_depre_amount + @depre_amount

					exec dbo.xsp_asset_depreciation_schedule_commercial_insert @p_id					 = 0
																				,@p_asset_code			 = @p_code
																				,@p_depreciation_date	 = @date
																				,@p_original_price		 = @original_price
																				,@p_depreciation_amount	 = @depre_amount
																				,@p_accum_depre_amount	 = @accum_depre_amount
																				,@p_net_book_value		 = @new_netbook_value_comm
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
		end	


		--if @adjust_type = 'REVAL'
		--begin
		--	update	dbo.asset
		--	set		net_book_value_comm			= isnull(@new_netbook_value_comm, 0)
		--			,purchase_price				= @original_price --@new_netbook_value_comm --isnull(original_price, 0) + isnull(@total_adjustment, 0)
		--			--
		--			,mod_date					= @p_mod_date
		--			,mod_by						= @p_mod_by
		--			,mod_ip_address				= @p_mod_ip_address
		--	where	code						= @p_asset_code ;
		--end
		--else
		--begin
		--	update	dbo.asset
		--	set		net_book_value_comm			= isnull(@new_netbook_value_comm, 0)
		--			,total_depre_comm			= 0
		--			,purchase_price				= @new_netbook_value_comm --isnull(original_price, 0) + isnull(@total_adjustment, 0)
		--			--
		--			,mod_date					= @p_mod_date
		--			,mod_by						= @p_mod_by
		--			,mod_ip_address				= @p_mod_ip_address
		--	where	code						= @p_asset_code ;
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
