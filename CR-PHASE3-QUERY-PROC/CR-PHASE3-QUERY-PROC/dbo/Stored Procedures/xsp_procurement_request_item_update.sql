CREATE PROCEDURE dbo.xsp_procurement_request_item_update
(
	@p_id							bigint
	,@p_procurement_request_code	nvarchar(50)
	,@p_item_code					nvarchar(50)
	,@p_item_name					nvarchar(250)
	,@p_quantity_request			int
	,@p_approved_quantity			int = 0
	,@p_specification				nvarchar(4000)
	,@p_remark						nvarchar(4000)
	,@p_type_asset_code				nvarchar(50)	= null
	,@p_item_category_code			nvarchar(250)	= null
	,@p_item_category_name			nvarchar(50)	= null
	,@p_item_merk_code				nvarchar(50)	= null
	,@p_item_merk_name				nvarchar(250)	= null
	,@p_item_model_code				nvarchar(50)	= null
	,@p_item_model_name				nvarchar(250)	= null
	,@p_item_type_code				nvarchar(50)	= null
	,@p_item_type_name				nvarchar(250)	= null
	,@p_fa_code						nvarchar(50)	= null
	,@p_fa_name						nvarchar(250)	= null
	,@p_category_type				nvarchar(15)	= null
	,@p_is_bbn						nvarchar(1)		= null
	,@p_bbn_name					nvarchar(250)	= null
	,@p_bbn_address					nvarchar(4000)	= null
	,@p_subvention_amount			decimal(18,2)	= 0
	,@p_is_recom					nvarchar(1)		= NULL
    ,@p_condition					nvarchar(50)	= ''
	--
	,@p_mod_date					datetime
	,@p_mod_by						nvarchar(15)
	,@p_mod_ip_address				nvarchar(15)
)
as
begin
	declare @msg				nvarchar(max)
			,@procurement_type	nvarchar(50)

	begin try
		if @p_is_bbn = 'T'
			set @p_is_bbn = '1'
		else
			set @p_is_bbn = '0'

		if @p_is_recom = 'T'
			set @p_is_recom = '1'
		else
			set @p_is_recom = '0'

		if @p_quantity_request <= 0
		begin
			set @msg = 'Quantity request must be greater than 0.';
			raiserror(@msg, 16, -1) ;
		end ;

		select @procurement_type = pr.procurement_type 
		from dbo.procurement_request_item pri
		inner join dbo.procurement_request pr on (pr.code = pri.procurement_request_code)
		where id = @p_id

		if @procurement_type = 'MOBILISASI'
		begin
			if @p_quantity_request <> 1
			begin
				set @msg = 'Quantity request must be 1.';
				raiserror(@msg, 16, -1) ;
			end
		end

		if (@procurement_type IN ('MOBILISASI','EXPENSE'))  -- 2025/06/23 CR PRIORITY (+) raffy penambahan validasi 
		begin
			if (isnull(@p_fa_code,'')='')
			begin
				set @msg = 'Please input fixed asset'
				raiserror(@msg, 16, -1) ;
			end
		end

		if (@procurement_type = 'EXPENSE')
		begin
			if exists
			(
				select	1 
				from	ifinams.dbo.asset ast 
				where	ast.code = @p_fa_code
				and		 isnull(ast.is_gps,'0') = '1'
				and		 isnull(ast.gps_status,'') not in ('','UNSUBSCRIBE')
			)
			begin
				set @msg = N'Assets Already Have Active GPS';
				raiserror(@msg, 16, -1) ;
			end
		end

		if exists
		(
			select	b.asset_code
			from	ifinams.dbo.sale					   a
					inner join ifinams.dbo.sale_detail b on a.code = b.sale_code
			where	b.asset_code = @p_fa_code
					and a.status not in ('CANCEL', 'REJECT')
		)
		begin
			set @msg = N'Asset Is In Sales Request Process.' ;
			raiserror(@msg, 16, -1) ;
		end ;

		if(@p_is_bbn = '0')
		begin
			set @p_bbn_name = null
			set @p_bbn_address = null
			set @p_subvention_amount = 0
		end

		update	procurement_request_item
		set		procurement_request_code	= @p_procurement_request_code
				,item_code					= @p_item_code
				,item_name					= @p_item_name
				,quantity_request			= @p_quantity_request
				,approved_quantity			= @p_approved_quantity
				,specification				= @p_specification
				,remark						= @p_remark
				,type_asset_code			= @p_type_asset_code
				,item_category_code			= @p_item_category_code
				,item_category_name			= @p_item_category_name
				,item_merk_code				= @p_item_merk_code
				,item_merk_name				= @p_item_merk_name
				,item_model_code			= @p_item_model_code
				,item_model_name			= @p_item_model_name
				,item_type_code				= @p_item_type_code
				,item_type_name				= @p_item_type_name
				,fa_code					= @p_fa_code
				,fa_name					= @p_fa_name
				,category_type				= @p_category_type
				,is_bbn						= @p_is_bbn
				,bbn_name					= @p_bbn_name
				,bbn_address				= @p_bbn_address
				,subvention_amount			= @p_subvention_amount
				,is_recom					= @p_is_recom
				,condition					= @p_condition
				--
				,mod_date					= @p_mod_date
				,mod_by						= @p_mod_by
				,mod_ip_address				= @p_mod_ip_address
		where	id = @p_id ;
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
			if (
				   error_message() like '%V;%'
				   or	error_message() like '%E;%'
			   )
			begin
				set @msg = error_message() ;
			end ;
			else
			begin
				set @msg = N'E;' + dbo.xfn_get_msg_err_generic() + N';' + error_message() ;
			end ;
		end ;

		raiserror(@msg, 16, -1) ;

		return ;
	end catch ;
end ;
