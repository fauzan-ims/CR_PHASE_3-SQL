CREATE PROCEDURE [dbo].[xsp_purchase_order_detail_object_info_upload_file_update]
(
	@p_id					bigint
	,@p_file_name			nvarchar(250) 
	,@p_file_paths			nvarchar(250) 
	-- (+) Ari 2024-03-22	ket : add new file upload
	--,@p_file_name_stnk		nvarchar(250) = ''
	,@p_file_paths_stnk		nvarchar(250) = ''
	--,@p_file_name_stck		nvarchar(250) = ''
	,@p_file_paths_stck		nvarchar(250) = ''
	--,@p_file_name_keur		nvarchar(250) = ''
	,@p_file_paths_keur		nvarchar(250) = ''
	,@p_type				nvarchar(50) = ''
)
AS
BEGIN
	declare @msg				nvarchar(max) 
			,@file_name_stnk	nvarchar(250)
			,@file_name_stck	nvarchar(250)
			,@file_name_keur	nvarchar(250)


	begin try
		--update	dbo.purchase_order_detail_object_info
		--set		file_name = upper(@p_file_name)
		--		,file_path = upper(@p_file_paths)
		--where	id = @p_id ;


		-- (+) Ari 2024-03-25 ket : add new file upload
		if(@p_type = 'STNK' or @p_type = 'STNK DELETE')
		begin
			
			set @file_name_stnk = @p_file_name -- (+) Ari 2024-03-26 ket : diambil dari file name agar logic api untuk keseluruhan tidak terganggu (perbedaannya hanya pada date time span yg masuk (impact ke priview))

			if(@p_type = 'STNK DELETE')
			begin
				update	dbo.purchase_order_detail_object_info
				set		stnk_file_no = ''
						,stnk_file_path = ''
				where	id = @p_id ;
			end
            else
            begin
				update	dbo.purchase_order_detail_object_info
				set		stnk_file_no = upper(@file_name_stnk)
						,stnk_file_path = upper(@p_file_paths_stnk)
				where	id = @p_id ;
			end
		end
        else if(@p_type = 'STCK' or @p_type = 'STCK DELETE')
		begin
			
			set @file_name_stck = @p_file_name -- (+) Ari 2024-03-26 ket : diambil dari file name agar logic api untuk keseluruhan tidak terganggu (perbedaannya hanya pada date time span yg masuk (impact ke priview))

			if(@p_type = 'STCK DELETE')
			begin
				update	dbo.purchase_order_detail_object_info
				set		stck_file_no = ''
						,stck_file_path = ''
				where	id = @p_id ;
			end
            else
            begin
				update	dbo.purchase_order_detail_object_info
				set		stck_file_no = upper(@file_name_stck)
						,stck_file_path = upper(@p_file_paths_stck)
				where	id = @p_id ;
			end
		end
        else if(@p_type = 'KEUR' or @p_type = 'KEUR DELETE')
		begin
        
			set @file_name_keur = @p_file_name -- (+) Ari 2024-03-26 ket : diambil dari file name agar logic api untuk keseluruhan tidak terganggu (perbedaannya hanya pada date time span yg masuk (impact ke priview))

			if(@p_type = 'KEUR DELETE')
			begin
				update	dbo.purchase_order_detail_object_info
				set		keur_file_no = ''
						,keur_file_path = ''
				where	id = @p_id ;
			end
            else
            begin
				update	dbo.purchase_order_detail_object_info
				set		keur_file_no = upper(@file_name_keur)
						,keur_file_path = upper(@p_file_paths_keur)
				where	id = @p_id ;
			end
			
		end
        else 
		begin
			update	dbo.purchase_order_detail_object_info
			set		stnk_file_no	= isnull(upper(@file_name_stnk),'')
					,stnk_file_path = isnull(upper(@p_file_paths_stnk),'')
					,stck_file_no	= isnull(upper(@file_name_stck),'')
					,stck_file_path = isnull(upper(@p_file_paths_stck),'')
					,keur_file_no	= isnull(upper(@file_name_keur),'')
					,keur_file_path = isnull(upper(@p_file_paths_keur),'')
			where	id = @p_id ;
		end
        -- (+) Ari 2024-03-25 

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
