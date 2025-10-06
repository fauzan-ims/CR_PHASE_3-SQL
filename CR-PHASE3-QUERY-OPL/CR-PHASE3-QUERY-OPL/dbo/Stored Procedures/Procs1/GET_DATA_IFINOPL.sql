 
-- Membuat stored procedure untuk menampilkan video yang belum pernah disewa
CREATE PROCEDURE [dbo].[GET_DATA_IFINOPL]
AS
BEGIN
    SELECT top 10 * FROM AGREEMENT_ASSET
END;
