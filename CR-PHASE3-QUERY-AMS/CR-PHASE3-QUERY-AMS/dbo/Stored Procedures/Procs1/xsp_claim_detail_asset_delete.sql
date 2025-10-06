CREATE PROCEDURE [dbo].[xsp_claim_detail_asset_delete]
(
	@p_id bigint
)
as
begin
	declare @msg		nvarchar(max)
			,@code		nvarchar(50)
			,@remark	nvarchar(4000)
	begin try
		select @code = claim_code 
		from dbo.claim_detail_asset
		where id = @p_id

		delete	claim_detail_asset
		where	id = @p_id ;

		select	@remark = stuff((
							select	distinct
									',' + avh.plat_no + avh.engine_no + avh.chassis_no
							from	dbo.claim_detail_asset				  cda
									inner join dbo.insurance_policy_asset ipa on cda.policy_asset_code = ipa.code
									inner join dbo.asset_vehicle		  avh on avh.asset_code		   = ipa.fa_code
							where	cda.claim_code = @code
							for xml path('')
						), 1, 1, ''
					   ) ;

		update dbo.claim_main
		set asset_info		= @remark
		where code			= @code
	end try
	begin catch
		declare @error int ;

		set @error = @@error ;

		if (@error = 2627)
		begin
			set @msg = dbo.xfn_get_msg_err_code_already_exist() ;
		end ;
		else if (@error = 547)
		begin
			set @msg = dbo.xfn_get_msg_err_code_already_used() ;
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
