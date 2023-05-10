SELECT osm_id, name, type, geom
FROM public.points_table
WHERE type = 'bus_stop'
LIMIT 100;

EXPLAIN ANALYZE SELECT osm_id, name, type, geom FROM public.points_table WHERE type = 'bus_stop' LIMIT 100;

                                                     QUERY PLAN                                                      
----------------------------------------------------------------------------------------------------------------------
 Limit  (cost=0.00..40.93 rows=100 width=70) (actual time=2.313..4.445 rows=100 loops=1)
   ->  Seq Scan on points_table  (cost=0.00..4102.41 rows=10024 width=70) (actual time=2.311..4.410 rows=100 loops=1)
         Filter: ((type)::text = 'bus_stop'::text)
         Rows Removed by Filter: 26318
 Planning Time: 0.082 ms
 Execution Time: 4.476 ms
(6 rows)



  osm_id   |               name                |   type   |                        geom                        
-----------+-----------------------------------+----------+----------------------------------------------------
 320949338 | Subway Station East               | bus_stop | 0101000020E6100000F36B90EE0C7D52C024ED461FF3604440
 419363225 | Graham Avenue & Richardson Street | bus_stop | 0101000020E61000008A0684317D7C52C0CD188B4BFA5B4440
 419363978 | Dwight Street & Van Dyke Street   | bus_stop | 0101000020E61000009812EE3AC08052C05C3F582140564440
 419367068 | Flatbush Avenue & Park Place      | bus_stop | 0101000020E61000006935C9343F7E52C0D60BF43FAF564440
 419367181 | East 34th Street & 3rd Avenue     | bus_stop | 0101000020E6100000802E75EB907E52C035EAC6606A5F4440
 435889389 | Columbia Street & Warren Street   | bus_stop | 0101000020E61000007750E4A40B8052C0BE840A0E2F584440
 502792663 | Main Street & 60th Avenue         | bus_stop | 0101000020E6100000D0A2D2E3D27452C03A18FBDC1A5F4440
 502793580 | Main Street & Kissena Boulevard   | bus_stop | 0101000020E6100000B5DFDA89127552C0445266DE05614440
 502793612 | Main Street & Sanford Avenue      | bus_stop | 0101000020E6100000181D35CB0A7552C0974FFB52E4604440
 502832907 | Main Street & 41st Avenue         | bus_stop | 0101000020E6100000330A383A1D7552C0058DF4FD2F614440
(10 rows)



SELECT
  p1.osm_id AS point1_id,
  p2.osm_id AS point2_id,
  ST_Distance(p1.geom::geography, p2.geom::geography) AS distance_meters
FROM public.points_table p1, public.points_table p2
WHERE p1.osm_id = '419363978'
  AND p2.osm_id = '419363225';


EXPLAIN ANALYZE SELECT p1.osm_id AS point1_id, p2.osm_id AS point2_id, ST_Distance(p1.geom::geography, p2.geom::geography) AS distance_meters FROM public.points_table p1, public.points_table p2 WHERE p1.osm_id = '419363978' AND p2.osm_id = '419363225';

 point1_id | point2_id | distance_meters 
-----------+-----------+-----------------
 419363978 | 419363225 |   7507.75086526
(1 row)




 Nested Loop  (cost=0.00..8229.84 rows=1 width=24) (actual time=3.312..34.313 rows=1 loops=1)
   ->  Seq Scan on points_table p1  (cost=0.00..4102.41 rows=1 width=40) (actual time=1.663..16.280 rows=1 loops=1)
         Filter: (osm_id = '419363978'::double precision)
         Rows Removed by Filter: 173632
   ->  Seq Scan on points_table p2  (cost=0.00..4102.41 rows=1 width=40) (actual time=1.616..17.998 rows=1 loops=1)
         Filter: (osm_id = '419363225'::double precision)
         Rows Removed by Filter: 173632
 Planning Time: 33.091 ms
 Execution Time: 34.343 ms
(9 rows)


                                                     QUERY PLAN                                                     
--------------------------------------------------------------------------------------------------------------------
 Nested Loop  (cost=0.00..8229.84 rows=1 width=24) (actual time=3.553..37.635 rows=1 loops=1)
   ->  Seq Scan on points_table p1  (cost=0.00..4102.41 rows=1 width=40) (actual time=1.801..17.545 rows=1 loops=1)
         Filter: (osm_id = '419363978'::double precision)
         Rows Removed by Filter: 173632
   ->  Seq Scan on points_table p2  (cost=0.00..4102.41 rows=1 width=40) (actual time=1.713..20.047 rows=1 loops=1)
         Filter: (osm_id = '419363225'::double precision)
         Rows Removed by Filter: 173632
 Planning Time: 0.129 ms
 Execution Time: 37.696 ms
