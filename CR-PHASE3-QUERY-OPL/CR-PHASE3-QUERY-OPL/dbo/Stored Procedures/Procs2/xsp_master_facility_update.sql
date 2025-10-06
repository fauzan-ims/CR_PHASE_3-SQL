CREATE PROCEDURE dbo.xsp_master_facility_update
(
	@p_code			   nvarchar(50)
	,@p_description	   nvarchar(250)
	,@p_facility_type  nvarchar(2)
	,@p_deskcoll_min   int
	,@p_deskcoll_max   int
	,@p_sp1_days	   int
	,@p_sp2_days	   int
	,@p_somasi_days	   int
	,@p_aging_days1	   int
	,@p_aging_days2	   int
	,@p_aging_days3	   int
	,@p_aging_days4	   int
	,@p_is_active	   nvarchar(1)
	--
	,@p_mod_date	   datetime
	,@p_mod_by		   nvarchar(15)
	,@p_mod_ip_address nvarchar(15)
)
as
begin
	declare @msg nvarchar(max) ;

	if @p_is_active = 'T'
		set @p_is_active = '1' ;
	else
		set @p_is_active = '0' ;

	begin try
		if exists (select 1 from master_facility where description = @p_description and code <> @p_code)
		begin
			set @msg = 'Description already exist';
			raiserror(@msg, 16, -1) ;
		end 

		update	master_facility
		set		description			= upper(@p_description)
				,facility_type		= @p_facility_type
				,deskcoll_min		= @p_deskcoll_min
				,deskcoll_max		= @p_deskcoll_max
				,sp1_days			= @p_sp1_days
				,sp2_days			= @p_sp2_days
				,somasi_days		= @p_somasi_days
				,aging_days1		= @p_aging_days1
				,aging_days2		= @p_aging_days2
				,aging_days3		= @p_aging_days3
				,aging_days4		= @p_aging_days4
				,is_active			= @p_is_active
				--
				,mod_date			= @p_mod_date
				,mod_by				= @p_mod_by
				,mod_ip_address		= @p_mod_ip_address
		where	code				= @p_code ;
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
