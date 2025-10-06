CREATE PROCEDURE dbo.xsp_replacement_getrow
(
	@p_code nvarchar(50)
)
as
begin
	declare @total_asset int ;

	select	@total_asset = count(1)
	from	dbo.replacement_detail
	where	replacement_code = @p_code ;

	select	rpl.code
			,rpl.branch_code
			,rpl.branch_name
			,rpl.replacement_date
			,rpl.status
			,rpl.type
			,rpl.cover_note_no
			,rpl.cover_note_date
			,rpl.cover_note_exp_date
			,rpl.new_cover_note_no
			,rpl.new_cover_note_date
			,rpl.new_cover_note_exp_date
			,rpl.file_name
			,rpl.paths
			,rpl.remarks
			,case
				 when rpl.type = 'EXTEND' then '1'
				 else '0'
			 end 'is_extend'
			,@total_asset 'total_asset'
			,@total_asset 'count_asset'
			,vendor_code
			,vendor_name
			,vendor_address
			,vendor_pic_name
			,vendor_pic_area_phone_no
			,vendor_pic_phone_no
	from	replacement rpl
			--left join dbo.replacement_request rr on (rr.replacement_code = rpl.code)
			left join dbo.replacement_request rr on rr.id = rpl.replacement_request_id --(+)raffy 2025/05/13 perubahan join untuk menampilkan identitas vendor imon 2505000066
	where	rpl.code = @p_code ;
end ;
