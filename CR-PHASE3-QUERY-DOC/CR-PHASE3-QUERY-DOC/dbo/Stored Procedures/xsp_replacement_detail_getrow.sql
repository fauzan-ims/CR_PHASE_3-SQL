CREATE procedure dbo.xsp_replacement_detail_getrow
(
	@p_id bigint
)
as
begin
	select	rpd.id
			,rpd.replacement_code
			,rpd.replacement_request_detail_id
			,rpd.asset_no
			,fam.asset_name
			,fam.reff_no_1
			,fam.reff_no_2
			,fam.reff_no_3
			,rpd.type
			,rpd.bpkb_no
			,rpd.bpkb_date
			,rpd.bpkb_name
			,rpd.bpkb_address
			,rpd.stnk_name
			,rpd.stnk_exp_date
			,rpd.stnk_tax_date
			,rpd.file_name
			,rpd.paths
			,rp.status
	from	replacement_detail rpd
			inner join dbo.replacement rp on (rp.code			= rpd.replacement_code)
			left join dbo.fixed_asset_main fam on (fam.asset_no = rpd.asset_no)
	where	rpd.id = @p_id ;
end ;
