CREATE PROCEDURE [dbo].[xsp_procurement_return]
(
	@p_code						 nvarchar(50)
	--
	,@p_mod_date				 datetime
	,@p_mod_by					 nvarchar(15)
	,@p_mod_ip_address			 nvarchar(15)
)
as
begin
	declare @msg					nvarchar(max)
			,@count_procurement		int
			,@count_request			int 
			,@code_proc_request		nvarchar(50)
			,@reff_no				nvarchar(50)
			,@code_procurement		nvarchar(50)

	begin try

		--delete dbo.procurement
		--where code = @p_code

		----- kalau mau di delete semua
		----delete dbo.procurement
		----where procurement_request_code = @p_procurement_request_code

		--update dbo.procurement_request
		--set		status			= 'HOLD'
		--		--
		--		,mod_date		= @p_mod_date
		--		,mod_by			= @p_mod_by
		--		,mod_ip_address = @p_mod_ip_address
		--where	code			= @p_procurement_request_code

		select @code_proc_request = procurement_request_code
		from dbo.procurement
		where code = @p_code

		select @reff_no = asset_no 
		from dbo.procurement_request
		where code = @code_proc_request

		if exists
		(
			select	1
			from	dbo.procurement
			where	procurement_request_code = @code_proc_request
					and status				 = 'POST'
		)
		begin
			set @msg = N'Cannot return this data, because other data with the same procurement request code already post.' ;

			raiserror(@msg, 16, 1) ;
		end ;

		if(isnull(@reff_no,'') = '')
		begin
			declare curr_return_proc cursor fast_forward read_only for
			select code
			from dbo.procurement
			where procurement_request_code = @code_proc_request
			
			open curr_return_proc
			
			fetch next from curr_return_proc 
			into @code_procurement
			
			while @@fetch_status = 0
			begin
			    update	dbo.procurement
				set		status			= 'CANCEL'
						,mod_date		= @p_mod_date
						,mod_by			= @p_mod_by
						,mod_ip_address = @p_mod_ip_address
				where	code			= @code_procurement ;
			
			    fetch next from curr_return_proc 
				into @code_procurement
			end
			
			close curr_return_proc
			deallocate curr_return_proc

			update	dbo.procurement_request
			set		status			= 'HOLD'
					,mod_date		= @p_mod_date
					,mod_by			= @p_mod_by
					,mod_ip_address = @p_mod_ip_address
			where	code			= @code_proc_request ;
		end
		else
		begin
			set @msg = 'Cannot return this data because this data from operating lease.' ;
			raiserror(@msg, 16, 1) ;
		end
	end try
	begin catch
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
