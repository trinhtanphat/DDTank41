using Game.Base.Packets;
using Bussiness;
using SqlDataProvider.Data;
using Game.Server.Managers;
using System;
using Bussiness.Managers;

namespace Game.Server.Packets.Client
{
    [PacketHandler(92, "场景用户离开")]
    public class OpenVipHandler : IPacketHandler
    {
        private const int PayWithXu = 0;
        private const int PayWithGold = 1;
        private const int GoldPerXu = 1000;

        private int TotalPrice(int renewal)
        {
            ShopItemInfo itemVipInfo = ShopMgr.FindShopbyTemplateID((int)EquipType.VIPCARD);
            if (itemVipInfo == null || itemVipInfo.AUnit <= 0)
                return -1;

            if (renewal == itemVipInfo.AUnit)
                return itemVipInfo.AValue1;
            if (renewal == itemVipInfo.BUnit)
                return itemVipInfo.BValue1;
            if (renewal == itemVipInfo.CUnit)
                return itemVipInfo.CValue1;

            return (int)Math.Ceiling((float)itemVipInfo.AValue1 * renewal / itemVipInfo.AUnit);
        }

        private static void Refund(GamePlayer player, int paymentMode, int charged)
        {
            if (charged <= 0)
                return;

            if (paymentMode == PayWithGold)
                player.AddGold(charged);
            else
                player.AddMoney(charged);
        }

        public int HandlePacket(GameClient client, GSPacketIn packet)
        {
            string nickname = packet.ReadString();
            int renewalDays = packet.ReadInt();
            int paymentMode = PayWithXu;
            try
            {
                paymentMode = packet.ReadByte();
            }
            catch
            {
                // Older clients did not append a payment-mode byte.
                paymentMode = PayWithXu;
            }

            if (paymentMode != PayWithGold)
                paymentMode = PayWithXu;

            int xuPrice = TotalPrice(renewalDays);
            if (renewalDays <= 0 || xuPrice <= 0)
            {
                client.Out.SendMessage(eMessageType.Normal, "Thời hạn VIP không hợp lệ.");
                return 0;
            }

            int charged;
            try
            {
                charged = paymentMode == PayWithGold ? checked(xuPrice * GoldPerXu) : xuPrice;
            }
            catch (OverflowException)
            {
                client.Out.SendMessage(eMessageType.Normal, "Chi phí VIP không hợp lệ.");
                return 0;
            }

            bool paid = paymentMode == PayWithGold
                ? client.Player.RemoveGold(charged) == charged
                : client.Player.MoneyDirect(charged, false, false);
            if (!paid)
            {
                client.Out.SendMessage(
                    eMessageType.Normal,
                    paymentMode == PayWithGold ? "Không đủ Vàng để gia hạn VIP." : "Không đủ Xu để gia hạn VIP.");
                return 0;
            }

            string msg = "Kích hoạt VIP thành công!";
            GamePlayer player = WorldMgr.GetClientByPlayerNickName(nickname);
            DailyRecordInfo dailyRecord = new DailyRecordInfo
            {
                UserID = client.Player.PlayerCharacter.ID,
                Type = 6,
                Value = "VIP"
            };

            DateTime expireDay = DateTime.Now;
            int typeVIP = (int)client.Player.SetTypeVIP(renewalDays);
            using (PlayerBussiness playerBussiness = new PlayerBussiness())
            {
                int renewalResult = playerBussiness.VIPRenewal(nickname, renewalDays, typeVIP, ref expireDay);
                if (renewalResult != 1)
                {
                    Refund(client.Player, paymentMode, charged);
                    client.Out.SendMessage(eMessageType.Normal, "Gia hạn VIP thất bại. Chi phí đã được hoàn lại.");
                    return 0;
                }

                if (player == null)
                {
                    msg = "Đã cập nhật VIP cho " + nickname + ". Người chơi đang offline; dữ liệu sẽ có hiệu lực khi đăng nhập.";
                }
                else if (client.Player.PlayerCharacter.NickName == nickname)
                {
                    if (client.Player.PlayerCharacter.typeVIP == 0)
                    {
                        client.Player.OpenVIP(renewalDays, expireDay);
                    }
                    else
                    {
                        client.Player.ContinuousVIP(renewalDays, expireDay);
                        msg = "Gia hạn VIP thành công!";
                    }

                    client.Player.AddExpVip(xuPrice);
                    if (client.Player.PlayerCharacter.typeVIP > 0)
                        client.Player.PlayerCharacter.VIPNextLevelDaysNeeded = client.Player.GetVIPNextLevelDaysNeeded(client.Player.PlayerCharacter.VIPLevel, client.Player.PlayerCharacter.VIPExp);
                    client.Out.SendOpenVIP(client.Player);
                }
                else
                {
                    string receiverMessage;
                    if (player.PlayerCharacter.typeVIP == 0)
                    {
                        player.OpenVIP(renewalDays, expireDay);
                        msg = "Kích hoạt VIP cho " + nickname + " thành công!";
                        receiverMessage = client.Player.PlayerCharacter.NickName + " đã kích hoạt VIP cho bạn!";
                    }
                    else
                    {
                        player.ContinuousVIP(renewalDays, expireDay);
                        msg = "Gia hạn VIP cho " + nickname + " thành công!";
                        receiverMessage = client.Player.PlayerCharacter.NickName + " đã gia hạn VIP cho bạn!";
                    }

                    player.AddExpVip(xuPrice);
                    if (player.PlayerCharacter.typeVIP > 0)
                        player.PlayerCharacter.VIPNextLevelDaysNeeded = player.GetVIPNextLevelDaysNeeded(player.PlayerCharacter.VIPLevel, player.PlayerCharacter.VIPExp);
                    player.Out.SendOpenVIP(player);
                    player.Out.SendMessage(eMessageType.Normal, receiverMessage);
                }

                client.Out.SendMessage(eMessageType.Normal, msg);
            }

            return 0;
        }
    }
}
