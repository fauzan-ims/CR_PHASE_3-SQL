CREATE PROCEDURE dbo.xsp_mutation_receive_getrows
(
	@p_keywords				nvarchar(50)
	,@p_pagenumber			int
	,@p_rowspage			int
	,@p_order_by			int
	,@p_sort_by				nvarchar(5)
	,@p_branch_code			nvarchar(50)	= 'ALL'
	,@p_location_code		nvarchar(50)	= ''
	,@p_filter_type			nvarchar(5)
	,@p_status_received		nvarchar(20)	= 'ALL'
)
as
begin
	declare @rows_count int = 0 ;

	if(@p_status_received = 'ALL')
	begin
		if(@p_filter_type = 'FROM')
		begin
			select	@rows_count = count(1)
			from	dbo.mutation_detail md
					inner join dbo.mutation mt on (mt.code = md.mutation_code)
					inner join dbo.asset ass on (ass.code  = md.asset_code)
					--inner join dbo.mutation_document mdc on (mdc.mutation_code = mt.code) 
			where	mt.from_branch_code		  = case @p_branch_code
												when 'ALL' then mt.from_branch_code
												else @p_branch_code
											end
			and		mt.from_location_code	  = case @p_location_code
												when '' then mt.from_location_code
												else @p_location_code
											end
			--and		md.status_received = case @p_status_received
			--			when 'ALL' then md.status_received
			--			else @p_status_received
			--		end
			and		md.status_received in ('SENT', 'RECEIVED')
			and		(
						mt.code												 like '%' + @p_keywords + '%'
						or	md.asset_code									 like '%' + @p_keywords + '%'
						or	md.description									 like '%' + @p_keywords + '%'
						or	mt.from_branch_name								 like '%' + @p_keywords + '%'
						or	mt.to_branch_name								 like '%' + @p_keywords + '%'
						or	ass.item_name									 like '%' + @p_keywords + '%'
						or	ass.item_code									 like '%' + @p_keywords + '%'
						or	mt.status										 like '%' + @p_keywords + '%'
						or	md.status_received								 like '%' + @p_keywords + '%'
						or	mt.code											 like '%' + @p_keywords + '%'
						or	convert(nvarchar(30), mt.mutation_date, 103)	 like '%' + @p_keywords + '%'
						or	convert(nvarchar(30), md.receive_date, 103)		 like '%' + @p_keywords + '%'
						or	ass.barcode										 like '%' + @p_keywords + '%'
						or	md.remark_return								 like '%' + @p_keywords + '%'
						or	md.remark_unpost								 like '%' + @p_keywords + '%'
						or	md.file_name									 like '%' + @p_keywords + '%'
						or	md.path											 like '%' + @p_keywords + '%'
					) ;

			select		md.mutation_code
						,md.asset_code
						,convert(nvarchar(30), mt.mutation_date, 103) 'mutation_date'
						,convert(nvarchar(30), md.receive_date, 103) 'receive_date'
						,md.receive_date 'receive_date_default'
						,mt.code
						,mt.status
						,md.status_received
						,mt.requestor_code
						,md.remark_return
						,md.remark_unpost
						,ass.barcode
						,md.id
						,mt.to_branch_name
						,mt.from_branch_name
						,md.description
						,md.file_name
						,md.path
						,@rows_count 'rowcount'
			from		dbo.mutation_detail md
						inner join dbo.mutation mt on (mt.code = md.mutation_code)
						inner join dbo.asset ass on (ass.code  = md.asset_code)
						--inner join dbo.mutation_document mdc on (mdc.mutation_code = mt.code)
			where	mt.from_branch_code		  = case @p_branch_code
												when 'ALL' then mt.from_branch_code
												else @p_branch_code
											end
			and		mt.from_location_code	  = case @p_location_code
												when '' then mt.from_location_code
												else @p_location_code
											end
			--and		md.status_received = case @p_status_received
			--			when 'ALL' then md.status_received
			--			else @p_status_received
			--		end
			and		md.status_received in ('SENT', 'RECEIVED')
			and		(
						mt.code												 like '%' + @p_keywords + '%'
						or	md.asset_code									 like '%' + @p_keywords + '%'
						or	md.description									 like '%' + @p_keywords + '%'
						or	mt.from_branch_name								 like '%' + @p_keywords + '%'
						or	mt.to_branch_name								 like '%' + @p_keywords + '%'
						or	ass.item_name									 like '%' + @p_keywords + '%'
						or	ass.item_code									 like '%' + @p_keywords + '%'
						or	mt.status										 like '%' + @p_keywords + '%'
						or	md.status_received								 like '%' + @p_keywords + '%'
						or	mt.code											 like '%' + @p_keywords + '%'
						or	convert(nvarchar(30), mt.mutation_date, 103)	 like '%' + @p_keywords + '%'
						or	convert(nvarchar(30), md.receive_date, 103)		 like '%' + @p_keywords + '%'
						or	ass.barcode										 like '%' + @p_keywords + '%'
						or	md.remark_return								 like '%' + @p_keywords + '%'
						or	md.remark_unpost								 like '%' + @p_keywords + '%'
						or	md.file_name									 like '%' + @p_keywords + '%'
						or	md.path											 like '%' + @p_keywords + '%'
					)
			order by	case
							when @p_sort_by = 'asc' then case @p_order_by
															 when 1 then mt.code
														 end
						end asc
						,case
							 when @p_sort_by = 'desc' then case @p_order_by
															 when 1 then mt.code
														   end
						 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
		end
		else
		begin
			select	@rows_count = count(1)
			from	dbo.mutation_detail md
					inner join dbo.mutation mt on (mt.code = md.mutation_code)
					inner join dbo.asset ass on (ass.code  = md.asset_code)
					--inner join dbo.mutation_document mdc on (mdc.mutation_code = mt.code)
			where	mt.to_branch_code		  = case @p_branch_code
												when 'ALL' then mt.to_branch_code
												else @p_branch_code
											end
			and		mt.to_location_code	  = case @p_location_code
												when '' then mt.to_location_code
												else @p_location_code
											end
			--and		md.status_received = case @p_status_received
			--			when 'ALL' then md.status_received
			--			else @p_status_received
			--		end
			and		md.status_received in ('SENT', 'RECEIVED')
			and		(
						mt.code												 like '%' + @p_keywords + '%'
						or	md.asset_code									 like '%' + @p_keywords + '%'
						or	md.description									 like '%' + @p_keywords + '%'
						or	mt.from_branch_name								 like '%' + @p_keywords + '%'
						or	mt.to_branch_name								 like '%' + @p_keywords + '%'
						or	ass.item_name									 like '%' + @p_keywords + '%'
						or	ass.item_code									 like '%' + @p_keywords + '%'
						or	mt.status										 like '%' + @p_keywords + '%'
						or	md.status_received								 like '%' + @p_keywords + '%'
						or	mt.code											 like '%' + @p_keywords + '%'
						or	convert(nvarchar(30), mt.mutation_date, 103)	 like '%' + @p_keywords + '%'
						or	convert(nvarchar(30), md.receive_date, 103)		 like '%' + @p_keywords + '%'
						or	ass.barcode										 like '%' + @p_keywords + '%'
						or	md.remark_return								 like '%' + @p_keywords + '%'
						or	md.remark_unpost								 like '%' + @p_keywords + '%'
						or	md.file_name									 like '%' + @p_keywords + '%'
						or	md.path											 like '%' + @p_keywords + '%'
					) ;

			select		md.mutation_code
						,md.asset_code
						,convert(nvarchar(30), mt.mutation_date, 103) 'mutation_date'
						,convert(nvarchar(30), md.receive_date, 103) 'receive_date'
						,md.receive_date 'receive_date_default'
						,mt.code
						,mt.status
						,md.status_received
						,mt.requestor_code
						,md.remark_return
						,md.remark_unpost
						,ass.barcode
						,md.id
						,mt.to_branch_name
						,mt.from_branch_name
						,md.description
						,md.file_name
						,md.path
						,@rows_count 'rowcount'
			from		dbo.mutation_detail md
						inner join dbo.mutation mt on (mt.code = md.mutation_code)
						inner join dbo.asset ass on (ass.code  = md.asset_code)
						--inner join dbo.mutation_document mdc on (mdc.mutation_code = mt.code)
			where	mt.to_branch_code		  = case @p_branch_code
												when 'ALL' then mt.to_branch_code
												else @p_branch_code
											end
			and		mt.to_location_code	  = case @p_location_code
												when '' then mt.to_location_code
												else @p_location_code
											end
			--and		md.status_received = case @p_status_received
			--			when 'ALL' then md.status_received
			--			else @p_status_received
			--		end
			and		md.status_received in ('SENT', 'RECEIVED')
			and		(
						mt.code												 like '%' + @p_keywords + '%'
						or	md.asset_code									 like '%' + @p_keywords + '%'
						or	md.description									 like '%' + @p_keywords + '%'
						or	mt.from_branch_name								 like '%' + @p_keywords + '%'
						or	mt.to_branch_name								 like '%' + @p_keywords + '%'
						or	ass.item_name									 like '%' + @p_keywords + '%'
						or	ass.item_code									 like '%' + @p_keywords + '%'
						or	mt.status										 like '%' + @p_keywords + '%'
						or	md.status_received								 like '%' + @p_keywords + '%'
						or	mt.code											 like '%' + @p_keywords + '%'
						or	convert(nvarchar(30), mt.mutation_date, 103)	 like '%' + @p_keywords + '%'
						or	convert(nvarchar(30), md.receive_date, 103)		 like '%' + @p_keywords + '%'
						or	ass.barcode										 like '%' + @p_keywords + '%'
						or	md.remark_return								 like '%' + @p_keywords + '%'
						or	md.remark_unpost								 like '%' + @p_keywords + '%'
						or	md.file_name									 like '%' + @p_keywords + '%'
						or	md.path											 like '%' + @p_keywords + '%'
					)
			order by	case
							when @p_sort_by = 'asc' then case @p_order_by
															 when 1 then mt.code
														 end
						end asc
						,case
							 when @p_sort_by = 'desc' then case @p_order_by
															 when 1 then mt.code
														   end
						 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
		end
	end
	else
	begin
		if(@p_filter_type = 'FROM')
		begin
			select	@rows_count = count(1)
			from	dbo.mutation_detail md
					inner join dbo.mutation mt on (mt.code = md.mutation_code)
					inner join dbo.asset ass on (ass.code  = md.asset_code)
					--inner join dbo.mutation_document mdc on (mdc.mutation_code = mt.code)
			where	mt.from_branch_code		  = case @p_branch_code
												when 'ALL' then mt.from_branch_code
												else @p_branch_code
											end
			and		mt.from_location_code	  = case @p_location_code
												when '' then mt.from_location_code
												else @p_location_code
											end
			--and		md.status_received = case @p_status_received
			--			when 'ALL' then md.status_received
			--			else @p_status_received
			--		end
			and		md.status_received in ('SENT', 'RECEIVED')
			and		(
						mt.code												 like '%' + @p_keywords + '%'
						or	md.asset_code									 like '%' + @p_keywords + '%'
						or	md.description									 like '%' + @p_keywords + '%'
						or	mt.from_branch_name								 like '%' + @p_keywords + '%'
						or	mt.to_branch_name								 like '%' + @p_keywords + '%'
						or	ass.item_name									 like '%' + @p_keywords + '%'
						or	ass.item_code									 like '%' + @p_keywords + '%'
						or	mt.status										 like '%' + @p_keywords + '%'
						or	md.status_received								 like '%' + @p_keywords + '%'
						or	mt.code											 like '%' + @p_keywords + '%'
						or	convert(nvarchar(30), mt.mutation_date, 103)	 like '%' + @p_keywords + '%'
						or	convert(nvarchar(30), md.receive_date, 103)		 like '%' + @p_keywords + '%'
						or	ass.barcode										 like '%' + @p_keywords + '%'
						or	md.remark_return								 like '%' + @p_keywords + '%'
						or	md.remark_unpost								 like '%' + @p_keywords + '%'
						or	md.file_name									 like '%' + @p_keywords + '%'
						or	md.path											 like '%' + @p_keywords + '%'
					) ;

			select		md.mutation_code
						,md.asset_code
						,convert(nvarchar(30), mt.mutation_date, 103) 'mutation_date'
						,convert(nvarchar(30), md.receive_date, 103) 'receive_date'
						,md.receive_date 'receive_date_default'
						,mt.code
						,mt.status
						,md.status_received
						,mt.requestor_code
						,md.remark_return
						,md.remark_unpost
						,ass.barcode
						,md.id
						,mt.to_branch_name
						,mt.from_branch_name
						,md.description
						,md.file_name
						,md.path
						,@rows_count 'rowcount'
			from		dbo.mutation_detail md
						inner join dbo.mutation mt on (mt.code = md.mutation_code)
						inner join dbo.asset ass on (ass.code  = md.asset_code)
						--inner join dbo.mutation_document mdc on (mdc.mutation_code = mt.code)
			where	mt.from_branch_code		  = case @p_branch_code
												when 'ALL' then mt.from_branch_code
												else @p_branch_code
											end
			and		mt.from_location_code	  = case @p_location_code
												when '' then mt.from_location_code
												else @p_location_code
											end
			--and		md.status_received = case @p_status_received
			--			when 'ALL' then md.status_received
			--			else @p_status_received
			--		end
			and		md.status_received in ('SENT', 'RECEIVED')
			and		(
						mt.code												 like '%' + @p_keywords + '%'
						or	md.asset_code									 like '%' + @p_keywords + '%'
						or	md.description									 like '%' + @p_keywords + '%'
						or	mt.from_branch_name								 like '%' + @p_keywords + '%'
						or	mt.to_branch_name								 like '%' + @p_keywords + '%'
						or	ass.item_name									 like '%' + @p_keywords + '%'
						or	ass.item_code									 like '%' + @p_keywords + '%'
						or	mt.status										 like '%' + @p_keywords + '%'
						or	md.status_received								 like '%' + @p_keywords + '%'
						or	mt.code											 like '%' + @p_keywords + '%'
						or	convert(nvarchar(30), mt.mutation_date, 103)	 like '%' + @p_keywords + '%'
						or	convert(nvarchar(30), md.receive_date, 103)		 like '%' + @p_keywords + '%'
						or	ass.barcode										 like '%' + @p_keywords + '%'
						or	md.remark_return								 like '%' + @p_keywords + '%'
						or	md.remark_unpost								 like '%' + @p_keywords + '%'
						or	md.file_name									 like '%' + @p_keywords + '%'
						or	md.path											 like '%' + @p_keywords + '%'
					)
			order by	case
							when @p_sort_by = 'asc' then case @p_order_by
															 when 1 then mt.code
														 end
						end asc
						,case
							 when @p_sort_by = 'desc' then case @p_order_by
															 when 1 then mt.code
														   end
						 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
		end
		else
		begin
			select	@rows_count = count(1)
			from	dbo.mutation_detail md
					inner join dbo.mutation mt on (mt.code = md.mutation_code)
					inner join dbo.asset ass on (ass.code  = md.asset_code)
					--inner join dbo.mutation_document mdc on (mdc.mutation_code = mt.code)
			where	mt.to_branch_code		  = case @p_branch_code
												when 'ALL' then mt.to_branch_code
												else @p_branch_code
											end
			and		mt.to_location_code	  = case @p_location_code
												when '' then mt.to_location_code
												else @p_location_code
											end
			--and		md.status_received = case @p_status_received
			--			when 'ALL' then md.status_received
			--			else @p_status_received
			--		end
			and		md.status_received in ('SENT', 'RECEIVED')
			and		(
						mt.code												 like '%' + @p_keywords + '%'
						or	md.asset_code									 like '%' + @p_keywords + '%'
						or	md.description									 like '%' + @p_keywords + '%'
						or	mt.from_branch_name								 like '%' + @p_keywords + '%'
						or	mt.to_branch_name								 like '%' + @p_keywords + '%'
						or	ass.item_name									 like '%' + @p_keywords + '%'
						or	ass.item_code									 like '%' + @p_keywords + '%'
						or	mt.status										 like '%' + @p_keywords + '%'
						or	md.status_received								 like '%' + @p_keywords + '%'
						or	mt.code											 like '%' + @p_keywords + '%'
						or	convert(nvarchar(30), mt.mutation_date, 103)	 like '%' + @p_keywords + '%'
						or	convert(nvarchar(30), md.receive_date, 103)		 like '%' + @p_keywords + '%'
						or	ass.barcode										 like '%' + @p_keywords + '%'
						or	md.remark_return								 like '%' + @p_keywords + '%'
						or	md.remark_unpost								 like '%' + @p_keywords + '%'
						or	md.file_name									 like '%' + @p_keywords + '%'
						or	md.path											 like '%' + @p_keywords + '%'
					) ;

			select		md.mutation_code
						,md.asset_code
						,convert(nvarchar(30), mt.mutation_date, 103) 'mutation_date'
						,convert(nvarchar(30), md.receive_date, 103) 'receive_date'
						,md.receive_date 'receive_date_default'
						,mt.code
						,mt.status
						,md.status_received
						,mt.requestor_code
						,md.remark_return
						,md.remark_unpost
						,ass.barcode
						,md.id
						,mt.to_branch_name
						,mt.from_branch_name
						,md.description
						,md.file_name
						,md.path
						,@rows_count 'rowcount'
			from		dbo.mutation_detail md
						inner join dbo.mutation mt on (mt.code = md.mutation_code)
						inner join dbo.asset ass on (ass.code  = md.asset_code)
						--inner join dbo.mutation_document mdc on (mdc.mutation_code = mt.code)
			where	mt.to_branch_code		  = case @p_branch_code
												when 'ALL' then mt.to_branch_code
												else @p_branch_code
											end
			and		mt.to_location_code	  = case @p_location_code
												when '' then mt.to_location_code
												else @p_location_code
											end
			--and		md.status_received = case @p_status_received
			--			when 'ALL' then md.status_received
			--			else @p_status_received
			--		end
			and		md.status_received in ('SENT', 'RECEIVED')
			and		(
						mt.code												 like '%' + @p_keywords + '%'
						or	md.asset_code									 like '%' + @p_keywords + '%'
						or	md.description									 like '%' + @p_keywords + '%'
						or	mt.from_branch_name								 like '%' + @p_keywords + '%'
						or	mt.to_branch_name								 like '%' + @p_keywords + '%'
						or	ass.item_name									 like '%' + @p_keywords + '%'
						or	ass.item_code									 like '%' + @p_keywords + '%'
						or	mt.status										 like '%' + @p_keywords + '%'
						or	md.status_received								 like '%' + @p_keywords + '%'
						or	mt.code											 like '%' + @p_keywords + '%'
						or	convert(nvarchar(30), mt.mutation_date, 103)	 like '%' + @p_keywords + '%'
						or	convert(nvarchar(30), md.receive_date, 103)		 like '%' + @p_keywords + '%'
						or	ass.barcode										 like '%' + @p_keywords + '%'
						or	md.remark_return								 like '%' + @p_keywords + '%'
						or	md.remark_unpost								 like '%' + @p_keywords + '%'
						or	md.file_name									 like '%' + @p_keywords + '%'
						or	md.path											 like '%' + @p_keywords + '%'
					)
			order by	case
							when @p_sort_by = 'asc' then case @p_order_by
															 when 1 then mt.code
															 when 2 then mt.from_branch_name
															 when 3 then mt.mutation_date
															 when 4 then md.remark_return
															 when 5 then md.remark_unpost
															 when 6 then md.file_name
															 when 7 then md.status_received
														 end
						end asc
						,case
							 when @p_sort_by = 'desc' then case @p_order_by
															 when 1 then mt.code
															 when 2 then mt.from_branch_name
															 when 3 then mt.mutation_date
															 when 4 then md.remark_return
															 when 5 then md.remark_unpost
															 when 6 then md.file_name
															 when 7 then md.status_received
														   end
						 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
		end
	end
end ;
