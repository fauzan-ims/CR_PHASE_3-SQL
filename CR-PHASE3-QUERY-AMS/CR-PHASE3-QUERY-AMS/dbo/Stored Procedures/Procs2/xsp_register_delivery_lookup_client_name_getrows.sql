CREATE PROCEDURE [dbo].[xsp_register_delivery_lookup_client_name_getrows]
(
	@p_keywords	   nvarchar(50),
    @p_pagenumber	INT,
    @p_rowspage	INT,
    @p_order_by	INT,
    @p_sort_by		NVARCHAR(5)
)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @rows_count INT = 0;

    SELECT @rows_count = COUNT(DISTINCT ast.client_no + '|' + ast.client_name)
    FROM dbo.REGISTER_MAIN rm
    INNER JOIN dbo.asset ast ON ast.code = rm.fa_code
    WHERE (
        ast.client_no LIKE '%' + @p_keywords + '%'
        OR ast.client_name LIKE '%' + @p_keywords + '%'
    );

    WITH cte AS (
        SELECT DISTINCT
            ast.client_no,
            ast.client_name
        FROM dbo.REGISTER_MAIN rm
        INNER JOIN dbo.asset ast ON ast.code = rm.fa_code
        WHERE (
            ast.client_no LIKE '%' + @p_keywords + '%'
            OR ast.client_name LIKE '%' + @p_keywords + '%'
        )
    )
    SELECT 
        client_no
        ,client_name
        ,@rows_count		'rowcount'
    FROM cte
    ORDER BY
        CASE 
            WHEN @p_sort_by = 'asc' AND @p_order_by = 1 THEN client_name 
        END ASC,
        CASE 
            WHEN @p_sort_by = 'desc' AND @p_order_by = 1 THEN client_name 
        END DESC
    OFFSET ((@p_pagenumber - 1) * @p_rowspage) ROWS
    FETCH NEXT @p_rowspage ROWS ONLY;
END;
