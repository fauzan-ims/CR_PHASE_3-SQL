create procedure dbo.xsp_agreement_asset_electronic_getrow
(
	@p_asset_no nvarchar(50)
)
as
begin
	select	aae.asset_no
			,aae.colour
			,aae.remarks
			,mvc.description 'electronic_category_desc'
			,mvs.description 'electronic_subcategory_desc'
			,mvm.description 'electronic_merk_desc'
			,mvmo.description 'electronic_model_desc'
			,mvu.description 'electronic_unit_desc'
	from	agreement_asset_electronic aae
			left join dbo.master_electronic_category mvc on (mvc.code	 = aae.electronic_category_code)
			left join dbo.master_electronic_subcategory mvs on (mvs.code = aae.electronic_subcategory_code)
			left join dbo.master_electronic_merk mvm on (mvm.code		 = aae.electronic_merk_code)
			left join dbo.master_electronic_model mvmo on (mvmo.code	 = aae.electronic_model_code)
			left join dbo.master_electronic_unit mvu on (mvu.code		 = aae.electronic_unit_code)
	where	aae.asset_no = @p_asset_no ;
end ;
