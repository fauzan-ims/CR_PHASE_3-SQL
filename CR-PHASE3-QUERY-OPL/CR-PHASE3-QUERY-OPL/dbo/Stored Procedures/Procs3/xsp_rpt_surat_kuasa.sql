--Created by, Rian at 26/06/2023 

--created by, Rian at 24/03/2023 

CREATE PROCEDURE dbo.xsp_rpt_surat_kuasa
(
	@p_code			   nvarchar(50)
	,@p_user_id		   nvarchar(50)
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
	declare @skt_no			  nvarchar(50)
			,@company_name	  nvarchar(50)
			,@company_city	  nvarchar(50)
			,@company_address nvarchar(400)
			,@asset_no		  nvarchar(50)
			,@report_title	  nvarchar(50)
			,@report_image	  nvarchar(250) ;

	--delete data di tabel report
	delete	dbo.rpt_surat_kuasa
	where	user_id = @p_user_id

	--select company name dari global param
	select	@company_name = value
	from	dbo.sys_global_param
	where	code = 'COMP' ;

	--select company cty dari global param
	select	@company_city = value
	from	dbo.sys_global_param
	where	code = 'INVCITY' ;

	--select company address dari global param
	select	@company_address = value
	from	dbo.sys_global_param
	where	code = 'INVADD' ;

	--set report image dari global param
	select	@report_image = value
	from	dbo.sys_global_param
	where	code = 'IMGRPT' ;

	--set report titel, memberikan judul terhadap report
	set @report_title = 'SURAT KUASA' ;

	insert into dbo.rpt_surat_kuasa
	(
		user_id
		,report_company_name
		,report_title
		,report_image
		,company_city
		,company_address
		,letter_no
		,agreement_no
		,signer_collector
		,signer_collector_position
		,collector
		,collector_position
		,agreement_sign_date
		,client_name
		,client_address
		,client_phone_no
		,asset_no
		,asset_name
		,asset_year
		,fa_reff_no_01
		,fa_reff_no_02
		,fa_ref_no_03
		,asset_type_code
		,LETTER_EXP_DATE
		--
		,cre_date
		,cre_by
		,cre_ip_address
		,mod_date
		,mod_by
		,mod_ip_address
	)
	select	@p_user_id
			,@company_name
			,@report_title
			,@report_image
			,@company_city
			,@company_address
			,rl.letter_no
			,rl.agreement_no
			,rl.letter_signer_collector_name
			,rl.letter_signer_collector_position
			,rl.letter_collector_name
			,rl.letter_collector_position
			,am.agreement_sign_date
			,aas.deliver_to_name
			,aas.deliver_to_address
			,aas.deliver_to_area_no + aas.deliver_to_phone_no
			,aas.fa_code
			,aas.fa_name
			,aas.asset_year
			,aas.fa_reff_no_01
			,aas.fa_reff_no_02
			,aas.fa_reff_no_03
			,aas.asset_type_code
			,rl.letter_exp_date
			--
			,@p_cre_date
			,@p_cre_by
			,@p_cre_ip_address
			,@p_mod_date
			,@p_mod_by
			,@p_mod_ip_address
	from	dbo.repossession_letter rl
			left join dbo.repossession_letter_collateral rlc on (rlc.letter_code = rl.code)
			left join dbo.agreement_main am on (am.agreement_no					 = rl.agreement_no)
			left join dbo.agreement_asset aas on (aas.asset_no					 = rlc.asset_no)
	where	rl.code = @p_code ;
end ;
