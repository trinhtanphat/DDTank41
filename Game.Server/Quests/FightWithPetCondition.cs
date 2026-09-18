using Game.Logic;
using SqlDataProvider.Data;

namespace Game.Server.Quests
{
    public class FightWithPetCondition : BaseCondition
    {
        private GamePlayer m_player;

        public FightWithPetCondition(BaseQuest quest, QuestConditionInfo info, int value)
            : base(quest, info, value)
        {
        }

        public override void AddTrigger(GamePlayer player)
        {
            m_player = player;
            player.GameOver += player_GameOver;
        }

        private void player_GameOver(AbstractGame game, bool isWin, int gainXp, bool isSpanArea, bool isCouple)
        {
            // Condition 45 means: finish a battle while an equipped pet joins the player.
            // GamePlayer.Pet is sourced from PetBag.GetPetIsEquip() during login/equip refresh.
            if (m_player != null && m_player.Pet != null && Value > 0)
            {
                Value--;
            }

            if (Value < 0)
            {
                Value = 0;
            }
        }

        public override void RemoveTrigger(GamePlayer player)
        {
            player.GameOver -= player_GameOver;
            if (ReferenceEquals(m_player, player))
            {
                m_player = null;
            }
        }

        public override bool IsCompleted(GamePlayer player)
        {
            return Value <= 0;
        }
    }
}
