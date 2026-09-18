using Bussiness;
using Bussiness.Managers;
using SqlDataProvider.Data;
using System;
using System.Collections.Generic;

namespace Game.Server.GameUtils
{
    public class PlayerTreasure
    {
        private readonly object m_lock = new object();
        private readonly GamePlayer m_player;
        private readonly bool m_saveToDb;
        private List<TreasureDataInfo> m_treasureData = new List<TreasureDataInfo>();
        private List<TreasureDataInfo> m_treasureDig = new List<TreasureDataInfo>();
        private UserTreasureInfo m_treasure;

        public GamePlayer Player => m_player;
        public List<TreasureDataInfo> TreasureData => m_treasureData;
        public List<TreasureDataInfo> TreasureDig => m_treasureDig;
        public UserTreasureInfo CurrentTreasure => m_treasure;

        public PlayerTreasure(GamePlayer player, bool saveTodb)
        {
            m_player = player;
            m_saveToDb = saveTodb;
            m_treasure = new UserTreasureInfo();
        }

        public virtual void LoadFromDatabase()
        {
            if (!m_saveToDb)
            {
                return;
            }

            using (PlayerBussiness db = new PlayerBussiness())
            {
                UserTreasureInfo loaded = db.GetSingleTreasure(Player.PlayerCharacter.ID);
                List<TreasureDataInfo> data = db.GetSingleTreasureData(Player.PlayerCharacter.ID);
                lock (m_lock)
                {
                    m_treasure = loaded;
                    m_treasureData = data ?? new List<TreasureDataInfo>();
                    m_treasureDig = m_treasureData.FindAll(x => x != null && x.pos > 0);
                    if (m_treasure == null)
                    {
                        CreateTreasureUnsafe();
                    }
                }
            }
        }

        public void CreateTreasure()
        {
            lock (m_lock)
            {
                CreateTreasureUnsafe();
            }
        }

        private void CreateTreasureUnsafe()
        {
            m_treasure = new UserTreasureInfo
            {
                ID = 0,
                UserID = Player.PlayerCharacter.ID,
                NickName = Player.PlayerCharacter.NickName,
                treasure = 1,
                treasureAdd = 0,
                logoinDays = 1,
                friendHelpTimes = 0,
                isBeginTreasure = false,
                isEndTreasure = false,
                LastLoginDay = DateTime.Now
            };
        }

        public void AddfriendHelpTimes()
        {
            lock (m_lock)
            {
                if (m_treasure.friendHelpTimes < 5)
                {
                    m_treasure.friendHelpTimes++;
                    if (m_treasure.friendHelpTimes == 5 && m_treasure.treasureAdd == 0)
                    {
                        m_treasure.treasureAdd = 1;
                    }
                }
            }
        }

        public void UpdateUserTreasure(UserTreasureInfo info)
        {
            if (info == null)
            {
                return;
            }
            lock (m_lock)
            {
                m_treasure = info;
            }
        }

        public void UpdateLoginDay()
        {
            lock (m_lock)
            {
                if (m_treasure == null)
                {
                    CreateTreasureUnsafe();
                }

                bool newDay = m_treasure.isValidDate();
                if (m_treasureData.Count == 0)
                {
                    m_treasureData = TreasureAwardMgr.CreateTreasureData(Player.PlayerCharacter.ID);
                }
                else if (newDay)
                {
                    List<TreasureDataInfo> fresh = TreasureAwardMgr.CreateTreasureData(Player.PlayerCharacter.ID);
                    for (int i = 0; i < fresh.Count && i < m_treasureData.Count; i++)
                    {
                        fresh[i].ID = m_treasureData[i].ID;
                    }
                    m_treasureData = fresh;
                    m_treasureDig = new List<TreasureDataInfo>();
                }

                if (newDay)
                {
                    if ((int)DateTime.Now.Subtract(m_treasure.LastLoginDay).TotalDays > 1)
                    {
                        m_treasure.logoinDays = 0;
                    }
                    m_treasure.logoinDays++;
                    m_treasure.treasure = Math.Min(3, m_treasure.logoinDays);
                    m_treasure.treasureAdd = 0;
                    m_treasure.friendHelpTimes = 0;
                    m_treasure.isBeginTreasure = false;
                    m_treasure.isEndTreasure = false;
                    m_treasure.LastLoginDay = DateTime.Now;
                }
            }
        }

        public bool TryDig(int oneBasedPosition, out TreasureDataInfo reward)
        {
            reward = null;
            lock (m_lock)
            {
                int index = oneBasedPosition - 1;
                if (index < 0 || index >= m_treasureData.Count)
                {
                    return false;
                }

                TreasureDataInfo item = m_treasureData[index];
                if (item == null || item.pos > 0 || m_treasure == null)
                {
                    return false;
                }

                if (m_treasure.treasure > 0)
                {
                    m_treasure.treasure--;
                }
                else if (m_treasure.treasureAdd > 0)
                {
                    m_treasure.treasureAdd--;
                }
                else
                {
                    return false;
                }

                item.pos = oneBasedPosition;
                if (!m_treasureDig.Contains(item))
                {
                    m_treasureDig.Add(item);
                }
                reward = item;
                return true;
            }
        }

        public void MarkEnd()
        {
            lock (m_lock)
            {
                m_treasure.isBeginTreasure = false;
                m_treasure.isEndTreasure = true;
            }
        }

        public void MarkBegin()
        {
            lock (m_lock)
            {
                m_treasure.isBeginTreasure = true;
            }
        }

        public virtual void SaveToDatabase()
        {
            if (!m_saveToDb)
            {
                return;
            }

            lock (m_lock)
            {
                using (PlayerBussiness db = new PlayerBussiness())
                {
                    if (m_treasure != null && m_treasure.IsDirty)
                    {
                        if (m_treasure.ID > 0)
                        {
                            db.UpdateUserTreasureInfo(m_treasure);
                        }
                        else
                        {
                            db.AddUserTreasureInfo(m_treasure);
                        }
                    }

                    foreach (TreasureDataInfo item in m_treasureData)
                    {
                        if (item == null || !item.IsDirty)
                        {
                            continue;
                        }
                        if (item.ID > 0)
                        {
                            db.UpdateTreasureData(item);
                        }
                        else
                        {
                            db.AddTreasureData(item);
                        }
                    }
                }
            }
        }
    }
}
