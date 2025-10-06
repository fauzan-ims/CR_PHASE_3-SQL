CREATE PROCEDURE [dbo].[xsp_agreement_main_lookup_for_change_due_date]
(
	@p_keywords			nvarchar(50)
	,@p_pagenumber		int
	,@p_rowspage		int
	,@p_order_by		int
	,@p_sort_by			nvarchar(5)
	--
	,@p_branch_code		nvarchar(50) 
)
as
begin
	declare @rows_count int = 0 ;

	if exists
	(
		select	1
		from	sys_global_param
		where	code	  = 'HO'
				and value = @p_branch_code
	)
	begin
		set @p_branch_code = 'ALL' ;
	end ;

	select	@rows_count = count(1)
	from	agreement_main am
			outer apply
			(
				select	count(1) asset_count
				from	dbo.agreement_asset aa
				where	(aa.agreement_no = am.agreement_no)
						and aa.asset_no not in
							(
								select	ddcd.asset_no
								from	dbo.due_date_change_detail ddcd
										inner join dbo.due_date_change_main ddcm on (ddcd.due_date_change_code = ddcm.code)
								where	ddcd.is_change = '1'
										and change_status not in
										(
											'CANCEL', 'REJECT', 'EXPIRED'
										)
							)
			) aa
	where	agreement_status		   = 'GO LIVE'
			--and agreement_sub_status   = ''
			and isnull(am.termination_status,'') = ''
			and isnull(opl_status, '') = ''
			--and		(agreement_no not in (select agreement_no from dbo.write_off_main where wo_status not in ('REJECT', 'CANCEL'))
			--		or agreement_no not in (select agreement_no from dbo.et_main where et_status not  in ('REJECT', 'CANCEL') ))
			and branch_code			   = case @p_branch_code
											 when 'ALL' then branch_code
											 else @p_branch_code
										 end
			--and agreement_no not in
			--	(
			--		select	agreement_no
			--		from	dbo.due_date_change_main
			--		where	change_status not in
			--				(
			--					'CANCEL', 'REJECT', 'EXPIRED'
			--				)
			--	)
			and isnull(asset_count, 1) >= 1
			and
			(
				agreement_no like '%' + @p_keywords + '%'
				or	agreement_external_no like '%' + @p_keywords + '%'
				or	client_name like '%' + @p_keywords + '%'
			) ;

	select	agreement_no
			,agreement_external_no	 
			,client_no                   
			,client_name
			,am.billing_type
			,aa.billing_mode
			,aa.prorate
			,@rows_count 'rowcount'
	from	agreement_main am
			outer apply
			(
				select	count(1) asset_count, max(aa.billing_mode) billing_mode, max(aa.prorate) prorate
				from	dbo.agreement_asset aa
				where	(aa.agreement_no = am.agreement_no)
						and aa.asset_no not in
							(
								select	ddcd.asset_no
								from	dbo.due_date_change_detail ddcd
										inner join dbo.due_date_change_main ddcm on (ddcd.due_date_change_code = ddcm.code)
								where	ddcd.is_change = '0'
										and change_status not in
										(
											'CANCEL', 'REJECT', 'EXPIRED'
										)
							)
			) aa
	where	agreement_status		   = 'GO LIVE'
			--and agreement_sub_status   = ''
			and isnull(am.termination_status,'') = ''
			and isnull(opl_status, '') = ''
			--and		(agreement_no not in (select agreement_no from dbo.write_off_main where wo_status not in ('REJECT', 'CANCEL'))
			--		or agreement_no not in (select agreement_no from dbo.et_main where et_status not  in ('REJECT', 'CANCEL') ))
			and branch_code			   = case @p_branch_code
											 when 'ALL' then branch_code
											 else @p_branch_code
										 end
			--and agreement_no not in
			--	(
			--		select	agreement_no
			--		from	dbo.due_date_change_main
			--		where	change_status not in
			--				(
			--					'CANCEL', 'REJECT', 'EXPIRED'
			--				)
			--	)
			and isnull(asset_count, 1) >= 1
			and
			(
				agreement_no like '%' + @p_keywords + '%'
				or	agreement_external_no like '%' + @p_keywords + '%'
				or	client_name like '%' + @p_keywords + '%'
			)
	order by	case 
					when @p_sort_by = 'asc' then 
												case @p_order_by
													when 1 then agreement_no	                    
													when 2 then client_name  
												end
												end asc, 
				case
					when @p_sort_by = 'desc' then 
												case @p_order_by
													when 1 then agreement_no	                    
													when 2 then client_name  	
												end
											end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
