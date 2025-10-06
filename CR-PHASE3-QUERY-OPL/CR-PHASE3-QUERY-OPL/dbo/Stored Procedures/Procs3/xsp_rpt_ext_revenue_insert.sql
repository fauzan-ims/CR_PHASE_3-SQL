CREATE PROCEDURE dbo.xsp_rpt_ext_revenue_insert
AS
BEGIN
	DECLARE @code			   NVARCHAR(50)
			,@year			   NVARCHAR(4)
			,@month			   NVARCHAR(2)
			,@msg			   NVARCHAR(MAX)
			--,@p_cre_date	   datetime		= '2023-12-31'
			,@p_cre_date	   DATETIME = dbo.xfn_get_system_date()
			,@p_cre_by		   NVARCHAR(15) = N'JOB'
			,@p_cre_ip_address NVARCHAR(15) = N'JOB' 
			,@system_date	   DATETIME = dbo.xfn_get_system_date()

	IF(@p_cre_date < EOMONTH(@p_cre_date)) -- (+) Ari 2024-02-05 ket : get last eom
	begin
		SET @p_cre_date = DATEADD(MONTH, -1, @p_cre_date)
		SET @p_cre_date = EOMONTH(@p_cre_date)
	END

	BEGIN TRY
		DELETE	dbo.rpt_ext_revenue

		INSERT INTO rpt_ext_revenue
		(
			eom
			,agrmntno
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
		SELECT	EOMONTH(@p_cre_date)
				, ISNULL(am.agreement_external_no, ISNULL(jd.agreement_no, jo.JOURNAL_REFF_NO))
				, jd.orig_amount_cr - jd.orig_amount_db
				,am.asset_condition
				,CASE am.ASSET_TYPE_CODE WHEN 'VHCL' THEN '1'
					WHEN 'HE' THEN '2'
					ELSE 'NA'
				end -- 1 vehicle, 2 he , else NA
				,am.merk_code
				,am.vehicle_type_code
				,am.ASSET_NAME
				,am.model_code
				,am.fa_code   
				,am.registration_class_type
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
					,aa.ASSET_NAME
					,right(aav.vehicle_type_code, len(aav.vehicle_type_code)-1-len(aav.vehicle_model_code)) model_code
					,isnull(aa.fa_code, aa.replacement_fa_code)'fa_code'
					,mit.REGISTRATION_CLASS_TYPE
					,aa.fa_name
			from	dbo.agreement_main am
					inner join dbo.agreement_asset aa on (aa.agreement_no		  = am.agreement_no)
					inner join dbo.sys_general_subcode sgs on (sgs.code			  = aa.asset_type_code)
					left join dbo.agreement_asset_vehicle aav on (aav.asset_no	  = aa.asset_no)
					outer apply 
					(
						select	mi.registration_class_type 
						from	ifinams.dbo.asset_vehicle av
						inner join ifinbam.dbo.master_item mi on mi.code = av.type_item_code or av.type_item_code = mi.type_code
						where	av.asset_code = isnull(aa.fa_code ,aa.replacement_fa_code)
					)mit
					--left join dbo.agreement_asset_machine aam on (aam.asset_no	  = aa.asset_no)
					--left join dbo.agreement_asset_he aah on (aah.asset_no		  = aa.asset_no)
					--left join dbo.agreement_asset_electronic aae on (aae.asset_no = aa.asset_no)
			where	am.agreement_no = jd.agreement_no
		) am
		where	jd.account_no in
		(
			'50401304', '50401100', '50401101', '50401102', '50401103', '50401104', '50401107', '50401200', '50401202', '50401203', '50401204', '50401303'
		)
		and convert(varchar(6), jo.journal_trx_date, 112)  =  convert(varchar(6), @p_cre_date, 112) 


		 -- (+) Ari 2024-02-12 ket : add log 
		if not exists (
							select	1 
							from	dbo.rpt_ext_revenue_log
							where	eom = @p_cre_date
					   )
		begin
			insert dbo.rpt_ext_revenue_log
			(
				eom
				,agrmntno
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
				   ,agrmntno
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
			from	dbo.rpt_ext_revenue
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
			set @msg = N'v' + N';' + @msg ;
		end ;
		else
		begin
			if (
				   error_message() like '%v;%'
				   or	error_message() like '%e;%'
			   )
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
