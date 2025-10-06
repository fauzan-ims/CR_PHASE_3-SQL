
-- Stored Procedure

CREATE PROCEDURE [dbo].[xsp_final_good_receipt_note_getrow]
(
	@p_code NVARCHAR(50)
)
AS
BEGIN
	declare @counttotal			int
			,@countreceive		int
			,@reff_no			nvarchar(50)
			,@code_grn			nvarchar(50)
			,@code_final		nvarchar(50)
			,@grn				nvarchar(4000)
			,@total_rcv			int
			,@total_item		int
			,@unit_from			nvarchar(15)
			,@procurement_type	nvarchar(25)


	--sepria 03052025: update script jadi lebih simple dan gk berat

	select  fgrn.code
			,fgrn.DATE
			,fgrn.reff_no
			,fgrn.complate_date
			,fgrn.status
			,fgrn.REMARK

			,grn.good_receipt_note_code	
			,grnd.total_received	'receive_item'
			,pr.total_item



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

	WHERE	fgrn.CODE = @p_code

	--select		@unit_from			= po.unit_from
	--			,@procurement_type	= po.procurement_type
	--from		dbo.final_good_receipt_note_detail	   fgrn
	--			left join dbo.good_receipt_note_detail grnd on grnd.id = fgrn.good_receipt_note_detail_id
	--			left join dbo.good_receipt_note		   grn on grn.code = grnd.good_receipt_note_code
	--			left join dbo.purchase_order		   po on po.code   = grn.purchase_order_code

	--where		fgrn.final_good_receipt_note_code = @p_code

	--create table #codegrn
	--(
	--	code_final		nvarchar(50)	COLLATE Latin1_General_CI_AS
	--	,grn			nvarchar(4000)	COLLATE Latin1_General_CI_AS
	--)

	--create table #totalrcv
	--(
	--	code_final			nvarchar(50)	COLLATE Latin1_General_CI_AS

	--	,total_receive		int
	--)

	--create table #totalitem
	--(

	--	code_final		nvarchar(50)	COLLATE Latin1_General_CI_AS
	--	,total_item		int
	--)

	--begin --untuk mengambil code GRN
	--	declare c_looping cursor for
	--	select	grnd.good_receipt_note_code
	--			,fgrn.code
	--	from	dbo.final_good_receipt_note fgrn
	--			left join dbo.final_good_receipt_note_detail fgrd on (fgrd.final_good_receipt_note_code = fgrn.code)
	--			left join dbo.good_receipt_note_detail grnd on (grnd.id = fgrd.good_receipt_note_detail_id)

	--	open c_looping
	--	fetch next from c_looping

	--	into	@code_grn
	--			,@code_final

	--	while @@fetch_status = 0
	--	begin
	--			if not exists (select 1 from #codegrn where code_final = @code_final)
	--			begin
	--				insert into #codegrn

	--				(
	--					grn
	--					,code_final
	--				)
	--				values 
	--				(
	--					@code_grn
	--					,@code_final
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
	--	end
	--	close c_looping
	--	deallocate c_looping
	--end

	--begin -- untuk mengambil data total receive
	--	declare b_looping cursor for
	--	select	fgrn.final_good_receipt_note_code
	--			,count(fgrn.id)

	--	from	dbo.final_good_receipt_note_detail fgrn
	--	left join dbo.good_receipt_note_detail grnd on grnd.id=fgrn.good_receipt_note_detail_id
	--	left join dbo.good_receipt_note grn on grn.code = grnd.good_receipt_note_code
	--	left join dbo.purchase_order po on po.code = grn.purchase_order_code
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

	--begin -- untuk mengambil data total
	--	declare d_looping cursor for
	--	select	prc.asset_no
	--			,count(prc.asset_no)
	--	from	dbo.procurement_request prc
	--	inner join dbo.procurement pr on (pr.procurement_request_code = prc.code)
	--	where prc.status not in ('CANCEL', 'REJECT')
	--	and pr.unit_from = @unit_from
	--	and prc.procurement_type = @procurement_type
	--	group by prc.asset_no
	--	,pr.unit_from

	--	open d_looping
	--	fetch next from d_looping
	--	into	@code_final
	--			,@total_item

	--	while @@fetch_status = 0
	--	begin
	--			insert into #totalitem
	--			(
	--				code_final
	--				,total_item
	--			)
	--			values
	--			(
	--				@code_final
	--				,@total_item
	--			)

	--		fetch d_looping
	--		into	@code_final
	--				,@total_item
	--	end
	--	close d_looping
	--	deallocate d_looping
	--end

	--select	@reff_no = reff_no
	--from	dbo.final_good_receipt_note
	--where	code = @p_code ;


	--select	code
	--		,date
	--		,complate_date
	--		,status
	--		,fgrn.reff_no
	--		,remark
	--		,rcv.total_receive						   'receive_item'
	--		,isnull(tim.total_item, rcv.total_receive) 'total_item'
	--from	final_good_receipt_note						 fgrn
	--		left join dbo.final_good_receipt_note_detail fgrnd on (fgrn.code   = fgrnd.final_good_receipt_note_code)
	--		left join #codegrn							 dg on dg.code_final   = fgrn.code
	--		left join #totalrcv							 rcv on rcv.code_final = fgrn.code
	--		left join #totalitem						 tim on tim.code_final = fgrn.reff_no
	--where	code = @p_code ;
end ;
