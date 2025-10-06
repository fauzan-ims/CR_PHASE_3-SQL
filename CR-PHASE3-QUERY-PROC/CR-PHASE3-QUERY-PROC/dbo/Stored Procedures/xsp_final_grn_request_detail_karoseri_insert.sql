
-- Stored Procedure

-- Stored Procedure

CREATE PROCEDURE [dbo].[xsp_final_grn_request_detail_karoseri_insert]
(
	@p_id									 bigint = 0 output
	,@p_final_grn_request_detail_id			 int
	,@p_application_no						 nvarchar(50)
	,@p_final_grn_request_detail_karoseri_id int
	--
	,@p_cre_date							 datetime
	,@p_cre_by								 nvarchar(15)
	,@p_cre_ip_address						 nvarchar(15)
	,@p_mod_date							 datetime
	,@p_mod_by								 nvarchar(15)
	,@p_mod_ip_address						 nvarchar(15)
	,@p_grn_po_detail_id					bigint = 0
)
as
begin
	declare @msg	nvarchar(max)
			,@count int 
			,@item_code		nvarchar(50)
			,@grn_po_detail_id nvarchar(50)


	begin try

	--select	@item_code = item_code 
	--from	dbo.final_grn_request_detail_karoseri_lookup 
	--where	id = @p_final_grn_request_detail_karoseri_id

	--IF NOT EXISTS
	--(
	--	SELECT	1 
	--	FROM	dbo.FINAL_GRN_REQUEST_DETAIL_KAROSERI a
	--	INNER JOIN dbo.FINAL_GRN_REQUEST_DETAIL_KAROSERI_LOOKUP b ON  b.id = a.FINAL_GRN_REQUEST_DETAIL_KAROSERI_ID
	--	WHERE	a.FINAL_GRN_REQUEST_DETAIL_ID = @p_final_grn_request_detail_id AND b.ITEM_CODE = @item_code
	--	)

	--IF NOT EXISTS
	--(
	--	SELECT	1 
	--	FROM	dbo.FINAL_GRN_REQUEST_DETAIL_KAROSERI a
	--	WHERE	a.FINAL_GRN_REQUEST_DETAIL_ID = @p_final_grn_request_detail_id
	--	AND		a.id_temp	= @p_final_grn_request_detail_karoseri_id
	--	)

		--declare @grn_po_detail_id nvarchar(50)

		select	@grn_po_detail_id	= grn_po_detail_id
		from	FINAL_GRN_REQUEST_DETAIL_KAROSERI_LOOKUP
		where	id = @p_final_grn_request_detail_karoseri_id ;


		begin

		--select	@grn_po_detail_id	= grn_po_detail_id
		--from	dbo.final_grn_request_detail_karoseri_lookup
		--where	id = @p_id ;

			insert into dbo.final_grn_request_detail_karoseri
			(
				final_grn_request_detail_id
				,application_no
				,final_grn_request_detail_karoseri_id
				--
				,cre_date
				,cre_by
				,cre_ip_address
				,mod_date
				,mod_by
				,mod_ip_address
				,grn_po_detail_id
			)
			values
			(
				@p_final_grn_request_detail_id
				,@p_application_no
				,@p_final_grn_request_detail_karoseri_id
				--
				,@p_cre_date
				,@p_cre_by
				,@p_cre_ip_address
				,@p_mod_date
				,@p_mod_by
				,@p_mod_ip_address
				,@grn_po_detail_id
			) ;
			set @p_id = @@identity ;
		--END ;
		--ELSE
  --      BEGIN
		--	UPDATE dbo.FINAL_GRN_REQUEST_DETAIL_KAROSERI
		--	SET		FINAL_GRN_REQUEST_DETAIL_KAROSERI_ID = @p_final_grn_request_detail_karoseri_id
		--			,APPLICATION_NO	= @p_application_no
		--			,MOD_DATE		= @p_mod_date
		--			,MOD_BY			= @p_mod_by
		--			,MOD_IP_ADDRESS	= @p_mod_ip_address
		--	WHERE	FINAL_GRN_REQUEST_DETAIL_ID = @p_final_grn_request_detail_id
		END;
	END try
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
