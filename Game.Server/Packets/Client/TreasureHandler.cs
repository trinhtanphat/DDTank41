using Bussiness;
using Bussiness.Managers;
using Game.Base.Packets;
using Game.Server.Managers;
using Game.Server.Packets;
using SqlDataProvider.Data;

namespace Game.Server.Packets.Client
{
    [PacketHandler(135, "Treasure hunting")]
    public class TreasureHandler : IPacketHandler
    {
        public int HandlePacket(GameClient client, GSPacketIn packet)
        {
            int command = packet.ReadInt();
            int userId = client.Player.PlayerCharacter.ID;
            GSPacketIn response = new GSPacketIn(135, userId);

            switch ((TreasurePackageType)command)
            {
                case TreasurePackageType.IN_TREASURE:
                    client.Player.Treasure.UpdateLoginDay();
                    UserTreasureInfo state = client.Player.Treasure.CurrentTreasure;
                    var data = client.Player.Treasure.TreasureData;
                    var dug = client.Player.Treasure.TreasureDig;
                    response.WriteInt((int)TreasurePackageType.IN_TREASURE);
                    response.WriteInt(state.logoinDays);
                    response.WriteInt(state.treasure);
                    response.WriteInt(state.treasureAdd);
                    response.WriteInt(state.friendHelpTimes);
                    response.WriteBoolean(state.isEndTreasure);
                    response.WriteBoolean(state.isBeginTreasure);
                    response.WriteInt(data.Count);
                    foreach (TreasureDataInfo item in data)
                    {
                        response.WriteInt(item.TemplateID);
                        response.WriteInt(item.ValidDate);
                        response.WriteInt(item.Count);
                    }
                    response.WriteInt(dug.Count);
                    foreach (TreasureDataInfo item in dug)
                    {
                        response.WriteInt(item.TemplateID);
                        response.WriteInt(item.pos);
                        response.WriteInt(item.ValidDate);
                        response.WriteInt(item.Count);
                    }
                    client.Player.SendTCP(response);
                    client.Player.Treasure.SaveToDatabase();
                    return 0;

                case TreasurePackageType.ARRANGE_FRIEND_FARM:
                    int targetUserId = packet.ReadInt();
                    using (PlayerBussiness db = new PlayerBussiness())
                    {
                        db.RemoveIsArrange(targetUserId);
                    }
                    GamePlayer target = WorldMgr.GetPlayerById(targetUserId);
                    if (target != null)
                    {
                        target.Treasure.AddfriendHelpTimes();
                        target.Treasure.SaveToDatabase();
                    }
                    else
                    {
                        using (PlayerBussiness db = new PlayerBussiness())
                        {
                            db.UpdateFriendHelpTimes(targetUserId);
                        }
                    }
                    response.WriteInt((int)TreasurePackageType.ARRANGE_FRIEND_FARM);
                    response.WriteInt(0);
                    client.Player.SendTCP(response);
                    return 0;

                case TreasurePackageType.END_TREASURE:
                    client.Player.Treasure.MarkEnd();
                    response.WriteInt((int)TreasurePackageType.END_TREASURE);
                    response.WriteBoolean(true);
                    client.Player.SendTCP(response);
                    client.Player.Treasure.SaveToDatabase();
                    client.Player.SendHideMessage("Số lần đào hôm nay đã hết.");
                    return 0;

                case TreasurePackageType.DIG:
                    int position = packet.ReadInt();
                    int index = position - 1;
                    var treasureData = client.Player.Treasure.TreasureData;
                    if (index < 0 || index >= treasureData.Count)
                    {
                        return 0;
                    }

                    TreasureDataInfo candidate = treasureData[index];
                    if (candidate == null || candidate.pos > 0)
                    {
                        return 0;
                    }

                    ItemTemplateInfo template = ItemMgr.FindItemTemplate(candidate.TemplateID);
                    if (template == null)
                    {
                        client.Player.SendHideMessage("Phần thưởng kho báu không hợp lệ, vui lòng báo GM.");
                        return 0;
                    }

                    TreasureDataInfo reward;
                    if (!client.Player.Treasure.TryDig(position, out reward))
                    {
                        client.Player.SendHideMessage("Số lần đào hôm nay đã hết.");
                        return 0;
                    }

                    ItemInfo itemInfo = ItemInfo.CreateFromTemplate(template, reward.Count, 105);
                    itemInfo.IsBinds = true;
                    itemInfo.ValidDate = reward.ValidDate;
                    client.Player.AddTemplate(itemInfo, itemInfo.Template.BagType, reward.Count, eGameView.OtherTypeGet);

                    UserTreasureInfo afterDig = client.Player.Treasure.CurrentTreasure;
                    response.WriteInt((int)TreasurePackageType.DIG);
                    response.WriteInt(reward.TemplateID);
                    response.WriteInt(position);
                    response.WriteInt(reward.Count);
                    response.WriteInt(afterDig.treasure);
                    response.WriteInt(afterDig.treasureAdd);
                    client.Player.SendTCP(response);
                    client.Player.SendHideMessage("Bạn nhận được " + itemInfo.Template.Name + " x" + reward.Count);
                    client.Player.Treasure.SaveToDatabase();
                    return 0;

                case TreasurePackageType.START_GAME:
                    client.Player.Treasure.MarkBegin();
                    response.WriteInt((int)TreasurePackageType.START_GAME);
                    response.WriteBoolean(true);
                    client.Player.SendTCP(response);
                    client.Player.Treasure.SaveToDatabase();
                    return 0;

                default:
                    return 0;
            }
        }
    }
}
