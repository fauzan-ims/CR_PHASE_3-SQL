--CREATED by ALIV at 11/05/2023
CREATE PROCEDURE dbo.xsp_spaf_asset_getrow
(
	@p_code nvarchar(50)
)
as
begin
	select	code
			,date				
			,fa_code			
			,spaf_pct			
			,spaf_amount		
			,validation_status	
			,validation_date	
			,validation_remark	
			,claim_code			
			,mod_date			
			,mod_by				
			,mod_ip_address		
	from	spaf_asset
	where	code = @p_code ;
end ;
