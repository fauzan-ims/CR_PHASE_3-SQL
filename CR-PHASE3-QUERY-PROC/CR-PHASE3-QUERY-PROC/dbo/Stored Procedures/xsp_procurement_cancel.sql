CREATE PROCEDURE [dbo].[xsp_procurement_cancel]
(
	@p_code						 nvarchar(50)
	,@p_procurement_request_code nvarchar(50)
	--
	,@p_mod_date				 datetime
	,@p_mod_by					 nvarchar(15)
	,@p_mod_ip_address			 nvarchar(15)
)
as
begin
	declare @msg				nvarchar(max)
			,@count_procurement int
			,@count_request		int 
			,@asset_no			nvarchar(50)
			,@category_type		nvarchar(50)
			,@procurement_code	nvarchar(50)
			,@unit_from			nvarchar(15)
			,@proc_type			nvarchar(50)
			,@proc_request_code	nvarchar(50)
			,@reff_no			nvarchar(50)
			,@description_log	nvarchar(4000)
			,@item_name			nvarchar(250)
			,@date				datetime = GETDATE()
			,@application_no	nvarchar(50)


	begin try

		select	@asset_no	= asset_no
				,@proc_type	= procurement_type
		from	dbo.procurement_request
		where	code = @p_procurement_request_code

		select @unit_from	= unit_from
				,@item_name	= item_name
		from dbo.procurement
		where code = @p_code


		if	(@asset_no is not null and @proc_type = 'PURCHASE' and @unit_from = 'BUY')
		begin
			begin --validasi 1
				select @category_type = pri.category_type 
				from dbo.procurement prc
				inner join dbo.procurement_request pr on (prc.procurement_request_code = pr.code)
				inner join dbo.procurement_request_item pri on (pri.procurement_request_code = pr.code)
				where prc.code = @p_code

				if(@category_type <> 'ASSET')
				begin
					set @msg = 'Can only be canceled on Unit data.' ;
					raiserror(@msg, 16, 1) ;
				end
			end

			begin --validasi 2
				if exists(select 1 from dbo.procurement prc 
				inner join dbo.procurement_request pr on (pr.code = prc.procurement_request_code) 
				where pr.asset_no = @asset_no 
				and prc.status = 'POST'
				and prc.unit_from = @unit_from)
				begin
					set @msg = 'Cannot cancel this data, because Aksesoris/Karosesi already post.' ;
					raiserror(@msg, 16, 1) ;
				end
			end

			begin --validasi 3
				if exists(select 1 from dbo.procurement prc 
				inner join dbo.procurement_request pr on (pr.code = prc.procurement_request_code) 
				where pr.asset_no = @asset_no 
				and prc.status = 'POST'
				and prc.unit_from = 'RENT')
				begin
					set @msg = 'Cannot cancel this data, because asset GTS already post.' ;
					raiserror(@msg, 16, 1) ;
				end
			end

			begin --validasi 4
				if exists(select 1 from dbo.procurement prc 
				inner join dbo.procurement_request pr on (pr.code = prc.procurement_request_code) 
				where pr.asset_no = @asset_no 
				and prc.status = 'HOLD'
				and prc.unit_from = 'RENT')
				begin
					set @msg = 'Please cancel asset GTS first.' ;
					raiserror(@msg, 16, 1) ;
				end
			end

			--begin -- validasi 3
			--	if exists(select 1 from ifinopl.dbo.realization rlz 
			--	inner join ifinopl.dbo.realization_detail rlzd on (rlz.code = rlzd.realization_code)
			--	where rlz.status <> 'POST'
			--	and rlzd.asset_no = @asset_no)
			--	begin
			--		set @msg = 'Cannot cancel this data, because this data already realization.' ;
			--		raiserror(@msg, 16, 1) ;
			--	END
			--end

            
			--update	dbo.proc_interface_purchase_request
			--set		result_date	= dbo.xfn_get_system_date()
			--		,request_status = 'CANCEL'
			--		--
			--		,mod_date		= @p_mod_date
			--		,mod_by			= @p_mod_by
			--		,mod_ip_address	= @p_mod_ip_address
			--where	asset_no		= @asset_no ;

			declare cursor_name cursor fast_forward read_only for 
			select	prc.code
					,pr.code
					,pr.reff_no
			from	dbo.procurement					   prc
					inner join dbo.procurement_request pr on (pr.code = prc.procurement_request_code)
			where	pr.asset_no = @asset_no ;

			open cursor_name
			
			fetch next from cursor_name
			into @procurement_code
				,@proc_request_code
				,@reff_no
			
			while @@fetch_status = 0
			begin
			    update	procurement
				set		status							= 'CANCEL'
						,procurement_request_item_id	= 0
						--
						,mod_date						= @p_mod_date
						,mod_by							= @p_mod_by
						,mod_ip_address					= @p_mod_ip_address
				where	code							= @procurement_code ;

				update	procurement_request
				set		status			= 'CANCEL'
						--
						,mod_date		= @p_mod_date
						,mod_by			= @p_mod_by
						,mod_ip_address = @p_mod_ip_address
				where	code			= @proc_request_code ;

				update	dbo.proc_interface_purchase_request
				set		result_date	= dbo.xfn_get_system_date()
						,request_status = 'CANCEL'
						--
						,mod_date		= @p_mod_date
						,mod_by			= @p_mod_by
						,mod_ip_address	= @p_mod_ip_address
				where	code			= @reff_no ;

			    fetch next from cursor_name 
				into @procurement_code
					,@proc_request_code
					,@reff_no
			end
			
			close cursor_name
			deallocate cursor_name
		end
		else if (@asset_no is not null and @proc_type = 'MOBILISASI')
		begin
			update	procurement
			set		status							= 'CANCEL'
					--
					,mod_date						= @p_mod_date
					,mod_by							= @p_mod_by
					,mod_ip_address					= @p_mod_ip_address
			where	code							= @p_code ;

			update dbo.PROCUREMENT_REQUEST
			set STATUS = 'CANCEL'
			--
					,mod_date						= @p_mod_date
					,mod_by							= @p_mod_by
					,mod_ip_address					= @p_mod_ip_address
			where	code							= @p_procurement_request_code ;

		end
		else if(@asset_no is not null and @proc_type = 'PURCHASE' and @unit_from = 'RENT')
		begin
			update	procurement
			set		status							= 'CANCEL'
					,procurement_request_item_id	= 0
					--
					,mod_date						= @p_mod_date
					,mod_by							= @p_mod_by
					,mod_ip_address					= @p_mod_ip_address
			where	code							= @p_code ;

			update	procurement_request
			set		status			= 'CANCEL'
					--
					,mod_date		= @p_mod_date
					,mod_by			= @p_mod_by
					,mod_ip_address = @p_mod_ip_address
			where	code			= @p_procurement_request_code ;

			select	@reff_no = reff_no
			from	dbo.procurement_request
			where	code = @p_procurement_request_code ;

			update	dbo.proc_interface_purchase_request
			set		result_date	= dbo.xfn_get_system_date()
					,request_status = 'CANCEL'
					--
					,mod_date		= @p_mod_date
					,mod_by			= @p_mod_by
					,mod_ip_address	= @p_mod_ip_address
			where	code			= @reff_no ;
		end
		else
		begin
			update	procurement
			set		status							= 'CANCEL'
					,procurement_request_item_id	= 0
					--
					,mod_date						= @p_mod_date
					,mod_by							= @p_mod_by
					,mod_ip_address					= @p_mod_ip_address
			where	code							= @p_code ;

			select	@count_procurement = count(code)
			from	dbo.procurement
			where	procurement_request_code = @p_procurement_request_code
					and status				 = 'CANCEL' ;

			select	@count_request				= count(id)
			from	dbo.procurement_request_item
			where	procurement_request_code	= @p_procurement_request_code ;

			if (@count_procurement = @count_request)
			begin
				update	procurement_request
				set		status			= 'CANCEL'
						--
						,mod_date		= @p_mod_date
						,mod_by			= @p_mod_by
						,mod_ip_address = @p_mod_ip_address
				where	code			= @p_procurement_request_code ;
			end ;
		end

		select @application_no = isnull(application_no,'') 
		from ifinopl.dbo.application_asset 
		where asset_no = @asset_no

		if(@application_no <> '')
		begin
			set @description_log = 'Procurement cancel, Asset no : ' + @asset_no + ' - ' + @item_name
		
			exec ifinopl.dbo.xsp_application_log_insert @p_id					= 0
														,@p_application_no		= @application_no
														,@p_log_date			= @date
														,@p_log_description		= @description_log
														,@p_cre_date			= @p_mod_date
														,@p_cre_by				= @p_mod_by
														,@p_cre_ip_address		= @p_mod_ip_address
														,@p_mod_date			= @p_mod_date
														,@p_mod_by				= @p_mod_by
														,@p_mod_ip_address		= @p_mod_ip_address
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