(9 rows)



SELECT
  p1.osm_id AS reference_point_id,
  p2.osm_id AS nearby_point_id,
  p2.type,
  p2.geom,
  ST_Distance(p1.geom::geography, p2.geom::geography) AS distance_meters
FROM public.points_table p1, public.points_table p2
WHERE p1.osm_id = '419363225'
  AND ST_DWithin(p1.geom::geography, p2.geom::geography, 500) -- 500 meters
  AND p1.osm_id <> p2.osm_id
  LIMIT 10;

EXPLAIN ANALYZE SELECT p1.osm_id AS reference_point_id, p2.osm_id AS nearby_point_id, p2.type, p2.geom, ST_Distance(p1.geom::geography, p2.geom::geography) AS distance_meters FROM public.points_table p1, public.points_table p2 WHERE p1.osm_id = '419363225' AND ST_DWithin(p1.geom::geography, p2.geom::geography, 500) AND p1.osm_id <> p2.osm_id LIMIT 10;


 reference_point_id | nearby_point_id |      type       |                        geom                        | distance_meters 
--------------------+-----------------+-----------------+----------------------------------------------------+-----------------
          419363225 |        42463363 | traffic_signals | 0101000020E6100000D0EBF428817C52C04589F1F5105C4440 |     79.48926378
          419363225 |        42463370 | traffic_signals | 0101000020E610000089EE59D7687C52C00F09DFFB1B5C4440 |    155.08107289
          419363225 |        42463374 | traffic_signals | 0101000020E61000009242B4B16D7C52C045679945285C4440 |    175.11711456
          419363225 |        42464292 | traffic_signals | 0101000020E610000075690DEF837C52C0ED80EB8A195C4440 |    111.45478415
          419363225 |        42466376 | stop            | 0101000020E61000007D3F355EBA7C52C0E76ED74B535C4440 |    436.45753914
          419363225 |        42466392 | stop            | 0101000020E6100000DB8AFD65777C52C03ACC9717605C4440 |    346.27521248
          419363225 |        42466398 | stop            | 0101000020E6100000268E3C10597C52C061A92EE0655C4440 |    409.43268954
          419363225 |        42466401 | stop            | 0101000020E6100000E02C25CB497C52C030BDFDB9685C4440 |    458.60298664
          419363225 |        42467872 | traffic_signals | 0101000020E610000008AF5DDA707C52C005F9D9C8755B4440 |    453.55591459
          419363225 |        42467880 | traffic_signals | 0101000020E61000007E665AAC727C52C07D9752978C5B4440 |    375.71683617
(10 rows)

                                                              QUERY PLAN                                                                 
-------------------------------------------------------------------------------------------------------------------------------------------
 Limit  (cost=0.00..250343.98 rows=10 width=65) (actual time=5.395..8.016 rows=10 loops=1)
   ->  Nested Loop  (cost=0.00..4355985.19 rows=174 width=65) (actual time=5.394..8.012 rows=10 loops=1)
         Join Filter: ((p1.osm_id <> p2.osm_id) AND st_dwithin((p1.geom)::geography, (p2.geom)::geography, '500'::double precision, true))
         Rows Removed by Join Filter: 1010
         ->  Seq Scan on points_table p1  (cost=0.00..4102.41 rows=1 width=40) (actual time=1.703..1.704 rows=1 loops=1)
               Filter: (osm_id = '419363225'::double precision)
               Rows Removed by Filter: 16718
         ->  Seq Scan on points_table p2  (cost=0.00..3668.33 rows=173633 width=49) (actual time=0.014..0.192 rows=1020 loops=1)
 Planning Time: 0.352 ms
 Execution Time: 8.046 ms
(10 rows)


 Limit  (cost=0.00..250343.98 rows=10 width=65) (actual time=5.469..8.332 rows=10 loops=1)
   ->  Nested Loop  (cost=0.00..4355985.19 rows=174 width=65) (actual time=5.467..8.328 rows=10 loops=1)
         Join Filter: ((p1.osm_id <> p2.osm_id) AND st_dwithin((p1.geom)::geography, (p2.geom)::geography, '500'::double precision, true))
         Rows Removed by Join Filter: 1010
         ->  Seq Scan on points_table p1  (cost=0.00..4102.41 rows=1 width=40) (actual time=1.651..1.652 rows=1 loops=1)
               Filter: (osm_id = '419363225'::double precision)
               Rows Removed by Filter: 16718
         ->  Seq Scan on points_table p2  (cost=0.00..3668.33 rows=173633 width=49) (actual time=0.011..0.178 rows=1020 loops=1)
 Planning Time: 0.154 ms
 Execution Time: 8.369 ms
