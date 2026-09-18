SET XACT_ABORT ON;
BEGIN TRANSACTION;

UPDATE dbo.Server_Config
SET Value = CASE Name
    WHEN 'VIPMaxLevel' THEN '20'
    WHEN 'VIPExpForEachLv' THEN '0|200|400|800|2000|4000|8000|20000|40000|80000|200000|400000|800000|1200000|1800000|2600000|3600000|4800000|6200000|7800000'
    WHEN 'VIPExpNeededForEachLv' THEN '0|200|400|800|2000|4000|8000|20000|40000|80000|200000|400000|800000|1200000|1800000|2600000|3600000|4800000|6200000|7800000'
    WHEN 'VIPDailyPackID' THEN '112112|112113|112114|112115|112116|112117|112118|112119|112120|112204|112205|112206|112206|112206|112206|112206|112206|112206|112206|112206'
    WHEN 'VIPExtraBindMoneyUpper' THEN '0|0|0|9999|9999|12999|12999|12999|12999|19999|19999|19999|19999|19999|19999|19999|19999|19999|19999|19999'
    WHEN 'VIPLotteryCountMaxPerDay' THEN '3|4|5|6|7|8|9|10|11|12|13|15|15|15|15|15|15|15|15|15'
    WHEN 'VIPOfferDecreaseRate' THEN '0|0|0|0|0|0|0|0|0|0|0|0|0|0|0|0|0|0|0|0'
    WHEN 'VIPPayAimEnergy' THEN '120|120|120|120|120|50|50|50|50|30|30|30|30|30|30|30|30|30|30|30'
    WHEN 'VIPQuestFinishDirect' THEN '0|0|0|0|0|2|2|2|2|3|3|4|4|4|4|4|4|4|4|4'
    WHEN 'VIPQuestStar' THEN '2|2|2|2|2|3|3|3|3|3|3|3|3|3|3|3|3|3|3|3'
    WHEN 'VIPRateForGP' THEN '1.1|1.2|1.3|1.4|1.5|1.8|1.8|1.8|1.8|1.9|1.9|2.0|2.0|2.0|2.0|2.0|2.0|2.0|2.0|2.0'
    WHEN 'VIPStrengthenEx' THEN '25|25|25|35|35|50|50|50|50|50|50|50|50|50|50|50|50|50|50|50'
    WHEN 'VIPTakeCardDisCount' THEN '100|100|100|90|90|80|80|80|80|80|70|70|70|70|70|70|70|70|70|70'
    ELSE Value
END
WHERE Name IN
(
    'VIPMaxLevel',
    'VIPExpForEachLv',
    'VIPExpNeededForEachLv',
    'VIPDailyPackID',
    'VIPExtraBindMoneyUpper',
    'VIPLotteryCountMaxPerDay',
    'VIPOfferDecreaseRate',
    'VIPPayAimEnergy',
    'VIPQuestFinishDirect',
    'VIPQuestStar',
    'VIPRateForGP',
    'VIPStrengthenEx',
    'VIPTakeCardDisCount'
);

IF (SELECT COUNT(*) FROM dbo.Server_Config WHERE Name IN
(
    'VIPMaxLevel',
    'VIPExpForEachLv',
    'VIPExpNeededForEachLv',
    'VIPDailyPackID',
    'VIPExtraBindMoneyUpper',
    'VIPLotteryCountMaxPerDay',
    'VIPOfferDecreaseRate',
    'VIPPayAimEnergy',
    'VIPQuestFinishDirect',
    'VIPQuestStar',
    'VIPRateForGP',
    'VIPStrengthenEx',
    'VIPTakeCardDisCount'
)) <> 13
BEGIN
    THROW 51020, 'Required VIP20 Server_Config rows are missing.', 1;
END;

COMMIT TRANSACTION;
