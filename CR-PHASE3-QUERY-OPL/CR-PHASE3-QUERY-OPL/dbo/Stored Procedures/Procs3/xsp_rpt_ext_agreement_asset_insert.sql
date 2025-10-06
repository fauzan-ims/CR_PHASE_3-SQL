CREATE PROCEDURE dbo.xsp_rpt_ext_agreement_asset_insert
AS
BEGIN
	DECLARE @msg			   NVARCHAR(MAX)
			,@p_cre_date	   DATETIME		= '2025-07-31'--dbo.xfn_get_system_date()
			,@p_cre_by		   NVARCHAR(15) = N'JOB'
			,@p_cre_ip_address NVARCHAR(15) = N'JOB' ;

	begin try
		delete	dbo.rpt_ext_agreement_asset -- selalu clear all

		insert into rpt_ext_agreement_asset
		(
			agreement_id
			,branch
			,sequence
			,asset_brand_type_name
			,asset_type
			,asset_condition
			,asset_model
			,asset_brand
			,asset_brand_type
			,as_of
			,create_date
			,create_time
			--
			,cre_date
			,cre_by
			,cre_ip_address
			,mod_date
			,mod_by
			,mod_ip_address
		)
		select	am.agreement_external_no
				,am.branch_code
				,asq.RUNNING_NO
				,isnull(aav.MODEL_NAME , astvmodel.DESCRIPTION)
				,  case aa.asset_type_code WHEN 'VHCL' THEN '1'
					WHEN 'HE' THEN '2'
					ELSE 'NA'
				end -- 1 vehicle, 2 he , else NA  
				,CASE WHEN aa.asset_condition = 'USED' THEN 'USED NON SLB' ELSE aa.ASSET_CONDITION END -- RAFFY 2025/08/05 REQUEST PAK EDDY DI TEAMS
				,case  isnull( aav.type_item_code,'')
						 when '' then right(astv.vehicle_unit_code, len(astv.vehicle_unit_code)-1-len(astv.vehicle_model_code))
						 
						else right(aav.type_item_code, len(aav.type_item_code)-1-len(aav.model_code))	--isnull(aav.vehicle_model_code, isnull(aam.machinery_model_code, isnull(aah.he_model_code, aae.electronic_model_code)))
				end
				,isnull(aav.merk_code, astv.VEHICLE_MERK_CODE)								--isnull(aav.vehicle_merk_code, isnull(aam.machinery_merk_code, isnull(aah.he_merk_code, aae.electronic_merk_code)))
				,isnull(aav.MODEL_NAME, astvmerek.DESCRIPTION)								--isnull(aav.vehicle_merk_code, isnull(aam.machinery_merk_code, isnull(aah.he_merk_code, aae.electronic_merk_code)))
				--,LEFT(aav.type_item_name,50) --ISNULL(aav.vehicle_type_code, isnull(aam.machinery_type_code, isnull(aah.he_type_code, '')))
				,@p_cre_date
				,cast(GETDATE() as date)
				,cast(GETDATE() as time)
				--
				,@p_cre_date
				,@p_cre_by
				,@p_cre_ip_address
				,@p_cre_date
				,@p_cre_by
				,@p_cre_ip_address
		from  ifinopl.dbo.XXX_AGREEMENT_MAIN_AFTER_EOM_20250731 am 
		inner join ifinopl.dbo.XXX_AGREEMENT_ASSET_AFTER_EOM_20250731 aa  on aa.agreement_no = am.agreement_no
		inner join ifinopl.dbo.agreement_squence_number_anaplan asq on asq.agreement_external_no = am.agreement_external_no
		left join ifinams.dbo.XXX_ASSET_VEHICLE_AFTER_EOM_20250731 aav on aav.asset_code = aa.fa_code
		left join ifinopl.dbo.XXX_AGREEMENT_ASSET_VEHICLE_AFTER_EOM_20250731 astv on astv.asset_no = aa.asset_no
		left join ifinopl.dbo.XXX_MASTER_VEHICLE_MERK_AFTER_EOM_20250731 astvmerek on astvmerek.code = astv.vehicle_merk_code
		left join ifinopl.dbo.XXX_MASTER_VEHICLE_MODEL_AFTER_EOM_20250731 astvmodel on astvmodel.code = astv.vehicle_model_code
		WHERE (am.agreement_status = 'GO LIVE' AND aa.ASSET_STATUS = 'RENTED') 
		--OR 
		--am.AGREEMENT_EXTERNAL_NO IN ( N'0000039/4/01/11/2023', N'0000040/4/38/03/2023', N'0000045/4/38/04/2023',
  --                                      N'0000059/4/01/08/2014', N'0000061/4/38/06/2023', N'0000062/4/04/10/2020',
  --                                      N'0000064/4/04/10/2020', N'0000065/4/04/10/2020', N'0000070/4/38/07/2023',
  --                                      N'0000073/4/38/08/2023', N'0000119/4/38/10/2023', N'0000120/4/38/10/2023',
  --                                      N'0000121/4/38/11/2023', N'0000122/4/38/11/2023', N'0000313/4/10/03/2020',
  --                                      N'0000315/4/10/04/2020', N'0000320/4/01/07/2019', N'0000392/4/01/12/2019',
  --                                      N'0000789/4/08/10/2022', N'0001048/4/01/06/2022', N'0001176/4/08/10/2023',
  --                                      N'0001191/4/08/11/2023', N'0000016/4/16/02/2015', N'0000017/4/16/03/2015',
  --                                      N'0000018/4/34/08/2022', N'0000026/4/01/11/2023', N'0000105/4/38/09/2023',
  --                                      N'0000114/4/38/10/2023', N'0000117/4/38/10/2023', N'0000211/4/03/09/2023',
  --                                      N'0000215/4/10/05/2019', N'0000216/4/10/05/2019', N'0000217/4/10/05/2019',
  --                                      N'0000218/4/10/05/2019', N'0000220/4/10/05/2019', N'0000221/4/10/05/2019',
  --                                      N'0000234/4/10/07/2019', N'0000235/4/10/07/2019', N'0000237/4/10/07/2019',
  --                                      N'0000244/4/10/08/2019', N'0000245/4/10/08/2019', N'0000289/4/01/05/2019',
  --                                      N'0000291/4/10/12/2019', N'0000292/4/10/12/2019', N'0000303/4/10/12/2019',
  --                                      N'0000309/4/01/07/2019', N'0000528/4/01/08/2020', N'0000556/4/10/11/2022',
  --                                      N'0000557/4/10/11/2022', N'0000014/4/16/02/2015', N'0000015/4/16/02/2015',
  --                                      N'0000497/4/10/07/2022', N'0000881/4/01/11/2021', N'0001132/4/08/09/2023',
  --                                      N' 0000830/4/10/11/2023', N'0000004/4/11/10/2021', N'0000083/4/38/08/2023',
  --                                      N'0000085/4/38/08/2023', N'0000086/4/03/10/2021', N'0000097/4/38/09/2023',
  --                                      N'0000433/4/10/03/2022', N'0000827/4/10/11/2023', N'0000828/4/10/11/2023',
  --                                      N'0000829/4/10/11/2023', N'0000836/4/01/08/2021', N'0000837/4/01/08/2021',
  --                                      N'0001105/4/01/08/2022', N'0001461/4/01/08/2023', N'0001493/4/01/09/2023',
  --                                      N'0001506/4/01/09/2023', N'0001510/4/01/09/2023', N'0001554/4/01/11/2023',
  --                                      N'0001555/4/01/11/2023', N'0001557/4/01/11/2023', N'0001561/4/01/11/2023',
  --                                      N'0001562/4/01/11/2023 ', N'0001569/4/01/11/2023', N'0001570/4/01/11/2023',
  --                                      N'0001934/4/08/02/2024', N'0001935/4/08/02/2024', N'0002401/4/08/06/2024',
  --                                      N'0002825/4/08/09/2024', N'0002826/4/08/09/2024', N'0001417/4/01/07/2023',
  --                                      N'0001453/4/01/07/2023', N'0001454/4/01/07/2023', N'0001834/4/10/01/2024',
  --                                      N'0001910/4/38/02/2024', N'0002089/4/10/03/2024', N'0002177/4/08/04/2024',
  --                                      N'0002564/4/08/07/2024', N'0003115/4/08/10/2024', N'0001205/4/08/11/2023',
  --                                      N'0001206/4/08/11/2023', N'0001693/4/08/11/2023', N'0001723/4/10/01/2024',
  --                                      N'0002046/4/01/03/2024', N'0002873/4/08/09/2024', N'0002880/4/08/09/2024',
  --                                      N'0002883/4/08/09/2024', N'0002887/4/08/09/2024', N'0002889/4/08/09/2024',
  --                                      N'0002912/4/08/09/2024', N'0002916/4/08/09/2024', N'0002918/4/08/09/2024',
  --                                      N'0002926/4/08/09/2024', N'0002940/4/08/09/2024', N'0002941/4/08/09/2024',
  --                                      N'0002946/4/08/09/2024', N'0002962/4/08/09/2024', N'0002963/4/08/09/2024',
  --                                      N'0002972/4/08/09/2024', N'0003014/4/08/10/2024', N'0003025/4/08/10/2024',
  --                                      N'0003029/4/08/10/2024', N'0003033/4/08/10/2024', N'0003035/4/08/10/2024',
  --                                      N'0003052/4/08/10/2024', N'0003053/4/08/10/2024', N'0003064/4/08/10/2024','0003456/4/10/11/2024'
  --                                    );

					 
			insert into 	dbo.RPT_EXT_AGREEMENT_ASSET
				(
					ASSET_MODEL
					,ASSET_BRAND
					,ASSET_BRAND_TYPE
					,ASSET_BRAND_TYPE_NAME
					,ASSET_TYPE
					,ASSET_CONDITION
					,AGREEMENT_ID
					,BRANCH
					,SEQUENCE
					,AS_OF
					,CREATE_DATE
					,CREATE_TIME
					,CRE_DATE
					,CRE_BY
					,CRE_IP_ADDRESS
					,MOD_DATE
					,MOD_BY
					,MOD_IP_ADDRESS
				)
			values
				(
					N'NA'		   -- ASSET_MODEL - nvarchar(50)
					,N'NA'	   -- ASSET_BRAND - nvarchar(50)
					,N'NA'	   -- ASSET_BRAND_TYPE - nvarchar(50)
					,N'NA'	   -- ASSET_BRAND_TYPE_NAME - nvarchar(250)
					,N'NA'	   -- ASSET_TYPE - nvarchar(50)
					,N'NA'	   -- ASSET_CONDITION - nvarchar(50)
					,N'REPLACEMENT CAR'	   -- AGREEMENT_ID - nvarchar(50)
					,N'2001'	   -- BRANCH - nvarchar(50)
					,N'1481'	   -- SEQUENCE - nvarchar(50)
					,@p_cre_date
					,cast(GETDATE() as date)
					,cast(GETDATE() as time)
					--
					,@p_cre_date
					,@p_cre_by
					,@p_cre_ip_address
					,@p_cre_date
					,@p_cre_by
					,@p_cre_ip_address
				)		
				insert into 	dbo.RPT_EXT_AGREEMENT_ASSET
				(
					ASSET_MODEL
					,ASSET_BRAND
					,ASSET_BRAND_TYPE
					,ASSET_BRAND_TYPE_NAME
					,ASSET_TYPE
					,ASSET_CONDITION
					,AGREEMENT_ID
					,BRANCH
					,SEQUENCE
					,AS_OF
					,CREATE_DATE
					,CREATE_TIME
					,CRE_DATE
					,CRE_BY
					,CRE_IP_ADDRESS
					,MOD_DATE
					,MOD_BY
					,MOD_IP_ADDRESS
				)
			values
				(
					N'NA'		   -- ASSET_MODEL - nvarchar(50)
					,N'NA'	   -- ASSET_BRAND - nvarchar(50)
					,N'NA'	   -- ASSET_BRAND_TYPE - nvarchar(50)
					,N'NA'	   -- ASSET_BRAND_TYPE_NAME - nvarchar(250)
					,N'NA'	   -- ASSET_TYPE - nvarchar(50)
					,N'NA'	   -- ASSET_CONDITION - nvarchar(50)
					,N'UNIT STOCK'	   -- AGREEMENT_ID - nvarchar(50)
					,N'2001'	   -- BRANCH - nvarchar(50)
					,N'3802'	   -- SEQUENCE - nvarchar(50)
					,@p_cre_date
					,cast(GETDATE() as date)
					,cast(GETDATE() as time)
					--
					,@p_cre_date
					,@p_cre_by
					,@p_cre_ip_address
					,@p_cre_date
					,@p_cre_by
					,@p_cre_ip_address
				)		
						
				UPDATE	dbo.RPT_EXT_AGREEMENT_ASSET
				SET		ASSET_MODEL = 'XCN5PT'
				WHERE	ASSET_MODEL = 'N5PT'	
				
				UPDATE dbo.RPT_EXT_AGREEMENT_ASSET
				SET ASSET_MODEL = 'HSC24D'
				WHERE ASSET_MODEL = 'C24D'
				
				UPDATE dbo.RPT_EXT_AGREEMENT_ASSET
				SET ASSET_MODEL = 'HSCD4M'
				WHERE ASSET_MODEL = 'CD4M'	
				--		dbo.agreement_asset aa
				--inner join dbo.agreement_main am on (am.agreement_no		  = aa.agreement_no)
				--left join dbo.agreement_asset_vehicle aav on (aav.asset_no	  = aa.asset_no)
				--left join dbo.agreement_asset_machine aam on (aam.asset_no	  = aa.asset_no)
				--left join dbo.agreement_asset_he aah on (aah.asset_no		  = aa.asset_no)
				--left join dbo.agreement_asset_electronic aae on (aae.asset_no = aa.asset_no) ;
	end try
	begin catch
		if (len(@msg) <> 0)
		begin
			set @msg = N'v' + N';' + @msg ;
		end ;
		else
		begin
			set @msg = N'e;there is an error.' + N';' + error_message() ;
		end ;

		raiserror(@msg, 16, -1) ;

		return ;
	end catch ;
end ;
