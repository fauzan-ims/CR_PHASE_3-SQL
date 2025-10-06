CREATE PROCEDURE dbo.xsp_sys_it_param_getrows
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
	from	sys_it_param
	where	(
				system_date						like '%' + @p_keywords + '%'
				or	db_mail_profile				like '%' + @p_keywords + '%'
				or	user_auto_inactive			like '%' + @p_keywords + '%'
				or	password_max_repeat_time	like '%' + @p_keywords + '%'
				or	password_max_login_try		like '%' + @p_keywords + '%'
				or	password_next_change		like '%' + @p_keywords + '%'
				or	password_min_char			like '%' + @p_keywords + '%'
				or	password_max_char			like '%' + @p_keywords + '%'
				or	password_regex				like '%' + @p_keywords + '%'
				or	password_use_uppercase		like '%' + @p_keywords + '%'
				or	password_use_lowercase		like '%' + @p_keywords + '%'
				or	password_contain_number		like '%' + @p_keywords + '%'
				or	is_eod_running				like '%' + @p_keywords + '%'
				or	eod_manual_flag				like '%' + @p_keywords + '%'
			);

		select		system_date
					,db_mail_profile
					,user_auto_inactive
					,password_max_repeat_time
					,password_max_login_try
					,password_next_change
					,password_min_char
					,password_max_char
					,password_regex
					,password_use_uppercase
					,password_use_lowercase
					,password_contain_number
					,is_eod_running
					,eod_manual_flag
		from		dbo.sys_it_param
		where		(
						system_date						like '%' + @p_keywords + '%'
						or	db_mail_profile				like '%' + @p_keywords + '%'
						or	user_auto_inactive			like '%' + @p_keywords + '%'
						or	password_max_repeat_time	like '%' + @p_keywords + '%'
						or	password_max_login_try		like '%' + @p_keywords + '%'
						or	password_next_change		like '%' + @p_keywords + '%'
						or	password_min_char			like '%' + @p_keywords + '%'
						or	password_max_char			like '%' + @p_keywords + '%'
						or	password_regex				like '%' + @p_keywords + '%'
						or	password_use_uppercase		like '%' + @p_keywords + '%'
						or	password_use_lowercase		like '%' + @p_keywords + '%'
						or	password_contain_number		like '%' + @p_keywords + '%'
						or	is_eod_running				like '%' + @p_keywords + '%'
						or	eod_manual_flag				like '%' + @p_keywords + '%'
					)

order by case  
					when @p_sort_by = 'asc' then case @p_order_by
													when 1 then system_date
													when 2 then db_mail_profile
													when 4 then user_auto_inactive
													when 5 then password_max_repeat_time
													when 6 then password_max_login_try
													when 7 then password_next_change
													when 8 then password_min_char
													when 9 then password_max_char
													when 10 then password_regex
													when 11 then password_use_uppercase
													when 12 then password_use_lowercase
													when 13 then password_contain_number
													when 14 then is_eod_running
													when 15 then eod_manual_flag
												 end
				end asc 
				,case when @p_sort_by = 'desc' then case @p_order_by
													when 1 then system_date
													when 2 then db_mail_profile
													when 4 then user_auto_inactive
													when 5 then password_max_repeat_time
													when 6 then password_max_login_try
													when 7 then password_next_change
													when 8 then password_min_char
													when 9 then password_max_char
													when 10 then password_regex
													when 11 then password_use_uppercase
													when 12 then password_use_lowercase
													when 13 then password_contain_number
													when 14 then is_eod_running
													when 15 then eod_manual_flag
													end
		end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;

end ;
