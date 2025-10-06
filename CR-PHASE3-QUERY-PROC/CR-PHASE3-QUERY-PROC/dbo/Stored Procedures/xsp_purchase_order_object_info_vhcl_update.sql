CREATE PROCEDURE dbo.xsp_purchase_order_object_info_vhcl_update
(
	@p_id								bigint
	,@p_good_receipt_note_detail_id		bigint
	--
	,@p_mod_date						datetime
	,@p_mod_by							nvarchar(15)
	,@p_mod_ip_address					nvarchar(15)
)
as
begin
	declare @msg			nvarchar(max)
			,@plat_no		nvarchar(50)
			,@engine_no		nvarchar(50)
			,@chasis_no		nvarchar(50)
			,@code_grn		nvarchar(50)
			,@id_grn		int
			,@spec			nvarchar(max)
			,@spesification	nvarchar(4000)

	begin try
		create table #temp_table
		(
			plat_no				nvarchar(50)
			,engine_no			nvarchar(50)
			,chasis_no			nvarchar(50)
			,new_spesification	nvarchar(max)
		)

		update	dbo.purchase_order_detail_object_info
		set		good_receipt_note_detail_id = @p_good_receipt_note_detail_id
				,file_name					= ''
				,file_path					= ''
				--
				,mod_date					= @p_mod_date
				,mod_by						= @p_mod_by
				,mod_ip_address				= @p_mod_ip_address
		where	id							= @p_id ;


		select	@code_grn = good_receipt_note_code
		from	dbo.good_receipt_note_detail
		where	id = @p_good_receipt_note_detail_id ;
		
		declare curr_grn_detail cursor fast_forward read_only for
		select	id
				,spesification
		from	dbo.good_receipt_note_detail
		where	good_receipt_note_code = @code_grn ;
		
		open curr_grn_detail
		
		fetch next from curr_grn_detail 
		into @id_grn
			,@spesification
		
		while @@fetch_status = 0
		begin
				insert into #temp_table
				(
					plat_no
					,engine_no
					,chasis_no
					,new_spesification
				)
				select	plat_no
						,engine_no
						,chassis_no
						,@spesification
				from	dbo.purchase_order_detail_object_info
				where	good_receipt_note_detail_id = @id_grn ;

		    fetch next from curr_grn_detail 
			into @id_grn
				,@spesification
		end
		
		close curr_grn_detail
		deallocate curr_grn_detail

		select	@spec = stuff((
						  select	distinct
									',' + new_spesification + ' ' + plat_no + ' ' + engine_no + ' ' + chasis_no
						  from		#temp_table
						  for xml path('')
					  ), 1, 1, ''
					 ) ;

		update	dbo.good_receipt_note
		set		new_spesification = LEFT(@spec,4000)
		where	code = @code_grn ;


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
