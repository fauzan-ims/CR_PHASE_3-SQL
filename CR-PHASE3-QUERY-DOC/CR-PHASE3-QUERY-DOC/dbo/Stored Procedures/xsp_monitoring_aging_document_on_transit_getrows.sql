CREATE PROCEDURE dbo.xsp_monitoring_aging_document_on_transit_getrows
(
	@p_keywords				nvarchar(50)
	,@p_pagenumber			int
	,@p_rowspage			int
	,@p_order_by			int
	,@p_sort_by				nvarchar(5)
	,@p_branch_code			nvarchar(50)
)
as
begin

	declare @msg		nvarchar(max)
			,@rows_count int = 0 
			,@code nvarchar(50)
			,@branch_code nvarchar(50)
			,@branch_name nvarchar(250)
			,@movement_location nvarchar(250)
			,@movement_type nvarchar(250)
			,@aging int
			,@one_day int
			,@two_day int
			,@three_day int
			,@more_than_three_day INT
			,@movement_from nvarchar(250)
			,@from_to nvarchar(250);

	--if exists ( select 1 from sys_global_param where code ='HO' and value = @p_branch_code)
	--begin
	--	set @p_branch_code = 'ALL'
	--end

	declare @temptable table
		(
			code nvarchar(50),
			branch_code nvarchar(50),
			branch_name nvarchar(250),
			movement_type nvarchar(250),
			movement_location nvarchar(250),
			movement_from nvarchar(250),
			from_to nvarchar(250),
			one_day int,
			two_day int,
			three_day int,
			more_than_three_day int
		);

	INSERT INTO @temptable
	(
		code,
	    branch_code,
	    branch_name,
	    movement_type,
	    movement_location,
		movement_from,
		from_to,
	    one_day,
	    two_day,
	    three_day,
	    more_than_three_day
	)
	select distinct
				code
				,branch_code
				,branch_name
				,movement_type
				,movement_location
				--,isnull(movement_to_branch_name, movement_to_dept_name) 'from_to' 
				,case movement_type
					when 'SEND' then 
								case MOVEMENT_LOCATION 
									when 'BRANCH' then BRANCH_NAME
									when 'DEPARTMENT' then BRANCH_NAME
								end
					when 'RETURN' then 
								case MOVEMENT_LOCATION
									when 'BRANCH' then MOVEMENT_TO_BRANCH_NAME
									when 'DEPARTMENT' then MOVEMENT_FROM_DEPT_NAME
								end
				end 'movement_from'
				,case movement_type
					when 'SEND' then 
								case MOVEMENT_LOCATION 
									when 'BRANCH' then MOVEMENT_TO_BRANCH_NAME
									when 'DEPARTMENT' then MOVEMENT_TO_DEPT_NAME
								end
					when 'RETURN' then 
								case MOVEMENT_LOCATION
									when 'BRANCH' then BRANCH_NAME
									when 'DEPARTMENT' then BRANCH_NAME
								end
				end 'from_to'
				,0
				,0
				,0
				,0
		from	dbo.document_movement
		where	branch_code = @p_branch_code
				--branch_code = case @p_branch_code
				--				when 'ALL' then branch_code
				--				else @p_branch_code
				--			  end
		and		movement_status = 'ON PROCESS';

	declare cursor_count cursor fast_forward read_only for 
		
		select distinct
				code
				,branch_code
				,branch_name
				, movement_location
				, movement_type
				--,isnull(movement_to_branch_name, movement_to_dept_name) 'from_to' 
				,case movement_type
					when 'SEND' then 
								case MOVEMENT_LOCATION 
									when 'BRANCH' then BRANCH_NAME
									when 'DEPARTMENT' then BRANCH_NAME
								end
					when 'RETURN' then 
								case MOVEMENT_LOCATION
									when 'BRANCH' then MOVEMENT_TO_BRANCH_NAME
									when 'DEPARTMENT' then MOVEMENT_FROM_DEPT_NAME
								end
				end 'movement_from'
				,case movement_type
					when 'SEND' then 
								case MOVEMENT_LOCATION 
									when 'BRANCH' then MOVEMENT_TO_BRANCH_NAME
									when 'DEPARTMENT' then MOVEMENT_TO_DEPT_NAME
								end
					when 'RETURN' then 
								case MOVEMENT_LOCATION
									when 'BRANCH' then BRANCH_NAME
									when 'DEPARTMENT' then BRANCH_NAME
								end
				end 'from_to'
		from	dbo.document_movement
		where	movement_status = 'ON PROCESS'
		and		branch_code = @p_branch_code
				--branch_code = case @p_branch_code
				--				when 'ALL' then branch_code
				--				else @p_branch_code
				--			  end

		open cursor_count

		fetch next from cursor_count into 
						@code
						,@branch_code
						,@branch_name	
						,@movement_location		
						,@movement_type	
						,@movement_from
						,@from_to
		while @@fetch_status = 0

		BEGIN
        
			--reset variabel
			SET @one_day	= 0;
			SET @two_day	= 0;
			SET @three_day	= 0;
			SET @more_than_three_day = 0;

			-- one day
			select	@one_day = count(1) 
			from	dbo.document_movement dm
					inner join dbo.document_movement_detail dmd on (dm.code = dmd.movement_code)
			where	dm.branch_code = @branch_code
			and		dm.movement_status = 'ON PROCESS'
			and		dm.movement_type = @movement_type
			and		dm.movement_location = @movement_location
			and dm.CODE = @code
			--and		movement_to_branch_name = @from_to
			and		datediff(day, dm.movement_date, dbo.xfn_get_system_date()) = 1;
			
			-- two day
			select	@two_day = count(1) 
			from	dbo.document_movement dm
					inner join dbo.document_movement_detail dmd on (dm.code = dmd.movement_code)
			where	dm.branch_code = @branch_code
			and		dm.movement_status = 'ON PROCESS'
			and		dm.movement_type = @movement_type
			and		dm.movement_location = @movement_location
			and dm.CODE = @code
			--and		movement_to_branch_name = @from_to
			and		datediff(day, dm.movement_date, dbo.xfn_get_system_date()) = 2;

			-- three day
			select	@three_day = count(1) 
			from	dbo.document_movement dm
					inner join dbo.document_movement_detail dmd on (dm.code = dmd.movement_code)
			where	dm.branch_code = @branch_code
			and		dm.movement_status = 'ON PROCESS'
			and		dm.movement_type = @movement_type
			and		dm.movement_location = @movement_location
			and dm.CODE = @code
			--and		movement_to_branch_name = @from_to
			and		datediff(day, dm.movement_date, dbo.xfn_get_system_date()) = 3;

			-- more than three day
			select	@more_than_three_day = count(1) 
			from	dbo.document_movement dm
					inner join dbo.document_movement_detail dmd on (dm.code = dmd.movement_code)
			where	dm.branch_code = @branch_code
			and		dm.movement_status = 'ON PROCESS'
			and		dm.movement_type = @movement_type
			and		dm.movement_location = @movement_location
			and dm.CODE = @code
			--and		movement_to_branch_name = @from_to
			and		datediff(day, dm.movement_date, dbo.xfn_get_system_date()) > 3;  

			update	@temptable
			set		one_day				 = @one_day
					,two_day			 = @two_day
					,three_day			 = @three_day
					,more_than_three_day = @more_than_three_day
			where	branch_code			 = @branch_code
			and		movement_type		 = @movement_type
			and		movement_location	 = movement_location
			and CODE = @code
			--and		from_to				 = @from_to;

			fetch next from cursor_count into 
						@code
						,@branch_code
						,@branch_name	
						,@movement_location		
						,@movement_type	
						,@movement_from
						,@from_to
		end
            
		close cursor_count
		deallocate cursor_count

	--select	*
	--from	@temptable;

	select	@rows_count = count(1)
	from	@temptable
	where	branch_code = @p_branch_code
				--branch_code = case @p_branch_code
				--				when 'ALL' then branch_code
				--				else @p_branch_code
				--			  end
	and		(
				branch_name						like '%' + @p_keywords + '%'
				or	movement_location			like '%' + @p_keywords + '%'
				or	movement_type				like '%' + @p_keywords + '%'
				or	one_day						like '%' + @p_keywords + '%'
				or	two_day						like '%' + @p_keywords + '%'
				or	three_day					like '%' + @p_keywords + '%'
				or	more_than_three_day			like '%' + @p_keywords + '%'
				or	from_to						like '%' + @p_keywords + '%'
			) ;


		select		branch_code
					,branch_name 
					,movement_location 
					,movement_type
					,one_day
					,two_day
					,three_day 
					,more_than_three_day 
					,movement_from
					,from_to
					,@rows_count 'rowcount'
		from		@temptable
		where		branch_code = @p_branch_code
				--branch_code = case @p_branch_code
				--				when 'ALL' then branch_code
				--				else @p_branch_code
				--			  end
		and			(
						branch_name						like '%' + @p_keywords + '%'
						or	movement_location			like '%' + @p_keywords + '%'
						or	movement_type				like '%' + @p_keywords + '%'
						or	one_day						like '%' + @p_keywords + '%'
						or	two_day						like '%' + @p_keywords + '%'
						or	three_day					like '%' + @p_keywords + '%'
						or	more_than_three_day			like '%' + @p_keywords + '%'
						or	movement_from				like '%' + @p_keywords + '%'
						or	from_to						like '%' + @p_keywords + '%'
					) 
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													when 1 then movement_from
													when 2 then from_to	
													when 3 then movement_type	
													when 4 then movement_location			
													when 5 then cast(one_day as sql_variant)			
													when 6 then cast(two_day as sql_variant)			
													when 7 then cast(three_day as sql_variant)			
													when 8 then cast(more_than_three_day as sql_variant)
												 end
				end asc 
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
													    when 1 then movement_from
														when 2 then from_to	
														when 3 then movement_type	
														when 4 then movement_location			
														when 5 then cast(one_day as sql_variant)			
														when 6 then cast(two_day as sql_variant)			
														when 7 then cast(three_day as sql_variant)			
														when 8 then cast(more_than_three_day as sql_variant)
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
