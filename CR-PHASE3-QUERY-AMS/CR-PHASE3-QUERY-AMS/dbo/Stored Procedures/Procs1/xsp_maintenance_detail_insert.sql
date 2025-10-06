CREATE PROCEDURE [dbo].[xsp_maintenance_detail_insert]
(
	@p_id								bigint = 0 output
	,@p_maintenance_code				nvarchar(50)
	,@p_service_code					nvarchar(50)	= ''
	,@p_service_name					nvarchar(50)	= ''
	,@p_file_name						nvarchar(250)	= ''
	,@p_path							nvarchar(250)	= ''
	,@p_quantity						int				= 0
	,@p_pph_amount						decimal(18,2)	= 0
	,@p_ppn_amount						decimal(18,2)	= 0
	,@p_service_amount					decimal(18,2)	= 0
	,@p_service_type					nvarchar(50)	= ''
	,@p_asset_maintenance_schedule_id	bigint = 0
	,@p_part_number						INT				= 0
	--
	,@p_cre_date						datetime
	,@p_cre_by							nvarchar(15)
	,@p_cre_ip_address					nvarchar(50)
	,@p_mod_date						datetime
	,@p_mod_by							nvarchar(15)
	,@p_mod_ip_address					nvarchar(50)
)
as
begin
	declare @msg nvarchar(max) ;

	begin try
		insert into maintenance_detail
		(
			maintenance_code
			,service_code
			,service_name
			,file_name
			,path
			,quantity
			,pph_amount
			,ppn_amount
			,service_fee
			,service_type
			,asset_maintenance_schedule_id
			,part_number
			--
			,cre_date
			,cre_by
			,cre_ip_address
			,mod_date
			,mod_by
			,mod_ip_address
		)
		values
		(	@p_maintenance_code
			,@p_service_code
			,@p_service_name
			,@p_file_name
			,@p_path
			,@p_quantity
			,@p_pph_amount
			,@p_ppn_amount
			,@p_service_amount
			,@p_service_type
			,@p_asset_maintenance_schedule_id
			,@p_part_number
			--
			,@p_cre_date
			,@p_cre_by
			,@p_cre_ip_address
			,@p_mod_date
			,@p_mod_by
			,@p_mod_ip_address
		) ;

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
			set @msg = N'V' + N';' + @msg ;
		end ;
		else
		begin
			if (error_message() like '%V;%' or error_message() like '%E;%')
			begin
				set @msg = error_message() ;
			end
			else 
			begin
				set @msg = N'E;' + dbo.xfn_get_msg_err_generic() + N';' + error_message() ;
			end
		end ;

		raiserror(@msg, 16, -1) ;

		return ;
	end catch ;	
end ;
