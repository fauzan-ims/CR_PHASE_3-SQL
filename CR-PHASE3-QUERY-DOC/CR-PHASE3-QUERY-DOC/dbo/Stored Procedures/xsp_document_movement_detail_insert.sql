CREATE PROCEDURE dbo.xsp_document_movement_detail_insert
(
	@p_id					  int			 = 0 output
	,@p_movement_code		  nvarchar(50)
	,@p_document_code		  nvarchar(50)
	,@p_document_request_code nvarchar(50)	 = null
	,@p_document_pending_code nvarchar(50)	 = null
	,@p_is_reject			  nvarchar(1)	 = '0'
	,@p_remarks				  nvarchar(4000) = ''
	--
	,@p_cre_date			  datetime
	,@p_cre_by				  nvarchar(15)
	,@p_cre_ip_address		  nvarchar(15)
	,@p_mod_date			  datetime
	,@p_mod_by				  nvarchar(15)
	,@p_mod_ip_address		  nvarchar(15)
)
as
begin
	declare @msg nvarchar(max) ;

	begin try

		--if exists
		--(
		--	select	1
		--	from	dbo.document_movement
		--	where	code			  = @p_movement_code
		--			and movement_location = 'CLIENT'
		--)
		--begin
		--	insert into document_movement_detail
		--	(
		--		movement_code
		--		,document_code
		--		,document_request_code
		--		,document_pending_code
		--		,is_reject
		--		,remarks
		--		--
		--		,cre_date
		--		,cre_by
		--		,cre_ip_address
		--		,mod_date
		--		,mod_by
		--		,mod_ip_address
		--	)
		--	select	DISTINCT @p_movement_code
		--			,code
		--			,@p_document_request_code
		--			,@p_document_pending_code
		--			,@p_is_reject
		--			,@p_remarks
		--			--
		--			,@p_cre_date
		--			,@p_cre_by
		--			,@p_cre_ip_address
		--			,@p_mod_date
		--			,@p_mod_by
		--			,@p_mod_ip_address
		--	from	dbo.document_main
		--	where	asset_no in
		--			(
		--				select	asset_no
		--				from	dbo.document_main
		--				where	code = @p_document_code
		--			)
		--			and code not in
		--				(
		--					select	document_code
		--					from	dbo.document_movement_detail
		--					where	movement_code = @p_movement_code
		--				) 
		--end ;
		--else
		--begin
			insert into document_movement_detail
			(
				movement_code
				,document_code
				,document_request_code
				,document_pending_code
				,is_reject
				,remarks
				--
				,cre_date
				,cre_by
				,cre_ip_address
				,mod_date
				,mod_by
				,mod_ip_address
			)
			values
			(	@p_movement_code
				,@p_document_code
				,@p_document_request_code
				,@p_document_pending_code
				,@p_is_reject
				,@p_remarks
				--
				,@p_cre_date
				,@p_cre_by
				,@p_cre_ip_address
				,@p_mod_date
				,@p_mod_by
				,@p_mod_ip_address
			) ;
		--end

			set @p_id = @@identity ;
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
			if (
				   error_message() like '%V;%'
				   or	error_message() like '%E;%'
			   )
			begin
				set @msg = error_message() ;
			end ;
			else
			begin
				set @msg = 'E;' + dbo.xfn_get_msg_err_generic() + ';' + error_message() ;
			end ;
		end ;

		raiserror(@msg, 16, -1) ;

		return ;
	end catch ;
end ;
