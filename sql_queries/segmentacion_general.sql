DROP TABLE IF EXISTS ed_temp_ventas_frigidaire; 

CREATE TEMPORARY TABLE ed_temp_ventas_frigidaire 
SELECT documento,A.tipdoc, A.clidoc 
, CASE 
	when B.movtdd IS NULL then  
	SUBSTRING_INDEX(fn_segmenta_g(SUM(movtot_sales_sum), SUM(movcpe_sales_distinct), MAX(esmayorista)),';',1) 
	ELSE 'Fraude' 
END AS segmento 
, CASE 
	when B.movtdd is null then  
	SUBSTRING_INDEX(fn_segmenta_g(SUM(movtot_sales_sum), SUM(movcpe_sales_distinct), MAX(esmayorista)),';',-1) 
	ELSE 'Fraude SAC' 
	END AS subsegmento 
, MAX(esmayorista) AS esmayorista 
FROM ( 
	SELECT fn_documento(A.tipdoc, A.clidoc) AS documento 
	,A.tipdoc, A.clidoc 
	, CASE WHEN SUBSTRING(movcpe,1,2) <> '07' THEN SUM(A.movtot) END AS movtot_sales_sum 
	, CASE WHEN SUBSTRING(movcpe,1,2) <> '07' THEN SUM(A.movcan) END AS movcan_sales_sum 
	, CASE WHEN SUBSTRING(movcpe,1,2) <> '07' THEN COUNT(DISTINCT A.movcpe) END AS movcpe_sales_distinct 
	, CASE WHEN SUBSTRING(movcpe,1,2) <> '07' THEN MIN(A.movfec) END AS movfec_sales_min 
	, CASE WHEN SUBSTRING(movcpe,1,2) <> '07' THEN MAX(A.movfec) END AS movfec_sales_max 
	, CASE WHEN SUBSTRING(movcpe,1,2) <> '07' THEN MAX(esmayorista) END AS esmayorista 
	, CASE WHEN SUBSTRING(movcpe,1,2) = '07' THEN SUM(A.movtot) END AS movtot_dev_sum 
	, CASE WHEN SUBSTRING(movcpe,1,2) = '07' THEN SUM(A.movcan) END AS movcan_dev_sum 
	, CASE WHEN SUBSTRING(movcpe,1,2) = '07' THEN COUNT(DISTINCT A.movcpe) END AS movcpe_dev_distinct 
	, CASE WHEN SUBSTRING(movcpe,1,2) = '07' THEN MIN(A.movfec) END AS movfec_dev_min 
	, CASE WHEN SUBSTRING(movcpe,1,2) = '07' THEN MAX(A.movfec) END AS movfec_dev_max 
	#, CASE WHEN COUNT(movcpe) >= 3	 
	FROM  
		( 
		SELECT 
		A.tipdoc, A.clidoc,A.movfec, A.movcpe,SUM(A.movtot) AS movtot, SUM(A.movcan) AS movcan 
		, MAX(esmayorista) AS esmayorista #mayorista 
		FROM 
			( 
			SELECT A.tipdoc, A.clidoc,A.movfec,A.movcpe, A.artcod 
			, SUM(A.movtot) AS movtot, SUM(A.movcan) AS movcan 
			, CASE WHEN SUM(A.movcan) >=3 THEN 1 ELSE 0 END AS esmayorista 
			FROM temp_ventasrv3 A 
			WHERE DATE(A.movfec) >= DATE_ADD(CURDATE(), INTERVAL -1 MONTH) 
			GROUP BY A.tipdoc, A.clidoc,A.movfec, A.movcpe, A.artcod 
			) AS A 
		GROUP BY A.tipdoc, A.clidoc,A.movfec, A.movcpe 
		) AS A 
	GROUP BY fn_documento(A.tipdoc, A.clidoc), SUBSTRING(movcpe,1,2)  
	) AS A LEFT JOIN ventasfraudes B ON A.tipdoc = B.movtdd AND A.clidoc = B.movndd #A.documento = fn_documento(B.movtdd, B.movndd)
GROUP BY documento; 
SELECT A.segmento, A.subsegmento, COUNT(*) AS numero_clientes FROM ed_temp_ventas_frigidaire A 
GROUP BY A.segmento, A.subsegmento; 