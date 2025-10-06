--created by, Bilal at 04/07/2023 

CREATE PROCEDURE dbo.xsp_rpt_kwitansi_spaf
(
	@p_user_id		   nvarchar(max)
	,@p_spaf_code	   nvarchar(50)
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
	delete	dbo.rpt_kwitansi_spaf
	where	user_id = @p_user_id ;

	declare @msg			 nvarchar(max)
			,@report_company nvarchar(250)
			,@report_image	 nvarchar(250)
			,@report_title	 nvarchar(250)
			,@client_name	 nvarchar(250)
			,@currency_desc	 nvarchar(4000)
			,@for_payment	 nvarchar(4000)
			,@payment_with	 nvarchar(4000)
			,@pl_or_cf_no	 nvarchar(50)
			,@on_behalf_of	 nvarchar(250)
			,@total			 decimal(18, 2)
			,@kota			 nvarchar(50)
			,@date			 datetime
			,@nama			 nvarchar(50)
			,@position_name	 nvarchar(250)
			,@branch_code	 nvarchar(50)
			,@no_telp		 nvarchar(50) 
			,@nama_fmd		 nvarchar(50)
			,@claim_type	 nvarchar(100);

	begin try
		select	@report_image = value
		from	dbo.sys_global_param
		where	code = 'IMGDSF' ;

		select	@branch_code = value
		from	dbo.SYS_GLOBAL_PARAM
		where	code = 'HO' ;

		select	@nama			= sbs.signer_name 
				,@position_name = spo.description
		from	ifinsys.dbo.sys_branch_signer sbs
		inner join ifinsys.dbo.sys_employee_position sep on sep.emp_code = sbs.emp_code and sep.base_position='1'
		inner join ifinsys.dbo.sys_position spo on spo.code = sep.position_code
		where	sbs.signer_type_code = 'HFBD'
				and sbs.branch_code = @branch_code ;
		
		select	@nama_fmd			= sbs.signer_name 
		from	ifinsys.dbo.sys_branch_signer sbs
		inner join ifinsys.dbo.sys_employee_position sep on sep.emp_code = sbs.emp_code and sep.base_position='1'
		inner join ifinsys.dbo.sys_position spo on spo.code = sep.position_code
		where	sbs.signer_type_code = 'HFMD'
				and sbs.branch_code = @branch_code ;

		select  @claim_type = claim_type 
		from	dbo.spaf_claim
		where	code = @p_spaf_code

		select	@no_telp = value
		from	dbo.sys_global_param
		where	code = 'tlp2' ;

		set @report_title = N'Report Kwitansi' ;

		insert into dbo.rpt_kwitansi_spaf
		(
			user_id
			,spaf_code
			,nama
			,report_company
			,report_title
			,report_image
			,client_name
			,currency_desc
			,for_payment
			,payment_with
			,pl_or_cf_no
			,on_behalf_of
			,total
			,kota
			,date
			,no_telp
			--
			,cre_date
			,cre_by
			,cre_ip_address
			,mod_date
			,mod_by
			,mod_ip_address
		)
		select	top 1
				@p_user_id
				,@p_spaf_code
				,CASE	WHEN @claim_type = 'OPL SPAF' THEN @nama
					WHEN @claim_type = 'OPL Subsidy (FE)' THEN @nama
					WHEN @claim_type = 'OPL Subsidy (FUSO)' THEN @nama
					ELSE @nama_fmd
				end
				,@report_company
				,@report_title
				,@report_image
				,'PT. Dipo Star Finance'	--aa.client_name
				,dbo.terbilang(spaf.CLAIM_AMOUNT + spaf.PPN_AMOUNT)
				,case
					 when spaf.CLAIM_TYPE = 'OPL SPAF' then 'SALES PROMOTION ASSISTANCE FEE KENDARAAN MITSUBISHI(MFTBC)' + spaf.CLAIM_TYPE + ' - ' + 'Bulan ' + cast(datename(month, spaf.FAKTUR_DATE) as nvarchar(50)) + ' ' + cast(year(spaf.FAKTUR_DATE) as nvarchar(50))
					 else 'INSENTIF PEMBIAYAAN MITSUBISHI ' + spaf.CLAIM_TYPE + ' - ' + 'Bulan ' + cast(datename(month, spaf.FAKTUR_DATE) as nvarchar(50)) + ' ' + cast(year(spaf.FAKTUR_DATE) as nvarchar(50))
				 end
				,@payment_with
				,@pl_or_cf_no
				,@on_behalf_of
				,spaf.CLAIM_AMOUNT + spaf.PPN_AMOUNT
				,'JAKARTA'
				,spaf.FAKTUR_DATE
				,@no_telp
											--
				,@p_cre_date
				,@p_cre_by
				,@p_cre_ip_address
				,@p_mod_date
				,@p_mod_by
				,@p_mod_ip_address
		from	dbo.SPAF_CLAIM					 spaf
				inner join dbo.SPAF_CLAIM_DETAIL spafd on (spaf.CODE = spafd.SPAF_CLAIM_CODE)
				inner join dbo.SPAF_ASSET		 spaa on (spaa.CODE	 = spafd.SPAF_ASSET_CODE)
				inner join dbo.ASSET			 aa on (aa.CODE		 = spaa.FA_CODE)
		where	spaf.CODE = @p_spaf_code ;
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
			if (
				   error_message() like '%V;%'
				   or	error_message() like '%E;%'
			   )
			begin
				set @msg = error_message() ;
			end ;
			else
			begin
				set @msg = N'E;' + dbo.xfn_get_msg_err_generic() + N';' + error_message() ;
			end ;
		end ;

		raiserror(@msg, 16, -1) ;

		return ;
	end catch ;
end ;
