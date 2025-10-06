--CREATE by ALIV at 11-05-2023
CREATE PROCEDURE dbo.xsp_ifinams_interface_spaf_asset_getrow
(
	@p_id bigint
)
as
begin
	select	id					
			,code				
			,date				
			,fa_code				
			,spaf_pct			
			,spaf_amount			
			,validation_status	
			,validation_date		
			,validation_remark	
			,claim_code			
	from	ifinams_interface_spaf_asset
	where	id = @p_id ;
end ;
