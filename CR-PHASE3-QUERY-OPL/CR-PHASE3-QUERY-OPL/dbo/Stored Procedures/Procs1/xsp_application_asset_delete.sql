CREATE PROCEDURE dbo.xsp_application_asset_delete
(
	@p_asset_no		   nvarchar(50)
	--
	,@p_mod_date	   datetime
	,@p_mod_by		   nvarchar(15)
	,@p_mod_ip_address nvarchar(15)
)
as
begin
	declare @msg			 nvarchar(max)
			,@application_no nvarchar(50)
			,@asset_no		 nvarchar(50)
			,@fa_code		 nvarchar(50)
			,@asset_type_code nvarchar(50)

	begin try
		--delete realization detail karena FK --(+) Louis Senin, 29 Januari 2024 13.43.50 --
		delete dbo.realization_detail where asset_no = @p_asset_no

		select	@application_no = aa.application_no 
				--(+) Ari 2023-12-01 ket : add asset_no and fa_code for update status rental
				,@asset_no = aa.asset_no
				,@fa_code = aa.fa_code
				,@asset_type_code = aa.asset_type_code
		from	dbo.application_asset aa  
		where	aa.asset_no = @p_asset_no ; 
		 
		delete dbo.application_asset_detail
		where	asset_no = @p_asset_no ;

		delete dbo.asset_insurance_detail
		where	asset_no = @p_asset_no ;
	
		exec dbo.xsp_application_main_rental_amount_update @p_application_no	= @application_no
														   ,@p_mod_date			= @p_mod_date	  
														   ,@p_mod_by			= @p_mod_by		  
														   ,@p_mod_ip_address	= @p_mod_ip_address

		--(+) Ari 2023-12-01 ket : for update fixed asset return to not reserved
		declare currapplicationasset cursor fast_forward read_only for
		select	asset_no
				,fa_code
		from	dbo.application_asset
		where	application_no		= @application_no
				and	asset_no		= @p_asset_no
				and	unit_source		= 'STOCK'
				--and asset_condition = 'USED' ;

		open currapplicationasset ;

		fetch next from currapplicationasset
		into @asset_no 
			,@fa_code ;

		while @@fetch_status = 0
		begin


			exec ifinams.dbo.xsp_asset_update_rental_status @p_code				= @fa_code
															,@p_rental_reff_no	= @asset_no
															,@p_rental_status	= null
															,@p_reserved_by		= null
															,@p_is_cancel		= N'1'
															,@p_mod_date		= @p_mod_date
															,@p_mod_by			= @p_mod_by
															,@p_mod_ip_address	= @p_mod_ip_address
			
				
				
			fetch next from currapplicationasset
			into @asset_no 
				,@fa_code ;
		end ;

		close currapplicationasset ;
		deallocate currapplicationasset ;
		
		-- Louis Selasa, 08 Juli 2025 10.32.39 -- 
		-- insert application log
		begin
		
			declare @unit_desc nvarchar(4000)
					,@remark_log nvarchar(4000)
					,@id bigint

			if (@asset_type_code = 'VHCL') --jika asset type nya vehicle
			begin
				select	@unit_desc = mvu.description
				from	dbo.application_asset_vehicle aav
						left join dbo.master_vehicle_unit mvu on (mvu.code		  = aav.vehicle_unit_code)
				where	aav.asset_no = @p_asset_no ;
			end ;
			else if (@asset_type_code = 'ELEC') --jika type asset nya electric
			begin
				select	@unit_desc = meu.description 
				from	application_asset_electronic aae
						left join dbo.master_electronic_unit meu on (meu.code		 = aae.electronic_unit_code)
				where	aae.asset_no = @p_asset_no ;
			end ;
			else if (@asset_type_code = 'HE') --jika type asset nya heavy equipment
			begin
				select	@unit_desc = mhu.description
				from	dbo.application_asset_he aah
						left join master_he_unit mhu on (mhu.code		 = aah.he_unit_code)
				where	aah.asset_no = @p_asset_no ;
			end ;
			else if (@asset_type_code = 'MCHN') --jika type asset nya machine
			begin
				select	@unit_desc = mmu.description
				from	dbo.application_asset_machine aam
						left join master_machinery_unit mmu on (mmu.code		= aam.machinery_unit_code)
				where	aam.asset_no = @p_asset_no ;
			end ;

			set @remark_log = 'Delete Asset : ' + @p_asset_no + ' ' + @unit_desc;

			exec dbo.xsp_application_log_insert @p_id				= @id output 
												,@p_application_no	= @application_no
												,@p_log_date		= @p_mod_date
												,@p_log_description	= @remark_log
												,@p_cre_date		= @p_mod_date	  
												,@p_cre_by			= @p_mod_by		  
												,@p_cre_ip_address	= @p_mod_ip_address
												,@p_mod_date		= @p_mod_date	  
												,@p_mod_by			= @p_mod_by		  
												,@p_mod_ip_address	= @p_mod_ip_address
		end
		-- Louis Selasa, 08 Juli 2025 10.32.39 -- 
		
		delete application_asset
		where	asset_no = @p_asset_no ;

		
	end try
	begin catch
		declare @error int ;

		set @error = @@error ;

		if (@error = 547)
		begin
			set @msg = dbo.xfn_get_msg_err_code_already_used() ;
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



