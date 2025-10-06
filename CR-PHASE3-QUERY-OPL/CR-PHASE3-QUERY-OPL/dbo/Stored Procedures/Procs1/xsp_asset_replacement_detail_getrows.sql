CREATE PROCEDURE dbo.xsp_asset_replacement_detail_getrows
(
	@p_keywords				nvarchar(50)
	,@p_pagenumber			int
	,@p_rowspage			int
	,@p_order_by			int
	,@p_sort_by				nvarchar(5)
	--
	,@p_replacement_code	nvarchar(50)
	
)
as
begin

	declare 	@rows_count int = 0 ;

	select 	@rows_count = count(1)
	from	asset_replacement_detail ard
			left join dbo.agreement_asset asta on (asta.asset_no = ard.old_asset_no)
			--left join dbo.agreement_asset astb on (astb.asset_no = ard.new_asset_code)
			left join dbo.sys_general_subcode sgs on (sgs.code = ard.reason_code)
	where	ard.replacement_code = @p_replacement_code
	and		(
					ard.old_asset_no									like 	'%'+@p_keywords+'%'
				or	asta.asset_name										like 	'%'+@p_keywords+'%'
				or	ard.new_fa_code										like 	'%'+@p_keywords+'%'
				or	ard.new_fa_name										like 	'%'+@p_keywords+'%'
				--or	astb.asset_name									like 	'%'+@p_keywords+'%'
				or	ard.replacement_type								like 	'%'+@p_keywords+'%'
				or	sgs.description										like 	'%'+@p_keywords+'%'
				or	convert(varchar(20),ard.estimate_return_date,103)	like 	'%'+@p_keywords+'%'
				or	ard.remark											like 	'%'+@p_keywords+'%'
				or	ard.delivery_address								like 	'%'+@p_keywords+'%'
				or	ard.contact_name									like 	'%'+@p_keywords+'%'
				or	ard.contact_phone_no								like 	'%'+@p_keywords+'%'
			);

	select	ard.id
			,ard.replacement_code
			,ard.old_asset_no
			,asta.asset_name
			,ard.new_fa_code
			,ard.new_fa_name
			--,astb.asset_name 'new_asset_name'
			,case ard.replacement_type when 'PERMANENT' then 'PERMANENT - GTS'
				else 'TEMPORARY'
			end 'replacement_type'
			,ard.reason_code
			,asta.asset_type_code
			,sgs.description 'reason_name'
			,convert(varchar(20),ard.estimate_return_date,103) 'estimate_return_date'
			,ard.remark
			,convert(varchar(20),ard.old_handover_in_date,130) 'old_handover_in_date'
			,convert(varchar(20),ard.old_handover_out_date,130) 'old_handover_out_date'
			,convert(varchar(20),ard.new_handover_out_date,130) 'new_handover_out_date'
			,convert(varchar(20),ard.new_handover_in_date,130) 'new_handover_in_date'
			--(+) Ari 2023-09-12 ket : add plat no
			,asta.fa_reff_no_01 'old_asset_plat_no'
			,ard.new_fa_ref_no_01 'new_asset_plat_no'
			--(+) Ari 2023-09-12
			,ard.delivery_address
			,ard.contact_name
			,ard.contact_phone_no
			,@rows_count	 'rowcount'
	from	asset_replacement_detail ard
			left join dbo.agreement_asset asta on (asta.asset_no = ard.old_asset_no)
			--left join dbo.agreement_asset astb on (astb.asset_no = ard.new_asset_code)
			left join dbo.sys_general_subcode sgs on (sgs.code = ard.reason_code)
	where	ard.replacement_code = @p_replacement_code
	and		(
					ard.old_asset_no									like 	'%'+@p_keywords+'%'
				or	asta.asset_name										like 	'%'+@p_keywords+'%'
				or	ard.new_fa_code										like 	'%'+@p_keywords+'%'
				or	ard.new_fa_name										like 	'%'+@p_keywords+'%'
				--or	astb.asset_name									like 	'%'+@p_keywords+'%'
				or	case ard.replacement_type when 'PERMANENT' then 'PERMANENT - GTS' else 'TEMPORARY' end 								like 	'%'+@p_keywords+'%'
				or	sgs.description										like 	'%'+@p_keywords+'%'
				or	convert(varchar(20),ard.estimate_return_date,103)	like 	'%'+@p_keywords+'%'
				or	ard.remark											like 	'%'+@p_keywords+'%'
				or	ard.delivery_address								like 	'%'+@p_keywords+'%'
				or	ard.contact_name									like 	'%'+@p_keywords+'%'
				or	ard.contact_phone_no								like 	'%'+@p_keywords+'%'
			)
		order by	 case
						when @p_sort_by = 'asc' then case @p_order_by
								when 1	then ard.old_asset_no
								when 2	then ard.new_fa_code
								when 3	then case ard.replacement_type when 'PERMANENT' then 'PERMANENT - GTS' else 'TEMPORARY'	end 
								when 4	then sgs.description
								when 5	then cast(ard.estimate_return_date as sql_variant)
								when 6	then ard.delivery_address
								when 7	then ard.contact_name
								when 8	then ard.contact_phone_no
								when 9	then ard.remark
						end
					end asc
					 ,case
						when @p_sort_by = 'desc' then case @p_order_by
								when 1	then ard.old_asset_no
								when 2	then ard.new_fa_code
								when 3	then case ard.replacement_type when 'PERMANENT' then 'PERMANENT - GTS' else 'TEMPORARY'	end 
								when 4	then sgs.description
								when 5	then cast(ard.estimate_return_date as sql_variant)
								when 6	then ard.delivery_address
								when 7	then ard.contact_name
								when 8	then ard.contact_phone_no
								when 9	then ard.remark
						end
					end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end