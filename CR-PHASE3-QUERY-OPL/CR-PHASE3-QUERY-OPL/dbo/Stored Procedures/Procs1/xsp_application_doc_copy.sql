-- Louis Selasa, 02 April 2024 19.20.13 --
/*
exec xsp_application_doc_copy
*/
CREATE PROCEDURE dbo.xsp_application_doc_copy
(
	@p_client_no	   nvarchar(50)
	,@p_application_no nvarchar(50)
	--
	,@p_cre_date	   datetime
	,@p_cre_by		   nvarchar(15)
	,@p_cre_ip_address nvarchar(15)
	,@p_mod_date	   datetime
	,@p_mod_by		   nvarchar(15)
	,@p_mod_ip_address nvarchar(15)
)
as
begin
	declare @msg				 nvarchar(max)
			,@get_application_no nvarchar(50) 

	-- cr phase 3 sepria 30092025: update application doc, masuk ke app entry saat client macthing. untuk ambil settingan terbaru dari grouup
	--select		top 1
	--			@get_application_no = am.application_no
	--from		dbo.client_main cm
	--			inner join dbo.application_main am on (am.client_code = cm.code)
	--where		cm.client_no			  = @p_client_no
	--			and am.application_no	  <> @p_application_no
	--			and am.application_status = 'GO LIVE'
	--order by	am.golive_date desc ;

	begin TRY
    
		delete dbo.application_doc
		where application_no = @p_application_no

		exec dbo.xsp_application_doc_generate @p_application_no = @p_application_no,             -- nvarchar(50)
											  @p_cre_date = @p_cre_date, -- datetime
											  @p_cre_by = @p_cre_by,                     -- nvarchar(15)
											  @p_cre_ip_address = @p_cre_ip_address,             -- nvarchar(15)
											  @p_mod_date = @p_mod_date, -- datetime
											  @p_mod_by = @p_mod_by,                     -- nvarchar(15)
											  @p_mod_ip_address = @p_mod_ip_address              -- nvarchar(15)
	
		--if not exists
		--(
		--	select	1
		--	from	dbo.application_doc
		--	where	application_no = @get_application_no
		--)
		--begin
		--	insert into dbo.application_doc
		--	(
		--		application_no
		--		,document_code
		--		,filename
		--		,paths
		--		,expired_date
		--		,promise_date
		--		,is_required
		--		,waive_status
		--		,waive_request_date
		--		,waive_approve_by
		--		,waive_approve_date
		--		,is_valid
		--		,remarks
		--		--
		--		,cre_date
		--		,cre_by
		--		,cre_ip_address
		--		,mod_date
		--		,mod_by
		--		,mod_ip_address
		--	)
		--	select	@p_application_no
		--			,document_code
		--			,filename
		--			,paths
		--			,expired_date
		--			,promise_date
		--			,is_required
		--			,waive_status
		--			,waive_request_date
		--			,waive_approve_by
		--			,waive_approve_date
		--			,is_valid
		--			,remarks
		--			--
		--			,@p_cre_date
		--			,@p_cre_by
		--			,@p_cre_ip_address
		--			,@p_mod_date
		--			,@p_mod_by
		--			,@p_mod_ip_address
		--	from	dbo.application_doc
		--	where	application_no = @get_application_no ;
		--end ;
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
			set @msg = N'V' + N';' + @msg ;
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
				set @msg = N'E;' + dbo.xfn_get_msg_err_generic() + N';' + error_message() ;
			end ;
		end ;

		raiserror(@msg, 16, -1) ;

		return ;
	end catch ;
end ;
