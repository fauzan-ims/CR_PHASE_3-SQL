CREATE PROCEDURE [dbo].[xsp_deposit_move_getrows]
(
	@p_keywords		nvarchar(50)
	,@p_pagenumber	int
	,@p_rowspage	int
	,@p_order_by	int
	,@p_sort_by		nvarchar(5)
	,@p_branch_code nvarchar(50)
	,@p_move_status nvarchar(10)
)
as
begin
	declare @rows_count int = 0 ;
	if exists ( select 1 from sys_global_param where code ='HO' and value = @p_branch_code)
	begin
		set @p_branch_code = 'ALL'
	end

	select	@rows_count = count(1)
	from	deposit_move dm
			inner join dbo.agreement_main amf on (amf.agreement_no = dm.from_agreement_no)
			--inner join dbo.agreement_main amt on (amt.agreement_no = dm.to_agreement_no) -- Louis Senin, 30 Juni 2025 16.53.13 -- 
	where	dm.branch_code	   = case @p_branch_code
									 when 'ALL' then dm.branch_code
									 else @p_branch_code
								 end
			and dm.move_status = case @p_move_status
									 when 'ALL' then dm.move_status
									 else @p_move_status
								 end
			and (
					dm.code										like '%' + @p_keywords + '%'
					or	dm.branch_name							like '%' + @p_keywords + '%'
					or	convert(varchar(30), dm.move_date, 103) like '%' + @p_keywords + '%'
					or	amf.agreement_external_no				like '%' + @p_keywords + '%'
					or	amf.client_name							like '%' + @p_keywords + '%'
					-- Louis Senin, 30 Juni 2025 16.53.24 -- 
					--or	amt.agreement_external_no				like '%' + @p_keywords + '%'
					--or	amt.client_name							like '%' + @p_keywords + '%'
					-- Louis Senin, 30 Juni 2025 16.53.27 -- 
					or	dm.move_status							like '%' + @p_keywords + '%'
				) ;

		select		dm.code
					,dm.branch_name							
					,convert(varchar(30), dm.move_date, 103) 'move_date'
					,amf.agreement_external_no 'from_agreement_no'				
					,amf.client_name 'from_client_name'						
					-- Louis Senin, 30 Juni 2025 16.53.24 -- 	
					--,amt.agreement_external_no 'to_agreement_no'	 			
					--,amt.client_name 'to_client_name'				
					-- Louis Senin, 30 Juni 2025 16.53.24 -- 			
					,dm.move_status							
					,@rows_count 'rowcount'
		from		deposit_move dm
					inner join dbo.agreement_main amf on (amf.agreement_no = dm.from_agreement_no)
					--inner join dbo.agreement_main amt on (amt.agreement_no = dm.to_agreement_no) -- Louis Senin, 30 Juni 2025 16.53.49 -- 
		where		dm.branch_code	   = case @p_branch_code
											 when 'ALL' then dm.branch_code
											 else @p_branch_code
										 end
					and dm.move_status = case @p_move_status
											 when 'ALL' then dm.move_status
											 else @p_move_status
										 end
					and (
							dm.code										like '%' + @p_keywords + '%'
							or	dm.branch_name							like '%' + @p_keywords + '%'
							or	convert(varchar(30), dm.move_date, 103) like '%' + @p_keywords + '%'
							or	amf.agreement_external_no				like '%' + @p_keywords + '%'
							or	amf.client_name							like '%' + @p_keywords + '%'
							-- Louis Senin, 30 Juni 2025 16.53.24 -- 
							--or	amt.agreement_external_no				like '%' + @p_keywords + '%'
							--or	amt.client_name							like '%' + @p_keywords + '%'
							-- Louis Senin, 30 Juni 2025 16.53.24 -- 
							or	dm.move_status							like '%' + @p_keywords + '%'
						)
		order by	case
					when @p_sort_by = 'asc' then case @p_order_by
														when 1 then dm.code
														when 2 then dm.branch_name							
														when 3 then cast(dm.move_date as sql_variant)
														when 4 then amf.agreement_external_no				
														--when 5 then amt.agreement_external_no -- Louis Senin, 30 Juni 2025 16.54.07 -- 				
														when 5 then dm.move_status	
												 end
					end asc
					,case
					 when @p_sort_by = 'desc' then case @p_order_by
														when 1 then dm.code
														when 2 then dm.branch_name							
														when 3 then cast(dm.move_date as sql_variant)
														when 4 then amf.agreement_external_no				
														--when 5 then amt.agreement_external_no	 -- Louis Senin, 30 Juni 2025 16.54.07 -- 			
														when 5 then dm.move_status
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
