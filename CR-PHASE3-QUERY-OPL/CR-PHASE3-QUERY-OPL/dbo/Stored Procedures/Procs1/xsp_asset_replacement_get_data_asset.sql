CREATE procedure xsp_asset_replacement_get_data_asset
as
begin
	select ard.new_fa_code 
	from		dbo.asset_replacement ar
	inner join	dbo.asset_replacement_detail ard on (ard.replacement_code = ar.code)
	where		ar.STATUS not in ('DONE', 'CANCEL')
end
