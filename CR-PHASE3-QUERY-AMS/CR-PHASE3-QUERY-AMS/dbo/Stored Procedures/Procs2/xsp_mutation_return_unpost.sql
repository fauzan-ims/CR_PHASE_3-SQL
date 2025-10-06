CREATE PROCEDURE dbo.xsp_mutation_return_unpost
(
	@p_id					bigint
	--
	,@p_mod_by				nvarchar(15)
	,@p_mod_date			datetime
	,@p_mod_ip_address		nvarchar(15)
	--
	,@p_remark_return		nvarchar(400) = ''
	,@p_remark_unpost		nvarchar(400) = ''  
) as
begin
	declare @status				nvarchar(20)
			,@remarks			nvarchar(4000)
			,@status_detail		nvarchar(20)
			,@status_header		nvarchar(20)
			,@mutation_code		nvarchar(50)
			,@base_data			int
			,@received_data		int
			,@unpost_data		int
			,@return_data		int
			,@msg				nvarchar(max)

	begin try
			if isnull(@p_remark_unpost,'') = '' and isnull(@p_remark_return,'') = ''
			begin
				set @msg = 'Please fill in remarks return or unpost.';
				raiserror(@msg ,16,-1);
			end

			select	@mutation_code = mutation_code
			from	dbo.mutation_detail
			where	id = cast(@p_id as int)

			select	@status			= status
			from	dbo.mutation
			where	code	= @mutation_code;

			if	(@status = 'CANCEL')
			begin
				set @msg = 'Data already cancel.';
				raiserror(@msg ,16,-1);
			end 
			
			if	(@status = 'UNPOST')
			begin
				set @msg = 'Data already unpost.';
				raiserror(@msg ,16,-1);
			end 
		
			if isnull(@p_remark_return,'') <> ''
			begin
				select	@remarks = @p_remark_return
						,@status_detail = 'RETURNED'
			end
			else if isnull(@p_remark_unpost,'') <> ''
			begin
				select	 @remarks = @p_remark_unpost
						,@status_detail = 'UNPOSTED'
			end
	
			update	dbo.mutation_detail
			set		status_received		= @status_detail
					,remark_unpost		= isnull(@p_remark_unpost,'')
					,remark_return		= isnull(@p_remark_return,'')
					--
					,mod_date			= @p_mod_date
					,mod_by				= @p_mod_by
					,mod_ip_address		= @p_mod_ip_address
			where	id = cast(@p_id as int) -- Arga 29-Oct-2021 ket : for BAF based on detail item (+)
			

			-- Trisna 08-Nov-2022 ket : for WOM (-) ====
			/*
			sampling detail data asset mutation = 10
			handling case for header status :
				A. 5 RECEIVED 5 UNPOSTED -> UNPOSTED
				B. 5 RECEIVED 5 RETURNED -> RETURNED
				C. 5 RETURNED 5 UNPOSTED -> UNPOSTED
				D. 2 RECEIVED 5 RETURNED 3 UNPOSTED -> UNPOSTED
				E. 10 RETURNED -> RETURNED
				F. 10 RECEIVED -> POST
				G. 10 UNPOSTED -> CANCEL
				H. NULL
			*/
			
			select	@base_data = count(mutation_code)
			from	dbo.mutation_detail
			where	mutation_code = @mutation_code
			
			select	@received_data = count(mutation_code)
			from	dbo.mutation_detail
			where	mutation_code = @mutation_code
			and		isnull(status_received,'') = 'RECEIVED'
			
			select	@return_data = count(mutation_code)
			from	dbo.mutation_detail
			where	mutation_code = @mutation_code
			and		isnull(status_received,'') = 'RETURNED'
			
			select	@unpost_data = count(mutation_code)
			from	dbo.mutation_detail
			where	mutation_code = @mutation_code
			and		isnull(status_received,'') = 'UNPOSTED'


			if (@base_data = @return_data) -- case e
			begin
				set @status_header = 'RETURNED';
			end
			else if (@base_data = @received_data) -- case f
			begin
				set @status_header = 'POST';
			end
			else if (@base_data = @unpost_data) -- case g
			begin
				set @status_header = 'CANCEL';
			end
			else if exists (select 1 from dbo.mutation_detail where mutation_code = @mutation_code and isnull(status_received,'') = 'UNPOSTED') -- case a, c, d
			begin
			    set @status_header = 'UNPOSTED';
			end
			else if exists (select 1 from dbo.mutation_detail where mutation_code = @mutation_code and isnull(status_received,'') = 'RETURNED') -- case b
			begin
			    set @status_header = 'RETURNED';
			end


			/*/*
			sampling detail data asset mutation = 10
			handling case for header status :
				A. 5 RECEIVED 5 UNPOSTED -> POST
				B. 5 RECEIVED 5 RETURNED -> RETURNED
				C. 5 RETURNED 5 UNPOSTED -> RETURNED
				D. 10 RETURNED -> RETURNED
				E. 10 RECEIVED -> POST
				F. 10 UNPOSTED -> CANCEL
				G. NULL
			*/

			select	@base_data = count(mutation_code)
			from	dbo.mutation_detail
			where	mutation_code = @mutation_code
			
			select	@received_data = count(mutation_code)
			from	dbo.mutation_detail
			where	mutation_code = @mutation_code
			and		isnull(status_received,'') = 'RECEIVED'
			
			select	@unpost_data = count(mutation_code)
			from	dbo.mutation_detail
			where	mutation_code = @mutation_code
			and		isnull(status_received,'') = 'UNPOSTED'


			if exists (select 1 from dbo.mutation_detail where mutation_code = @mutation_code and isnull(status_received,'') = '') -- case G
				set @status_header = 'PENDING'
			else if exists (select 1 from dbo.mutation_detail where mutation_code = @mutation_code and isnull(status_received,'') = 'RETURNED') -- case B, C, D
				set @status_header = 'RETURNED'
			else if @base_data = @received_data + @unpost_data -- case A
				set @status_header = 'POST'
			else if @base_data = @received_data -- case E
				set @status_header = 'POST'
			else if @base_data = @unpost_data -- case F
				set @status_header = 'CANCEL'
			*/
		
			update	dbo.mutation
			set		status				= @status_header
					--
					,mod_date			= @p_mod_date
					,mod_by				= @p_mod_by
					,mod_ip_address		= @p_mod_ip_address
					,remark				= case @status_header
											when 'PENDING' then ''
											when 'RETURNED' then @remarks
											when 'CANCEL' then @remarks
											when 'POST' then ''
											when 'UNPOST' then @remarks
											else ''
										end
			where	code = @mutation_code ;
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
end
