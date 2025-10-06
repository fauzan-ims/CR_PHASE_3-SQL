CREATE PROCEDURE [dbo].[xsp_agreement_main_lookup]
(
	@p_keywords			 nvarchar(50)
	,@p_pagenumber		 int
	,@p_rowspage		 int
	,@p_order_by		 int
	,@p_sort_by			 nvarchar(5)
	,@p_branch_code		 nvarchar(50) = 'ALL'
	,@p_client_code		 nvarchar(50) = ''
	,@p_currency_code	 nvarchar(3)  = ''
)
as
begin
	declare @rows_count int = 0 ;
	if exists ( select 1 from sys_global_param where code ='HO' and value = @p_branch_code)
	begin
		set @p_branch_code = 'ALL'
	end

	select	@rows_count = count(1)
	from	agreement_main
	where	branch_code		= case @p_branch_code
									when 'ALL' then branch_code
									else @p_branch_code
							  end
			and client_code		= case @p_client_code
									when '' then client_code
									else @p_client_code
							  end
			and currency_code		= case @p_currency_code
									when '' then currency_code
									else @p_currency_code
							  end
			and	CLIENT_CODE = @p_client_code
			and (
					agreement_external_no		    like '%' + @p_keywords + '%'
					or	client_name				    like '%' + @p_keywords + '%'
					or	currency_code			    like '%' + @p_keywords + '%'
					or	installment_amount		    like '%' + @p_keywords + '%'
					or	asset_description		    like '%' + @p_keywords + '%'
					or	facility_name			    like '%' + @p_keywords + '%'
					or	last_paid_installment_no	like '%' + @p_keywords + '%'
				) ;

		select		agreement_no
					,agreement_external_no
					,client_name
					,currency_code
					,client_code
					,installment_amount
					,asset_description
					,factoring_type
					,facility_name
					,last_paid_installment_no
					,@rows_count 'rowcount'
		from		agreement_main
		where		branch_code		= case @p_branch_code
											when 'ALL' then branch_code
											else @p_branch_code
									  end
					and client_code		= case @p_client_code
											when '' then client_code
											else @p_client_code
									  end
					and currency_code		= case @p_currency_code
											when '' then currency_code
											else @p_currency_code
									  end
					and	CLIENT_CODE = @p_client_code
					and (
							agreement_external_no		    like '%' + @p_keywords + '%'
							or	client_name				    like '%' + @p_keywords + '%'
							or	currency_code			    like '%' + @p_keywords + '%'
							or	installment_amount		    like '%' + @p_keywords + '%'
							or	asset_description		    like '%' + @p_keywords + '%'
							or	facility_name			    like '%' + @p_keywords + '%'
							or	last_paid_installment_no	like '%' + @p_keywords + '%'
						) 
		order by	case
					when @p_sort_by = 'asc' then case @p_order_by
														when 1 then agreement_external_no
														when 2 then cast(installment_amount as sql_variant)
														when 3 then asset_description
												 end
					end asc
					,case
					 when @p_sort_by = 'desc' then case @p_order_by
														when 1 then agreement_external_no
														when 2 then cast(installment_amount as sql_variant)
														when 3 then asset_description
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
