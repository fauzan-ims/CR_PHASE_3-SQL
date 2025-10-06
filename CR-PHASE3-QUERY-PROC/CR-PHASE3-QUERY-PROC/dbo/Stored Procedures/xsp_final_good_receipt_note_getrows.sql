CREATE PROCEDURE dbo.xsp_final_good_receipt_note_getrows
(
	@p_keywords			nvarchar(50)
	,@p_pagenumber		int
	,@p_rowspage		int
	,@p_order_by		int
	,@p_sort_by			nvarchar(5)
	,@p_status			nvarchar(50)
)
as
begin
	declare @rows_count			int = 0 
			,@code_grn			nvarchar(50)
			,@code_final		nvarchar(50)
			,@grn				nvarchar(4000)
			,@total_rcv			int
			,@total_item		int
			,@unit_from			nvarchar(15)
			,@procurement_type	nvarchar(25)
			,@reff_no			nvarchar(50)



	--sepria 03052025: update script jadi lebih simple dan gk berat
	
	select  @rows_count = COUNT(1)
	from	dbo.final_good_receipt_note fgrn
			outer apply (	select	 string_agg(grnd.good_receipt_note_code,', ') 'good_receipt_note_code'
							from (	select distinct grnd.good_receipt_note_code
									from	final_good_receipt_note_detail fgrnd 
											inner join dbo.good_receipt_note_detail grnd on grnd.id = fgrnd.good_receipt_note_detail_id
									where	fgrn.code = fgrnd.final_good_receipt_note_code
								)grnd
						)grn
			outer apply (	select	count(pod.po_code) 'total_received'
							from	final_good_receipt_note_detail fgrnd 
									inner join dbo.good_receipt_note_detail grnd on grnd.id = fgrnd.good_receipt_note_detail_id
									inner join dbo.purchase_order_detail pod on pod.id = grnd.purchase_order_detail_id
									inner join dbo.purchase_order po on po.code = pod.po_code
							where	fgrn.code = fgrnd.final_good_receipt_note_code
						)grnd
		
			outer apply (	select	count(1) 'total_item'
							from	dbo.purchase_order po  with (nolock)
									left join dbo.purchase_order_detail pod with (nolock) on (pod.po_code = po.code)
									left join dbo.supplier_selection_detail ssd with (nolock) on (ssd.id = pod.supplier_selection_detail_id)
									left join dbo.quotation_review_detail qrd with (nolock) on (qrd.id = ssd.quotation_detail_id)
									left join dbo.procurement prc with (nolock) on (prc.code collate latin1_general_ci_as = qrd.reff_no) 
									left join dbo.procurement prc2 with (nolock) on (prc2.code = ssd.reff_no)
									left join dbo.procurement_request pr with (nolock) on (pr.code = prc.procurement_request_code)
									inner join dbo.good_receipt_note_detail grnd on grnd.purchase_order_detail_id = pod.id
									inner join dbo.final_good_receipt_note_detail fgrnd on fgrnd.good_receipt_note_detail_id = grnd.id
							where	fgrnd.final_good_receipt_note_code = fgrn.code
							group by fgrnd.final_good_receipt_note_code
						)pr
	where		fgrn.status	= case @p_status
								when 'all' then fgrn.status
								else @p_status
							end
	and			(
						fgrn.code											like '%' + @p_keywords + '%'
					or	fgrn.reff_no										like '%' + @p_keywords + '%'
					or	convert(varchar(30), fgrn.complate_date, 103)		like '%' + @p_keywords + '%'
					or	fgrn.status											like '%' + @p_keywords + '%'
					or	grn.good_receipt_note_code							like '%' + @p_keywords + '%'
					or	grnd.total_received									like '%' + @p_keywords + '%'
					or	pr.total_item										like '%' + @p_keywords + '%'
				)

	select  fgrn.code
			,fgrn.reff_no
			,convert(varchar(30), fgrn.complate_date, 103)'complate_date'
			,fgrn.status
			,grn.good_receipt_note_code	'grn'
			,grnd.total_received	'total_receive'
			,pr.total_item
			,@rows_count 'rowcount'
	from	dbo.final_good_receipt_note fgrn
			outer apply (	select	 string_agg(grnd.good_receipt_note_code,', ') 'good_receipt_note_code'
							from (	select distinct grnd.good_receipt_note_code
									from	final_good_receipt_note_detail fgrnd 
											inner join dbo.good_receipt_note_detail grnd on grnd.id = fgrnd.good_receipt_note_detail_id
									where	fgrn.code = fgrnd.final_good_receipt_note_code
								)grnd
						)grn
			outer apply (	select	count(pod.po_code) 'total_received'
							from	final_good_receipt_note_detail fgrnd 
									inner join dbo.good_receipt_note_detail grnd on grnd.id = fgrnd.good_receipt_note_detail_id
									inner join dbo.purchase_order_detail pod on pod.id = grnd.purchase_order_detail_id
									inner join dbo.purchase_order po on po.code = pod.po_code
							where	fgrn.code = fgrnd.final_good_receipt_note_code
						)grnd
		
			outer apply (	select	count(1) 'total_item'
							from	dbo.purchase_order po  with (nolock)
									left join dbo.purchase_order_detail pod with (nolock) on (pod.po_code = po.code)
									left join dbo.supplier_selection_detail ssd with (nolock) on (ssd.id = pod.supplier_selection_detail_id)
									left join dbo.quotation_review_detail qrd with (nolock) on (qrd.id = ssd.quotation_detail_id)
									left join dbo.procurement prc with (nolock) on (prc.code collate latin1_general_ci_as = qrd.reff_no) 
									left join dbo.procurement prc2 with (nolock) on (prc2.code = ssd.reff_no)
									left join dbo.procurement_request pr with (nolock) on (pr.code = prc.procurement_request_code)
									inner join dbo.good_receipt_note_detail grnd on grnd.purchase_order_detail_id = pod.id
									inner join dbo.final_good_receipt_note_detail fgrnd on fgrnd.good_receipt_note_detail_id = grnd.id
							where	fgrnd.final_good_receipt_note_code = fgrn.code
							group by fgrnd.final_good_receipt_note_code
						)pr
	where		fgrn.status	= case @p_status
								when 'all' then fgrn.status
								else @p_status
							end
	and			(
						fgrn.code											like '%' + @p_keywords + '%'
					or	fgrn.reff_no										like '%' + @p_keywords + '%'
					or	convert(varchar(30), fgrn.complate_date, 103)		like '%' + @p_keywords + '%'
					or	fgrn.status											like '%' + @p_keywords + '%'
					or	grn.good_receipt_note_code							like '%' + @p_keywords + '%'
					or	grnd.total_received									like '%' + @p_keywords + '%'
					or	pr.total_item										like '%' + @p_keywords + '%'
				)
		order by	case
						when @p_sort_by = 'asc' then case @p_order_by
														 when 1 then fgrn.CODE										
														 when 2 then fgrn.REFF_NO									
														 when 3 then cast(fgrn.complate_date as sql_variant)	
														 when 4 then fgrn.STATUS										
														 when 5 then grn.good_receipt_note_code						
														 when 6 then grnd.total_received								
														 when 7 then pr.total_item									
													 end
					end asc
					,case
						 when @p_sort_by = 'desc' then case @p_order_by
															 when 1 then fgrn.CODE										
															 when 2 then fgrn.REFF_NO									
															 when 3 then cast(fgrn.complate_date as sql_variant)	
															 when 4 then fgrn.STATUS										
															 when 5 then grn.good_receipt_note_code						
															 when 6 then grnd.total_received								
															 when 7 then pr.total_item											
													   end
					 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;

	--end sepria 03052025
	--create table #codeunitandtype
	--(
	--	unit_from			nvarchar(15)	collate latin1_general_ci_as
	--	,procurement_type	nvarchar(25)	collate latin1_general_ci_as
	--	,code_final			nvarchar(50)	collate latin1_general_ci_as
	--	--,reff_no			nvarchar(50)	collate latin1_general_ci_as
	--)

	--create table #codegrn
	--(
	--	code_final			nvarchar(50)	collate latin1_general_ci_as
	--	,grn				nvarchar(4000)	collate latin1_general_ci_as
	--	--,unit_from			nvarchar(15)	collate latin1_general_ci_as
	--	--,procurement_type	nvarchar(25)	collate latin1_general_ci_as
	--)

	--create table #totalrcv
	--(
	--	code_final		nvarchar(50)	collate latin1_general_ci_as
	--	,total_receive	int
	--)

	--create table #totalitem
	--(
	--	code_final		nvarchar(50)	collate latin1_general_ci_as
	--	,total_item		int
	--	--,unit_from		nvarchar(15)	collate latin1_general_ci_as
	--)

	--begin -- untuk mengambil code grn
	--	declare c_looping cursor for
	--	select	grnd.good_receipt_note_code
	--			,fgrn.code
	--			--,po.unit_from
	--			--,po.procurement_type
	--	from	dbo.final_good_receipt_note fgrn
	--			left join dbo.final_good_receipt_note_detail fgrd on (fgrd.final_good_receipt_note_code = fgrn.code)
	--			left join dbo.good_receipt_note_detail grnd on (grnd.id = fgrd.good_receipt_note_detail_id)
	--			left join dbo.purchase_order_detail pod on (pod.id = grnd.purchase_order_detail_id)
	--			left join dbo.purchase_order po on (po.code = pod.po_code)

	--	open c_looping
	--	fetch next from c_looping
	--	into	@code_grn
	--			,@code_final
	--			--,@unit_from
	--			--,@procurement_type

	--	while @@fetch_status = 0
	--	begin
	--			if not exists (select 1 from #codegrn where code_final = @code_final)
	--			begin
	--				insert into #codegrn
	--				(
	--					grn
	--					,code_final
	--					--,unit_from
	--					--,procurement_type
	--				)
	--				values 
	--				(
	--					@code_grn
	--					,@code_final
	--					--,@unit_from
	--					--,@procurement_type
	--				)
	--			end
	--			else
	--			begin
	--				update #codegrn
	--				set		grn = grn + ' - ' + @code_grn
	--				where	 code_final = @code_final
	--			end

	--		fetch c_looping
	--		into	@code_grn
	--				,@code_final
	--				--,@unit_from
	--				--,@procurement_type
	--	end
	--	close c_looping
	--	deallocate c_looping
	--end

	--begin -- untuk mengambil unit from dan type procurement
	--	declare a_looping cursor fast_forward read_only for
 --       select		po.unit_from
	--				,po.procurement_type
	--				--,fgrn.reff_no
	--				,fgrn.final_good_receipt_note_code
	--	from		dbo.final_good_receipt_note_detail	   fgrn
	--				left join dbo.good_receipt_note_detail grnd on grnd.id = fgrn.good_receipt_note_detail_id
	--				left join dbo.good_receipt_note		   grn on grn.code = grnd.good_receipt_note_code
	--				left join dbo.purchase_order		   po on po.code   = grn.purchase_order_code
		
	--	open a_looping
		
	--	fetch next from a_looping 
	--	into @unit_from
	--		,@procurement_type
	--		,@code_final
	--		--,@reff_no
		
	--	while @@fetch_status = 0
	--	begin
	--	    insert into #codeunitandtype
	--	    (
	--	    	unit_from
	--	    	,procurement_type
	--			,code_final
	--			--,reff_no
	--	    )
	--	    values
	--	    (
	--	    	@unit_from
	--	    	,@procurement_type
	--			,@code_final
	--			--,@reff_no
	--	    )
	--	    fetch next from a_looping 
	--		into @unit_from
	--			,@procurement_type
	--			,@code_final
	--			--,@reff_no
	--	end
		
	--	close a_looping
	--	deallocate a_looping
	--end

	--begin -- untuk mengambil total receive
	--	declare b_looping cursor for
	--	select	fgrn.final_good_receipt_note_code
	--			,count(fgrn.id)
	--	from	dbo.final_good_receipt_note_detail fgrn
	--	left join dbo.good_receipt_note_detail grnd on grnd.id=fgrn.good_receipt_note_detail_id
	--	left join dbo.good_receipt_note grn on grn.code = grnd.good_receipt_note_code
	--	left join dbo.purchase_order po on po.code = grn.purchase_order_code
	--	--where po.unit_from is not null
	--	group by fgrn.final_good_receipt_note_code

	--	open b_looping
	--	fetch next from b_looping
	--	into	@code_final
	--			,@total_rcv

	--	while @@fetch_status = 0
	--	begin
	--			insert into #totalrcv
	--			(
	--				code_final
	--				,total_receive
	--			)
	--			values
	--			(
	--				@code_final
	--				,@total_rcv
	--			)

	--		fetch b_looping
	--		into	@code_final
	--				,@total_rcv
	--	end
	--	close b_looping
	--	deallocate b_looping
	--end

	--begin -- untuk mengambil data total item
	--	declare d_looping cursor for
	--	select	prc.asset_no
	--			,count(prc.asset_no)
	--			--,pr.unit_from
	--	from	dbo.procurement_request prc
	--	inner join dbo.procurement pr on (prc.code = pr.procurement_request_code)
	--	where prc.status not in ('cancel', 'reject')
	--	and pr.unit_from = @unit_from
	--	and prc.procurement_type = @procurement_type
	--	group by prc.asset_no
	--	,pr.unit_from

	--	open d_looping
	--	fetch next from d_looping
	--	into	@code_final
	--			,@total_item
	--			--,@unit_from

	--	while @@fetch_status = 0
	--	begin
	--			insert into #totalitem
	--			(
	--				code_final
	--				,total_item
	--				--,unit_from
	--			)
	--			values
	--			(
	--				@code_final
	--				,@total_item
	--				--,@unit_from
	--			)

	--		fetch d_looping
	--		into	@code_final
	--				,@total_item
	--				--,@unit_from
	--	end
	--	close d_looping
	--	deallocate d_looping
	--end

	--select	@rows_count = count(1)
	--from	final_good_receipt_note fgrn
	--		left join #codegrn dg on dg.code_final = fgrn.code
	--		--left join #codeunitandtype cut on cut.code_final = fgrn.code
	--		left join #totalrcv rcv on rcv.code_final = fgrn.code
	--		left join #totalitem tim on tim.code_final = fgrn.reff_no --and tim.unit_from = dg.unit_from
	--where	fgrn.status			  = case @p_status
	--								 when 'all' then fgrn.status
	--								 else @p_status
	--							 end
	--and		(
	--			fgrn.code												like '%' + @p_keywords + '%'
	--			or	convert(varchar(30), fgrn.complate_date, 103)		like '%' + @p_keywords + '%'
	--			or	tim.total_item										like '%' + @p_keywords + '%'
	--			or	rcv.total_receive									like '%' + @p_keywords + '%'
	--			or	fgrn.status											like '%' + @p_keywords + '%'
	--			or	fgrn.reff_no										like '%' + @p_keywords + '%'
	--			or	dg.grn												like '%' + @p_keywords + '%'
	--		) ;

	--select		fgrn.code
	--			,fgrn.reff_no
	--			,convert(varchar(50), fgrn.complate_date, 103)  'complate_date'
	--			,status
	--			,dg.grn
	--			,rcv.total_receive
	--			,isnull(tim.total_item,rcv.total_receive) 'total_item'
	--			,@rows_count 'rowcount'
	--from		final_good_receipt_note fgrn
	--			left join #codegrn dg on dg.code_final = fgrn.code
	--			--left join #codeunitandtype cut on cut.code_final = fgrn.code
	--			left join #totalrcv rcv on rcv.code_final = fgrn.code
	--			left join #totalitem tim on tim.code_final = fgrn.reff_no --and tim.unit_from = dg.unit_from
	--where		fgrn.status			  = case @p_status
	--								 when 'all' then fgrn.status
	--								 else @p_status
	--							 end
	--and			(
	--				fgrn.code												like '%' + @p_keywords + '%'
	--				or	convert(varchar(30), fgrn.complate_date, 103)		like '%' + @p_keywords + '%'
	--				or	tim.total_item										like '%' + @p_keywords + '%'
	--				or	rcv.total_receive									like '%' + @p_keywords + '%'
	--				or	fgrn.status											like '%' + @p_keywords + '%'
	--				or	fgrn.reff_no										like '%' + @p_keywords + '%'
	--				or	dg.grn												like '%' + @p_keywords + '%'
	--			)
	--order by	case
	--				when @p_sort_by = 'asc' then case @p_order_by
	--												 when 1 then fgrn.code
	--												 when 2 then dg.grn
	--												 when 3 then fgrn.reff_no
	--												 when 4 then cast(fgrn.complate_date as sql_variant)
	--												 when 5 then tim.total_item
	--												 when 6 then rcv.total_receive
	--												 when 7 then fgrn.status
	--											 end
	--			end asc
	--			,case
	--				 when @p_sort_by = 'desc' then case @p_order_by
	--													 when 1 then fgrn.code
	--													 when 2 then dg.grn
	--													 when 3 then fgrn.reff_no
	--													 when 4 then cast(fgrn.complate_date as sql_variant)
	--													 when 5 then tim.total_item
	--													 when 6 then rcv.total_receive
	--													 when 7 then fgrn.status
	--											   end
	--			 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;

	--drop table #codegrn 
end ;
