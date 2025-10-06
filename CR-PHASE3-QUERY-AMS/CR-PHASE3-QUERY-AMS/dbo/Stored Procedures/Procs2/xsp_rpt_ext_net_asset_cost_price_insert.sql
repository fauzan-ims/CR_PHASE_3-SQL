CREATE PROCEDURE dbo.xsp_rpt_ext_net_asset_cost_price_insert
as
begin
	declare @code			nvarchar(50)
			,@year				nvarchar(4)
			,@month				nvarchar(2)
			,@msg				nvarchar(max)
			--,@p_cre_date			datetime =  '2023-12-31'
			,@p_cre_date		datetime		= dateadd(day, -2, dbo.xfn_get_system_date())
			,@p_cre_by			nvarchar(15)	= N'JOB'
			,@p_cre_ip_address	nvarchar(15)	= N'JOB'
			,@periode			nvarchar(6) ;

	if (@p_cre_date < eomonth(@p_cre_date)) -- (+) Ari 2024-02-05 ket : get last eom
	begin
		set @p_cre_date = dateadd(month, -1, @p_cre_date) ;
		set @p_cre_date = eomonth(@p_cre_date) ;
	end ;


	begin try
		set @year = year(@p_cre_date) ;
		set @month = month(@p_cre_date) ;
		set @periode = @year + @month ;

		-- delete berdasarkan bulan dan tahun EOM
		delete	dbo.RPT_EXT_NET_ASSET_COST_PRICE ;

		--where	month(eom) = month(@p_cre_date)
		--and		year(eom) = year(@p_cre_date)
		--insert data asset yang period commercial nya sama dengan period EOM
		insert into RPT_EXT_NET_ASSET_COST_PRICE
		(
			EOM
			,ASSETNO
			,COSTPRICE
			,ASSETCONDITIONID
			,ASSETTYPEID
			,ASSETBRANDID
			,ASSETBRANDTYPEID
			,ASSETBRANDTYPENAME
			,ASSETMODELID
			---- raffy (+) 2025/08/06 imon 2508000017
			,fa_code
			,registration_class_type
			,asset_name
			--
			,CRE_DATE
			,CRE_BY
			,CRE_IP_ADDRESS
			,MOD_DATE
			,MOD_BY
			,MOD_IP_ADDRESS
		)
		select	eomonth(@p_cre_date)
				,ast.CODE
				,ast.PURCHASE_PRICE
				,ast.CONDITION
				,case ast.TYPE_CODE
					when 'VHCL' then
						'1'
					when 'HE' then
						'2' else 'NA'
				end						-- 1 vehicle, 2 he , else NA
				,av.MERK_CODE			--ast.merk_code
				,av.TYPE_ITEM_CODE		--ast.type_code_asset
				,av.TYPE_ITEM_NAME		--ast.type_name_asset
				,right(av.TYPE_ITEM_CODE, len(av.TYPE_ITEM_CODE) - 1 - len(av.MODEL_CODE))
										--
										--,@p_cre_date
				,ast.code
				,mi.registration_class_type
				,ast.item_name
				,dbo.xfn_get_system_date()
				,@p_cre_by
				,@p_cre_ip_address
										--,@p_cre_date
				,dbo.xfn_get_system_date()
				,@p_cre_by
				,@p_cre_ip_address
		--from	dbo.ASSET_AGING				aa
		--		inner join ASSET			ast on aa.CODE	= ast.CODE
		--		inner join dbo.ASSET_VEHICLE av on av.ASSET_CODE = ast.CODE
		--where aa.AGING_DATE														= '2024-12-02'
		--	and ast.PURCHASE_DATE													<= '2024-11-30'
		--	and
		--	(
		--			ast.SALE_DATE is null or ast.SALE_DATE						> '2024-11-30'
		--		)
		--	and
		--	(
		--			ast.DISPOSAL_DATE is null or ast.DISPOSAL_DATE				> '2024-11-30'
		--		)
		--	and ast.STATUS not in ('CANCEL', 'HOLD')
		--	and
		--	(
		--			ast.PERMIT_SELL_DATE is null or cast(ast.PERMIT_SELL_DATE as date) > '2024-11-30'
		--		)
		--	and aa.CODE not in 
		from	dbo.xxx_asset_20250831aftereom						 ast
				inner join dbo.asset_vehicle av on av.asset_code = ast.code
				outer apply
				(
					select	top 1 mi.registration_class_type 
					from	ifinbam.dbo.master_item mi 
					where	mi.code = av.type_item_code or mi.type_code = av.type_item_code
				)mi
		where	ASSET_FROM								 = 'BUY'
				and isnull(IS_PERMIT_TO_SELL, '0')		 = '0'
				and STATUS in
		(
			'STOCK', 'REPLACEMENT'
										  
		)
				and convert(char(6), PURCHASE_DATE, 112) <= convert(char(6), @p_cre_date, 112) 
				AND convert(char(6), ast.CRE_DATE, 112) <= convert(char(6), @p_cre_date, 112) 
																				   

		delete	dbo.RPT_EXT_NET_ASSET_COST_PRICE_LOG
		where EOM = @p_cre_date ;

		begin
			insert into dbo.RPT_EXT_NET_ASSET_COST_PRICE_LOG
			(
				EOM
				,ASSETNO
				,COSTPRICE
				,ASSETCONDITIONID
				,ASSETTYPEID
				,ASSETBRANDID
				,ASSETBRANDTYPEID
				,ASSETBRANDTYPENAME
				,ASSETMODELID
				,CRE_DATE
				,CRE_BY
				,CRE_IP_ADDRESS
				,MOD_DATE
				,MOD_BY
				,MOD_IP_ADDRESS
			)
			select	EOM
					,ASSETNO
					,COSTPRICE
					,ASSETCONDITIONID
					,ASSETTYPEID
					,ASSETBRANDID
					,ASSETBRANDTYPEID
					,ASSETBRANDTYPENAME
					,ASSETMODELID
					,CRE_DATE
					,CRE_BY
					,CRE_IP_ADDRESS
					,MOD_DATE
					,MOD_BY
					,MOD_IP_ADDRESS
			from	RPT_EXT_NET_ASSET_COST_PRICE ;
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
			set @msg = N'v' + N';' + @msg ;
		end ;
		else
		begin
			if (error_message() like '%v;%' or error_message() like '%e;%')
			begin
				set @msg = error_message() ;
			end ;
			else
			begin
				set @msg = N'e;' + dbo.xfn_get_msg_err_generic() + N';' + error_message() ;
			end ;
		end ;

		raiserror(@msg, 16, -1) ;

		return ;
	end catch ;
end ;

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[xsp_rpt_ext_net_asset_cost_price_insert] TO [ims-raffyanda]
    AS [dbo];

