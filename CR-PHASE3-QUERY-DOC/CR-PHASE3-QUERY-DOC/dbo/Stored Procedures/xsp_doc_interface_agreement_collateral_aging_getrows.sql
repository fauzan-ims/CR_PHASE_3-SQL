CREATE PROCEDURE dbo.xsp_doc_interface_agreement_collateral_aging_getrows
(
	@p_keywords	   nvarchar(50)
	,@p_pagenumber int
	,@p_rowspage   int
	,@p_order_by   int
	,@p_sort_by	   nvarchar(5)
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	doc_interface_agreement_collateral_aging
	where	(
				id like '%' + @p_keywords + '%'
				or	aging_date like '%' + @p_keywords + '%'
				or	agreement_no like '%' + @p_keywords + '%'
				or	collateral_no like '%' + @p_keywords + '%'
				or	branch_code like '%' + @p_keywords + '%'
				or	branch_name like '%' + @p_keywords + '%'
				or	locker_position like '%' + @p_keywords + '%'
				or	locker_name like '%' + @p_keywords + '%'
				or	drawer_name like '%' + @p_keywords + '%'
				or	row_name like '%' + @p_keywords + '%'
				or	document_status like '%' + @p_keywords + '%'
				or	mutation_type like '%' + @p_keywords + '%'
				or	mutation_location like '%' + @p_keywords + '%'
				or	mutation_from like '%' + @p_keywords + '%'
				or	mutation_to like '%' + @p_keywords + '%'
				or	mutation_by like '%' + @p_keywords + '%'
				or	mutation_date like '%' + @p_keywords + '%'
				or	mutation_return_date like '%' + @p_keywords + '%'
				or	last_mutation_type like '%' + @p_keywords + '%'
				or	last_mutation_date like '%' + @p_keywords + '%'
				or	last_locker_position like '%' + @p_keywords + '%'
				or	first_receive_date like '%' + @p_keywords + '%'
				or	release_customer_date like '%' + @p_keywords + '%'
			) ;


		select		id
					,aging_date
					,agreement_no
					,collateral_no
					,branch_code
					,branch_name
					,locker_position
					,locker_name
					,drawer_name
					,row_name
					,document_status
					,mutation_type
					,mutation_location
					,mutation_from
					,mutation_to
					,mutation_by
					,mutation_date
					,mutation_return_date
					,last_mutation_type
					,last_mutation_date
					,last_locker_position
					,first_receive_date
					,release_customer_date
					,@rows_count 'rowcount'
		from		doc_interface_agreement_collateral_aging
		where		(
						id like '%' + @p_keywords + '%'
						or	aging_date like '%' + @p_keywords + '%'
						or	agreement_no like '%' + @p_keywords + '%'
						or	collateral_no like '%' + @p_keywords + '%'
						or	branch_code like '%' + @p_keywords + '%'
						or	branch_name like '%' + @p_keywords + '%'
						or	locker_position like '%' + @p_keywords + '%'
						or	locker_name like '%' + @p_keywords + '%'
						or	drawer_name like '%' + @p_keywords + '%'
						or	row_name like '%' + @p_keywords + '%'
						or	document_status like '%' + @p_keywords + '%'
						or	mutation_type like '%' + @p_keywords + '%'
						or	mutation_location like '%' + @p_keywords + '%'
						or	mutation_from like '%' + @p_keywords + '%'
						or	mutation_to like '%' + @p_keywords + '%'
						or	mutation_by like '%' + @p_keywords + '%'
						or	mutation_date like '%' + @p_keywords + '%'
						or	mutation_return_date like '%' + @p_keywords + '%'
						or	last_mutation_type like '%' + @p_keywords + '%'
						or	last_mutation_date like '%' + @p_keywords + '%'
						or	last_locker_position like '%' + @p_keywords + '%'
						or	first_receive_date like '%' + @p_keywords + '%'
						or	release_customer_date like '%' + @p_keywords + '%'
					)
		order by case  
					when @p_sort_by = 'asc' then case @p_order_by
													when 1 then agreement_no
													when 2 then collateral_no
													when 3 then branch_code
													when 4 then branch_name
													when 5 then locker_position
													when 6 then locker_name
													when 7 then drawer_name
													when 8 then row_name
													when 9 then document_status
													when 10 then mutation_type
													when 11 then mutation_location
													when 12 then mutation_from
													when 13 then mutation_to
													when 14 then mutation_by
													when 15 then last_mutation_type
													when 16 then last_locker_position
												 end
				end asc 
				,case when @p_sort_by = 'desc' then case @p_order_by
														when 1 then agreement_no
														when 2 then collateral_no
														when 3 then branch_code
														when 4 then branch_name
														when 5 then locker_position
														when 6 then locker_name
														when 7 then drawer_name
														when 8 then row_name
														when 9 then document_status
														when 10 then mutation_type
														when 11 then mutation_location
														when 12 then mutation_from
														when 13 then mutation_to
														when 14 then mutation_by
														when 15 then last_mutation_type
														when 16 then last_locker_position
													end
		end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ; 
end ;
