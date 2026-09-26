-- GA4 E-commerce Funnel Analysis
-- Dataset: bigquery-public-data.ga4_obfuscated_sample_ecommerce (Google Merchandise Store)
-- Period: 2020-11-01 to 2021-01-31

-- 1. Dataset overview
SELECT
  COUNT(DISTINCT user_pseudo_id) AS users,
  COUNT(*) AS events,
  MIN(event_date) AS first_day,
  MAX(event_date) AS last_day
FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
WHERE _TABLE_SUFFIX BETWEEN '20201101' AND '20210131';


-- 2. Overall purchase funnel (unique users reaching each step)
SELECT
  COUNT(DISTINCT user_pseudo_id) AS visitors,
  COUNT(DISTINCT IF(event_name = 'view_item', user_pseudo_id, NULL)) AS viewed_product,
  COUNT(DISTINCT IF(event_name = 'add_to_cart', user_pseudo_id, NULL)) AS added_to_cart,
  COUNT(DISTINCT IF(event_name = 'begin_checkout', user_pseudo_id, NULL)) AS began_checkout,
  COUNT(DISTINCT IF(event_name = 'purchase', user_pseudo_id, NULL)) AS purchased
FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
WHERE _TABLE_SUFFIX BETWEEN '20201101' AND '20210131';


-- 3. Funnel by acquisition channel (traffic_source.medium)
SELECT
  traffic_source.medium AS channel,
  COUNT(DISTINCT user_pseudo_id) AS visitors,
  COUNT(DISTINCT IF(event_name = 'view_item', user_pseudo_id, NULL)) AS viewed_product,
  COUNT(DISTINCT IF(event_name = 'add_to_cart', user_pseudo_id, NULL)) AS added_to_cart,
  COUNT(DISTINCT IF(event_name = 'purchase', user_pseudo_id, NULL)) AS purchased,
  ROUND(100 * COUNT(DISTINCT IF(event_name = 'purchase', user_pseudo_id, NULL))
        / COUNT(DISTINCT user_pseudo_id), 2) AS conversion_rate_pct
FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
WHERE _TABLE_SUFFIX BETWEEN '20201101' AND '20210131'
GROUP BY channel
ORDER BY visitors DESC;


-- 4. Referral traffic by source (checks for self-referrals)
SELECT
  traffic_source.source AS source,
  COUNT(DISTINCT user_pseudo_id) AS visitors,
  COUNT(DISTINCT IF(event_name = 'purchase', user_pseudo_id, NULL)) AS purchased,
  ROUND(100 * COUNT(DISTINCT IF(event_name = 'purchase', user_pseudo_id, NULL))
        / COUNT(DISTINCT user_pseudo_id), 2) AS conversion_rate_pct
FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
WHERE _TABLE_SUFFIX BETWEEN '20201101' AND '20210131'
  AND traffic_source.medium = 'referral'
GROUP BY source
ORDER BY visitors DESC
LIMIT 10;


-- 5. Conversion by channel, with self-referrals separated and obfuscated rows removed
SELECT
  CASE
    WHEN traffic_source.medium = 'referral'
         AND traffic_source.source LIKE '%googlemerchandisestore%' THEN 'referral (self)'
    WHEN traffic_source.medium = 'referral' THEN 'referral (external)'
    WHEN traffic_source.medium = '(none)' THEN 'direct'
    WHEN traffic_source.medium = 'cpc' THEN 'paid search (cpc)'
    ELSE traffic_source.medium
  END AS channel,
  COUNT(DISTINCT user_pseudo_id) AS visitors,
  COUNT(DISTINCT IF(event_name = 'purchase', user_pseudo_id, NULL)) AS purchased
FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
WHERE _TABLE_SUFFIX BETWEEN '20201101' AND '20210131'
  AND traffic_source.medium NOT IN ('<Other>', '(data deleted)')
GROUP BY channel;


-- 6. Funnel by device category
SELECT
  device.category AS device,
  COUNT(DISTINCT user_pseudo_id) AS visitors,
  COUNT(DISTINCT IF(event_name = 'add_to_cart', user_pseudo_id, NULL)) AS added_to_cart,
  COUNT(DISTINCT IF(event_name = 'begin_checkout', user_pseudo_id, NULL)) AS began_checkout,
  COUNT(DISTINCT IF(event_name = 'purchase', user_pseudo_id, NULL)) AS purchased,
  ROUND(100 * COUNT(DISTINCT IF(event_name = 'purchase', user_pseudo_id, NULL))
        / COUNT(DISTINCT user_pseudo_id), 2) AS conversion_rate_pct
FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
WHERE _TABLE_SUFFIX BETWEEN '20201101' AND '20210131'
GROUP BY device
ORDER BY visitors DESC;
