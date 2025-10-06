CREATE PROCEDURE dbo.xsp_rpt_ext_write_off_insert
as
begin
	declare @msg			   nvarchar(max)
			--,@p_cre_date	   datetime		= '2023-12-31'
			,@p_cre_date	   datetime = dbo.xfn_get_system_date()
			,@p_cre_by		   nvarchar(15) = N'JOB'
			,@p_cre_ip_address nvarchar(15) = N'JOB' 
			,@system_date	   datetime = dbo.xfn_get_system_date()

	if(@p_cre_date < eomonth(@p_cre_date)) -- (+) Ari 2024-02-05 ket : get last eom
	begin
		set @p_cre_date = dateadd(month, -1, @p_cre_date)
		set @p_cre_date = eomonth(@p_cre_date)
	end

	begin try
		delete	dbo.rpt_ext_write_off

		insert into rpt_ext_write_off
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
			---- raffy (+) 2025/08/06 imon 2508000017
			,fa_code
			,registration_class_type
			,asset_name
			--
			,cre_date
			,cre_by
			,cre_ip_address
			,mod_date
			,mod_by
			,mod_ip_address
		)
		select	EOMONTH(@p_cre_date)
				 ,ISNULL(am.agreement_external_no, ISNULL(jd.agreement_no, jo.JOURNAL_REFF_NO))
				,jd.orig_amount_db - jd.orig_amount_cr
				,am.asset_condition
				,case am.asset_type_code WHEN 'VHCL' THEN '1'
					WHEN 'HE' THEN '2'
					ELSE 'NA'
				end -- 1 vehicle, 2 he , else NA
				,am.merk_code
				,am.vehicle_type_code
				,am.asset_name
				,am.model_code
				,am.fa_code
				,am.REGISTRATION_CLASS_TYPE
				,am.fa_name
				--
				--,@p_cre_date
				,@system_date
				,@p_cre_by
				,@p_cre_ip_address
				--,@p_cre_date
				,@system_date
				,@p_cre_by
				,@p_cre_ip_address
		from	ifinacc.dbo.journal_detail jd
				inner join ifinacc.dbo.journal jo on (jo.code = jd.journal_code)
				outer apply
				(
					select	top 1
							am.agreement_external_no
							,aa.asset_condition
							,aav.vehicle_type_code 
							,aav.vehicle_merk_code 'merk_code'
							,aa.asset_type_code
							,aa.asset_name
							,am.currency_code
							,right(aav.vehicle_type_code, len(aav.vehicle_type_code)-1-len(aav.vehicle_model_code)) model_code
							,ISNULL(aa.FA_CODE,aa.REPLACEMENT_FA_CODE)'fa_code'
							,mit.REGISTRATION_CLASS_TYPE
							,ISNULL(aa.FA_NAME,aa.REPLACEMENT_FA_NAME) 'fa_name'
					from	dbo.agreement_main am
							inner join dbo.agreement_asset aa on (aa.agreement_no		  = am.agreement_no)
							inner join dbo.sys_general_subcode sgs on (sgs.code			  = aa.asset_type_code)
							left join dbo.agreement_asset_vehicle aav on (aav.asset_no	  = aa.asset_no)
							outer apply 
							(
								select	mi.registration_class_type 
								from	ifinams.dbo.asset_vehicle av
								inner join ifinbam.dbo.master_item mi on mi.code = av.type_item_code
								where	av.asset_code = isnull(aa.fa_code ,aa.replacement_fa_code)
							)mit
							--left join dbo.agreement_asset_machine aam on (aam.asset_no	  = aa.asset_no)
							--left join dbo.agreement_asset_he aah on (aah.asset_no		  = aa.asset_no)
							--left join dbo.agreement_asset_electronic aae on (aae.asset_no = aa.asset_no)
					where	am.agreement_no = jd.agreement_no
				) am
				where	jd.account_no in
				(
					'70405200', '70405100', '50402202', '50402102', '50409101', '50409109'
				)
				and convert(varchar(6), jo.journal_trx_date, 112)  =  convert(varchar(6), @p_cre_date, 112) 

	-- (+) Ari 2024-02-12 ket : add log
	if not exists (
					select	1 
					from	dbo.rpt_ext_write_off_log
					where	eom = @p_cre_date
				  )
	begin
		insert into dbo.rpt_ext_write_off_log
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
		from	dbo.rpt_ext_write_off		
	end
				 
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

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[xsp_rpt_ext_write_off_insert] TO [ims-raffyanda]
    AS [dbo];

