using log4net;
using SqlDataProvider.Data;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Reflection;
using System.Threading;

namespace Bussiness.Managers
{
    public static class TreasureAwardMgr
    {
        private static readonly ILog log = LogManager.GetLogger(MethodBase.GetCurrentMethod().DeclaringType);
        private static readonly ReaderWriterLock m_lock = new ReaderWriterLock();
        private static Dictionary<int, TreasureAwardInfo> _treasureAward = new Dictionary<int, TreasureAwardInfo>();
        private static readonly ThreadSafeRandom rand = new ThreadSafeRandom();

        public static bool Init()
        {
            return ReLoad();
        }

        public static bool ReLoad()
        {
            try
            {
                Dictionary<int, TreasureAwardInfo> loaded = new Dictionary<int, TreasureAwardInfo>();
                using (PlayerBussiness db = new PlayerBussiness())
                {
                    foreach (TreasureAwardInfo info in db.GetAllTreasureAward())
                    {
                        if (info != null && !loaded.ContainsKey(info.ID))
                        {
                            loaded.Add(info.ID, info);
                        }
                    }
                }

                m_lock.AcquireWriterLock(15000);
                try
                {
                    _treasureAward = loaded;
                }
                finally
                {
                    m_lock.ReleaseWriterLock();
                }
                return true;
            }
            catch (Exception ex)
            {
                log.Error("TreasureAwardMgr", ex);
                return false;
            }
        }

        public static TreasureAwardInfo FindTreasureAwardInfo(int id)
        {
            m_lock.AcquireReaderLock(15000);
            try
            {
                TreasureAwardInfo info;
                return _treasureAward.TryGetValue(id, out info) ? info : null;
            }
            finally
            {
                m_lock.ReleaseReaderLock();
            }
        }

        public static List<TreasureAwardInfo> GetTreasureInfos()
        {
            m_lock.AcquireReaderLock(15000);
            try
            {
                return _treasureAward.Values.Where(x => x != null).ToList();
            }
            finally
            {
                m_lock.ReleaseReaderLock();
            }
        }

        public static List<TreasureDataInfo> CreateTreasureData(int userId)
        {
            List<TreasureAwardInfo> awards = GetTreasureInfos();
            List<TreasureDataInfo> result = new List<TreasureDataInfo>();
            if (awards.Count == 0)
            {
                log.Warn("TreasureAwardMgr has no treasure awards configured.");
                return result;
            }

            HashSet<int> usedTemplateIds = new HashSet<int>();
            int target = Math.Min(16, awards.Select(x => x.TemplateID).Distinct().Count());
            int attempts = 0;
            while (result.Count < target && attempts++ < 2048)
            {
                TreasureAwardInfo award = PickAward(awards);
                if (award == null || !usedTemplateIds.Add(award.TemplateID))
                {
                    continue;
                }
                result.Add(ToData(userId, award));
            }

            if (result.Count < target)
            {
                foreach (TreasureAwardInfo award in awards.OrderBy(x => x.ID))
                {
                    if (usedTemplateIds.Add(award.TemplateID))
                    {
                        result.Add(ToData(userId, award));
                        if (result.Count >= target)
                        {
                            break;
                        }
                    }
                }
            }
            return result;
        }

        private static TreasureAwardInfo PickAward(List<TreasureAwardInfo> awards)
        {
            int maxRandom = awards.Max(x => Math.Max(1, x.Random));
            int threshold = rand.Next(maxRandom);
            List<TreasureAwardInfo> eligible = awards.Where(x => Math.Max(1, x.Random) > threshold).ToList();
            if (eligible.Count == 0)
            {
                eligible = awards;
            }
            return eligible[rand.Next(eligible.Count)];
        }

        private static TreasureDataInfo ToData(int userId, TreasureAwardInfo award)
        {
            return new TreasureDataInfo
            {
                ID = 0,
                UserID = userId,
                TemplateID = award.TemplateID,
                Count = Math.Max(1, award.Count),
                ValidDate = award.Validate,
                pos = -1,
                BeginDate = DateTime.Now,
                IsExit = true
            };
        }
    }
}