(10 rows)





5)

SELECT osm_id, name, type, geom
FROM public.points_table
WHERE type = 'traffic_signals'
ORDER BY osm_id DESC
LIMIT 10;

SELECT osm_id, name, type, geom FROM public.points_table WHERE type = 'traffic_signals' ORDER BY osm_id DESC LIMIT 10;


   osm_id   | name |      type       |                        geom                        
------------+------+-----------------+----------------------------------------------------
 2141026551 |      | traffic_signals | 0101000020E6100000932930AE827C52C0D839179007684440
 2141026548 |      | traffic_signals | 0101000020E61000000B04A678017C52C0E8DCED7A69694440
 2141026546 |      | traffic_signals | 0101000020E6100000A80826EDFC7C52C0DD4DA6C0B8664440
 2141026544 |      | traffic_signals | 0101000020E61000007795FFDA0B7D52C0C8282A768F664440
 2141026542 |      | traffic_signals | 0101000020E6100000C14C254D4D7C52C0DB8827BB99684440
 2141026540 |      | traffic_signals | 0101000020E610000058AEB7CD547C52C0639CBF0985684440
 2141026538 |      | traffic_signals | 0101000020E6100000C8DE41A2BF7C52C01C0F119260674440
 2141026536 |      | traffic_signals | 0101000020E61000008E5C925E2F7C52C04CB32F8FEB684440
 2141026534 |      | traffic_signals | 0101000020E6100000E585CF317B7C52C03FBB8D171C684440
 2141026532 |      | traffic_signals | 0101000020E6100000A975D146647C52C0962941DA5A684440
(10 rows)




SELECT
  p1.osm_id AS reference_point_id,
  p2.osm_id AS nearby_point_id,
  p2.type,
  p2.geom,
  ST_Distance(p1.geom::geography, p2.geom::geography) AS distance_meters
FROM public.points_table p1, public.points_table p2
WHERE p1.osm_id = '2141026551'
  AND p1.osm_id <> p2.osm_id
ORDER BY distance_meters ASC
LIMIT 5;


SELECT p1.osm_id AS reference_point_id, p2.osm_id AS nearby_point_id, p2.type, p2.geom, ST_Distance(p1.geom::geography, p2.geom::geography) AS distance_meters FROM public.points_table p1, public.points_table p2 WHERE p1.osm_id = '2141026551' AND p1.osm_id <> p2.osm_id ORDER BY distance_meters ASC LIMIT 5;



 reference_point_id | nearby_point_id |   type   |                        geom                        | distance_meters 
--------------------+-----------------+----------+----------------------------------------------------+-----------------
         2141026551 |      -270500617 | crossing | 0101000020E6100000A064BCF7817C52C05A400D8409684440 |      7.56811277
         2141026551 |      -270500616 | crossing | 0101000020E610000016C09481837C52C01516815605684440 |      8.65674333
         2141026551 |      -270500618 | crossing | 0101000020E61000008FA042BF807C52C0A9E9C42F06684440 |     10.99435792
         2141026551 |      -270500615 | crossing | 0101000020E61000008CA83FB1847C52C06B2FFDA60B684440 |     17.30386859
         2141026551 |      -270500614 | crossing | 0101000020E610000080C63B76867C52C0C111EEDF06684440 |     19.61240341
(5 rows)



6) OPTIMIZATION




sql

WITH reference_point AS (
  SELECT geom AS ref_geom
  FROM public.points_table
  WHERE osm_id = 'reference_osm_id'
),
bounding_box AS (
  SELECT ST_Expand(ST_Envelope(ref_geom::geometry), search_radius_meters) AS bbox
  FROM reference_point
)
SELECT
  p.osm_id,
  ST_Distance(rp.ref_geom::geography, p.geom::geography) AS distance_meters
FROM public.points_table p, reference_point rp, bounding_box bb
WHERE ST_Intersects(p.geom, bb.bbox)
ORDER BY distance_meters ASC;



SELECT osm_id, name, type, geom
FROM public.points_table
WHERE type = 'traffic_signals'
ORDER BY osm_id DESC
LIMIT 10;




CREATE INDEX IF NOT EXISTS points_table_type_idx ON public.points_table(type);




