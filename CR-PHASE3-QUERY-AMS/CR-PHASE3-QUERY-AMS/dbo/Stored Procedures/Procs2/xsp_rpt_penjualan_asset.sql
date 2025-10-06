CREATE PROCEDURE dbo.xsp_rpt_penjualan_asset
(
	@p_user_id		   nvarchar(50)
	,@p_from_date	   datetime
	,@p_to_date		   datetime
	,@p_type		   nvarchar(50)
	,@p_is_condition   NVARCHAR(1) --(+) Untuk Kondisi Excel Data Only
	--
	,@p_cre_date	   datetime
	,@p_cre_by		   nvarchar(15)
	,@p_cre_ip_address nvarchar(15)
	,@p_mod_date	   datetime
	,@p_mod_by		   nvarchar(15)
	,@p_mod_ip_address nvarchar(15)
)
as
begin
	delete	dbo.rpt_penjualan_asset
	where	user_id = @p_user_id ;


	declare @msg			   nvarchar(max)
			,@report_company   nvarchar(250)
			,@report_title	   nvarchar(250)
			,@report_image	   nvarchar(250)
			,@agreement_id	   nvarchar(50)
			,@seq			   int = 0
			,@customer_name	   nvarchar(250)
			,@object		   nvarchar(50)
			,@year			   nvarchar(4)
			,@chassis_no	   nvarchar(50)
			,@engine_no		   nvarchar(50)
			,@plat_no		   nvarchar(50)
			,@purchase_price   decimal(18, 2)
			,@sold_price	   decimal(18, 2)
			,@sold_date		   datetime
			,@bv			   decimal(18, 2)
			,@gain_or_loss	   decimal(18, 2)
			,@profit_or_loss   decimal(18, 2)
			,@prosentase_nilai decimal(18, 2)
			,@buyer_name	   nvarchar(250)
			,@type_name		   nvarchar(50)
			,@tahun			   nvarchar(4) 
			,@percentage	   decimal(18,2);

	begin try
		select	@report_company = value
		from	dbo.SYS_GLOBAL_PARAM
		where	CODE = 'COMP2' ;

		set @report_title = N'Report Penjualan Asset' ;

		select	@report_image = value
		from	dbo.SYS_GLOBAL_PARAM
		where	CODE = 'IMGDSF' ;
		set @percentage=100;
		begin
			if (@p_type = 'DETAIL')
			begin
				declare curr_penjualan_asset_detail cursor fast_forward read_only for
				select	
				--CASE
				--			when ast.rental_status='IN USE' then ast.agreement_external_no 
				--			else  xkontrak.xagreement
				--		end
				--		,case
				--			when ast.rental_status='IN USE' then ast.client_name
				--			else xkontrak.xagreement
				--		END
    --                    , -- Hari - 27.Sep.2023 09:52 PM --	ganti pakai acara ambil last agreement
						xkontrak.xagreement
                        , xkontrak.xclientname
						,ast.item_name
						,cast(year(ast.purchase_date) as nvarchar)
						,isnull(av.chassis_no, '')
						,isnull(av.engine_no, '')
						,isnull(av.plat_no, '')
						,ast.purchase_price
						,sd.sold_amount
						,sd.sale_date
						,ast.net_book_value_comm
						,sd.gain_loss
						,sd.gain_loss_profit
						,case
							when ast.PURCHASE_PRICE is null then 0
							when ast.PURCHASE_PRICE = 0 then 0
							else (cast(isnull(sd.SOLD_AMOUNT,0) as decimal(18,2))) / (cast(ast.PURCHASE_PRICE as decimal(18,2))) * @percentage
							--else cast((sd.SOLD_AMOUNT / isnull(ast.PURCHASE_PRICE,0)) * 100 as decimal(18,2))
						end 
						,case
						when sd.buyer_type='PERSONAL' then sd.BUYER_NAME
						else upper(case
									--when sell_type = 'COP' then ass.client_name
									when sell_type = 'AUCTION' then ma.auction_name
									else upper(sd.buyer_signer_name)
								end)
						end
						,s.sell_type
						,cast(year(sd.sale_date) as nvarchar)
				from	dbo.asset					ast
						inner join dbo.sale_detail	sd on ast.code		= sd.asset_code
						inner join dbo.sale			s on s.code			= sd.sale_code
						left join dbo.asset_vehicle av on av.asset_code = ast.code
						left join dbo.master_auction ma on (ma.code = s.auction_code)
						outer apply (
							select top 1 xaa.AGREEMENT_NO 'xagreement', xam.CLIENT_NAME 'xclientname' 
							FROM ifinopl.dbo.agreement_asset xaa
							INNER join ifinopl.dbo.agreement_main xam on xam.agreement_no = xaa.agreement_no
							where xaa.FA_CODE = ast.code 
							order by xam.agreement_date desc
						) xkontrak
				where	cast(sd.sale_date as date)
						between cast(@p_from_date as date) and cast(@p_to_date as date)
						and ast.status = 'SOLD' ;

				open curr_penjualan_asset_detail ;

				fetch next from curr_penjualan_asset_detail
				into @agreement_id
					 ,@customer_name
					 ,@object
					 ,@year
					 ,@chassis_no
					 ,@engine_no
					 ,@plat_no
					 ,@purchase_price
					 ,@sold_price
					 ,@sold_date
					 ,@bv
					 ,@gain_or_loss
					 ,@profit_or_loss
					 ,@prosentase_nilai
					 ,@buyer_name
					 ,@type_name
					 ,@tahun ;

				while @@fetch_status = 0
				begin
				set @seq = @seq + 1
					insert into dbo.rpt_penjualan_asset
					(
						user_id
						,filter_from_date
						,filter_to_date
						,filter_type
						,report_company
						,report_title
						,report_image
						,agreement_id
						,seq
						,customer_name
						,object
						,year
						,chassis_no
						,engine_no
						,plat_no
						,purchase_price
						,sold_price
						,sold_date
						,bv
						,gain_or_loss
						,profit_or_loss
						,prosentase_nilai
						,buyer_name
						,type_name
						,tahun
						,is_condition
						--
						,cre_date
						,cre_by
						,cre_ip_address
						,mod_date
						,mod_by
						,mod_ip_address
					)
					values
					(
						@p_user_id
						,@p_from_date
						,@p_to_date
						,@p_type
						,@report_company
						,@report_title
						,@report_image
						,@agreement_id
						,@seq
						,@customer_name
						,@object
						,@year
						,@chassis_no
						,@engine_no
						,@plat_no
						,@purchase_price
						,@sold_price
						,@sold_date
						,@bv
						,@gain_or_loss
						,@profit_or_loss
						,@prosentase_nilai
						,@buyer_name
						,@type_name
						,@tahun
						,@p_is_condition
						--
						,@p_cre_date
						,@p_cre_by
						,@p_cre_ip_address
						,@p_mod_date
						,@p_mod_by
						,@p_mod_ip_address
					) ;

					fetch next from curr_penjualan_asset_detail
					into @agreement_id
						 ,@customer_name
						 ,@object
						 ,@year
						 ,@chassis_no
						 ,@engine_no
						 ,@plat_no
						 ,@purchase_price
						 ,@sold_price
						 ,@sold_date
						 ,@bv
						 ,@gain_or_loss
						 ,@profit_or_loss
						 ,@prosentase_nilai
						 ,@buyer_name
						 ,@type_name
						 ,@tahun ;
				end ;

				close curr_penjualan_asset_detail ;
				deallocate curr_penjualan_asset_detail ;
			end ;

			if (@p_type = 'SUMMARY')
			
			delete	dbo.RPT_PENJUALAN_ASSET_SUMMARY
			where	user_id = @p_user_id ;

			begin
				declare @tahun_sum				  nvarchar(4)
						,@total_unit			  int
						,@sum_of_gain_or_loss	  decimal(18, 2)
						,@avg_purchase_price	  decimal(18, 2)
						,@avg_sold_price		  decimal(18, 2)
						,@sell_type				  nvarchar(50)

				
				DECLARE curr_penjualan_asset_summary CURSOR FAST_FORWARD READ_ONLY FOR 
				select		cast(year(ast.SALE_DATE) as nvarchar)
							,count(ast.code)
							,sum(sd.gain_loss)
							,avg(ast.purchase_price)
							,avg(sd.sold_amount)
							,s.sell_type
				from		dbo.asset					ast
							inner join dbo.sale_detail	sd on ast.code		= sd.asset_code
							inner join dbo.sale			s on s.code			= sd.sale_code
							left join dbo.asset_vehicle av on av.asset_code = ast.code
				where		cast(sd.sale_date as date)
							between cast(@p_from_date as date) and cast(@p_to_date as date)
							and ast.status = 'SOLD'
				group by	cast(year(ast.SALE_DATE) as nvarchar), s.sell_type ;
				
				OPEN curr_penjualan_asset_summary
				
				FETCH NEXT FROM curr_penjualan_asset_summary INTO  
						@tahun_sum		
						,@total_unit			
						,@sum_of_gain_or_loss  
						,@avg_purchase_price	
						,@avg_sold_price		
						,@sell_type				
				
				WHILE @@FETCH_STATUS = 0
				BEGIN

				insert into dbo.rpt_penjualan_asset_summary
				(
					user_id
					,tahun
					,sell_type
					,total_unit
					,sum_of_gain_or_loss
					,purchase_price
					,sold_price
				)
				values
				(
					@p_user_id	
					,@tahun_sum	
					,@sell_type	
					,@total_unit
					,@sum_of_gain_or_loss
					,@avg_purchase_price
					,@avg_sold_price
				)
				    
				
				    FETCH NEXT FROM curr_penjualan_asset_summary INTO 
						@tahun_sum		
						,@total_unit			
						,@sum_of_gain_or_loss  
						,@avg_purchase_price	
						,@avg_sold_price		
						,@sell_type	
				END
				
				CLOSE curr_penjualan_asset_summary
				DEALLOCATE curr_penjualan_asset_summary
				
			end ;

			if not exists
			(
				select	1
				from	dbo.RPT_PENJUALAN_ASSET
				where	USER_ID = @p_user_id
			)
			begin
				insert into dbo.rpt_penjualan_asset
				(
					user_id
					,filter_from_date
					,filter_to_date
					,filter_type
					,report_company
					,report_title
					,report_image
					,agreement_id
					,seq
					,customer_name
					,object
					,year
					,chassis_no
					,engine_no
					,plat_no
					,purchase_price
					,sold_price
					,sold_date
					,bv
					,gain_or_loss
					,profit_or_loss
					,prosentase_nilai
					,buyer_name
					,type_name
					,tahun
					,is_condition
					--
					,cre_date
					,cre_by
					,cre_ip_address
					,mod_date
					,mod_by
					,mod_ip_address
				)
				values
				(
					@p_user_id
					,@p_from_date
					,@p_to_date
					,@p_type
					,@report_company
					,@report_title
					,@report_image
					,''
					,null
					,''
					,''
					,''
					,''
					,''
					,''
					,null
					,null
					,null
					,null
					,null
					,null
					,null
					,''
					,''
					,''
					,@p_is_condition
					--
					,@p_cre_date
					,@p_cre_by
					,@p_cre_ip_address
					,@p_mod_date
					,@p_mod_by
					,@p_mod_ip_address
				) ;
			end

			if not exists
			(
				select	*
				from	dbo.rpt_penjualan_asset_summary
				where	USER_ID = @p_user_id
			)
			begin
				insert into dbo.rpt_penjualan_asset_summary
					(
						user_id
						,tahun
						,sell_type
						,total_unit
						,sum_of_gain_or_loss
						,purchase_price
						,sold_price
					)
					values
					(
						@p_user_id	
						,''	
						,''	
						,0
						,0
						,0
						,0
					)
				end

		create table #rpt_summary_penjualan
		(
			user_id			nvarchar(50)
			,tahun			nvarchar(4)
			,purchase_price	decimal(18, 2)
			,sold_price		decimal(18, 2)
		) ;

		insert into #rpt_summary_penjualan
		(
			user_id
			,tahun
			,purchase_price
			,sold_price
		)
		select		@p_user_id
					,tahun
					,avg(purchase_price)
					,avg(sold_price)
		from		dbo.rpt_penjualan_asset_summary
		where		user_id = @p_user_id
		group by	tahun ;
		SELECT * FROM #rpt_summary_penjualan
		update	dbo.rpt_penjualan_asset_summary
		set		sum_avg_purchase_price =
				(
					select	sum(purchase_price)
					from	#rpt_summary_penjualan
					where	user_id = @p_user_id
				)
				,sum_avg_sold_price =
				 (
					 select sum(sold_price)
					 from	#rpt_summary_penjualan
					 where	user_id = @p_user_id
				 )
		where	user_id = @p_user_id ;

		drop table #rpt_summary_penjualan ;
		end ;
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
