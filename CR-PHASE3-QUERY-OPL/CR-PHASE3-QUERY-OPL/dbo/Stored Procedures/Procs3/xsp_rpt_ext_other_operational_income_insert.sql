CREATE PROCEDURE dbo.xsp_rpt_ext_other_operational_income_insert
as
begin
	declare @code			   nvarchar(50)
			,@year			   nvarchar(4)
			,@month			   nvarchar(2)
			,@msg			   nvarchar(max)
			,@p_cre_date	   datetime		=  '2023-11-30'
			,@p_cre_by		   nvarchar(15) = N'JOB'
			,@p_cre_ip_address nvarchar(15) = N'JOB' ;

	begin try
		delete	dbo.rpt_ext_other_operational_income

		insert into rpt_ext_other_operational_income
		(
			eom
			,coa
			,assetconditionid
			,assettypeid
			,assetbrandid
			,assetbrandtypeid
			,assetbrandtypename
			,assetmodelid
			--
			,cre_date
			,cre_by
			,cre_ip_address
			,mod_date
			,mod_by
			,mod_ip_address
		)
		select	EOMONTH(@p_cre_date)
				,jd.account_no
				,am.asset_condition
				,case am.ASSET_TYPE_CODE WHEN 'VHCL' THEN '1'
					WHEN 'HE' THEN '2'
					ELSE 'NA'
				end -- 1 vehicle, 2 he , else NA
				,am.merk_code
				,am.vehicle_model_code
				,am.ASSET_NAME
				,am.model_code
				--
				,@p_cre_date
				,@p_cre_by
				,@p_cre_ip_address
				,@p_cre_date
				,@p_cre_by
				,@p_cre_ip_address
		from	ifinacc.dbo.journal_detail jd
				inner join ifinacc.dbo.journal jo on (jo.code = jd.journal_code)
				outer apply
				(
					select	top 1
							aa.asset_condition
							--,isnull(aav.vehicle_type_code, isnull(aam.machinery_type_code, isnull(aah.he_type_code, ''))) 'type_code'
							,aav.vehicle_merk_code 'merk_code'
							--,isnull(aav.vehicle_merk_code, isnull(aam.machinery_merk_code, isnull(aah.he_merk_code, aae.electronic_merk_code))) 'merk_code'
							,aav.vehicle_model_code
							,aa.asset_name
							,aa.asset_type_code
							--,sgs.description 'asset_type_name'
							 ,right(aav.vehicle_type_code, len(aav.vehicle_type_code)-1-len(aav.vehicle_model_code))'model_code'
							--,isnull(aav.vehicle_model_code, isnull(aam.machinery_model_code, isnull(aah.he_model_code, aae.electronic_model_code))) 'model_code'
					from	dbo.agreement_main am
							inner join dbo.agreement_asset aa on (aa.agreement_no		  = am.agreement_no)
							inner join dbo.sys_general_subcode sgs on (sgs.code			  = aa.asset_type_code)
							left join dbo.agreement_asset_vehicle aav on (aav.asset_no	  = aa.asset_no)
							--left join dbo.agreement_asset_machine aam on (aam.asset_no	  = aa.asset_no)
							--left join dbo.agreement_asset_he aah on (aah.asset_no		  = aa.asset_no)
							--left join dbo.agreement_asset_electronic aae on (aae.asset_no = aa.asset_no)
					where	am.agreement_no = jd.agreement_no
				) am
		WHERE
			jd.account_no in
		(
			'50109101', '50109102', '50109103', '50109104', '50109105', '50109106', '50109201', '50109202', '50109203', '50109204', '50109205', '50129101', '50129102', '50129103', '50129104', '50129105', '50129106', '50129201', '50129202', '50129203', '50129204', '50129205', '50149101', '50149102', '50149103', '50149104', '50149105', '50149106', '50149201', '50149202', '50149203', '50149204', '50149205', '50169101', '50169102', '50169103', '50169104', '50169105', '50169106', '50169201', '50169202', '50169203', '50169204', '50169205', '50209100', '50209101', '50209102', '50209103', '50209104', '50209105', '50209106', '50209200', '50209201', '50209202', '50209203', '50209204', '50209205', '50229100', '50229101', '50229102', '50229103', '50229104', '50229105', '50229106', '50229200', '50229201', '50229202', '50229203', '50229204', '50229205', '50309100', '50309101', '50309102', '50309103', '50309105', '50309200', '50309201', '50309202', '50309203', '50309205', '50409100', '50409101', '50409102', '50409103', '50409104', '50409106', '50409200', '50409201', '50409202', '50409203', '50409204', '50409205', '50501100', '50509100', '50509101', '50509102', '50509103', '50509104', '50601100', '50609100', '50609101', '50609102', '50609103', '50609104', '50701100', '50709100', '50709101', '50709102', '50709103', '50709104', '59000100', '59000101', '59000102', '59000103', '59000104', '59002104', '60101000', '60101001', '60102000', '60103000', '60201000', '60201001', '60202000', '60203000', '60302000', '69001010', '69001020', '69001030', '69001040', '69001050', '80501134'
		)
		AND
		  convert(varchar(6), jo.journal_trx_date, 112)  =  convert(varchar(6), @p_cre_date, 112)    
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
