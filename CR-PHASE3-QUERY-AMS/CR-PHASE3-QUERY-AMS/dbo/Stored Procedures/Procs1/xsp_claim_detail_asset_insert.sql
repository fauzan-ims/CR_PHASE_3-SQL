CREATE PROCEDURE [dbo].[xsp_claim_detail_asset_insert]
(
	@p_id				  bigint = 0 output
	,@p_claim_code		  nvarchar(50)
	,@p_policy_asset_code nvarchar(50)
	--
	,@p_cre_date		  datetime
	,@p_cre_by			  nvarchar(15)
	,@p_cre_ip_address	  nvarchar(15)
	,@p_mod_date		  datetime
	,@p_mod_by			  nvarchar(15)
	,@p_mod_ip_address	  nvarchar(15)
)
as
begin
	declare @msg		nvarchar(max)
			,@remark	nvarchar(4000)

	begin try
		insert into claim_detail_asset
		(
			claim_code
			,policy_asset_code
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
			@p_claim_code
			,@p_policy_asset_code
			--
			,@p_cre_date
			,@p_cre_by
			,@p_cre_ip_address
			,@p_mod_date
			,@p_mod_by
			,@p_mod_ip_address
		) ;

		set @p_id = @@identity ;

		select	@remark = stuff((
							select	distinct
									',' + avh.plat_no + avh.engine_no + avh.chassis_no
							from	dbo.claim_detail_asset				  cda
									inner join dbo.insurance_policy_asset ipa on cda.policy_asset_code = ipa.code
									inner join dbo.asset_vehicle		  avh on avh.asset_code		   = ipa.fa_code
							where	cda.claim_code = @p_claim_code
							for xml path('')
						), 1, 1, ''
					   ) ;

		update dbo.claim_main
		set asset_info		= @remark
			--
			,mod_by			= @p_mod_by
			,mod_date		= @p_mod_date
			,mod_ip_address	= @p_mod_ip_address
		where code			= @p_claim_code
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
