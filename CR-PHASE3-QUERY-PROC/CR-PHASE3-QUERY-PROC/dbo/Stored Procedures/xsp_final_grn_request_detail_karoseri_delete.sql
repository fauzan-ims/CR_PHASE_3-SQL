
-- Stored Procedure

-- Stored Procedure

CREATE PROCEDURE [dbo].[xsp_final_grn_request_detail_karoseri_delete]
(
	@p_id INT
)
AS
BEGIN
	DECLARE @msg	NVARCHAR(MAX)
			,@count INT ;

	BEGIN TRY
		--select	@count = count(1)
		--from	dbo.FINAL_GRN_REQUEST_DETAIL_KAROSERI
		--where	ID = @p_id ;

		--if (@count > 1)
		--begin
		--	update	dbo.final_grn_request_detail_karoseri_lookup
		--	set		final_grn_request_detail_karoseri_id = 0
		--	where	final_grn_request_detail_karoseri_id = @p_id ;
		--end ;
		--else
		--begin
		--	set @msg = N'Cannot delete this data.' ;

		--	raiserror(@msg, 16, 1) ;
		--end ;
		delete	dbo.final_grn_request_detail_karoseri
		where	id = @p_id ;


		--UPDATE dbo.FINAL_GRN_REQUEST_DETAIL_KAROSERI
		--SET		FINAL_GRN_REQUEST_DETAIL_KAROSERI_ID = NULL
		--		,APPLICATION_NO = NULL
		--WHERE ID = @p_id
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
			set @msg = @msg ;
		end ;
		else
		begin
			if (
				   error_message() like '%v;%'
				   or	error_message() like '%e;%'
			   )
			begin
				set @msg = error_message() ;
			end ;
			else
			begin
				set @msg = N'e;' + dbo.xfn_get_msg_err_generic() + N';' + error_message() ;
			end ;
		end ;

		raiserror(@msg, 16, -1) ;

		return ;
	end catch ;
end ;
