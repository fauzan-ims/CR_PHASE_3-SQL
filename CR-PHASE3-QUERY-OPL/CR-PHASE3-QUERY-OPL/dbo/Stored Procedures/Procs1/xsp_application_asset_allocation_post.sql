--created by, Rian at 02/06/2023 

CREATE PROCEDURE [dbo].[xsp_application_asset_allocation_post]
	@p_asset_no		   nvarchar(50)
	--
	,@p_mod_date	   DATETIME
	,@p_mod_by		   NVARCHAR(15)
	,@p_mod_ip_address NVARCHAR(15)
AS
BEGIN
	DECLARE @msg					NVARCHAR(MAX) 
			,@agreement_no			NVARCHAR(50)
			,@purchase_status		NVARCHAR(50)
			,@realization_code		NVARCHAR(50)
			,@realization_result	NVARCHAR(4000)
			,@application_no		NVARCHAR(50)
			,@purchase_gts_status	NVARCHAR(50)
			,@agreement_external_no NVARCHAR(50)
			,@is_request_gts		NVARCHAR(1)
			,@asset_type_code		NVARCHAR(50)
			

	BEGIN TRY
		SELECT	@is_request_gts			= is_request_gts
				,@purchase_status		= purchase_status
				,@purchase_gts_status	= purchase_gts_status
				,@asset_type_code		= asset_type_code
				,@application_no		= application_no
		FROM	dbo.application_asset
		WHERE	asset_no = @p_asset_no ;

			if (@is_request_gts = '1')
			begin
				--validasi jika datanya sudah realisasi atau agreement
				if exists
				(
					select	1
					from	dbo.application_asset aa
					where	aa.asset_no			   = @p_asset_no
							and aa.purchase_gts_status = 'NONE' 
							and isnull(aa.replacement_fa_code, '') = ''
				)
				begin
					set @msg = 'Please Purchase Asset or Select Asset for Asset : ' + @p_asset_no;
					raiserror (@msg, 16, -1);
				end; 

				if (@purchase_gts_status = 'NONE')
				begin
					--validasi jika datanya sudah realisasi atau agreement
					if exists
					(
						select	1
						from	dbo.application_asset aa
						where	aa.asset_no			   = @p_asset_no
								and aa.purchase_gts_status  = 'REALIZATION'
					)
					begin
						set @msg = 'Data Already Post';
						raiserror (@msg, 16, -1);
					end; 

					--update purchsase status nya menjadi realization
					update	dbo.application_asset
					set		purchase_gts_status = 'REALIZATION'
							,asset_status       = 'REALIZATION'-- Louis Selasa, 08 Juli 2025 10.42.08 -- 
							--
							,mod_date			= @p_mod_date
							,mod_by				= @p_mod_by
							,mod_ip_address		= @p_mod_ip_address
					where	asset_no			= @p_asset_no ;



				end
			end;
			else
			begin 
				if(@purchase_status in ('ON PROCESS','NONE')) -- jika purchase baru maka akan update realization
				begin
					--validasi jika datanya sudah realisasi atau agreement
					if exists
					(
						select	1
						from	dbo.application_asset aa
						where	aa.asset_no			   = @p_asset_no
								and aa.purchase_status = 'NONE' 
								and isnull(aa.fa_code, '') = ''
					)
					begin
						set @msg = 'Please Purchase Asset or Select Asset for Asset : ' + @p_asset_no;
						raiserror (@msg, 16, -1);
					end; 

					--validasi jika datanya sudah realisasi atau agreement
					if exists
					(
						select	1
						from	dbo.application_asset aa
						where	aa.asset_no			   = @p_asset_no
								and aa.purchase_status  = 'REALIZATION'
					)
					begin
						set @msg = 'Data Already Realization.';
						raiserror (@msg, 16, -1);
					end; 
					 
					--update purchsase status nya menjadi realization
					update	dbo.application_asset
					set		purchase_status = 'REALIZATION'
							,asset_status   = 'REALIZATION'-- Louis Selasa, 08 Juli 2025 10.42.08 -- 
							--
							,mod_date		= @p_mod_date
							,mod_by			= @p_mod_by
							,mod_ip_address = @p_mod_ip_address
					where	asset_no		= @p_asset_no ;


				end
			end;
			
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

			set @remark_log = 'Realization Asset : ' + @p_asset_no + ' ' + @unit_desc;

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
		
		--if(@purchase_status = 'ON PROCESS')
		--begin
			if not exists
			(
				select	1
				from	dbo.application_asset
				where	asset_no				= @p_asset_no
						and isnull(fa_code, isnull(replacement_fa_code, '')) = ''
			)
			BEGIN 
				if exists
				(
					select	1
					from	dbo.realization_detail rd
							inner join dbo.realization on (realization.code = rd.realization_code)
					where	rd.asset_no = @p_asset_no
							and status	= 'POST'
				)
				begin
					if not exists
					(
						select	1
						from	dbo.opl_interface_handover_asset
						where	asset_no = @p_asset_no
								and status <> 'CANCEL'
					)
					begin 
						select	@agreement_no				= agreement_no 
								,@agreement_external_no		= agreement_external_no
						from	dbo.realization_detail rd
								inner join dbo.realization on (realization.code = rd.realization_code)
						where	rd.asset_no = @p_asset_no
								and status	= 'POST'

						if exists(select 1 from dbo.application_asset where asset_no = @p_asset_no and isnull(is_request_gts, '0') = '1' and isnull(replacement_fa_code,'') <> '')
						begin
							exec dbo.xsp_application_asset_allocation_proceed @p_asset_no				= @p_asset_no
																			  ,@p_agreement_no			= @agreement_no
																			  ,@p_agreement_external_no = @agreement_external_no
																			  --				 
																			  ,@p_mod_date				= @p_mod_date
																			  ,@p_mod_by				= @p_mod_by
																			  ,@p_mod_ip_address		= @p_mod_ip_address ;
						end
						else if exists (select 1 from dbo.application_asset where asset_no = @p_asset_no and isnull(is_request_gts, '0') = '0' and isnull(fa_code,'') <> '')
						begin
							exec dbo.xsp_application_asset_allocation_proceed	@p_asset_no					= @p_asset_no
																				,@p_agreement_no			= @agreement_no
																				,@p_agreement_external_no	= @agreement_external_no
																				--				 
																				,@p_mod_date				= @p_mod_date
																				,@p_mod_by					= @p_mod_by
																				,@p_mod_ip_address			= @p_mod_ip_address ;
						end
					end ;
				end ;
			end
			
		--end
		--else if(@purchase_status = 'REALIZATION')
		--begin
		--	select @realization_code		= rlz.code
		--			,@agreement_no			= agreement_no
		--			,@application_no		= application_no
		--			,@agreement_external_no	= agreement_external_no
		--	from dbo.realization rlz
		--	inner join dbo.realization_detail rlzd on rlzd.realization_code = rlz.code
		--	where rlzd.asset_no = @p_asset_no

		--	exec dbo.xsp_application_asset_allocation_proceed @p_asset_no					= @p_asset_no
		--													  ,@p_agreement_no				= @agreement_no
		--													  ,@p_agreement_external_no		= @agreement_external_no
		--													  ,@p_mod_date					= @p_mod_date
		--													  ,@p_mod_by					= @p_mod_by
		--													  ,@p_mod_ip_address			= @p_mod_ip_address
			
		--end

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
