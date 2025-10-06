CREATE PROCEDURE dbo.xsp_rpt_ext_asset_selling_insert
AS
BEGIN
    DECLARE @msg				nvarchar(MAX)
            --@p_cre_date DATETIME= '2023-12-31',
			,@p_cre_date		datetime = dateadd(day, -11, dbo.xfn_get_system_date())
            ,@p_cre_by			nvarchar(15) = N'JOB'
            ,@p_cre_ip_address	nvarchar(15) = N'JOB'
			,@system_date		datetime = dbo.xfn_get_system_date()

	if(@p_cre_date < eomonth(@p_cre_date)) -- (+) Ari 2024-02-05 ket : get last eom
	begin
		set @p_cre_date = dateadd(month, -1, @p_cre_date)
		set @p_cre_date = eomonth(@p_cre_date)
	end

    begin try

        delete dbo.rpt_ext_asset_selling
        --where month(eom) = month(@p_cre_date)
        --      and year(eom) = year(@p_cre_date);

        insert into rpt_ext_asset_selling
        (
            eom,
            assetno,
            amt,
            assetconditionid,
            assettypeid,  -- type
            assetbrandid, -- merk
            assetbrandtypeid,
            assetbrandtypename,
            assetmodelid, --model
                          --
			---- raffy (+) 2025/08/06 imon 2508000017
			fa_code,
			registration_class_type,
			asset_name,
            cre_date,
            cre_by,
            cre_ip_address,
            mod_date,
            mod_by,
            mod_ip_address
        )
        select EOMONTH(@p_cre_date),
             ISNULL(ast.agreement_external_no, ISNULL(jd.agreement_no, jrn.JOURNAL_REFF_NO)),
               jd.orig_amount_db - jd.orig_amount_cr,
               ast.condition,
				ast.asset_type, -- 1 vehicle, 2 he , else NA
				ast.MERK_CODE,
				ast.type_code_asset,
				ast.assetbrandtypename, --am.asset_name,
				ast.assetmodelid, --.model_code,
				ast.fa_code,
				ast.registration_class_type,
				ast.item_name,
               --
               --@p_cre_date,
			   @system_date,
               @p_cre_by,
               @p_cre_ip_address,
               --@p_cre_date,
			   @system_date,
               @p_cre_by,
               @p_cre_ip_address
        from ifinacc.dbo.journal_detail jd
            inner join ifinacc.dbo.journal jrn on (jrn.code = jd.journal_code)
			-- (+) Ari 2024-02-12 ket : jika agreement (referensi) pada journal kosong pake kondisi yg ini
			outer apply (
							select	top 1
									rr.received_source_no 'asset_no'
							from	ifinfin.dbo.received_transaction_detail rtd
							inner	join ifinfin.dbo.received_request rr on (rr.code = rtd.received_request_code)
							where	rtd.received_transaction_code = jrn.journal_reff_no
						) oast
			-- (+) Ari 2024-02-12
			outer apply (
					SELECT top 1
							ast.condition
							,ast.ITEM_NAME
							,case ast.TYPE_CODE  WHEN 'VHCL' THEN '1'
								WHEN 'HE' THEN '2'
								ELSE 'NA'
							end asset_type -- 1 vehicle, 2 he , else NA
							,ast.merk_code
							,av.MERK_NAME assetbrandtypename
							,ast.type_code_asset
							,ast.type_name_asset
							,ast.AGREEMENT_EXTERNAL_NO
							,right(av.type_item_code, len(av.type_item_code)-1-len(av.model_code)) assetmodelid
							,ast.CODE 'fa_code'
							,mi.REGISTRATION_CLASS_TYPE
							--,ast.ITEM_NAME
					from asset ast
					inner join dbo.asset_vehicle av on av.asset_code = ast.code
					inner join ifinbam.dbo.master_item mi on mi.code = av.type_item_code
					--where av.asset_code = jd.agreement_no
					--(+) Ari 2024-02-12 ket : ganti kondisi jika kosong pakai kondisi yg seperti ini
					where	av.asset_code = case isnull(jd.agreement_no,'')
												when ''
												then oast.asset_no
												else jd.agreement_no
											end
			
			) ast
     --       outer apply
					--(
     --       				select	top 1
					--					am.agreement_external_no
					--					,aa.asset_condition
					--					,aav.vehicle_type_code 
					--					,aav.vehicle_merk_code 'merk_code'
					--					,aa.asset_type_code
					--					,aa.asset_name
					--					,am.currency_code
					--					,right(aav.vehicle_type_code, len(aav.vehicle_type_code)-1-len(aav.vehicle_model_code)) model_code
					--			from	ifinopl.dbo.agreement_main am
					--					inner join ifinopl.dbo.agreement_asset aa on (aa.agreement_no		  = am.agreement_no)
					--					left join ifinopl.dbo.agreement_asset_vehicle aav on (aav.asset_no	  = aa.asset_no)
					--			where	am.agreement_no = jd.agreement_no
					--) am
				where	
						jd.account_no in
						(
							'50409105', '50409107', '50409108'
						)
						 AND 
						 CONVERT(varchar(6), jrn.journal_trx_date, 112)  =  convert(varchar(6), @p_cre_date, 112) 


    --select	@p_cre_date
    --		,sld.asset_code
    --		,sld.sold_amount
    --		,ast.condition
    --		,ast.type_code
    --		,ast.merk_code
    --		,ast.type_code_asset
    --		,ast.type_name_asset
    --		,ast.model_code
    --		--
    --		,@p_cre_date				
    --		,@p_cre_by					
    --		,@p_cre_ip_address			
    --		,@p_cre_date				
    --		,@p_cre_by					
    --		,@p_cre_ip_address	
    --from	dbo.sale sl
    --		inner join dbo.sale_detail sld on sld.sale_code = sl.code
    --		inner join dbo.asset ast on ast.code = sld.asset_code
    --where	sld.sale_detail_status in ('APPROVE','PAID')
    --and		sld.is_sold = '1'


	-- (+) Ari 2024-02-12 ket : add log
	if not exists (
					select	1 
					from	dbo.rpt_ext_asset_selling_log
					where	eom = @p_cre_date
				  )
	begin
		insert into dbo.rpt_ext_asset_selling_log
		(
			eom
			,assetno
			,amt
			,assetconditionid
			,assettypeid
			,assetbrandid
			,assetbrandtypeid
			,assetbrandtypename
			,assetmodelid
			,cre_date
			,cre_by
			,cre_ip_address
			,mod_date
			,mod_by
			,mod_ip_address
		)
		select	eom
			   ,assetno
			   ,amt
			   ,assetconditionid
			   ,assettypeid
			   ,assetbrandid
			   ,assetbrandtypeid
			   ,assetbrandtypename
			   ,assetmodelid
			   ,cre_date
			   ,cre_by
			   ,cre_ip_address
			   ,mod_date
			   ,mod_by
			   ,mod_ip_address 
		from	dbo.rpt_ext_asset_selling

	end	

    END TRY
    BEGIN CATCH
        IF (LEN(@msg) <> 0)
        BEGIN
            SET @msg = N'v' + N';' + @msg;
        END;
        ELSE
        BEGIN
            SET @msg = N'e;there is an error.' + N';' + ERROR_MESSAGE();
        END;

        RAISERROR(@msg, 16, -1);

        RETURN;
    END CATCH;
END;

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[xsp_rpt_ext_asset_selling_insert] TO [ims-raffyanda]
    AS [dbo];

