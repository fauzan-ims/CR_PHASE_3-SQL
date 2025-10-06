CREATE PROCEDURE dbo.xsp_rpt_ext_depre_all_contract_insert_backup
AS
BEGIN
    DECLARE @code NVARCHAR(50),
            @year NVARCHAR(4),
            @month NVARCHAR(2),
            @msg NVARCHAR(MAX),
            @p_cre_date datetime = EOMONTH(DATEADD(MONTH,-1,GETDATE())),
            @p_cre_by nvarchar(15) = 'job',
            @p_cre_ip_address nvarchar(15) = 'job';

    BEGIN TRY
 
	/*
	
		-- IMMATURE

		asssset depre schedule dari EOM hingga berakhir depre asset
		kolom nomor agreement jika kosong , diisi nomor asset / jenis asset
	*/
        delete dbo.rpt_ext_depre_all_contract -- data selalu di cleanup
        --where month(cre_date) = month(@p_cre_date)
        --      and year(create_date) = year(@p_cre_date);

		begin -- current month
        insert into rpt_ext_depre_all_contract
        (
            agreement_id,
            depreciation_date,
            net_investment,
            depreciation_amount,
            cummulative_amount,
            unit,
            installment,
            sequence,
            asset_model,
            asset_brand,
            asset_brand_type,
            asset_brand_type_name,
            asset_type,
            asset_condition,
            as_of,
            create_date, 
            create_time,
			--
            cre_date,
            cre_by,
            cre_ip_address,
            mod_date,
            mod_by,
            mod_ip_address
        )

		select		isnull(	 am.AGREEMENT_EXTERNAL_NO, case ass.STATUS
													when 'STOCK' then 'UNIT STOCK'
													when 'REPLACEMENT' then 'REPLACEMENT CAR'
												end
						  )
					,eomonth(@p_cre_date)										   -- tanggal akhir bulan
					,sum(ass.purchase_price)
					,sum(isnull(adsc.depreciation_amount,0))
					,sum(ass.total_depre_comm)
					,count(1)
					,sum(aa.LEASE_ROUNDED_AMOUNT)
					,rpt.SEQUENCE
					,right(av.TYPE_ITEM_CODE, len(av.TYPE_ITEM_CODE) - 1 - len(av.MODEL_CODE)) -- av.model_code, -- tipe
					,av.MERK_CODE
					,av.MODEL_NAME
					,av.MODEL_NAME
																							   --ass.type_name_asset,
					,case ass.TYPE_CODE
						 when 'VHCL' then '1'
						 when 'HE' then '2'
						 else 'NA'
					 end																	   -- 1 vehicle, 2 he , else NA
					,ass.CONDITION
					,@p_cre_date
					,@p_cre_date
					,cast(getdate() as time)
																							   --
					,@p_cre_date
					,@p_cre_by
					,@p_cre_ip_address
					,@p_cre_date
					,@p_cre_by
					,@p_cre_ip_address
		from		dbo.ASSET									ass
		inner join	dbo.ASSET_VEHICLE							av on av.ASSET_CODE = ass.CODE
		left join	dbo.ASSET_DEPRECIATION_SCHEDULE_COMMERCIAL	adsc on adsc.ASSET_CODE = ass.CODE and  convert(varchar(6), adsc.depreciation_date , 112) = convert(varchar(6), @p_cre_date , 112)  
		left join	ifinopl.dbo.rpt_ext_agreement_main ram on ass.agreement_external_no = ram.agreement_id
		left join	IFINOPL.dbo.AGREEMENT_ASSET					aa on aa.FA_CODE = ass.CODE
																	  and aa.AGREEMENT_NO = ass.AGREEMENT_NO
																	  and aa.ASSET_STATUS = 'RENTED'
																	  and ram.AGREEMENT_ID =  ass.AGREEMENT_NO
		left join	IFINOPL.dbo.AGREEMENT_MAIN					am on am.AGREEMENT_NO = aa.AGREEMENT_NO
																	  and ass.AGREEMENT_EXTERNAL_NO = am.AGREEMENT_EXTERNAL_NO

		--inner join IFINOPL.dbo.RPT_EXT_AGREEMENT_MAIN			rpt on   rpt.AGREEMENT_ID = isnull(	  am.AGREEMENT_EXTERNAL_NO, case ass.STATUS
		--																															when 'STOCK' then 'UNIT STOCK'
		--																															when 'REPLACEMENT' then 'REPLACEMENT CAR'
		--																														end
		--																								 )
		--												)
		outer apply (
						select top 1
							   rpt.SEQUENCE
						from   IFINOPL.dbo.RPT_EXT_AGREEMENT_MAIN rpt
						where  rpt.AGREEMENT_ID = isnull(	am.AGREEMENT_EXTERNAL_NO, case ass.STATUS
																						  when 'STOCK' then 'UNIT STOCK'
																						  when 'REPLACEMENT' then 'REPLACEMENT CAR'
																					  end
														)
					)							rpt
		where		ass.PURCHASE_DATE							  <= @p_cre_date
					and (
							ass.SALE_DATE is null
							or ass.SALE_DATE					  > @p_cre_date
						)
					and (
							ass.DISPOSAL_DATE is null
							or ass.DISPOSAL_DATE				  > @p_cre_date
						)
					and ASSET_FROM								 = 'BUY'
				and isnull(IS_PERMIT_TO_SELL, '0')		 = '0'
				and STATUS in
		(
			'STOCK', 'REPLACEMENT'
		)

		GROUP by isnull(am.agreement_external_no, case ass.STATUS 
														when 'STOCK' then 'UNIT STOCK'
														when 'REPLACEMENT' then 'REPLACEMENT CAR'
													end),
               eomonth(adsc.depreciation_date), -- tanggal akhir bulan
			   rpt.sequence,
                right(av.type_item_code, len(av.type_item_code)-1-len(av.model_code)),-- av.model_code, -- tipe
               av.merk_code,
               av.MODEL_NAME,
               av.MODEL_NAME,
               --ass.type_name_asset,
               CASE ass.type_code WHEN 'VHCL' THEN '1'
					WHEN 'HE' THEN '2'
					ELSE 'NA'
				end, -- 1 vehicle, 2 he , else NA
               ass.condition;
		end


		begin -- next month

		  insert into rpt_ext_depre_all_contract
        (
            agreement_id,
            depreciation_date,
            net_investment,
            depreciation_amount,
            cummulative_amount,
            unit,
            installment,
            sequence,
            asset_model,
            asset_brand,
            asset_brand_type,
            asset_brand_type_name,
            asset_type,
            asset_condition,
            as_of,
            create_date, 
            create_time,
			--
            cre_date,
            cre_by,
            cre_ip_address,
            mod_date,
            mod_by,
            mod_ip_address
        )

		select		isnull(	  am.AGREEMENT_EXTERNAL_NO, case ass.STATUS
													when 'STOCK' then 'UNIT STOCK'
													when 'REPLACEMENT' then 'REPLACEMENT CAR'
												end
						  )
					,eomonth(adsc.depreciation_date)										   -- tanggal akhir bulan
					,sum(adsc.original_price)
					,sum(isnull(adsc.depreciation_amount,0))
					,sum(adsc.accum_depre_amount)
					,count(1)
					,sum(aa.lease_rounded_amount)
					,rpt.SEQUENCE
					,right(av.TYPE_ITEM_CODE, len(av.TYPE_ITEM_CODE) - 1 - len(av.MODEL_CODE)) -- av.model_code, -- tipe
					,av.MERK_CODE
					,av.MODEL_NAME
					,av.MODEL_NAME
																							   --ass.type_name_asset,
					,case ass.TYPE_CODE
						 when 'VHCL' then '1'
						 when 'HE' then '2'
						 else 'NA'
					 end																	   -- 1 vehicle, 2 he , else NA
					,ass.CONDITION
					,@p_cre_date
					,@p_cre_date
					,cast(getdate() as time)
																							   --
					,@p_cre_date
					,@p_cre_by
					,@p_cre_ip_address
					,@p_cre_date
					,@p_cre_by
					,@p_cre_ip_address
		from		dbo.ASSET									ass
		inner join	dbo.ASSET_VEHICLE							av on av.ASSET_CODE = ass.CODE
		left join	dbo.ASSET_DEPRECIATION_SCHEDULE_COMMERCIAL	adsc on adsc.ASSET_CODE = ass.CODE and  convert(varchar(6), adsc.depreciation_date , 112) > convert(varchar(6), @p_cre_date , 112)  
		left join	ifinopl.dbo.rpt_ext_agreement_main ram on ass.agreement_external_no = ram.agreement_id
		left join	IFINOPL.dbo.AGREEMENT_ASSET					aa on aa.FA_CODE = ass.CODE
																	  and aa.AGREEMENT_NO = ass.AGREEMENT_NO
																	  and aa.ASSET_STATUS = 'RENTED'
																	  and ram.AGREEMENT_ID =  ass.AGREEMENT_NO
		left join	IFINOPL.dbo.AGREEMENT_MAIN					am on am.AGREEMENT_NO = aa.AGREEMENT_NO
																	  and ass.AGREEMENT_EXTERNAL_NO = am.AGREEMENT_EXTERNAL_NO
		outer apply (
						select top 1
							   rpt.SEQUENCE
						from   IFINOPL.dbo.RPT_EXT_AGREEMENT_MAIN rpt
						where  rpt.AGREEMENT_ID = isnull(	am.AGREEMENT_EXTERNAL_NO, case ass.STATUS
																						  when 'STOCK' then 'UNIT STOCK'
																						  when 'REPLACEMENT' then 'REPLACEMENT CAR'
																					  end
														)
					)							rpt
		where		ass.PURCHASE_DATE							  <= @p_cre_date
					and (
							ass.SALE_DATE is null
							or ass.SALE_DATE					  > @p_cre_date
						)
					and (
							ass.DISPOSAL_DATE is null
							or ass.DISPOSAL_DATE				  > @p_cre_date
						)
					and ASSET_FROM								 = 'BUY'
				and isnull(IS_PERMIT_TO_SELL, '0')		 = '0'
				and STATUS in
		(
			'STOCK', 'REPLACEMENT'
		)
					and adsc.ID is not null

		GROUP by isnull(am.agreement_external_no, case ass.STATUS 
														when 'STOCK' then 'UNIT STOCK'
														when 'REPLACEMENT' then 'REPLACEMENT CAR'
													end),
               eomonth(adsc.depreciation_date), -- tanggal akhir bulan
			   rpt.sequence,
                right(av.type_item_code, len(av.type_item_code)-1-len(av.model_code)),-- av.model_code, -- tipe
               av.merk_code,
               av.MODEL_NAME,
               av.MODEL_NAME,
               --ass.type_name_asset,
               CASE ass.type_code WHEN 'VHCL' THEN '1'
					WHEN 'HE' THEN '2'
					ELSE 'NA'
				end, -- 1 vehicle, 2 he , else NA
               ass.condition;

		end

		begin -- untuk asset mature

		declare @table_mature_schedule table
				(
					EOD_DATE datetime
				);
		declare @asset_mature table
				(
					ASSET_CODE  nvarchar(50)
				);

		begin -- temp imature
			insert into @table_mature_schedule
				(
					EOD_date
				)
			SELECT distinct DEPRECIATION_DATE FROM RPT_EXT_DEPRE_ALL_CONTRACT where DEPRECIATION_DATE > '2024-07-31' and DEPRECIATION_DATE <= '2027-03-31'

 
		end;
		begin -- temp asset mature
		insert into @asset_mature
			(
				ASSET_CODE
			)
		select		ass.CODE
		from		dbo.ASSET		  ass
		inner join	dbo.ASSET_VEHICLE av on av.ASSET_CODE = ass.CODE
		outer apply (
						select	 max(adsc.DEPRECIATION_DATE) 'DEPRECIATION_DATE'
						from	 IFINAMS.dbo.ASSET_DEPRECIATION_SCHEDULE_COMMERCIAL adsc with (nolock)
						where	 adsc.ASSET_CODE = ass.CODE
						group by adsc.ASSET_CODE
					)				  adsc
		where		ass.PURCHASE_DATE							  <= '2024-07-31'
					and (
							ass.SALE_DATE is null
							or ass.SALE_DATE					  > '2024-07-31'
						)
					and (
							ass.DISPOSAL_DATE is null
							or ass.DISPOSAL_DATE				  > '2024-07-31'
						)
					and ASSET_FROM								 = 'BUY'
				and isnull(IS_PERMIT_TO_SELL, '0')		 = '0'
				and STATUS in
		(
			'STOCK', 'REPLACEMENT'
		)
					and adsc.DEPRECIATION_DATE					  <= '2024-07-31';

		end 

		insert into RPT_EXT_DEPRE_ALL_CONTRACT
			(
				AGREEMENT_ID
				,DEPRECIATION_DATE
				,NET_INVESTMENT
				,DEPRECIATION_AMOUNT
				,CUMMULATIVE_AMOUNT
				,UNIT
				,INSTALLMENT
				,SEQUENCE
				,ASSET_MODEL
				,ASSET_BRAND
				,ASSET_BRAND_TYPE
				,ASSET_BRAND_TYPE_NAME
				,ASSET_TYPE
				,ASSET_CONDITION
				,AS_OF
				,CREATE_DATE
				,CREATE_TIME
				--
				,CRE_DATE
				,CRE_BY
				,CRE_IP_ADDRESS
				,MOD_DATE
				,MOD_BY
				,MOD_IP_ADDRESS
			)
		select		isnull(	  am.AGREEMENT_EXTERNAL_NO, case ass.STATUS
															when 'STOCK' then 'UNIT STOCK'
															when 'REPLACEMENT' then 'REPLACEMENT CAR'
														end
						  )
																							   ,mature.EOD_date										  
					,(ass.ORIGINAL_PRICE)
					,0
					,(ass.TOTAL_DEPRE_COMM)
					,1
					,(isnull(aa.LEASE_ROUNDED_AMOUNT, 0))
					,rpt.SEQUENCE
					,right(av.TYPE_ITEM_CODE, len(av.TYPE_ITEM_CODE) - 1 - len(av.MODEL_CODE)) -- av.model_code, -- tipe
					,av.MERK_CODE
					,av.MODEL_NAME
					,av.MODEL_NAME
																							   --ass.type_name_asset,
					,case ass.TYPE_CODE
						 when 'VHCL' then '1'
						 when 'HE' then '2'
						 else 'NA'
					 end																	   -- 1 vehicle, 2 he , else NA
					,ass.CONDITION
					,@p_cre_date
					,@p_cre_date
					,cast(getdate() as time)
																							   --
					,@p_cre_date
					,@p_cre_by
					,@p_cre_ip_address
					,@p_cre_date
					,@p_cre_by
					,@p_cre_ip_address
		from		dbo.ASSET						   ass
		inner join	dbo.ASSET_VEHICLE				   av on av.ASSET_CODE = ass.CODE
		inner join @table_mature_schedule mature on 1=1
		left join	IFINOPL.dbo.AGREEMENT_ASSET		   aa on aa.FA_CODE = ass.CODE
															 and aa.AGREEMENT_NO = ass.AGREEMENT_NO
															 and aa.ASSET_STATUS = 'RENTED'
															 --and ram.AGREEMENT_ID = ass.AGREEMENT_NO
		left join	IFINOPL.dbo.AGREEMENT_MAIN		   am on am.AGREEMENT_NO = aa.AGREEMENT_NO
															 and ass.AGREEMENT_EXTERNAL_NO = am.AGREEMENT_EXTERNAL_NO
		outer apply (
						select top 1
							   rpt.SEQUENCE 'SEQUENCE'
						from   IFINOPL.dbo.RPT_EXT_AGREEMENT_MAIN rpt
						where  rpt.AGREEMENT_ID = isnull(	am.AGREEMENT_EXTERNAL_NO, case ass.STATUS
																						  when 'STOCK' then 'UNIT STOCK'
																						  when 'REPLACEMENT' then 'REPLACEMENT CAR'
																					  end
														)
					)								   rpt
		where	exists
		(
			SELECT ASSET_CODE FROM @asset_mature mat where ass.CODE = mat.ASSET_CODE
		)


		end

		-- update khusus replacement dan stock

		update dbo.RPT_EXT_DEPRE_ALL_CONTRACT
		set	   ASSET_MODEL = 'NA'
			   ,ASSET_BRAND = 'NA'
			   ,ASSET_BRAND_TYPE = 'NA'
			   ,ASSET_BRAND_TYPE_NAME = 'NA'
			   ,ASSET_TYPE = 'NA'
			   ,ASSET_CONDITION = 'NA'
		where  AGREEMENT_ID in
		(
			'UNIT STOCK', 'REPLACEMENT CAR'
		);


 
		begin
		print 'backup before'
		-- select isnull(am.agreement_external_no, case ass.STATUS 
		--												when 'STOCK' then 'UNIT STOCK'
		--												when 'REPLACEMENT' then 'REPLACEMENT CAR'
		--											end),
  --             eomonth(adsc.depreciation_date), -- tanggal akhir bulan
  --             SUM(ass.purchase_price),
  --             SUM(adsc.depreciation_amount),
  --             SUM(adsc.accum_depre_amount),
  --             COUNT(1),
  --             SUM(aa.lease_rounded_amount),
		--	   rpt.sequence,
  --              right(av.type_item_code, len(av.type_item_code)-1-len(av.model_code)),-- av.model_code, -- tipe
  --             av.merk_code,
  --             av.MODEL_NAME,
  --             av.MODEL_NAME,
  --             --ass.type_name_asset,
  --             CASE ass.type_code WHEN 'VHCL' THEN '1'
		--			WHEN 'HE' THEN '2'
		--			ELSE 'NA'
		--		end, -- 1 vehicle, 2 he , else NA
  --             ass.condition,
  --             @p_cre_date,
  --             @p_cre_date,
  --             cast(getdate() as time),
  --             --
  --             @p_cre_date,
  --             @p_cre_by,
  --             @p_cre_ip_address,
  --             @p_cre_date,
  --             @p_cre_by,
  --             @p_cre_ip_address
  --      from dbo.asset ass
		--left join ifinopl.dbo.agreement_asset aa on aa.fa_code = ass.code and aa.agreement_no = ass.agreement_no and aa.ASSET_STATUS = 'RENTED'
		--left join  ifinopl.dbo.agreement_main am on am.agreement_no = aa.agreement_no and ass.agreement_external_no = am.agreement_external_no
		--inner join dbo.asset_depreciation_schedule_commercial adsc on adsc.asset_code = ass.code
  --      inner join dbo.asset_vehicle av on av.asset_code = ass.code
		--outer apply (
		--			SELECT TOP 1 rpt.sequence
		--			from ifinopl.dbo.rpt_ext_agreement_main rpt
		--			where rpt.agreement_id = isnull(am.agreement_external_no, case ass.status 
		--																			when 'STOCK' then 'UNIT STOCK'
		--																			when 'REPLACEMENT' then 'REPLACEMENT CAR'
		--																		end
		--																		)
		--			) rpt
		--where convert(varchar(6), adsc.depreciation_date , 112) >=  convert(varchar(6), @p_cre_date , 112)  
		----AND ass.rental_status = 'IN USE' 
		--AND ass.STATUS IN
		--				(
		--				N'REPLACEMENT',
		--				N'STOCK'
		--				)


		--GROUP by isnull(am.agreement_external_no, case ass.STATUS 
		--												when 'STOCK' then 'UNIT STOCK'
		--												when 'REPLACEMENT' then 'REPLACEMENT CAR'
		--											end),
  --             eomonth(adsc.depreciation_date), -- tanggal akhir bulan
		--	   rpt.sequence,
  --              right(av.type_item_code, len(av.type_item_code)-1-len(av.model_code)),-- av.model_code, -- tipe
  --             av.merk_code,
  --             av.MODEL_NAME,
  --             av.MODEL_NAME,
  --             --ass.type_name_asset,
  --             CASE ass.type_code WHEN 'VHCL' THEN '1'
		--			WHEN 'HE' THEN '2'
		--			ELSE 'NA'
		--		end, -- 1 vehicle, 2 he , else NA
  --             ass.condition

		---- update khusus replacement dan stock

		--update dbo.RPT_EXT_DEPRE_ALL_CONTRACT
		--set	   ASSET_MODEL = 'NA'
		--	   ,ASSET_BRAND = 'NA'
		--	   ,ASSET_BRAND_TYPE = 'NA'
		--	   ,ASSET_BRAND_TYPE_NAME = 'NA'
		--	   ,ASSET_TYPE = 'NA'
		--	   ,ASSET_CONDITION = 'NA'
		--where  AGREEMENT_ID in
		--(
		--	'UNIT STOCK', 'REPLACEMENT CAR'
		--);

		end

						--and ass.AGREEMENT_EXTERNAL_NO ='0000154/4/04/06/2022'
		--AND ass.CODE ='4120040727'
		 
    --select	ass.agreement_no
    --		,adsc.depreciation_date
    --		,ass.purchase_price
    --		,adsc.depreciation_amount
    --		,adsc.accum_depre_amount
    --		,1--COUNT(adsc.asset_code)
    --		,asd.billing_amount--adsc.id
    --		,ass.code
    --		,avh.model_code
    --		,avh.merk_code
    --		,avh.type_item_code
    --		,avh.type_item_name
    --		,ass.type_code
    --		,ass.last_so_condition
    --		,ass.purchase_date
    --		,ass.cre_date
    --		,ass.cre_date--convert(varchar(8), ass.cre_date, 108)
    --		--
    --		,@p_cre_date
    --		,@p_cre_by
    --		,@p_cre_ip_address
    --		,@p_cre_date
    --		,@p_cre_by
    --		,@p_cre_ip_address
    --from 	dbo.asset_depreciation_schedule_commercial adsc
    --		inner join dbo.asset					   ass on (ass.code		  = adsc.asset_code)
    --		inner join dbo.asset_vehicle			   avh on (avh.asset_code = ass.code)
    --		outer apply (	select	top 1 aas.billing_amount 
    --						from	ifinopl.dbo.agreement_asset_amortization aas
    --								inner join ifinopl.dbo.agreement_asset ags on ags.agreement_no = aas.agreement_no and ags.asset_no = aas.asset_no
    --						where	aas.agreement_no = ass.agreement_no
    --						and		ags.fa_code = ass.code
    --					) asd
    --where	isnull(ass.agreement_no, '') <> ''
    --		and adsc.id in
    --			(
    --				select		max(id)
    --				from		dbo.asset_depreciation_schedule_commercial adsc
    --				where		adsc.transaction_code <> ''
    --				group by	adsc.asset_code
    --			) 
    --		and not exists (select 1 from dbo.rpt_ext_depre_all_contract rpt
    --						where	agreement_id = 	ass.agreement_no
    --						and		rpt.depreciation_date = adsc.depreciation_date
    --						and		rpt.sequence = ass.code
    --						)

    END TRY
    BEGIN CATCH
        DECLARE @error INT;

        SET @error = @@error;

        IF (@error = 2627)
        BEGIN
            SET @msg = dbo.xfn_get_msg_err_code_already_exist();
        END;

        IF (LEN(@msg) <> 0)
        BEGIN
            SET @msg = N'v' + N';' + @msg;
        END;
        ELSE
        BEGIN
            IF (ERROR_MESSAGE() LIKE '%v;%' OR ERROR_MESSAGE() LIKE '%e;%')
            BEGIN
                SET @msg = ERROR_MESSAGE();
            END;
            ELSE
            BEGIN
                SET @msg = N'e;' + dbo.xfn_get_msg_err_generic() + N';' + ERROR_MESSAGE();
            END;
        END;

        RAISERROR(@msg, 16, -1);

        RETURN;
    END CATCH;
END;
