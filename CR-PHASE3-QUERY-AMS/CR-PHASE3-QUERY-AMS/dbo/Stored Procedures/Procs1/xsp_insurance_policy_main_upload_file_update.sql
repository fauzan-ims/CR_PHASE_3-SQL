CREATE PROCEDURE [dbo].[xsp_insurance_policy_main_upload_file_update]
(
	@p_code		   nvarchar(50)
	,@p_file_name  nvarchar(250)
	,@p_file_paths nvarchar(250)
	,@p_base64	   varchar(max) = null
)
as
begin 

	declare @agreement_no			nvarchar(50)
			,@collateral_no			nvarchar(50)
			,@plafond_no			nvarchar(50)
			,@plafond_collateral_no nvarchar(50)
			,@doc_type				nvarchar(20)
			,@source_type			nvarchar(20)
			,@policy_eff_date		datetime
			,@policy_exp_date		datetime
			,@mod_date				datetime	 = getdate()
			,@mod_by				nvarchar(50) 
			,@mod_ip_address		nvarchar(50) ;

	select	@source_type			= source_type
			,@policy_eff_date		= policy_eff_date
			,@policy_exp_date		= policy_exp_date
			,@mod_ip_address		= mod_ip_address
			,@mod_by				= mod_by
	from	dbo.insurance_policy_main
	where	code					= @p_code ;
	 
	if (
		   isnull(@collateral_no, '') = ''
		   and	isnull(@plafond_no, '') = ''
		   and	isnull(@plafond_collateral_no, '') = ''
	   )
	begin
		set @doc_type = 'AGREEMENT' ;
	end ;
	else if (
				isnull(@plafond_no, '') = ''
				and isnull(@plafond_collateral_no, '') = ''
			)
	begin
		set @doc_type = 'AGREEMENT COLLATERAL' ;
	end ;
	else if (
				isnull(@plafond_collateral_no, '') = ''
				and isnull(@agreement_no, '') = ''
				and isnull(@collateral_no, '') = ''
			)
	begin
		set @doc_type = 'PLAFOND' ;
	end ;
	else if (
				isnull(@agreement_no, '') = ''
				and isnull(@collateral_no, '') = ''
			)
	begin
		set @doc_type = 'PLAFOND COLLATERAL' ;
	end ;

	set @p_file_name = upper(@p_file_name);
	set @p_file_paths = upper(@p_file_paths);

	update	dbo.insurance_policy_main
	set		file_name	= @p_file_name
			,paths		= @p_file_paths
			,doc_file	= cast(@p_base64 as varbinary(max))
	where	code		= @p_code ;

	-- insert ke table interface policy main untuk diterima modul IFINDOC
	--exec dbo.xsp_efam_interface_insurance_policy_main_insert @p_id						= 0
	--														,@p_module					= 'IFININS'
	--														,@p_doc_no					= @p_code
	--														,@p_doc_name				= 'DOCUMENT POLICY'
	--														,@p_doc_type				= @doc_type
	--														,@p_agreement_no			= @agreement_no
	--														,@p_collateral_no			= @collateral_no
	--														,@p_plafond_no				= @plafond_no
	--														,@p_plafond_collateral_no	= @plafond_collateral_no
	--														,@p_policy_eff_date			= @policy_eff_date
	--														,@p_policy_exp_date			= @policy_exp_date
	--														,@p_file_name				= @p_file_name
	--														,@p_paths					= @p_file_paths
	--														,@p_doc_file			    = @p_base64
	--														,@p_cre_date				= @mod_date
	--														,@p_cre_by					= @mod_by
	--														,@p_cre_ip_address			= @mod_ip_address
	--														,@p_mod_date				= @mod_date
	--														,@p_mod_by					= @mod_by
	--														,@p_mod_ip_address			= @mod_ip_address ;
end ;

