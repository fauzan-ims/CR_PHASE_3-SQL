--created by, Rian at 16/05/2023 

CREATE PROCEDURE dbo.xsp_sys_general_subcode_lookup_for_area_blacklist_transaction_detail
(
	@p_keywords						    nvarchar(50)
	,@p_pagenumber					    int
	,@p_rowspage					    int
	,@p_order_by					    int
	,@p_sort_by						    nvarchar(5)
	,@p_area_blacklist_transaction_code nvarchar(50)
)
as
begin
	declare @rows_count int = 0 ;
	
	select	@rows_count = count(1)
	from	sys_general_subcode sgs
	where	not exists
			(
				select	abtd.zip_code_code
				from	dbo.area_blacklist_transaction_detail abtd
				where	abtd.zip_code_code						 = sgs.code
						and abtd.area_blacklist_transaction_code = @p_area_blacklist_transaction_code
			)
			and sgs.general_code = ''
			and (
					sgs.code			like '%' + @p_keywords + '%'
					or	sgs.description like '%' + @p_keywords + '%'
				) ;

		select		sgs.code
					,sgs.description
					,@rows_count 'rowcount'
		from		sys_general_subcode sgs
		where		not exists
					(
						select	abtd.zip_code_code
						from	dbo.area_blacklist_transaction_detail abtd
						where	abtd.zip_code_code						 = sgs.code
								and abtd.area_blacklist_transaction_code = @p_area_blacklist_transaction_code
					)
					and sgs.general_code = 'JOB'
					and (
							sgs.code			like '%' + @p_keywords + '%'
							or	sgs.description like '%' + @p_keywords + '%'
						)

		order by 	case  
						when @p_sort_by = 'asc' then case @p_order_by
														when 1 then sgs.code
														when 2 then sgs.description
						  							end
					end asc 
					,case 
						when @p_sort_by = 'desc' then case @p_order_by
														when 1 then sgs.code
														when 2 then sgs.description
						  							end
					end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
