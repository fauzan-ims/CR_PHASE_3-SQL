CREATE PROCEDURE dbo.xsp_ar_daily_balancing_eod_concept
(
	@p_eod_date		datetime = null
)
as
begin
	declare @msg		nvarchar(max)
			,@eod_date	datetime = @p_eod_date --dbo.xfn_get_system_date() ; -- (+) Ari 2024-02-26 ket : ubah konsep dari eod menjadi parameterize
			,@loop		int = 1
			,@end_loop	int = 2

	BEGIN TRY

	IF (DATENAME(dw,(@eod_date))) = 'Sunday'
	BEGIN
		-- untuk minggu
		EXEC dbo.xsp_ar_daily_balancing_insert @p_eod_date = @p_eod_date

		WHILE @loop <= @end_loop
		BEGIN
			SET @eod_date = DATEADD(DAY, -1 * @loop,CAST(dbo.xfn_get_system_date() AS DATE))
			-- untuk jumat dan sabtu
			EXEC dbo.xsp_ar_daily_balancing_insert @p_eod_date = @eod_date

			SET @loop = @loop + 1
		END

	END
	ELSE
	BEGIN
		EXEC dbo.xsp_ar_daily_balancing_insert @p_eod_date = @p_eod_date

	END
    
	end try
	begin catch
		if (len(@msg) <> 0)
		begin
			set @msg = N'v' + N';' + @msg ;
		end ;
		else
		begin
			set @msg = N'e;there is an error.' + N';' + error_message() ;
		end ;

		raiserror(@msg, 16, -1) ;

		return ;
	end catch ;
end ;
