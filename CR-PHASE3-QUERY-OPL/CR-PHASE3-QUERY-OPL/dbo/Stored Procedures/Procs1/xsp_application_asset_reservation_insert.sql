--13/12/2022 Rian, Menambahkan reserv exp date, client name, client phone area, client phone no..

CREATE PROCEDURE dbo.xsp_application_asset_reservation_insert
(
	@p_id						bigint = 0 output
	,@p_employee_code			nvarchar(50)
	,@p_employee_name			nvarchar(250)
	,@p_status					nvarchar(10)
	,@p_client_name				nvarchar(250)
	,@p_client_phone_area_no	nvarchar(5)
	,@p_client_phone_no			nvarchar(15)
	,@p_remark					nvarchar(4000)
	,@p_fa_code					nvarchar(50)
	,@p_fa_name					nvarchar(250)
	,@p_application_no			nvarchar(50)  = null
	--
	,@p_cre_date				datetime
	,@p_cre_by					nvarchar(15)
	,@p_cre_ip_address			nvarchar(15)
	,@p_mod_date				datetime
	,@p_mod_by					nvarchar(15)
	,@p_mod_ip_address			nvarchar(15)
	
)
as
begin
	declare @msg						nvarchar(max) 
			,@value_global_param		int
			,@reserv_exp_date			datetime
			,@reserv_date				datetime;

	begin try
    
		set	@reserv_date = dbo.xfn_get_system_date()

		--13/12/2022 Rian, Menambahkan reserv exp date dengan nilai berdasarkan jumlah value global sistem (30) hari dari tanggal sistem 
		select	@value_global_param = value
		from	dbo.sys_global_param where code = 'RSVDAYS'

		select	@reserv_exp_date = dateadd(day,@value_global_param, dbo.xfn_get_system_date()) 

		if exists (
					select	1
					from	application_asset_reservation
					where	fa_code = @p_fa_code
					and		status <> 'CANCEL' 
					and		reserv_exp_date > dbo.xfn_get_system_date()
					)
		begin
			set @msg = 'Data already use in Transaction';
			raiserror(@msg ,16,-1)
        end

		insert into dbo.application_asset_reservation
		(
			employee_code
			,employee_name
			,reserv_date
			,reserv_exp_date	
			,status
			,client_name			
			,client_phone_area_no
			,client_phone_no	
			,remark	
			,fa_code
			,fa_name
			,application_no
			--
			,cre_date
			,cre_by
			,cre_ip_address
			,mod_date
			,mod_by
			,mod_ip_address
		)
		values
		(	@p_employee_code
			,@p_employee_name
			,@reserv_date
			,@reserv_exp_date
			,@p_status
			,@p_client_name			
			,@p_client_phone_area_no
			,@p_client_phone_no		
			,@p_remark
			,@p_fa_code
			,@p_fa_name
			,@p_application_no
			--
			,@p_cre_date
			,@p_cre_by
			,@p_cre_ip_address
			,@p_mod_date
			,@p_mod_by
			,@p_mod_ip_address
		) ;
		
		set @p_id = @@identity;
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
