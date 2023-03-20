SELECT 
A.tipdoc AS Tipo_Documento
, A.movtie AS Canal
, YEAR(A.movfec) AS Fecha
, B.catnom AS Categoria, B.catno2 AS Subcategoria
, SUM(A.movtot) AS Ventas
, SUM(A.movcan) AS Unidades
FROM ventasrv3 A
INNER JOIN catalogo B ON A.artcod = B.artcod
WHERE SUBSTRING(movcpe,6,2)<'10' AND (SUBSTRING(movcpe,5,1)>='A' AND SUBSTRING(movcpe,5,1)<='D')
AND YEAR(A.movfec) IN (2021,2022,2023) AND A.artcod = '';