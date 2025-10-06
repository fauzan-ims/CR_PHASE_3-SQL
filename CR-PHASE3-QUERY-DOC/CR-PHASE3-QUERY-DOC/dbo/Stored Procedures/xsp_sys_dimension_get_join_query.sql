CREATE PROCEDURE dbo.xsp_sys_dimension_get_join_query
(
	@p_query		nvarchar(1000) output
	,@p_done		int			   output
	,@p_from_table	nvarchar(50)
	,@p_from_column nvarchar(50)
	,@p_to_table	nvarchar(50)
	,@p_iteration	int
)
as
begin
	declare	@msg	nvarchar(max)
	begin try

		if @p_iteration = 0
		begin
			set @p_query = 'select @out = ' + @p_from_table + '.' + @p_from_column + ' from ' + @p_from_table ;
		end ;

		if @p_from_table = @p_to_table
		begin
			return ;
		end ;

		if @p_iteration > 5
		begin
			set @p_query = '' ;

			return ;
		end ;
		declare @parent_table nvarchar(50)
				,@parent_col  nvarchar(50)
				,@ref_table	  nvarchar(50)
				,@ref_col	  nvarchar(50)
				,@join_query  nvarchar(1000)
				,@done		  int = @p_done ;
	

		declare fk_cur cursor local fast_forward for
			select		tp.name
						,cp.name
						,tr.name
						,cr.name
			from		sys.foreign_keys fk
						inner join sys.tables tp on fk.parent_object_id					   = tp.object_id
						inner join sys.tables tr on fk.referenced_object_id				   = tr.object_id
						inner join sys.foreign_key_columns fkc on fkc.constraint_object_id = fk.object_id
						inner join sys.columns cp on fkc.parent_column_id				   = cp.column_id
													 and   fkc.parent_object_id			   = cp.object_id
						inner join sys.columns cr on fkc.referenced_column_id			   = cr.column_id
													 and   fkc.referenced_object_id		   = cr.object_id
			where		tp.name		= @p_from_table
						or	tr.name = @p_from_table
			order by	case when tp.name = @p_to_table then 1 else 2 end 
						,tp.name
						,cp.column_id ;

			open fk_cur ;

		fetch next from fk_cur
		into @parent_table
			 ,@parent_col
			 ,@ref_table
			 ,@ref_col ;

		while @@fetch_status = 0
		begin
			set @join_query = @p_query ;

			--search down from parent to child
			if @parent_table = @p_from_table
			begin
				if charindex(@ref_table + ' ', @join_query) > 0
				begin
					fetch next from fk_cur
					into @parent_table
						 ,@parent_col
						 ,@ref_table
						 ,@ref_col ;

					continue ;
				end ;

				set @join_query = @join_query + ' inner join ' + @ref_table + ' on ' + @ref_table + '.' + @ref_col + ' = ' + @parent_table + '.' + @parent_col ;

				if @ref_table = @p_to_table
				begin
					set @p_query = @join_query ;
					set @p_done = 1 ;

					close fk_cur ;
					deallocate fk_cur ;

					return ;
				end ;
				else
				begin
					set @p_iteration = @p_iteration + 1 ;

					exec dbo.xsp_sys_dimension_get_join_query @p_query			= @join_query output 
															  ,@p_done			= @done output 
															  ,@p_from_table	= @ref_table 
															  ,@p_from_column	= @ref_col 
															  ,@p_to_table		= @p_to_table 
															  ,@p_iteration		= @p_iteration ; 

					if @done = 1
					begin
						set @p_query = @join_query ;
						set @p_done = 1 ;

						close fk_cur ;
						deallocate fk_cur ;

						return ;
					end ;
				end ;
			end ;
			else
			begin
				if charindex(@parent_table + ' ', @join_query) > 0
				begin
					fetch next from fk_cur
					into @parent_table
						 ,@parent_col
						 ,@ref_table
						 ,@ref_col ;

					continue ;
				end ;

				set @join_query = @join_query + ' inner join ' + @parent_table + ' on ' + @parent_table + '.' + @parent_col + ' = ' + @ref_table + '.' + @ref_col ;

				if @parent_table = @p_to_table
				begin
					set @p_query = @join_query ;
					set @p_done = 1 ;

					close fk_cur ;
					deallocate fk_cur ;

					return ;
				end ;
				else
				begin
					set @p_iteration = @p_iteration + 1 ;

					exec dbo.xsp_sys_dimension_get_join_query @p_query			= @join_query output 
															  ,@p_done			= @done output 
															  ,@p_from_table	= @parent_table
															  ,@p_from_column	= @parent_col 
															  ,@p_to_table		= @p_to_table 
															  ,@p_iteration		= @p_iteration ; 

					if @done = 1
					begin
						set @p_query = @join_query ;
						set @p_done = 1 ;

						close fk_cur ;
						deallocate fk_cur ;

						return ;
					end ;
				end ;
			end ;

			fetch next from fk_cur
			into @parent_table
				 ,@parent_col
				 ,@ref_table
				 ,@ref_col ;
		end ;

		close fk_cur ;
		deallocate fk_cur ;

		set @p_query = '' ;
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
