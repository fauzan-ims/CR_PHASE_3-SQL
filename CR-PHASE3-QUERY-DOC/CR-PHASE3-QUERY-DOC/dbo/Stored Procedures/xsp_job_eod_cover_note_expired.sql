-- Raffyanda 12/01/2024  --
create PROCEDURE dbo.xsp_job_eod_cover_note_expired
AS
BEGIN
	DECLARE @msg					   NVARCHAR(MAX)
			,@mod_date				   DATETIME		= GETDATE()
			,@mod_by				   NVARCHAR(15) = N'EOD'
			,@mod_ip_address		   NVARCHAR(15) = N'SYSTEM'
			,@replacement_code		   NVARCHAR(50) ;

	BEGIN TRY
		BEGIN
			DECLARE cur_replacement_request CURSOR FAST_FORWARD READ_ONLY FOR
			SELECT	ID
			FROM	dbo.REPLACEMENT_REQUEST
			WHERE	COVER_NOTE_EXP_DATE <= dbo.xfn_get_system_date() AND STATUS = 'HOLD'

			OPEN cur_replacement_request ;

			FETCH NEXT FROM cur_replacement_request
			INTO @replacement_code ;

			WHILE @@fetch_status = 0
			BEGIN
				EXEC dbo.xsp_replacement_request_expired @p_id				= @replacement_code,	-- nvarchar(50)
				                                         @p_mod_date		= @mod_date,			-- datetime
				                                         @p_mod_by			= @mod_by,              -- nvarchar(15)
				                                         @p_mod_ip_address	= @mod_ip_address       -- nvarchar(15)
				


				fetch next from cur_replacement_request
				into @replacement_code ;
			end ;

			close cur_replacement_request ;
			deallocate cur_replacement_request ;
		end ;
	end try
	begin catch
		if (len(@msg) <> 0)
		begin
			set @msg = N'V' + N';' + @msg ;
		end ;
		else
		begin
			set @msg = N'E;There is an error.' + N';' + error_message() ;
		end ;

		raiserror(@msg, 16, -1) ;

		return ;
	end catch ;
end ;
