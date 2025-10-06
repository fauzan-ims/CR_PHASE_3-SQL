--created by, Rian at 10/07/2023 

CREATE procedure dbo.xsp_ams_interface_asset_vehicle_update_insert
(
	@p_id					bigint output
	,@p_fa_code				nvarchar(50)
	,@p_fa_reff_no_1		nvarchar(50)
	,@p_fa_reff_no_2		nvarchar(50)
	,@p_fa_reff_no_3		nvarchar(50)
	,@p_settle_date			datetime		= null
	,@p_job_status			nvarchar(250)	= null
	,@p_failed_remarks		nvarchar(4000)	= null
	--
	,@p_cre_date			datetime
	,@p_cre_by				nvarchar(15)
	,@p_cre_ip_address		nvarchar(15)
	,@p_mod_date			datetime
	,@p_mod_by				nvarchar(15)
	,@p_mod_ip_address		nvarchar(15)
)
as
begin
	declare @msg	nvarchar(max)
			,@year	nvarchar(2)
			,@month nvarchar(2)
			,@code	nvarchar(50) ;

	begin try
		insert into dbo.ams_interface_asset_vehicle_update
		(
			fa_code
			,fa_reff_no_1
			,fa_reff_no_2
			,fa_reff_no_3
			,settle_date
			,job_status
			,failed_remarks
			,cre_date
			,cre_by
			,cre_ip_address
			,mod_date
			,mod_by
			,mod_ip_address
		)
		values
		(	
			@p_fa_code			
			,@p_fa_reff_no_1	
			,@p_fa_reff_no_2	
			,@p_fa_reff_no_3	
			,@p_settle_date		
			,@p_job_status		
			,@p_failed_remarks	
			--
			,@p_cre_date		
			,@p_cre_by			
			,@p_cre_ip_address	
			,@p_mod_date		
			,@p_mod_by			
			,@p_mod_ip_address	
		) 

		set @p_id = @@identity ;

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

