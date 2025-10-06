CREATE PROCEDURE [dbo].[xsp_supplier_selection_detail_update_supplier]
(
	 @p_id						bigint
	,@p_supplier_code			nvarchar(50)
	,@p_supplier_name			nvarchar(250)
	,@p_supplier_address		nvarchar(4000)	 = ''
	,@p_supplier_npwp			nvarchar(20)	 = null
		--
	,@p_mod_date				datetime
	,@p_mod_by					nvarchar(15)
	,@p_mod_ip_address			nvarchar(15)
)
as
begin
	declare @msg			nvarchar(max) 
			,@pph			decimal(9, 6)
			,@ppn			decimal(9, 6)
			,@pph_amount	decimal(18,2)
			,@ppn_amount	decimal(18,2)
			,@total_amount	decimal(18,2)
			,@tax_code		nvarchar(50)
			,@tax_name		nvarchar(250)

	begin try
		
		--if not exists(select 1 from dbo.master_vendor where npwp = @p_supplier_npwp)  -- (+) Ari 2023-12-12 ket : check vendor di master
		--begin
		--	set @msg = 'Vendor doesn`t exist. Please check Vendor in Master Vendor'
		--	raiserror(@msg, 16, -1)
		--end
        
		--IF (isnull(@p_supplier_npwp, '') = '')
		--BEGIN
		--	set @msg = 'Vendor doesn`t exist. Please check Vendor in Master Vendor'
		--	raiserror(@msg, 16, -1)
  --      end

	-- if @p_supplier_npwp is null -- (+) Ari 2024-02-01 ket : validasi dihidupin kembali
	--begin
	--	set @msg = 'This Vendor doesnt have NPWP no'
	--	raiserror(@msg, 16, -1)
	--end

		update	supplier_selection_detail
		set		supplier_code		= @p_supplier_code
				,supplier_name		= @p_supplier_name
				,supplier_address	= @p_supplier_address
				,supplier_npwp		= @p_supplier_npwp
					--
				,mod_date			= @p_mod_date
				,mod_by				= @p_mod_by
				,mod_ip_address		= @p_mod_ip_address
		where	id	= @p_id

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
end
