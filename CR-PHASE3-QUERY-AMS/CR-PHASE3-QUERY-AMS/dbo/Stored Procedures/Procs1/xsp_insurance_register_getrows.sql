CREATE PROCEDURE [dbo].[xsp_insurance_register_getrows]
(
	@p_keywords			nvarchar(50)
	,@p_pagenumber		int
	,@p_rowspage		int
	,@p_order_by		int
	,@p_sort_by			nvarchar(5)
	,@p_branch_code		nvarchar(50)
	,@p_register_status nvarchar(10) = ''
	,@p_insurance_type  nvarchar(10) = ''
	,@p_is_renual		nvarchar(1)
	,@p_from_date		datetime = ''
	,@p_to_date			datetime = ''
)
as
begin
	declare @rows_count int = 0 ;
	if exists ( select 1 from sys_global_param where code ='HO' and value = @p_branch_code)	begin		set @p_branch_code = 'ALL'	end
    
	if @p_is_renual = '0'
	begin
		select	@rows_count = count(1)
		from	insurance_register ir
				left join dbo.master_insurance mi on (mi.code				= ir.insurance_code)
		where	ir.is_renual		   = '0'
				and ir.branch_code	   = case @p_branch_code
											 when 'ALL' then ir.branch_code
											 else @p_branch_code
										 end
				and ir.register_status = case @p_register_status
											 when 'ALL' then ir.register_status
											 else @p_register_status
										 end
				and ir.insurance_type = case @p_insurance_type
											 when 'ALL' then ir.insurance_type
											 else @p_insurance_type
										 end
				and (
						ir.register_no			like '%' + @p_keywords + '%'
						or ir.branch_name		like '%' + @p_keywords + '%' 
						or mi.insurance_name 	like '%' + @p_keywords + '%'
						or ir.register_status	like '%' + @p_keywords + '%'
						or ir.register_remarks	like '%' + @p_keywords + '%'
					) ;

			select		ir.code
						,ir.register_no
						,ir.branch_name 
						,mi.insurance_name
						,ir.register_status
						,ir.register_remarks
						,convert(varchar(30), ir.from_date, 103) 'from_date'
						,convert(varchar(30), ir.to_date, 103) 'to_date'
						,@rows_count 'rowcount'
			from		insurance_register ir
						left join dbo.master_insurance mi on (mi.code				= ir.insurance_code)
			where		ir.is_renual		   = '0'
						and ir.branch_code	   = case @p_branch_code
													 when 'ALL' then ir.branch_code
													 else @p_branch_code
												 end
						and ir.register_status = case @p_register_status
													 when 'ALL' then ir.register_status
													 else @p_register_status
												 end
						and ir.insurance_type = case @p_insurance_type
													 when 'ALL' then ir.insurance_type
													 else @p_insurance_type
												 end
						and (
								ir.register_no			like '%' + @p_keywords + '%'
								or ir.branch_name		like '%' + @p_keywords + '%' 
								or mi.insurance_name 	like '%' + @p_keywords + '%'
								or ir.register_status	like '%' + @p_keywords + '%'
								or ir.register_remarks	like '%' + @p_keywords + '%'
							)

		order by case  
					when @p_sort_by = 'asc' then case @p_order_by
													when 1 then ir.register_no
													when 2 then ir.branch_name
													when 3 then mi.insurance_name
													when 4 then ir.register_remarks
													when 5 then ir.register_status
												 end
				end asc 
				,case when @p_sort_by = 'desc' then case @p_order_by
														when 1 then ir.register_no
														when 2 then ir.branch_name
														when 3 then mi.insurance_name
														when 4 then ir.register_remarks
														when 5 then ir.register_status
													end
				end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;	
	end ;
	else
	begin
		select	@rows_count = count(1)
		from	insurance_register ir
				left join dbo.master_insurance mi on (mi.code				= ir.insurance_code)
		where	ir.is_renual		   = '0'
				and ir.branch_code	   = case @p_branch_code
											 when 'ALL' then ir.branch_code
											 else @p_branch_code
										 end
				and ir.register_status = case @p_register_status
											 when 'ALL' then ir.register_status
											 else @p_register_status
										 end
				and ir.insurance_type = case @p_insurance_type
											 when 'ALL' then ir.insurance_type
											 else @p_insurance_type
										 end
				and (
						ir.register_no								like '%' + @p_keywords + '%'
						or ir.branch_name							like '%' + @p_keywords + '%' 
						or mi.insurance_name 						like '%' + @p_keywords + '%'
						or ir.register_status						like '%' + @p_keywords + '%'
						or ir.register_remarks	like '%' + @p_keywords + '%'
					) ;

			select		ir.code
						,ir.register_no
						,ir.branch_name 
						,mi.insurance_name
						,ir.register_status
						,ir.register_remarks
						,@rows_count 'rowcount'
			from		insurance_register ir
						left join dbo.master_insurance mi on (mi.code				= ir.insurance_code)
			where		ir.is_renual		   = '0'
						and ir.branch_code	   = case @p_branch_code
													 when 'ALL' then ir.branch_code
													 else @p_branch_code
												 end
						and ir.register_status = case @p_register_status
													 when 'ALL' then ir.register_status
													 else @p_register_status
												 end
						and ir.insurance_type = case @p_insurance_type
													 when 'ALL' then ir.insurance_type
													 else @p_insurance_type
												 end
						and (
								ir.register_no								like '%' + @p_keywords + '%'
								or ir.branch_name							like '%' + @p_keywords + '%' 
								or mi.insurance_name 						like '%' + @p_keywords + '%'
								or ir.register_status						like '%' + @p_keywords + '%'
								or ir.register_remarks	like '%' + @p_keywords + '%'
							)

		order by case  
					when @p_sort_by = 'asc' then case @p_order_by
													when 1 then ir.register_no
													when 2 then ir.branch_name
													when 3 then mi.insurance_name
													when 4 then ir.register_remarks
													when 5 then ir.register_status
												 end
				end asc 
				,case when @p_sort_by = 'desc' then case @p_order_by
														when 1 then ir.register_no
														when 2 then ir.branch_name
														when 3 then mi.insurance_name
														when 4 then ir.register_remarks
														when 5 then ir.register_status
													end
				end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;	
	end ;
end ;


