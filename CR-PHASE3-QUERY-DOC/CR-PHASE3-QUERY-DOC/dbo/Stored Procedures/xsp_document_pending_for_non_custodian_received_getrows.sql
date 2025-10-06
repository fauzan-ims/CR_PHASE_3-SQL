CREATE PROCEDURE dbo.xsp_document_pending_for_non_custodian_received_getrows
(
	@p_keywords				nvarchar(50)
	,@p_pagenumber			int
	,@p_rowspage			int
	,@p_order_by			int
	,@p_sort_by				nvarchar(5)
	,@p_initial_branch_code	nvarchar(50) -- cabang custody nya
	,@p_document_status		nvarchar(10)
	,@p_from_date			datetime
	,@p_to_date				datetime
)
as
begin
	declare @rows_count int = 0 ;

	if exists ( select 1 from sys_global_param where code ='HO' and value = @p_initial_branch_code)
	begin
		set @p_initial_branch_code = 'ALL'
	end


	select	@rows_count = count(1)
	from	document_pending dp
			inner join dbo.agreement_main am on (am.agreement_no		= dp.agreement_no)
			inner join dbo.agreement_collateral ac on (ac.collateral_no = dp.collateral_no)
			inner join dbo.agreement_asset ags on (ags.asset_no			= dp.asset_no)
			left join dbo.sys_general_document sgd on (dp.general_document_code = sgd.code)
	where	document_status			= @p_document_status
			and dp.branch_code		= case @p_initial_branch_code
											 when 'ALL' then dp.branch_code
											 else @p_initial_branch_code
										 end
			and	document_status			   = ( 'TRANSIT' )
			and am.agreement_date
			between @p_from_date and @p_to_date
			and (
					dp.branch_name										like '%' + @p_keywords + '%'
					or	am.agreement_external_no						like '%' + @p_keywords + '%'
					or	am.client_name									like '%' + @p_keywords + '%'
					or	ac.collateral_external_no						like '%' + @p_keywords + '%'
					or	ac.collateral_name								like '%' + @p_keywords + '%'
					or	ags.asset_external_no							like '%' + @p_keywords + '%'
					or	ags.asset_name									like '%' + @p_keywords + '%'
					or	sgd.document_name								like '%' + @p_keywords + '%'
					or	convert(varchar(30), am.agreement_date, 103)	like '%' + @p_keywords + '%'
					or	dp.document_no									like '%' + @p_keywords + '%'
				) ;

	if @p_sort_by = 'asc'
	begin
		select		dp.code
					,dp.branch_name
					,dp.document_type
					,am.agreement_external_no	
					,am.client_name					
					,convert(varchar(30), am.agreement_date, 103) 'agreement_date'				
					,ac.collateral_external_no	
					,ac.collateral_name			
					,ags.asset_external_no				
					,ags.asset_name
					,case dp.document_type
						when 'COLLATERAL' then ac.collateral_external_no
						when 'INSURANCE'  then ac.collateral_external_no
						else ags.asset_external_no
					end 'reff_no'
					,case dp.document_type
						when 'COLLATERAL' then ac.collateral_name
						when 'INSURANCE'  then ac.collateral_name
						else ags.asset_name
					end 'reff_name'
					,sgd.document_name	
					,dp.document_status
					,dp.initial_branch_name		
					,dp.document_no				
					,@rows_count 'rowcount'
		from		document_pending dp
					inner join dbo.agreement_main am on (am.agreement_no		= dp.agreement_no)
					inner join dbo.agreement_collateral ac on (ac.collateral_no = dp.collateral_no)
					inner join dbo.agreement_asset ags on (ags.asset_no			= dp.asset_no)
					left join dbo.sys_general_document sgd on (dp.general_document_code = sgd.code) 
		where		document_status		= @p_document_status
					and dp.branch_code	= case @p_initial_branch_code
											 when 'ALL' then dp.branch_code
											 else @p_initial_branch_code
										 end
					AND	document_status			  = ( 'TRANSIT' )
					and am.agreement_date
					between @p_from_date and @p_to_date
					and (
							dp.branch_name										like '%' + @p_keywords + '%'
							or	am.agreement_external_no						like '%' + @p_keywords + '%'
							or	am.client_name									like '%' + @p_keywords + '%'
							or	ac.collateral_external_no						like '%' + @p_keywords + '%'
							or	ac.collateral_name								like '%' + @p_keywords + '%'
							or	ags.asset_external_no							like '%' + @p_keywords + '%'
							or	ags.asset_name									like '%' + @p_keywords + '%'
							or	sgd.document_name								like '%' + @p_keywords + '%'
							or	convert(varchar(30), am.agreement_date, 103)	like '%' + @p_keywords + '%'
							or	dp.document_no									like '%' + @p_keywords + '%'
						) 
		order by	case @p_order_by
						when 1 then dp.branch_name  
						when 2 then dp.initial_branch_name
						when 3 then dp.document_no
						when 4 then am.client_name
						when 5 then isnull(ac.collateral_name, ags.asset_name)
						when 6 then dp.document_type
						when 7 then cast(am.agreement_date as sql_variant)	
						when 8 then dp.document_status		
					end asc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
	end ;
	else
	begin
		select		dp.code
					,dp.branch_name
					,dp.document_type
					,am.agreement_external_no	
					,am.client_name					
					,convert(varchar(30), am.agreement_date, 103) 'agreement_date'				
					,ac.collateral_external_no	
					,ac.collateral_name			
					,ags.asset_external_no				
					,ags.asset_name
					,case dp.document_type
						when 'COLLATERAL' then ac.collateral_external_no
						when 'INSURANCE'  then ac.collateral_external_no
						else ags.asset_external_no
					end 'reff_no'
					,case dp.document_type
						when 'COLLATERAL' then ac.collateral_name
						when 'INSURANCE'  then ac.collateral_name
						else ags.asset_name
					end 'reff_name'
					,sgd.document_name	
					,dp.document_status
					,dp.initial_branch_name		
					,dp.document_no				
					,@rows_count 'rowcount'
		from		document_pending dp
					inner join dbo.agreement_main am on (am.agreement_no		= dp.agreement_no)
					inner join dbo.agreement_collateral ac on (ac.collateral_no = dp.collateral_no)
					inner join dbo.agreement_asset ags on (ags.asset_no			= dp.asset_no)
					left join dbo.sys_general_document sgd on (dp.general_document_code = sgd.code) 
		where		document_status		= @p_document_status
					and dp.branch_code	= case @p_initial_branch_code
											 when 'ALL' then dp.branch_code
											 else @p_initial_branch_code
										 end
					AND	document_status			   = ( 'TRANSIT' )
					and am.agreement_date
					between @p_from_date and @p_to_date
					and (
							dp.branch_name										like '%' + @p_keywords + '%'
							or	am.agreement_external_no						like '%' + @p_keywords + '%'
							or	am.client_name									like '%' + @p_keywords + '%'
							or	ac.collateral_external_no						like '%' + @p_keywords + '%'
							or	ac.collateral_name								like '%' + @p_keywords + '%'
							or	ags.asset_external_no							like '%' + @p_keywords + '%'
							or	ags.asset_name									like '%' + @p_keywords + '%'
							or	sgd.document_name								like '%' + @p_keywords + '%'
							or	convert(varchar(30), am.agreement_date, 103)	like '%' + @p_keywords + '%'
							or	dp.document_no									like '%' + @p_keywords + '%'
						) 
		order by	case @p_order_by
						when 1 then dp.branch_name  
						when 2 then dp.initial_branch_name
						when 3 then dp.document_no
						when 4 then am.client_name
						when 5 then isnull(ac.collateral_name, ags.asset_name)
						when 6 then dp.document_type
						when 7 then cast(am.agreement_date as sql_variant)	
						when 8 then dp.document_status
					end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
	end ;
end ;
