CREATE PROCEDURE [dbo].[xsp_checking_date_from_month]
(
	@p_date		nvarchar(2) = ''
	,@p_month	nvarchar(50)
	,@p_year	nvarchar(4)
)
as
begin
	if @p_date is not null
		begin try
		declare @is_date nvarchar(50)
			,@month	 int 
			,@tanggal_awal datetime
			,@tanggal_max  datetime 
			,@tanggal_maxi nvarchar(50)
			,@msg		   nvarchar(250) ;

		if @p_month = 'Januari'
				set @month = 1
			else if @p_month = 'Februari'
				set @month = 2
			else if @p_month = 'Maret'
				set @month = 3
			else if @p_month = 'April'
				set @month = 4
			else if @p_month = 'Mei'
				set @month = 5
			else if @p_month = 'Juni'
				set @month = 6
			else if @p_month = 'Juli'
				set @month = 7
			else if @p_month = 'Agustus'
				set @month = 8
			else if @p_month = 'September'
				set @month = 9
			else if @p_month = 'Oktober'
				set @month = 10
			else if @p_month = 'November'
				set @month = 11
			else if @p_month = 'Desember'
				set @month = 12

			if @p_date <> ''
			begin
			select @tanggal_awal = datefromparts(@p_year,@month,1);
			select @tanggal_max = eomonth(@tanggal_awal);
			select @tanggal_maxi = day(@tanggal_max);
			if @p_date > @tanggal_maxi or @p_date = 0
			begin
				set @msg = 'Date format invalid.';
				raiserror(@msg, 16, -1)
			end ;
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
