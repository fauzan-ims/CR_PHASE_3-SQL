CREATE PROCEDURE [dbo].[xsp_insurance_policy_asset_insert]
(
	@p_code								nvarchar(50)		output
	,@p_policy_code						nvarchar(50)
	,@p_fa_code							nvarchar(50)
	,@p_sum_insured_amount				decimal(18, 2)
	,@p_depreciation_code				nvarchar(50)
	,@p_collateral_type					nvarchar(10)
	,@p_collateral_category_code		nvarchar(50)
	,@p_occupation_code					nvarchar(50)
	,@p_region_code						nvarchar(50)
	,@p_collateral_year					nvarchar(4)
	,@p_is_authorized_workshop			nvarchar(1)
	,@p_is_commercial					nvarchar(1)
	,@p_sppa_code						nvarchar(50)	= null
	,@p_accessories						nvarchar(4000)	= null
	,@p_insert_type						nvarchar(20)	= null
	--
	,@p_cre_date						datetime
	,@p_cre_by							nvarchar(15)
	,@p_cre_ip_address					nvarchar(15)
	,@p_mod_date						datetime
	,@p_mod_by							nvarchar(15)
	,@p_mod_ip_address					nvarchar(15)
)
as
begin
	declare @msg	nvarchar(max)
			,@year	nvarchar(2)
			,@month nvarchar(2) ;

	if @p_is_authorized_workshop = 'T'
		set @p_is_authorized_workshop = '1' ;
	else
		set @p_is_authorized_workshop = '0' ;

	if @p_is_commercial = 'T'
		set @p_is_commercial = '1' ;
	else
		set @p_is_commercial = '0' ;

	begin try

		set @year = substring(cast(datepart(year, @p_cre_date) as nvarchar), 3, 2) ;
		set @month = replace(str(cast(datepart(month, @p_cre_date) as nvarchar), 2, 0), ' ', '0') ;


		exec dbo.xsp_get_next_unique_code_for_table @p_unique_code			= @p_code output
													,@p_branch_code			= 'DSF'
													,@p_sys_document_code	= N''
													,@p_custom_prefix		= 'IPA'
													,@p_year				= @year
													,@p_month				= @month
													,@p_table_name			= 'INSURANCE_POLICY_ASSET'
													,@p_run_number_length	= 6
													,@p_delimiter			= '.'
													,@p_run_number_only		= N'0' ;
		
		insert into insurance_policy_asset
		(
			code
			,policy_code
			,fa_code
			,sum_insured_amount
			,depreciation_code
			,collateral_type
			,collateral_category_code
			,occupation_code
			,region_code
			,collateral_year
			,is_authorized_workshop
			,is_commercial
			,sppa_code
			,accessories
			,insert_type
			--
			,cre_date
			,cre_by
			,cre_ip_address
			,mod_date
			,mod_by
			,mod_ip_address
		)
		values
		(
			@p_code
			,@p_policy_code
			,@p_fa_code
			,@p_sum_insured_amount
			,@p_depreciation_code
			,@p_collateral_type
			,@p_collateral_category_code
			,@p_occupation_code
			,@p_region_code
			,@p_collateral_year
			,@p_is_authorized_workshop
			,@p_is_commercial
			,@p_sppa_code
			,@p_accessories
			,@p_insert_type
			--
			,@p_cre_date
			,@p_cre_by
			,@p_cre_ip_address
			,@p_mod_date
			,@p_mod_by
			,@p_mod_ip_address
		) ;
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
			set @msg = N'E;' + dbo.xfn_get_msg_err_generic() + N';' + error_message() ;
		end ;

		raiserror(@msg, 16, -1) ;

		return ;
	end catch ;
end ;
