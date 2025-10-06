CREATE PROCEDURE dbo.xsp_application_asset_reservation_update
(
	@p_id						bigint
    ,@p_client_name				nvarchar(250)
	,@p_client_phone_area_no	nvarchar(5)
	,@p_client_phone_no			nvarchar(15)
	,@p_remark					nvarchar(4000)
	,@p_fa_code					nvarchar(50)
	,@p_fa_name					nvarchar(250)
	-- 
	,@p_mod_date				datetime
	,@p_mod_by					nvarchar(15)
	,@p_mod_ip_address			nvarchar(15)
)
as
begin
	declare @msg nvarchar(max) ;

	begin try
    
	--13/12/2022, Rian Menambahkan validasi ketika update data tidak boleh sama dengan yang sudah terdaftar dan dengan data yang status nya hold, on process, dan post yang tanggal exp nya lebih besar dari tanggal sistem
		if exists (
					select	1
					from	application_asset_reservation
					where	id <> @p_id
					and		fa_code = @p_fa_code
					and		status <> 'CANCEL' 
					and		reserv_exp_date > dbo.xfn_get_system_date()
					)
		begin
			set @msg = 'Data Already Use';
			raiserror(@msg ,16,-1)
        end
		update	application_asset_reservation
		set		fa_code					= @p_fa_code
				,fa_name				= @p_fa_name
				,client_name			= @p_client_name
				,client_phone_area_no	= @p_client_phone_area_no
				,client_phone_no		= @p_client_phone_no
				,remark					= @p_remark
				--
				,mod_date		= @p_mod_date
				,mod_by			= @p_mod_by
				,mod_ip_address = @p_mod_ip_address
		where	id				= @p_id ;
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
