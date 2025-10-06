CREATE PROCEDURE [dbo].[xsp_tbo_document_detail_getrows]
(
	@p_keywords		   NVARCHAR(50)
	,@p_pagenumber	   INT
	,@p_rowspage	   INT
	,@p_order_by	   INT
	,@p_sort_by		   NVARCHAR(5)
	,@p_id			   BIGINT
	,@p_is_tbo		   NVARCHAR(1) = '0'
)
AS
BEGIN
	DECLARE @rows_count INT = 0 
			,@transaction_no	NVARCHAR(50)
			,@application_no	NVARCHAR(50);
	
	select	@transaction_no		= transaction_no
			,@application_no	= application_no
	from	dbo.tbo_document
	where	id = @p_id

	if exists
	(
		select	1
		from	dbo.tbo_document
		where	id = @p_id
				and	transaction_name = 'MASTER CONTRACT'
	)
	begin	

		select	@rows_count = count(1)
		from	dbo.tbo_document_detail rd
				inner join dbo.sys_general_document sgd on (sgd.code = rd.document_code)
		where	application_no = @application_no
				--and ad.promise_date is not null
				and (
						sgd.document_name								like '%' + @p_keywords + '%'
						or	rd.remarks									like '%' + @p_keywords + '%'
						--or	convert(varchar(30), ad.expired_date, 103)	like '%' + @p_keywords + '%'
						or	case rd.is_required
								when '1' then '*'
								else ''
							end											like '%' + @p_keywords + '%'
					) ;

		select		id
					,sgd.document_name
					,convert(varchar(30), rd.promise_date, 103) 'promise_date'
					,case rd.is_required
							when '1' then '*'
							else ''
						end 'is_required'
					,rd.is_valid
					,rd.remarks
					,rd.is_received
					,@rows_count 'rowcount'
		from		dbo.TBO_DOCUMENT_DETAIL rd
					inner join dbo.sys_general_document sgd on (sgd.code = rd.document_code)
		where		application_no = @application_no
					--and ad.promise_date is not null
					and (
							sgd.document_name								like '%' + @p_keywords + '%'
							or	rd.remarks									like '%' + @p_keywords + '%'
							--or	convert(varchar(30), ad.expired_date, 103)	like '%' + @p_keywords + '%'
							or	case rd.is_required
									when '1' then '*'
									else ''
								end											like '%' + @p_keywords + '%'
						)
		order by	case
						when @p_sort_by = 'asc' then case @p_order_by
															when 1 then sgd.document_name
															when 2 then cast(rd.promise_date as sql_variant)
															when 3 then rd.remarks
															--when 3 then cast(ad.expired_date as sql_variant)
															--when 4 then cast(ad.promise_date as sql_variant)
														
														end
					end asc
					,case
							when @p_sort_by = 'desc' then case @p_order_by
															when 1 then sgd.document_name
															when 2 then cast(rd.promise_date as sql_variant)
															when 3 then rd.remarks
															--when 3 then cast(ad.expired_date as sql_variant)
															--when 4 then cast(ad.promise_date as sql_variant)
														end
					end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;     
	end
    else
    begin
	select	@rows_count = count(1)
	from	dbo.TBO_DOCUMENT_DETAIL rd
			inner join dbo.sys_general_document sgd on (sgd.code = rd.document_code)
	where	rd.reff_code = @transaction_no
			--and rd.promise_date is not null
			and (
					sgd.document_name								like '%' + @p_keywords + '%'
					or	convert(varchar(30), rd.promise_date, 103)	like '%' + @p_keywords + '%' 
					or	case rd.is_required
							when '1' then '*'
							else ''
						end											like '%' + @p_keywords + '%'
				) ;

	select		id
				,sgd.document_name'document_name'
				,convert(varchar(30), rd.promise_date, 103) 'promise_date'
				,case rd.is_required
						when '1' then '*'
						else ''
					end 'is_required'
				,rd.is_valid'is_valid'
				,rd.is_received 'is_received'
				,rd.remarks 'remarks'
				,@rows_count 'rowcount'
	from		dbo.TBO_DOCUMENT_DETAIL rd
				inner join dbo.sys_general_document sgd on (sgd.code = rd.document_code)
	where		rd.reff_code = @transaction_no
				--and rd.promise_date is not null
				and (
						sgd.document_name								like '%' + @p_keywords + '%'
						or	rd.remarks									like '%' + @p_keywords + '%'
						or	convert(varchar(30), rd.promise_date, 103)	like '%' + @p_keywords + '%'
						or	case rd.is_required
								when '1' then '*'
								else ''
							end											like '%' + @p_keywords + '%'
					)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
														when 1 then sgd.document_name
														when 2 then cast(rd.promise_date as sql_variant)
														when 3 then rd.remarks
														--when 3 then cast(rd.expired_date as sql_variant)
														--when 4 then cast(rd.promise_date as sql_variant)
													
													end
				end asc
				,case
						when @p_sort_by = 'desc' then case @p_order_by
														when 1 then sgd.document_name
														when 2 then cast(rd.promise_date as sql_variant)
														when 3 then rd.remarks
														--when 3 then cast(rd.expired_date as sql_variant)
														--when 4 then cast(rd.promise_date as sql_variant)
													end
				end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;   
		

	end
		
end ;

