

CREATE PROCEDURE dbo.xsp_faktur_no_replacement_detail_upload_validasi
(
	@p_keywords								nvarchar(50)
	,@p_pagenumber							int
	,@p_rowspage							int
	,@p_order_by							int
	,@p_sort_by								nvarchar(5)
	--
	,@p_faktur_no_replacement_code			nvarchar(50)

)
as
begin

	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	dbo.faktur_no_replacement_detail_upload_validasi_1 
	where	faktur_no_replacement_code = @p_faktur_no_replacement_code
	and		(	
			
					id									like '%' + @p_keywords + '%'
				or	id_upload_data						like '%' + @p_keywords + '%'
				or	faktur_no_replacement_code			like '%' + @p_keywords + '%'
				or	user_id								like '%' + @p_keywords + '%'
				or	upload_date							like '%' + @p_keywords + '%'
				or	validasi							like '%' + @p_keywords + '%'
				or	cre_date							like '%' + @p_keywords + '%'
				or	cre_by								like '%' + @p_keywords + '%'
				or	cre_ip_address						like '%' + @p_keywords + '%'
				or	mod_date							like '%' + @p_keywords + '%'
				or	mod_by								like '%' + @p_keywords + '%'
				or	mod_ip_address						like '%' + @p_keywords + '%'

			) ;

	select	 id
            ,id_upload_data
            ,faktur_no_replacement_code
            ,user_id
            ,upload_date
            ,validasi
            ,cre_date
            ,cre_by
            ,cre_ip_address
            ,mod_date
            ,mod_by
            ,mod_ip_address
			,@rows_count 'rowcount'
	from	dbo.faktur_no_replacement_detail_upload_validasi_1 
	where	faktur_no_replacement_code = @p_faktur_no_replacement_code
			--outer apply (select code from dbo.credit_note cn where cn.invoice_no = inv.invoice_no and cn.status = 'post')cn
	and (	
					id									like '%' + @p_keywords + '%'
				or	id_upload_data						like '%' + @p_keywords + '%'
				or	faktur_no_replacement_code			like '%' + @p_keywords + '%'
				or	user_id								like '%' + @p_keywords + '%'
				or	upload_date							like '%' + @p_keywords + '%'
				or	validasi							like '%' + @p_keywords + '%'
				or	cre_date							like '%' + @p_keywords + '%'
				or	cre_by								like '%' + @p_keywords + '%'
				or	cre_ip_address						like '%' + @p_keywords + '%'
				or	mod_date							like '%' + @p_keywords + '%'
				or	mod_by								like '%' + @p_keywords + '%'
				or	mod_ip_address						like '%' + @p_keywords + '%'

			)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
														when 1 then faktur_no_replacement_code		
														when 2 then user_id							
														when 3 then upload_date						
														when 4 then validasi						
														when 5 then cre_date						
														when 6 then cre_by							
														when 7 then cre_ip_address					
														when 8 then mod_date						
														when 9 then mod_by							
														when 10 then mod_ip_address					
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
														when 1 then faktur_no_replacement_code		
														when 2 then user_id							
														when 3 then upload_date						
														when 4 then validasi						
														when 5 then cre_date						
														when 6 then cre_by							
														when 7 then cre_ip_address					
														when 8 then mod_date						
														when 9 then mod_by							
														when 10 then mod_ip_address					
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
