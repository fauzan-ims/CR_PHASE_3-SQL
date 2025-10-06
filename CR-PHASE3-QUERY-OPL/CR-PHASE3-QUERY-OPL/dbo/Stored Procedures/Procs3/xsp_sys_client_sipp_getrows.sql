CREATE PROCEDURE dbo.xsp_sys_client_sipp_getrows
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
	from	sys_client_sipp
	where	(
				code							like '%' + @p_keywords + '%'
				or	client_code					like '%' + @p_keywords + '%'
				or	sipp_kelompok_debtor		like '%' + @p_keywords + '%'
				or	sipp_kategori_debtor		like '%' + @p_keywords + '%'
				or	sipp_golongan_debtor		like '%' + @p_keywords + '%'
				or	sipp_hub_debtor_dg_pp		like '%' + @p_keywords + '%'
				or	sipp_sektor_ekonomi_debtor	like '%' + @p_keywords + '%'
			) ;
			  
		select		code
					,@rows_count 'rowcount'
		from		sys_client_sipp
		where		(
						code							like '%' + @p_keywords + '%'
						or	client_code					like '%' + @p_keywords + '%'
						or	sipp_kelompok_debtor		like '%' + @p_keywords + '%'
						or	sipp_kategori_debtor		like '%' + @p_keywords + '%'
						or	sipp_golongan_debtor		like '%' + @p_keywords + '%'
						or	sipp_hub_debtor_dg_pp		like '%' + @p_keywords + '%'
						or	sipp_sektor_ekonomi_debtor	like '%' + @p_keywords + '%'
					) 
		Order by case  
					when @p_sort_by = 'asc' then case @p_order_by
													when 1 then code
													when 2 then client_code
													when 3 then sipp_kelompok_debtor
													when 4 then sipp_kategori_debtor
													when 5 then sipp_golongan_debtor
													when 6 then sipp_hub_debtor_dg_pp
													when 7 then sipp_sektor_ekonomi_debtor
												 end
				end asc 
				,case when @p_sort_by = 'desc' then case @p_order_by
													when 1 then code
													when 2 then client_code
													when 3 then sipp_kelompok_debtor
													when 4 then sipp_kategori_debtor
													when 5 then sipp_golongan_debtor
													when 6 then sipp_hub_debtor_dg_pp
													when 7 then sipp_sektor_ekonomi_debtor
													end
		end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;	
end ;

