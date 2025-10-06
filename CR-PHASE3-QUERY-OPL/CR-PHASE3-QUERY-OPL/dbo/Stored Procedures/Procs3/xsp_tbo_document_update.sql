CREATE PROCEDURE [dbo].[xsp_tbo_document_update]
(
	@p_id					BIGINT
	,@p_is_received			NVARCHAR(1)	= '0'
	,@p_promise_date		DATETIME    = NULL
	,@p_is_valid			NVARCHAR(1) = '0'
	--,@p_transaction_name	NVARCHAR(50)
	,@p_remark				NVARCHAR(4000) = NULL
	,@p_remarks				NVARCHAR(4000) = NULL
	--
	,@p_mod_date	   DATETIME
	,@p_mod_by		   NVARCHAR(15)
	,@p_mod_ip_address NVARCHAR(15)
)
AS
BEGIN
	DECLARE @msg NVARCHAR(MAX) ;

	begin try 
		
		update	dbo.tbo_document
		set		remarks			= @p_remark
				--
				,mod_date		= @p_mod_date
				,mod_by			= @p_mod_by
				,mod_ip_address	= @p_mod_ip_address
		where	id	= @p_id
		
		--update dbo.tbo_document_detail
		--set		is_valid		= @p_is_valid	
		--		,is_received	= @p_is_received
		--		,remarks		= @p_remarks
		--		,promise_date	= @p_promise_date
				
		--		,mod_date		= @p_mod_date
		--		,mod_by			= @p_mod_by
		--		,mod_ip_address	= @p_mod_ip_address
		--where	id				= @p_id

	END TRY
	BEGIN CATCH
		DECLARE @error INT ;

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
