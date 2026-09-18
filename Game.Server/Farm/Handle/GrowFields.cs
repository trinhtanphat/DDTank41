using Game.Base.Packets;

namespace Game.Server.Farm.Handle
{
    [FarmHandleAttbute(2)]
	public class GrowFields : IFarmCommandHadler
    {
        public bool CommandHandler(GamePlayer Player, GSPacketIn packet)
        {
			int bagType = packet.ReadByte();
			int templateId = packet.ReadInt();
			int fieldId = packet.ReadInt();
			if (Player.FarmBag.GetItemCount(templateId) <= 0)
			{
				return true;
			}
			if (Player.Farm.GrowField(fieldId, templateId))
			{
				if (Player.FarmBag.RemoveTemplate(templateId, 1))
				{
					Player.OnSeedFoodPetEvent();
				}
				else
				{
					Player.Farm.killCropField(fieldId);
				}
			}
			return true;
        }
    }
}
