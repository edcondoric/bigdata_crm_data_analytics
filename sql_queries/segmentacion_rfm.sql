DROP TEMPORARY TABLE IF EXISTS temp_ventas_segmentacion_rfm; 
CREATE TEMPORARY TABLE temp_ventas_segmentacion_rfm 
SELECT fn_documento(A.tipdoc, A.clidoc) AS documento
, TIMESTAMPDIFF(DAY, MAX(A.movfec), CURDATE()) AS R #Recency
, COUNT(DISTINCT A.movfec) AS F #Frecuency
, SUM(A.movtot) AS M #Monetary
FROM  
    ( 
    SELECT A.movfec,A.tipdoc, A.clidoc, SUM(A.movtot) AS movtot 
    FROM ventasrv3 A 
    WHERE A.movfec >= DATE_ADD(CURDATE(), INTERVAL -2 YEAR) 
    GROUP BY A.movfec, A.tipdoc, A.clidoc 
    ) AS A 
GROUP BY A.tipdoc, A.clidoc; 