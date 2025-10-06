--Created, Aliv at 29-05-2023
CREATE PROCEDURE [dbo].[xsp_rpt_control_card_maintenance]
(
	@p_user_id				NVARCHAR(50) = ''
	,@p_agreement_no		NVARCHAR(50) = 'ALL'
	,@p_asset_code			NVARCHAR(50) = ' ALL'
	,@p_from_date			DATETIME 
	,@p_to_date				DATETIME
)
AS
BEGIN
   DELETE dbo.RPT_CONTROL_CARD_MAINTENANCE
   WHERE  USER_ID = @p_user_id ;

   -- (+) Ari 2023-09-04 ket : add table temporary
   declare @table_temp		table
   (
		user_id							nvarchar(50)
         ,report_company				nvarchar(250)
         ,report_title					nvarchar(250)
         ,report_image					nvarchar(250)
         ,agreement_no					nvarchar(50)
         ,customer_name					nvarchar(50)
         ,fixed_asset_code				nvarchar(50)
         ,fixed_asset_description		nvarchar(100)
         ,plat_no						nvarchar(50)
         ,merk_or_type					nvarchar(250)
         ,chassis_no					nvarchar(50)
         ,engine_no						nvarchar(50)
         ,contract_period				nvarchar(50)
         ,budget_maintenance			decimal(18,2)
         ,service_date					datetime
         ,km							int
         ,pekerjaan						nvarchar(250)
         ,jasa							int
         ,jenis_item					nvarchar(250)
         ,part_number					nvarchar(50)
         ,harga							decimal(18,2)
         ,jenis_item_sub				nvarchar(250)
         ,harga_sub						decimal(18,2)		
         ,pekerjaan_special_order		nvarchar(250)
         ,harga_special_order			decimal(18,2)
         ,total_biaya					decimal(18,2)
         ,workshop						nvarchar(250)
         ,remaining_budget				decimal(18,2)
   );
   -- (+) Ari 2023-09-04

   declare
      @msg                      nvarchar(max)
      ,@report_company          nvarchar(250)
      ,@report_title            nvarchar(250)
      ,@report_image            nvarchar(250)
      ,@agreement_no            nvarchar(50)
      ,@customer_name           nvarchar(50)
      ,@fixed_asset_code        nvarchar(50)
      ,@fixed_asset_description nvarchar(100)
      ,@plat_no                 nvarchar(50)
      ,@merk_or_type            nvarchar(100)
      ,@chassis_no              nvarchar(50)
      ,@engine_no               nvarchar(50)
      ,@contract_period         nvarchar(50)
      ,@budget_maintenance      decimal(18, 2)
      ,@service_date            datetime
      ,@km                      int
      ,@pekerjaan               nvarchar(50)
      ,@jasa                    int
      ,@jenis_item              nvarchar(50)
      ,@part_number             nvarchar(50)
      ,@harga                   decimal(18, 2)
      ,@jenis_item_sub          nvarchar(50)
      ,@harga_sub               decimal(18, 2)
      ,@pekerjaan_special_order nvarchar(50)
      ,@harga_special_order     decimal(18, 2)
      ,@total_biaya             decimal(18, 2)
      ,@workshop                nvarchar(50)
      ,@remaining_budget        decimal(18, 2) 
	  ,@ppn_amount				DECIMAL(18,2)
	  ,@pph_amount				DECIMAL(18,2);

   begin try
      select
            @report_company = VALUE
      from  dbo.SYS_GLOBAL_PARAM
      where CODE = 'COMP2' ;

      set @report_title = N'Report Control Card Maintenance' ;

      select
            @report_image = VALUE
      from  dbo.SYS_GLOBAL_PARAM
      where CODE = 'IMGDSF' ;


	  --insert into @table_temp
	  --(
	  --	user_id
	  --	,report_company
	  --	,report_title
	  --	,report_image
	  --	,agreement_no
	  --	,customer_name
	  --	,fixed_asset_code
	  --	,fixed_asset_description
	  --	,plat_no
	  --	,merk_or_type
	  --	,chassis_no
	  --	,engine_no
	  --	,contract_period
	  --	,budget_maintenance
	  --	,service_date
	  --	,km
	  --	,pekerjaan
	  --	,jasa
	  --	,jenis_item
	  --	,part_number
	  --	,harga
	  --	,jenis_item_sub
	  --	,harga_sub
	  --	,pekerjaan_special_order
	  --	,harga_special_order
	  --	,total_biaya
	  --	,workshop
	  --	,remaining_budget
	  --)
	 
	  --select		top 100
   --                 @p_user_id
   --                 ,@report_company
   --                 ,@report_title
   --                 ,@report_image
   --                 ,isnull(ass.agreement_external_no,'-') 'agreement_external_no'
   --                 ,isnull(ass.client_name,'-') 'client_name'
   --                 ,ass.code
   --                 ,ass.item_name
   --                 ,av.plat_no
   --                 ,av.type_item_name
   --                 ,av.chassis_no
   --                 ,av.engine_no
   --                 ,convert(varchar(20), billing.startdate, 106) + ' s/d '
   --                 + convert(varchar(20), billing.enddate, 106)                      contract_period         --contract period
			--		--,billing.contract_period
   --                 ,isnull(aast.budget_maintenance_amount,0)                            budget_maintenance      --budget maintenance
   --                 ,mn.work_date                                                                            -- service date
   --                 ,mn.actual_km                                                                        -- km
   --                 ,case
   --                     when wod.SERVICE_TYPE = 'JASA' then wod.[SERVICE_NAME]
   --                     else ''
   --                 end                                                               PEKERJAAN               --pekerjaan
   --                 ,case
   --                     when wod.SERVICE_TYPE = 'JASA' then wod.PAYMENT_AMOUNT
   --                     else 0
   --                 end                                                               JASA                    --jasa
   --                 ,case
   --                     when wod.SERVICE_TYPE = 'ITEM' then wod.[SERVICE_NAME]
   --                     else ''
   --                 end                                                               ITEM                    --jenis_item
   --                 ,wod.PART_NUMBER
   --                 ,case
   --                     when wod.SERVICE_TYPE = 'ITEM' then wod.PAYMENT_AMOUNT
   --                     else 0
   --                 end                                                               HARGA                   -- harga
   --                 ,''                                                                sub_item                -- jenis_item_sub : confirm tidak ada kata pak hari
   --                 ,0                                                                 sub_item_harga          -- harga_sub : confirm tidak ada kata pak hari
   --                 ,''                                                                special_order_pekerjaan -- pekerjaan special order : confirm tidak ada kata pak hari
   --                 ,0                                                                 special_order_harga     --hargaspecial : confirm tidak ada kata pak hari
   --                 ,isnull(wod.payment_amount, 0)                                     total_biaya             --total biaya
   --                 ,mn.vendor_name                                                                            -- workshop
   --                 ,isnull(aast.budget_maintenance_amount, 0)
   --                 - sum(isnull(wod.payment_amount, 0)) over (order by mn.work_date) remaining_budget        -- remaining
			--		--,(isnull(aast.budget_maintenance_amount,0) - isnull(rb.remaining_budget,0)) 'remaining_budget'
   --         from     dbo.asset                              ass with (nolock)
   --                 left join dbo.asset_vehicle            av with (nolock) on (av.asset_code = ass.code)
   --                 inner join dbo.work_order               wo with (nolock) on (wo.ASSET_CODE = ass.code)
   --                 left join dbo.work_order_detail        wod with (nolock) on (wod.work_order_code = wo.code)
			--		inner join dbo.maintenance              mn with (nolock) on (mn.code = wo.MAINTENANCE_CODE)
   --                 left join ifinopl.dbo.agreement_asset aast with (nolock) on aast.fa_code = ass.code
   --                 outer apply (
   --                                 select
   --                                     min(b1.due_date)  startdate
   --                                     ,max(b1.due_date) enddate
   --                                 from  ifinopl.dbo.AGREEMENT_ASSET_AMORTIZATION b1 with (nolock)
   --                                 where b1.agreement_no = ass.agreement_no
   --                             )                          billing
			--		-- (+) Ari 2023-09-04 ket : langsung ubah conversi di outher apply
			--		--outer apply (
			--		--				select	convert(varchar(20),min(b1.due_date),106) + ' s/d ' + convert(varchar(20),max(b1.due_date),106) 'contract_period'
   --  --                               from	ifinopl.dbo.agreement_asset_amortization b1 with (nolock)
   --  --                               where	b1.agreement_no = ass.agreement_no
			--		--				and		b1.asset_no = ass.asset_no
			--		--			) billing
			--		--outer apply (
			--		--				select	isnull(sum(wod2.payment_amount),0) 'remaining_budget'
			--		--				from	dbo.work_order_detail wod2
			--		--				where	wod2.asset_code = wod.asset_code
			--		--			) rb
			--		-- (+) Ari 2023-09-04
   --         where    ass.code = case @p_asset_code
			--									when ' ALL' then ass.code
			--									else @p_asset_code
			--								end	
			--		and isnull(ass.agreement_no,'-') = case @p_agreement_no
			--									when 'ALL' then isnull(ass.AGREEMENT_NO,'-')
			--									else @p_agreement_no
			--								end	
		

            

      begin
         declare c_card cursor local read_only fast_forward for
		SELECT distinct
				isnull(asset.agreement_external_no, '-')
				,isnull(asset.client_name, '-')
				,avh.asset_code
				,asset.item_name
				,avh.plat_no
				,avh.type_item_name
				,avh.chassis_no
				,avh.engine_no
				,convert(varchar(20), billing.startdate, 106) + ' s/d ' + convert(varchar(20), billing.enddate, 106)          
                ,isnull(agreement_asset.budget_maintenance_amount,0)
				,maintenance.work_date
				,maintenance.actual_km
				,case
                      when work_order_detail.service_type = 'JASA' then work_order_detail.service_name
                      else ''
                   end                                                   
                 ,case
                       when work_order_detail.service_type = 'JASA' then isnull(work_order_detail.payment_amount, work_order_detail.total_amount)
                       else 0
                   end
                  ,case
                       when work_order_detail.service_type = 'ITEM' then work_order_detail.service_name
                       else ''
                    end
                   ,work_order_detail.part_number
				   ,isnull(work_order_detail.service_fee,0)
                   --,case
                   --    when work_order_detail.service_type = 'ITEM' then isnull(work_order_detail.service_fee, work_order_detail.total_amount)
                   --    else 0
                   -- end
					,''
					,0
					,''
					,0
					,isnull(work_order_detail.payment_amount, 0)
					,maintenance.vendor_name
					,isnull(agreement_asset.budget_maintenance_amount, 0) - sum(isnull(work_order_detail.payment_amount, 0)) over (order by maintenance.work_date) remaining_budget        -- remaining
					,work_order_detail.ppn_amount
					,work_order_detail.pph_amount
		from dbo.asset_vehicle avh
		outer apply (select ass.agreement_no, ass.agreement_external_no, ass.client_name, ass.item_name from dbo.asset ass where ass.code = avh.asset_code) asset
		outer apply (select wo.code, wo.maintenance_code from dbo.work_order wo where wo.asset_code = avh.asset_code) work_order
		outer apply (select wod.service_type, wod.service_name, wod.payment_amount, wod.total_amount, wod.part_number, wod.service_fee, wod.ppn_amount, wod.pph_amount from dbo.work_order_detail wod where wod.work_order_code = work_order.code) work_order_detail
		outer apply (select mnt.work_date, mnt.actual_km, mnt.vendor_name from dbo.maintenance mnt where mnt.code = work_order.maintenance_code) maintenance
		outer apply (select aast.budget_maintenance_amount from ifinopl.dbo.agreement_asset aast where aast.fa_code = avh.asset_code and aast.agreement_no = asset.agreement_no) agreement_asset
		outer apply (select	min(b1.due_date)  startdate, max(b1.due_date) enddate from	ifinopl.dbo.agreement_asset_amortization b1 where	b1.agreement_no = asset.agreement_no)  billing
		where avh.asset_code = case @p_asset_code
					when ' ALL' then  avh.asset_code
					else @p_asset_code
				end
		and maintenance.work_date between cast(@p_from_date as date) and cast(@p_to_date as date)
		and isnull(asset.agreement_external_no, '-') = case REPLACE(@p_agreement_no,'.','/')
												when 'ALL' then isnull(asset.agreement_external_no,'-')
												else REPLACE(@p_agreement_no,'.','/')
											end	

         --buka cursor
         open c_card ;

         fetch next from c_card
         into
            @agreement_no
            ,@customer_name
            ,@fixed_asset_code
            ,@fixed_asset_description
            ,@plat_no
            ,@merk_or_type
            ,@chassis_no
            ,@engine_no
            ,@contract_period
            ,@budget_maintenance
            ,@service_date
            ,@km
            ,@pekerjaan
            ,@jasa
            ,@jenis_item
            ,@part_number
            ,@harga
            ,@jenis_item_sub
            ,@harga_sub
            ,@pekerjaan_special_order
            ,@harga_special_order
            ,@total_biaya
            ,@workshop
            ,@remaining_budget 
			,@ppn_amount
			,@pph_amount;

         while @@fetch_status = 0
         begin
            INSERT INTO dbo.RPT_CONTROL_CARD_MAINTENANCE
            (
                USER_ID,
                REPORT_COMPANY,
                REPORT_TITLE,
                REPORT_IMAGE,
                AGREEMENT_NO,
                CUSTOMER_NAME,
                FIXED_ASSET_CODE,
                FIXED_ASSET_DESCRIPTION,
                PLAT_NO,
                MERK_OR_TYPE,
                CHASSIS_NO,
                ENGINE_NO,
                CONTRACT_PERIOD,
                BUDGET_MAINTENANCE,
                SERVICE_DATE,
                KM,
                PEKERJAAN,
                JASA,
                JENIS_ITEM,
                PART_NUMBER,
                HARGA,
                JENIS_ITEM_SUB,
                HARGA_SUB,
                PEKERJAAN_SPECIAL_ORDER,
                HARGA_SPECIAL_ORDER,
                TOTAL_BIAYA,
                WORKSHOP,
                REMAINING_BUDGET,
                PPN,
                PPH
            )
            values
            (
               @p_user_id
               ,@report_company
               ,@report_title
               ,@report_image
               ,@agreement_no
               ,@customer_name
               ,@fixed_asset_code
               ,@fixed_asset_description
               ,@plat_no
               ,@merk_or_type
               ,@chassis_no
               ,@engine_no
               ,@contract_period
               ,@budget_maintenance
               ,@service_date
               ,@km
               ,@pekerjaan
               ,@jasa
               ,@jenis_item
               ,@part_number
               ,@harga
               ,@jenis_item_sub
               ,@harga_sub
               ,@pekerjaan_special_order
               ,@harga_special_order
               ,@total_biaya
               ,@workshop
               ,@remaining_budget
			   ,@ppn_amount
			   ,@pph_amount
            ) ;

            fetch next from c_card
            into
               @agreement_no
               ,@customer_name
               ,@fixed_asset_code
               ,@fixed_asset_description
               ,@plat_no
               ,@merk_or_type
               ,@chassis_no
               ,@engine_no
               ,@contract_period
               ,@budget_maintenance
               ,@service_date
               ,@km
               ,@pekerjaan
               ,@jasa
               ,@jenis_item
               ,@part_number
               ,@harga
               ,@jenis_item_sub
               ,@harga_sub
               ,@pekerjaan_special_order
               ,@harga_special_order
               ,@total_biaya
               ,@workshop
               ,@remaining_budget 
			   ,@ppn_amount
			   ,@pph_amount;
         end ;

         --ttup kursor
         close c_card ;
         deallocate c_card ;
      end ;
  --    insert into dbo.rpt_control_card_maintenance
  --    (
  --       user_id
  --       ,report_company
  --       ,report_title
  --       ,report_image
  --       ,agreement_no
  --       ,customer_name
  --       ,fixed_asset_code
  --       ,fixed_asset_description
  --       ,plat_no
  --       ,merk_or_type
  --       ,chassis_no
  --       ,engine_no
  --       ,contract_period
  --       ,budget_maintenance
  --       ,service_date
  --       ,km
  --       ,pekerjaan
  --       ,jasa
  --       ,jenis_item
  --       ,part_number
  --       ,harga
  --       ,jenis_item_sub
  --       ,harga_sub
  --       ,pekerjaan_special_order
  --       ,harga_special_order
  --       ,total_biaya
  --       ,workshop
  --       ,remaining_budget
		-- ,ppn
		-- ,pph
  --    )
		--select distinct
		--		@p_user_id
		--		,@report_company
		--		,@report_title
		--		,@report_image
		--		,isnull(asset.agreement_external_no, '-')
		--		,isnull(asset.client_name, '-')
		--		,avh.asset_code
		--		,asset.item_name
		--		,avh.plat_no
		--		,avh.type_item_name
		--		,avh.chassis_no
		--		,avh.engine_no
		--		,convert(varchar(20), billing.startdate, 106) + ' s/d ' + convert(varchar(20), billing.enddate, 106)          
  --              ,isnull(agreement_asset.budget_maintenance_amount,0)
		--		,maintenance.work_date
		--		,maintenance.actual_km
		--		,case
  --                    when work_order_detail.service_type = 'JASA' then work_order_detail.service_name
  --                    else ''
  --                 end                                                   
  --               ,case
  --                     when work_order_detail.service_type = 'JASA' then isnull(work_order_detail.payment_amount, work_order_detail.total_amount)
  --                     else 0
  --                 end
  --                ,case
  --                     when work_order_detail.service_type = 'ITEM' then work_order_detail.service_name
  --                     else ''
  --                  end
  --                 ,work_order_detail.part_number
		--		   ,isnull(work_order_detail.service_fee,0)
  --                 --,case
  --                 --    when work_order_detail.service_type = 'ITEM' then isnull(work_order_detail.service_fee, work_order_detail.total_amount)
  --                 --    else 0
  --                 -- end
		--			,''
		--			,0
		--			,''
		--			,0
		--			,isnull(work_order_detail.payment_amount, 0)
		--			,maintenance.vendor_name
		--			,isnull(agreement_asset.budget_maintenance_amount, 0) - sum(isnull(work_order_detail.payment_amount, 0)) over (order by maintenance.work_date) remaining_budget        -- remaining
		--			,work_order_detail.ppn_amount
		--			,work_order_detail.pph_amount
		--from dbo.asset_vehicle avh
		--outer apply (select ass.agreement_no, ass.agreement_external_no, ass.client_name, ass.item_name from dbo.asset ass where ass.code = avh.asset_code) asset
		--outer apply (select wo.code, wo.maintenance_code from dbo.work_order wo where wo.asset_code = avh.asset_code) work_order
		--outer apply (select wod.service_type, wod.service_name, wod.payment_amount, wod.total_amount, wod.part_number, wod.service_fee, wod.ppn_amount, wod.pph_amount from dbo.work_order_detail wod where wod.work_order_code = work_order.code) work_order_detail
		--outer apply (select mnt.work_date, mnt.actual_km, mnt.vendor_name from dbo.maintenance mnt where mnt.code = work_order.maintenance_code) maintenance
		--outer apply (select aast.budget_maintenance_amount from ifinopl.dbo.agreement_asset aast where aast.fa_code = avh.asset_code and aast.agreement_no = asset.agreement_no) agreement_asset
		--outer apply (select	min(b1.due_date)  startdate, max(b1.due_date) enddate from	ifinopl.dbo.agreement_asset_amortization b1 where	b1.agreement_no = asset.agreement_no)  billing
		--where avh.asset_code = case @p_asset_code
		--			when ' ALL' then  avh.asset_code
		--			else @p_asset_code
		--		end
		--and maintenance.work_date between cast(@p_from_date as date) and cast(@p_to_date as date)
		--and isnull(asset.agreement_external_no, '-') = case @p_agreement_no
		--										when 'ALL' then isnull(asset.agreement_external_no,'-')
		--										else @p_agreement_no
		--									end	
		--ass.code = case @p_asset_code
			--									when ' ALL' then ass.code
			--									else @p_asset_code
			--								end	
			--		and isnull(ass.agreement_no,'-') = case @p_agreement_no
			--									when 'ALL' then isnull(ass.AGREEMENT_NO,'-')
			--									else @p_agreement_no
			--								end	

		--order by asset.agreement_external_no

       --           select
       --                    distinct 
       --                    @p_user_id
       --                    ,@report_company
       --                    ,@report_title
       --                    ,@report_image
       --                    ,isnull(ass.agreement_external_no,'-') 'agreement_external_no'
       --                    ,isnull(ass.client_name,'-') 'client_name'
       --                    ,ass.code
       --                    ,ass.item_name
       --                    ,av.plat_no
       --                    ,av.type_item_name
       --                    ,av.chassis_no
       --                    ,av.engine_no
       --                    ,convert(varchar(20), billing.startdate, 106) + ' s/d '
       --                     + convert(varchar(20), billing.enddate, 106)                      contract_period         --contract period
       --                    ,isnull(aast.budget_maintenance_amount,0)                            budget_maintenance      --budget maintenance
       --                    ,mn.work_date                                                                            -- service date
       --                    ,mn.actual_km                                                                        -- km
       --                    ,case
       --                        when wod.SERVICE_TYPE = 'JASA' then wod.SERVICE_NAME
       --                        else ''
       --                     end                                                               PEKERJAAN               --pekerjaan
       --                    ,case
       --                        when wod.SERVICE_TYPE = 'JASA' then isnull(wod.PAYMENT_AMOUNT, wod.total_amount)
       --                        else 0
       --                     end                                                               JASA                    --jasa
       --                    ,case
       --                        when wod.SERVICE_TYPE = 'ITEM' then wod.SERVICE_NAME
       --                        else ''
       --                     end                                                               ITEM                    --jenis_item
       --                    ,wod.PART_NUMBER
       --                    ,case
       --                        when wod.SERVICE_TYPE = 'ITEM' then isnull(wod.PAYMENT_AMOUNT, wod.total_amount)
       --                        else 0
       --                     end                                                               HARGA                   -- harga
       --                    ,''                                                                sub_item                -- jenis_item_sub : confirm tidak ada kata pak hari
       --                    ,0                                                                 sub_item_harga          -- harga_sub : confirm tidak ada kata pak hari
       --                    ,''                                                                special_order_pekerjaan -- pekerjaan special order : confirm tidak ada kata pak hari
       --                    ,0                                                                 special_order_harga     --hargaspecial : confirm tidak ada kata pak hari
       --                    ,isnull(wod.payment_amount, 0)                                     total_biaya             --total biaya
       --                    ,mn.vendor_name                                                                            -- workshop
       --                    ,isnull(aast.budget_maintenance_amount, 0)
       --                     - sum(isnull(wod.payment_amount, 0)) over (order by mn.work_date) remaining_budget        -- remaining
       --           from     dbo.asset                              ass with (nolock)
       --                    inner join dbo.asset_vehicle            av with (nolock) on (av.asset_code = ass.code)
       --                    inner join dbo.work_order               wo with (nolock) on (wo.asset_code = ass.code)
       --                    inner join dbo.work_order_detail        wod with (nolock) on (wod.work_order_code = wo.code)
						 --  inner join dbo.maintenance              mn with (nolock) on (mn.code = wo.maintenance_code)
       --                    left join ifinopl.dbo.agreement_asset aast with (nolock) on (aast.fa_code = ass.code and aast.agreement_no = ass.agreement_no)
       --                    outer apply (
       --                                   select
       --                                         min(b1.due_date)  startdate
       --                                         ,max(b1.due_date) enddate
       --                                   from  ifinopl.dbo.AGREEMENT_ASSET_AMORTIZATION b1 with (nolock)
       --                                   where b1.agreement_no = ass.agreement_no
       --                                )                          billing
							----outer apply (
							----				select	case
							----							when wod.service_type = 'jasa' 
							----							then wod.service_name
							----							else ''
							----						end	'pekerjaan'                                                 
							----						,case
							----							when wod.service_type = 'jasa' then wod.payment_amount
							----							else 0
							----						end 'jasa'                                                             
							----						,case
							----							when wod.service_type = 'item' then wod.service_name
							----							else ''
							----						end 'item'                                                       
							----						,wod.part_number
							----						,case
							----							when wod.service_type = 'item' then wod.payment_amount
							----							else 0
							----						end 'harga'
							----						,isnull(wod.payment_amount,0) 'total_biaya'
							----				from	work_order_detail wod
							----				where	wod.work_order_code = wo.code
							----			) wod
       --           where    ass.code = case @p_asset_code
							--							when ' ALL' then ass.code
							--							else @p_asset_code
							--						end	
							--and isnull(ass.agreement_no,'-') = case @p_agreement_no
							--							when 'ALL' then isnull(ass.AGREEMENT_NO,'-')
							--							else @p_agreement_no
							--						end
							--and mn.work_date  between cast (@p_from_date as date) and cast (@p_to_date as date)
       --           order by agreement_external_no ;

	   --select	distinct
				--user_id
				--,report_company
				--,report_title
				--,report_image
				--,agreement_no
				--,customer_name
				--,fixed_asset_code
				--,fixed_asset_description
				--,plat_no
				--,merk_or_type
				--,chassis_no
				--,engine_no
				--,contract_period
				--,budget_maintenance
				--,service_date
				--,km
				--,pekerjaan
				--,jasa
				--,jenis_item
				--,part_number
				--,harga
				--,jenis_item_sub
				--,harga_sub
				--,pekerjaan_special_order
				--,harga_special_order
				--,total_biaya
				--,workshop
				--,remaining_budget 
	   --from		@table_temp

		if not exists(select 1 from dbo.RPT_CONTROL_CARD_MAINTENANCE where user_id = @p_user_id)
		begin
			insert into dbo.rpt_control_card_maintenance
			(
				user_id
				,report_company
				,report_title
				,report_image
				,agreement_no
				,customer_name
				,fixed_asset_code
				,fixed_asset_description
				,plat_no
				,merk_or_type
				,chassis_no
				,engine_no
				,contract_period
				,budget_maintenance
				,service_date
				,km
				,pekerjaan
				,jasa
				,jenis_item
				,part_number
				,harga
				,jenis_item_sub
				,harga_sub
				,pekerjaan_special_order
				,harga_special_order
				,total_biaya
				,workshop
				,remaining_budget
				,ppn
				,pph
			)
			select @p_user_id
					,@report_company
					,@report_title
					,@report_image
					,agreement_external_no
					,client_name
					,code
					,item_name
					,avh.plat_no
					,avh.type_item_name
					,avh.chassis_no
					,avh.engine_no
					,convert(varchar(20), billing.startdate, 106) + ' s/d ' + convert(varchar(20), billing.enddate, 106)
					,isnull(agreement_asset.budget_maintenance_amount,0)
					,null
					,0
					,'-'
					,'-'
					,'-'
					,'-'
					,0
					,'-'
					,0
					,'-'
					,0
					,0
					,'-'
					,0
					,0
					,0
			from dbo.asset ass
			inner join dbo.asset_vehicle avh on (ass.code = avh.asset_code)
			outer apply (select aast.budget_maintenance_amount from ifinopl.dbo.agreement_asset aast where aast.fa_code = ass.code and aast.agreement_no = aast.agreement_no) agreement_asset
			outer apply (select	min(b1.due_date)  startdate, max(b1.due_date) enddate from	ifinopl.dbo.agreement_asset_amortization b1 where	b1.agreement_no = ass.agreement_no)  billing
			where ass.code = @p_asset_code

			--values
			--(	 @p_user_id
			--	,@report_company
			--	,@report_title
			--	,@report_image
			--	,'-'
			--	,'-'
			--	,'-'
			--	,'-'
			--	,'-'
			--	,'-'
			--	,'-'
			--	,'-'
			--	,'-'
			--	,0
			--	,null
			--	,0
			--	,'-'
			--	,'-'
			--	,'-'
			--	,'-'
			--	,0
			--	,'-'
			--	,0
			--	,'-'
			--	,0
			--	,0
			--	,'-'
			--	,0
			--); 
		end;
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
