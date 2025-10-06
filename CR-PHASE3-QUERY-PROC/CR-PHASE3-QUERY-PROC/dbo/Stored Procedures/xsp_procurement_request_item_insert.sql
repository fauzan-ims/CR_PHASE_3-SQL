-- Stored Procedure

-- Stored Procedure

CREATE PROCEDURE dbo.xsp_procurement_request_item_insert
(
	@p_id							bigint = 0 output
	,@p_procurement_request_code	nvarchar(50)
	,@p_item_code					nvarchar(50)
	,@p_item_name					nvarchar(250)
	,@p_quantity_request			int		
	,@p_approved_quantity			int				= 0
	,@p_specification				nvarchar(4000)
	,@p_remark						nvarchar(4000)
	,@p_uom_code					nvarchar(50)
	,@p_uom_name					nvarchar(250)	
	,@p_type_asset_code				nvarchar(50)	= null
	,@p_item_category_code			nvarchar(50)	= null
	,@p_item_category_name			nvarchar(250)	= null
	,@p_item_merk_code				nvarchar(50)	= null
	,@p_item_merk_name				nvarchar(250)	= null
	,@p_item_model_code				nvarchar(50)	= null
	,@p_item_model_name				nvarchar(250)	= null
	,@p_item_type_code				nvarchar(50)	= null
	,@p_item_type_name				nvarchar(250)	= null
	,@p_fa_code						nvarchar(50)	= null
	,@p_fa_name						nvarchar(250)	= null
	,@p_category_type				nvarchar(15)	= null
	,@p_spaf_amount					decimal(18,2)	= null
	,@p_subvention_amount			decimal(18,2)	= null
	,@p_is_bbn						nvarchar(1)		= null
	,@p_bbn_name					nvarchar(250)	= null
	,@p_bbn_address					nvarchar(4000)	= null
	,@p_is_recom					nvarchar(1)		= null
	,@p_asset_amount				decimal(18,2)	= 0
	,@p_asset_discount_amount		decimal(18,2)	= 0
	,@p_karoseri_amount				decimal(18,2)	= 0
	,@p_karoseri_discount_amount	decimal(18,2)	= 0
	,@p_accesories_amount			decimal(18,2)	= 0
	,@p_accesories_discount_amount	decimal(18,2)	= 0
	,@p_mobilization_amount			decimal(18,2)	= 0
	,@p_otr_amount					decimal(18,2)	= 0
	,@p_gps_amount					decimal(18,2)	= 0
	,@p_budget_amount				decimal(18,2)	= 0
	,@p_bbn_location				nvarchar(4000)  = ''
	,@p_deliver_to_address			nvarchar(4000)  = ''
	--
	,@p_cre_date					datetime
	,@p_cre_by						nvarchar(15)
	,@p_cre_ip_address				nvarchar(15)
	,@p_mod_date					datetime
	,@p_mod_by						nvarchar(15)
	,@p_mod_ip_address				nvarchar(15)
	,@p_condition					nvarchar(15) = 'NEW'
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
		end

		select @procurement_type = procurement_type 
		from dbo.procurement_request
		where code = @p_procurement_request_code

		if @procurement_type = 'MOBILISASI'
		begin
			if @p_quantity_request <> 1
			begin
				set @msg = 'Quantity request must be 1.';
				raiserror(@msg, 16, -1) ;
			end
		end

		--01082025: VALIDASI HANYA UNTUK MANUAL
		if exists(select 1 from dbo.procurement_request where code = @p_procurement_request_code and isnull(asset_no,'') = '')
		begin
			if (@procurement_type IN ('MOBILISASI','EXPENSE')) -- 2025/06/23 CR PRIORITY (+) raffy penambahan validasi 
			begin
				if (isnull(@p_fa_code,'')='')
				begin
					set @msg = 'Please input fixed asset'
					raiserror(@msg, 16, -1) ;
				end
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


		if(@p_uom_name is null)
		begin
		    set @msg = 'please complete setting item'
			raiserror(@msg, 16, -1) ;
		end

		insert into procurement_request_item
		(
			procurement_request_code
			,item_code
			,item_name
			,quantity_request
			,approved_quantity
			,specification
			,remark
			,uom_code
			,uom_name
			,type_asset_code
			,item_category_code
			,item_category_name
			,item_merk_code
			,item_merk_name
			,item_model_code
			,item_model_name
			,item_type_code
			,item_type_name
			,fa_code
			,fa_name
			,category_type
			,spaf_amount
			,subvention_amount
			,is_recom
			,is_bbn
			,bbn_name
			,bbn_address
			,asset_amount
			,asset_discount_amount
			,karoseri_amount
			,karoseri_discount_amount
			,accesories_amount
			,accesories_discount_amount
			,mobilization_amount
			,otr_amount
			,gps_amount
			,budget_amount
			,bbn_location
			,deliver_to_address
			--
			,cre_date
			,cre_by
			,cre_ip_address
			,mod_date
			,mod_by
			,mod_ip_address
			,condition
		)
		values
		(	@p_procurement_request_code
			,@p_item_code
			,@p_item_name
			,@p_quantity_request
			,@p_approved_quantity
			,@p_specification
			,@p_remark
			,@p_uom_code
			,@p_uom_name
			,@p_type_asset_code
			,@p_item_category_code
			,@p_item_category_name
			,@p_item_merk_code
			,@p_item_merk_name
			,@p_item_model_code
			,@p_item_model_name
			,@p_item_type_code
			,@p_item_type_name
			,@p_fa_code
			,@p_fa_name
			,@p_category_type
			,@p_spaf_amount
			,@p_subvention_amount
			,@p_is_recom
			,@p_is_bbn
			,@p_bbn_name
			,@p_bbn_address
			,@p_asset_amount
			,@p_asset_discount_amount
			,@p_karoseri_amount
			,@p_karoseri_discount_amount
			,@p_accesories_amount
			,@p_accesories_discount_amount
			,@p_mobilization_amount
			,@p_otr_amount
			,@p_gps_amount
			,@p_budget_amount
			,@p_bbn_location
			,@p_deliver_to_address
			--
			,@p_cre_date
			,@p_cre_by
			,@p_cre_ip_address
			,@p_mod_date
			,@p_mod_by
			,@p_mod_ip_address
			,@p_condition
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
