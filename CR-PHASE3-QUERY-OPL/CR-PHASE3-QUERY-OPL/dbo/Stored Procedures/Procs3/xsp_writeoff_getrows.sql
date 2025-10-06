CREATE PROCEDURE [dbo].[xsp_writeoff_getrows]
(
	@p_keywords				nvarchar(50)
	,@p_pagenumber			int
	,@p_rowspage			int
	,@p_order_by			int
	,@p_sort_by				nvarchar(5)
	,@p_agreement_no		nvarchar(50)

)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	(
	
			select 'Write Off' as	'transaction_name'
					,code			'transaction_code'
					,wo_amount		'amount'
					,convert(varchar(30), wo_date, 103)	'date'
					,wo_remarks		'remark' 
					,@rows_count	'rowcount'
			from dbo.write_off_main 
			where wo_status = 'APPROVE'
			and agreement_no = @p_agreement_no
			union 
			select 'Recovery' 
					,code 
					,recovery_amount 
					,received_voucher_date 
					,recovery_remarks 
					,@rows_count 'rowcount'
			from dbo.write_off_recovery 
			where recovery_status = 'PAID'
			and agreement_no = @p_agreement_no
	
	
			) as wo
	where
			(
				wo.transaction_name								like '%' + @p_keywords + '%'
				or wo.transaction_code							like '%' + @p_keywords + '%'
				or wo.amount									like '%' + @p_keywords + '%'
				or wo.remark									like '%' + @p_keywords + '%'
				or convert(varchar(30), wo.date, 103) 			like '%' + @p_keywords + '%'
			) ;

	select	wo.transaction_name
			,wo.transaction_code
			,wo.amount
			,convert(nvarchar(30), wo.date, 103)
			,wo.remark	
		   	,@rows_count 'rowcount'			
	from	(
	
			select 'Write Off' as	'transaction_name'
					,code			'transaction_code'
					,wo_amount		'amount'
					,convert(varchar(30), wo_date, 103)	'date'
					,wo_remarks		'remark' 
					,@rows_count	'rowcount'
			from dbo.write_off_main 
			where wo_status = 'APPROVE'
			and agreement_no = @p_agreement_no
			union 
			select 'Recovery' 
					,code 
					,recovery_amount  
					,convert(varchar(30), received_voucher_date, 103)	'date' 
					,recovery_remarks 
					,@rows_count 'rowcount'
			from dbo.write_off_recovery 
			where recovery_status = 'PAID'
			and agreement_no = @p_agreement_no
	
	
			) as wo
		
	where
			(
				wo.transaction_name								like '%' + @p_keywords + '%'
				or wo.transaction_code							like '%' + @p_keywords + '%'
				or wo.amount									like '%' + @p_keywords + '%'
				or wo.remark									like '%' + @p_keywords + '%'
				or convert(varchar(30), wo.date, 103) 			like '%' + @p_keywords + '%'
			) 


		order by case  
					when @p_sort_by = 'asc' then case @p_order_by
													when 1 then wo.transaction_name			                    
													when 2 then wo.transaction_code		                   							
													when 3 then convert(varchar(30), wo.date, 103)
													when 4 then	cast(wo.amount as sql_variant)							
													when 5 then	wo.remark 

												 end
				end asc 
				,case when @p_sort_by = 'desc' then case @p_order_by
													when 1 then wo.transaction_name			                    
													when 2 then wo.transaction_code		                   							
													when 3 then convert(varchar(30), wo.date, 103)
													when 4 then	cast(wo.amount as sql_variant)							
													when 5 then	wo.remark 
													end
		end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;	
end ;
