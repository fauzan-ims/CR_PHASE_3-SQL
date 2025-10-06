CREATE PROCEDURE dbo.xsp_client_personal_matching_getrows
(
	@p_keywords				    nvarchar(50)
	,@p_pagenumber			    int
	,@p_rowspage			    int
	,@p_order_by			    int
	,@p_sort_by				    nvarchar(5)
	----
	,@p_full_name				nvarchar(250)   = ''
	,@p_mother_maiden_name		nvarchar(250)   = ''
	,@p_date_of_birth			DATETIME		= null
	,@p_place_of_birth			nvarchar(250)	=  ''
	,@p_document_no				nvarchar(50)	= ''
)
as
begin
	declare @msg		nvarchar(max) 
			,@rows_count int = 0 ;
	
	begin try
		if (@p_full_name			= '' and
			@p_mother_maiden_name	= '' and
			@p_date_of_birth		is null and
			@p_place_of_birth		=  '' and
			@p_document_no			= ''
		)
		begin
			set @msg = 'Please input at least one field';
			raiserror(@msg, 16, -1) ;
		end

		declare @checkingclient table
		(
			client_code				nvarchar(50)
			,client_type			nvarchar(50)
			,mother_maiden_name		nvarchar(250)
			,full_name				nvarchar(250)
			,date_of_birth			datetime
			,place_of_birth			nvarchar(250)
			,id_no					nvarchar(50)
			,check_status			nvarchar(50)
		)

		-- DATA CLIENT
		INSERT INTO	@checkingclient
		(
			client_code,
			client_type,
			mother_maiden_name,
			full_name,
			date_of_birth,
			place_of_birth,
			id_no,
			check_status
		)
		select cci.client_code
				,'PERSONAL'
				,cci.mother_maiden_name
				,cci.full_name	
				,cci.date_of_birth
				,cci.place_of_birth
				,ISNULL(cd.document_no,'')
				,'CLEAR'

		from client_personal_info cci
		inner join dbo.client_main cm on (cm.code = cci.client_code and  cm.is_validate = '1')
		left join client_doc cd on cd.client_code = cci.client_code and cd.doc_type_code = 'CLDOC'
		where	( ISNULL(cd.document_no,'')	= @p_document_no 
				or ( full_name like '%' + cast(@p_full_name as nvarchar(10)) + '%'  )
				or ( place_of_birth like '%' + cast(place_of_birth as nvarchar(10)) + '%' and date_of_birth = isnull(@p_date_of_birth,cci.date_of_birth) )
				or ( mother_maiden_name like '%' + cast(@p_full_name as nvarchar(10)) + '%' and date_of_birth = isnull(@p_date_of_birth,cci.date_of_birth) )
				)
		-- DATA BLACKKLIST
		insert into	@checkingclient
		(
			client_code,
			client_type,
			mother_maiden_name,
			full_name,
			date_of_birth,
			place_of_birth,
			id_no,
			check_status
		)
		select 'EXTERNAL'
				,'PERSONAL'
				,personal_mother_maiden_name
				,personal_name
				,personal_dob
				,''
				,personal_id_no
				,case	when	is_active = '0' then 'RELEASE'
						else	blacklist_type
				end 'BLACKLIST_TYPE'

		from dbo.client_blacklist
		where client_type = 'PERSONAL'
		and	 (( personal_name like '%' + cast(@p_full_name as nvarchar(10)) + '%')
		or	 (( personal_mother_maiden_name like '%' + cast(@p_mother_maiden_name as nvarchar(10)) + '%') and ( personal_dob= isnull(@p_date_of_birth,personal_dob) ))
		or	 ( personal_id_no like '%' + @p_document_no+ '%')  
			)




		select	@rows_count = count(1)
		from	@checkingclient
		where	(
					client_code										like '%' + @p_keywords + '%'
					or	client_type									like '%' + @p_keywords + '%'
					or	full_name									like '%' + @p_keywords + '%'
					or	mother_maiden_name							like '%' + @p_keywords + '%'
					or	place_of_birth								like '%' + @p_keywords + '%'
					or	convert(varchar(30), date_of_birth, 103)	like '%' + @p_keywords + '%'
				) ;

			select		client_code
						,client_type			
						,full_name			
						,mother_maiden_name	
						,place_of_birth
						,convert(varchar(30), date_of_birth, 103) 'date_of_birth'		
						,id_no
						,check_status		
						,@rows_count 'rowcount'
			from	@checkingclient
			where	(
						client_code										like '%' + @p_keywords + '%'
						or	id_no										LIKE '%' + @p_keywords + '%'
						or	full_name									like '%' + @p_keywords + '%'
						or	mother_maiden_name							like '%' + @p_keywords + '%'
						or	place_of_birth								like '%' + @p_keywords + '%'
						or	convert(varchar(30), date_of_birth, 103)	like '%' + @p_keywords + '%'
						or	check_status								like '%' + @p_keywords + '%'
					) 

		Order by case  
					when @p_sort_by = 'asc' then case @p_order_by
													when 1 then client_code
													when 2 then full_name			
													when 3 then id_no			
													when 4 then mother_maiden_name	
													when 5 then place_of_birth		
													when 6 then cast(date_of_birth as sql_variant)
													when 7 then check_status
												 end
				end asc 
				,case when @p_sort_by = 'desc' then case @p_order_by
														when 1 then client_code
														when 2 then full_name			
														when 3 then id_no			
														when 4 then mother_maiden_name	
														when 5 then place_of_birth		
														when 6 then cast(date_of_birth as sql_variant)
														when 7 then check_status
													end
		end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ; 
	
	end try
	Begin catch
		declare @error int ;

		set @error = @@error ;

		if (@error = 2627)
		begin
			set @msg = dbo.xfn_get_msg_err_code_already_exist() ;
		end ;

		if (len(@msg) <> 0)
		begin
			set @msg = 'V' + ';' + @msg ;
		end ;
		else
		begin
			if (error_message() like '%V;%' or error_message() like '%E;%')
			begin
				set @msg = error_message() ;
			end
			else 
			begin
				set @msg = 'E;' + dbo.xfn_get_msg_err_generic() + ';' + error_message() ;
			end
		end ;

		raiserror(@msg, 16, -1) ;

		return ;
	end catch ; 
end ;

