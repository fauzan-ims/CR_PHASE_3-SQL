CREATE PROCEDURE dbo.xsp_rpt_ext_interest_expense_insert
as
begin
	declare @code			   nvarchar(50)
			,@year			   nvarchar(4)
			,@month			   nvarchar(2)
			,@msg			   nvarchar(max)
			--,@p_cre_date	   datetime		= '2023-12-31'
			,@p_cre_date			datetime = dbo.xfn_get_system_date()
			,@p_cre_by		   nvarchar(15) = N'JOB'
			,@p_cre_ip_address nvarchar(15) = N'JOB' 
			,@system_date	   datetime = dbo.xfn_get_system_date()

	if(@p_cre_date < eomonth(@p_cre_date)) -- (+) Ari 2024-02-05 ket : get last eom
	begin
		set @p_cre_date = dateadd(month, -1, @p_cre_date)
		set @p_cre_date = eomonth(@p_cre_date)
	end

	begin TRY
    /*
		Kondisi
	agreement join agreement asset
	yang masih aktif sampai tanggal cetak
	tampilkan data per asset
	*/
		delete	dbo.rpt_ext_interest_expense

		insert into rpt_ext_interest_expense
		(
			eom
			,agrmntno
			,golivedate
			,tenor
			,osni
			,assetconditionid
			,assettypeid
			,assetbrandid
			,assetbrandtypeid
			,assetbrandtypename
			,assetmodelid
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
		select	@p_cre_date
				,am.agreement_external_no
				,am.agreement_date
				,am.periode
				,ass.net_book_value_comm
				,ags.asset_condition
				, case ags.asset_type_code WHEN 'VHCL' THEN '1'
					WHEN 'HE' THEN '2'
					ELSE 'NA'
				end -- 1 vehicle, 2 he , else NA
				,asv.vehicle_merk_code
				,asv.vehicle_type_code
				,mvm.description
				, right(asv.vehicle_type_code, len(asv.vehicle_type_code)-1-len(asv.vehicle_model_code))  
				,ass.code
				,mit.registration_class_type
				,ass.item_name
				--
				--,@p_cre_date
				,@system_date
				,@p_cre_by
				,@p_cre_ip_address
				--,@p_cre_date
				,@system_date
				,@p_cre_by
				,@p_cre_ip_address
		from	dbo.agreement_main am
				inner join dbo.agreement_asset ags on (ags.agreement_no	   = am.agreement_no)
				INNER JOIN dbo.agreement_asset_vehicle asv on (asv.asset_no = ags.asset_no)
				left join master_vehicle_merk mvm on( asv.vehicle_merk_code = mvm.code)
				--left join dbo.application_main apm on (apm.application_no  = am.application_no)
				--left join dbo.master_vehicle_type mvt on (mvt.code		   = asv.vehicle_type_code)
				left join ifinams.dbo.asset ass on (ags.fa_code			   = ass.code)
				outer apply 
				(
					select	mi.registration_class_type 
					from	ifinams.dbo.asset_vehicle av
					inner join ifinbam.dbo.master_item mi on mi.code = av.type_item_code
					where	av.asset_code = ass.code
				)mit
		where	(am.termination_date is null or convert(varchar(6), am.termination_date, 112)  >= convert(varchar(6),@p_cre_date , 112) ) -- yang masih aktif sampai tanggalccetak
			 --SELECT * FROM agreement_asset
			 --SELECT * FROM agreement_asset_vehicle
			 --SELECT * FROM  ifinams.dbo.asset
			 --SELECT * FROM dbo.MASTER_VEHICLE_MERK
			 --SELECT * FROM master_vehicle_type

		
		-- (+) Ari 2024-02-12 ket : add log
		if not exists (
						select	1 
						from	dbo.rpt_ext_interest_expense_log
						where	eom = @p_cre_date
					  )
		begin
			insert dbo.rpt_ext_interest_expense_log
			(
				eom
				,agrmntno
				,golivedate
				,tenor
				,osni
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
				   ,golivedate
				   ,tenor
				   ,osni
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
			from	dbo.rpt_ext_interest_expense
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
