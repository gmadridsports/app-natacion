-- begin the transaction, this will allow you to rollback any changes made during the test
BEGIN;

--- given the number of tests that will be run
select plan(12);

-- given a notice on the bulletin board
TRUNCATE TABLE public.bulletin_board CASCADE;
INSERT INTO public.bulletin_board (id, is_published, source_id, origin_source, body_message, publication_date,
                                   original_raw_data_message)
VALUES ('c654a8d2-72dc-4664-9699-000b19ec73b7', TRUE, '6310BAD0EF7CCA751B6D66D9B056AB74',
        'whatsapp', '*¡Atención a todas las personas socias de GMadrid Sports!* 📣', '2023-05-03 16:51:22.235239 +00:00',
        '{
          "t": 1709887624,
          "id": {
            "id": "6310BAD0EF7CCA751B6D66D9B056AB74",
            "fromMe": false,
            "remote": "34638782987-1599067857@g.us",
            "_serialized": "false_34638782987-1599067857@g.us_6310BAD0EF7CCA751B6D66D9B056AB74_34640818667@c.us",
            "participant": {
              "user": "34640818667",
              "server": "c.us",
              "_serialized": "34640818667@c.us"
            }
          },
          "to": {
            "user": "34675334144",
            "server": "c.us",
            "_serialized": "34675334144@c.us"
          },
          "ack": 0,
          "body": "*¡Atención a todas las personas socias de GMadrid Sports!* 📣\n\nQueremos mejorar la comunicación interna del club con el fin de ofrecer una experiencia aún más cercana y en la que estes al día de lo que acontece. 🚀\n\nQueda activo el canal de WhatsApp de GMadrid Sports INFO, este sustituirá al que hay actualmente en Telegram (_al finalizar el mes desaparecerá_).\n\n¡No te quedes fuera! Únete al nuevo grupo aquí https://whatsapp.com/channel/0029VaObvmKJuyAAyqI4Ve1g\n\n¡Te esperamos para vivir cada momento al máximo juntes! 🏆📲",
          "from": {
            "user": "34638782987-1599067857",
            "server": "g.us",
            "_serialized": "34638782987-1599067857@g.us"
          },
          "rcat": null,
          "star": false,
          "type": "chat",
          "invis": true,
          "links": [
            {
              "link": "https://whatsapp.com/channel/0029VaObvmKJuyAAyqI4Ve1g",
              "isSuspicious": false
            }
          ],
          "rowId": 999999474,
          "title": "GMadrid Sports INFO",
          "author": {
            "user": "34640818667",
            "server": "c.us",
            "_serialized": "34640818667@c.us"
          },
          "viewed": false,
          "subtype": "url",
          "isAvatar": false,
          "mediaKey": "O6/+r+PaoO00aZWnGsTXbqOp9sxSZB2Klq0w0b01zEM=",
          "broadcast": false,
          "thumbnail": "",
          "bizBotType": null,
          "description": "Invitación al canal de WhatsApp",
          "hasReaction": false,
          "isForwarded": true,
          "kicNotified": false,
          "matchedText": "https://whatsapp.com/channel/0029VaObvmKJuyAAyqI4Ve1g",
          "parentMsgId": null,
          "pollOptions": [],
          "canonicalUrl": "https://whatsapp.com/channel/0029VaObvmKJuyAAyqI4Ve1g",
          "botPluginType": null,
          "groupMentions": [],
          "inviteGrpType": "DEFAULT",
          "invokedBotWid": null,
          "messageSecret": {
            "0": 128,
            "1": 93,
            "2": 19,
            "3": 241,
            "4": 238,
            "5": 137,
            "6": 51,
            "7": 93,
            "8": 61,
            "9": 130,
            "10": 108,
            "11": 5,
            "12": 130,
            "13": 241,
            "14": 100,
            "15": 222,
            "16": 232,
            "17": 14,
            "18": 157,
            "19": 209,
            "20": 122,
            "21": 72,
            "22": 252,
            "23": 154,
            "24": 16,
            "25": 149,
            "26": 36,
            "27": 90,
            "28": 209,
            "29": 19,
            "30": 238,
            "31": 216
          },
          "stickerSentTs": 0,
          "botMsgBodyType": null,
          "isCarouselCard": false,
          "isFromTemplate": false,
          "isMdHistoryMsg": true,
          "thumbnailWidth": 640,
          "forwardingScore": 2,
          "pollInvalidated": false,
          "thumbnailHeight": 640,
          "thumbnailSha256": "/t4sv7LW3e7+vbOyfaBr7nwrUREhIxEpuaza/NWhnQs=",
          "latestEditMsgKey": null,
          "mentionedJidList": [],
          "mediaKeyTimestamp": 1709886849,
          "botPluginSearchUrl": null,
          "botTargetSenderJid": null,
          "thumbnailEncSha256": "pVNrAgryrFeFRuQodA3Guj+1j4vQMXRya1zDPuyZaZ8=",
          "botResponseTargetId": null,
          "thumbnailDirectPath": "/v/t62.36144-24/11837566_300324376132438_4633405433290806310_n.enc?ccb=11-4&oh=01_AdR3zPPIMwqMba5y_NScVlfLbo4LLfOOcHM0v3Sz3O3lgw&oe=66123CBA&_nc_sid=5e03e0",
          "botPluginMaybeParent": false,
          "lastPlaybackProgress": 0,
          "isVcardOverMmsDocument": false,
          "lastUpdateFromServerTs": 0,
          "botPluginReferenceIndex": null,
          "botPluginSearchProvider": null,
          "isDynamicReplyButtonsMsg": false,
          "requiresDirectConnection": false,
          "bizContentPlaceholderType": null,
          "hostedBizEncStateMismatch": false,
          "productHeaderImageRejected": false,
          "latestEditSenderTimestampMs": null,
          "botReelPluginThumbnailCdnUrl": null,
          "senderOrRecipientAccountTypeHosted": false,
          "placeholderCreatedWhenAccountIsHosted": false
        }');

--
-- 0. Policies are
--
select policies_are(
               'public',
               'bulletin_board',
               ARRAY ['authenticated member can read bulletin_board']
       );

--
-- 1. authenticated non-member users cannot perform any operation on the bulletin board
--
-- given a generic non-member user that can authenticate
SELECT tests.create_supabase_user('authenticated_non_member_user', 'authenticated@gmadridnatacion.bertamini.net');
select tests.clear_authentication();
select tests.rls_enabled('public');

-- When I authenticate as a non-member user
select tests.clear_authentication();
select tests.authenticate_as('authenticated_non_member_user');

-- Then I cannot read the bulletin board
select is_empty(
               'SELECT body_message FROM public.bulletin_board',
               'authenticated_non_member_user cannot read the bulletin board'
       );
-- Then I cannot insert a new notice on the bulletin board
select throws_ok(
               $$ insert into public.bulletin_board (id, is_published, source_id, origin_source, body_message, publication_date,
                                   original_raw_data_message) values ('c654a8d2-72dc-4664-9699-000b19ec73b7', TRUE , '6310BAD0EF7CCA751B6D66D9B056AB74',
        'whatsapp', '*¡Atención a todas las personas socias de GMadrid Sports!* 📣','2023-05-03 16:51:22.235239 +00:00',
        '{"t":1709887624,"id":{"id":"6310BAD0EF7CCA751B6D66D9B056AB74","fromMe":false,"remote":"34638782987-1599067857@g.us","_serialized":"false_34638782987-1599067857@g.us_6310BAD0EF7CCA751B6D66D9B056AB74_34640818667@c.us","participant":{"user":"34640818667","server":"c.us","_serialized":"34640818667@c.us"}},"to":{"user":"34675334144","server":"c.us","_serialized":"34675334144@c.us"},"ack":0,"body":"*¡Atención a todas las personas socias de GMadrid Sports!* 📣\n\nQueremos mejorar la comunicación interna del club con el fin de ofrecer una experiencia aún más cercana y en la que estes al día de lo que acontece. 🚀\n\nQueda activo el canal de WhatsApp de GMadrid Sports INFO, este sustituirá al que hay actualmente en Telegram (_al finalizar el mes desaparecerá_).\n\n¡No te quedes fuera! Únete al nuevo grupo aquí https://whatsapp.com/channel/0029VaObvmKJuyAAyqI4Ve1g\n\n¡Te esperamos para vivir cada momento al máximo juntes! 🏆📲","from":{"user":"34638782987-1599067857","server":"g.us","_serialized":"34638782987-1599067857@g.us"},"rcat":null,"star":false,"type":"chat","invis":true,"links":[{"link":"https://whatsapp.com/channel/0029VaObvmKJuyAAyqI4Ve1g","isSuspicious":false}],"rowId":999999474,"title":"GMadrid Sports INFO","author":{"user":"34640818667","server":"c.us","_serialized":"34640818667@c.us"},"viewed":false,"subtype":"url","isAvatar":false,"mediaKey":"O6/+r+PaoO00aZWnGsTXbqOp9sxSZB2Klq0w0b01zEM=","broadcast":false,"thumbnail":"","bizBotType":null,"description":"Invitación al canal de WhatsApp","hasReaction":false,"isForwarded":true,"kicNotified":false,"matchedText":"https://whatsapp.com/channel/0029VaObvmKJuyAAyqI4Ve1g","parentMsgId":null,"pollOptions":[],"canonicalUrl":"https://whatsapp.com/channel/0029VaObvmKJuyAAyqI4Ve1g","botPluginType":null,"groupMentions":[],"inviteGrpType":"DEFAULT","invokedBotWid":null,"messageSecret":{"0":128,"1":93,"2":19,"3":241,"4":238,"5":137,"6":51,"7":93,"8":61,"9":130,"10":108,"11":5,"12":130,"13":241,"14":100,"15":222,"16":232,"17":14,"18":157,"19":209,"20":122,"21":72,"22":252,"23":154,"24":16,"25":149,"26":36,"27":90,"28":209,"29":19,"30":238,"31":216},"stickerSentTs":0,"botMsgBodyType":null,"isCarouselCard":false,"isFromTemplate":false,"isMdHistoryMsg":true,"thumbnailWidth":640,"forwardingScore":2,"pollInvalidated":false,"thumbnailHeight":640,"thumbnailSha256":"/t4sv7LW3e7+vbOyfaBr7nwrUREhIxEpuaza/NWhnQs=","latestEditMsgKey":null,"mentionedJidList":[],"mediaKeyTimestamp":1709886849,"botPluginSearchUrl":null,"botTargetSenderJid":null,"thumbnailEncSha256":"pVNrAgryrFeFRuQodA3Guj+1j4vQMXRya1zDPuyZaZ8=","botResponseTargetId":null,"thumbnailDirectPath":"/v/t62.36144-24/11837566_300324376132438_4633405433290806310_n.enc?ccb=11-4&oh=01_AdR3zPPIMwqMba5y_NScVlfLbo4LLfOOcHM0v3Sz3O3lgw&oe=66123CBA&_nc_sid=5e03e0","botPluginMaybeParent":false,"lastPlaybackProgress":0,"isVcardOverMmsDocument":false,"lastUpdateFromServerTs":0,"botPluginReferenceIndex":null,"botPluginSearchProvider":null,"isDynamicReplyButtonsMsg":false,"requiresDirectConnection":false,"bizContentPlaceholderType":null,"hostedBizEncStateMismatch":false,"productHeaderImageRejected":false,"latestEditSenderTimestampMs":null,"botReelPluginThumbnailCdnUrl":null,"senderOrRecipientAccountTypeHosted":false,"placeholderCreatedWhenAccountIsHosted":false}') $$,
               'new row violates row-level security policy for table "bulletin_board"'
       );
-- Then I cannot update a notice on the bulletin board
SELECT is_empty(
               $$ update public.bulletin_board set body_message = 'test update' returning 'this should not be returned' $$,
               'bulletin_board cannot be updated by authenticated_non_member_user'
       );
select tests.clear_authentication();

--
-- 3. authenticated MEMBER users can perform reading operations on the bulletin board, and nothing else
--
-- When I am not authenticated
select tests.clear_authentication();

-- Then I cannot read the bulletin board
select is_empty(
               'SELECT body_message FROM public.bulletin_board',
               'unauthenticated cannot read the bulletin board'
       );
-- Then I cannot insert a new notice on the bulletin board
select throws_ok(
               $$ insert into public.bulletin_board (id, is_published, source_id, origin_source, body_message, publication_date,
                                   original_raw_data_message) values ('c654a8d2-72dc-4664-9699-000b19ec73b7', TRUE , '6310BAD0EF7CCA751B6D66D9B056AB74',
        'whatsapp', '*¡Atención a todas las personas socias de GMadrid Sports!* 📣','2023-05-03 16:51:22.235239 +00:00',
        '{"t":1709887624,"id":{"id":"6310BAD0EF7CCA751B6D66D9B056AB74","fromMe":false,"remote":"34638782987-1599067857@g.us","_serialized":"false_34638782987-1599067857@g.us_6310BAD0EF7CCA751B6D66D9B056AB74_34640818667@c.us","participant":{"user":"34640818667","server":"c.us","_serialized":"34640818667@c.us"}},"to":{"user":"34675334144","server":"c.us","_serialized":"34675334144@c.us"},"ack":0,"body":"*¡Atención a todas las personas socias de GMadrid Sports!* 📣\n\nQueremos mejorar la comunicación interna del club con el fin de ofrecer una experiencia aún más cercana y en la que estes al día de lo que acontece. 🚀\n\nQueda activo el canal de WhatsApp de GMadrid Sports INFO, este sustituirá al que hay actualmente en Telegram (_al finalizar el mes desaparecerá_).\n\n¡No te quedes fuera! Únete al nuevo grupo aquí https://whatsapp.com/channel/0029VaObvmKJuyAAyqI4Ve1g\n\n¡Te esperamos para vivir cada momento al máximo juntes! 🏆📲","from":{"user":"34638782987-1599067857","server":"g.us","_serialized":"34638782987-1599067857@g.us"},"rcat":null,"star":false,"type":"chat","invis":true,"links":[{"link":"https://whatsapp.com/channel/0029VaObvmKJuyAAyqI4Ve1g","isSuspicious":false}],"rowId":999999474,"title":"GMadrid Sports INFO","author":{"user":"34640818667","server":"c.us","_serialized":"34640818667@c.us"},"viewed":false,"subtype":"url","isAvatar":false,"mediaKey":"O6/+r+PaoO00aZWnGsTXbqOp9sxSZB2Klq0w0b01zEM=","broadcast":false,"thumbnail":"","bizBotType":null,"description":"Invitación al canal de WhatsApp","hasReaction":false,"isForwarded":true,"kicNotified":false,"matchedText":"https://whatsapp.com/channel/0029VaObvmKJuyAAyqI4Ve1g","parentMsgId":null,"pollOptions":[],"canonicalUrl":"https://whatsapp.com/channel/0029VaObvmKJuyAAyqI4Ve1g","botPluginType":null,"groupMentions":[],"inviteGrpType":"DEFAULT","invokedBotWid":null,"messageSecret":{"0":128,"1":93,"2":19,"3":241,"4":238,"5":137,"6":51,"7":93,"8":61,"9":130,"10":108,"11":5,"12":130,"13":241,"14":100,"15":222,"16":232,"17":14,"18":157,"19":209,"20":122,"21":72,"22":252,"23":154,"24":16,"25":149,"26":36,"27":90,"28":209,"29":19,"30":238,"31":216},"stickerSentTs":0,"botMsgBodyType":null,"isCarouselCard":false,"isFromTemplate":false,"isMdHistoryMsg":true,"thumbnailWidth":640,"forwardingScore":2,"pollInvalidated":false,"thumbnailHeight":640,"thumbnailSha256":"/t4sv7LW3e7+vbOyfaBr7nwrUREhIxEpuaza/NWhnQs=","latestEditMsgKey":null,"mentionedJidList":[],"mediaKeyTimestamp":1709886849,"botPluginSearchUrl":null,"botTargetSenderJid":null,"thumbnailEncSha256":"pVNrAgryrFeFRuQodA3Guj+1j4vQMXRya1zDPuyZaZ8=","botResponseTargetId":null,"thumbnailDirectPath":"/v/t62.36144-24/11837566_300324376132438_4633405433290806310_n.enc?ccb=11-4&oh=01_AdR3zPPIMwqMba5y_NScVlfLbo4LLfOOcHM0v3Sz3O3lgw&oe=66123CBA&_nc_sid=5e03e0","botPluginMaybeParent":false,"lastPlaybackProgress":0,"isVcardOverMmsDocument":false,"lastUpdateFromServerTs":0,"botPluginReferenceIndex":null,"botPluginSearchProvider":null,"isDynamicReplyButtonsMsg":false,"requiresDirectConnection":false,"bizContentPlaceholderType":null,"hostedBizEncStateMismatch":false,"productHeaderImageRejected":false,"latestEditSenderTimestampMs":null,"botReelPluginThumbnailCdnUrl":null,"senderOrRecipientAccountTypeHosted":false,"placeholderCreatedWhenAccountIsHosted":false}') $$,
               'new row violates row-level security policy for table "bulletin_board"'
       );
-- Then I cannot update a notice on the bulletin board
SELECT is_empty(
               $$ update public.bulletin_board set body_message = 'test update' returning 'this should not be returned' $$,
               'bulletin_board cannot be updated by unauthenticated users'
       );
select tests.clear_authentication();


--
-- 3. authenticated non-member users cannot perform any operation on the bulletin board
--
-- given a generic non-member user that can authenticate
SELECT tests.create_supabase_user('authenticated_member_user', 'authmember@gmadridnatacion.bertamini.net');
select tests.change_supabase_user_membership('authenticated_member_user', 'member');
select tests.authenticate_as('authenticated_member_user');
select tests.rls_enabled('public');

-- When I authenticate as a non-member user
select tests.clear_authentication();
select tests.authenticate_as('authenticated_member_user');

-- Then I can read the bulletin board
select results_eq(
               'SELECT id::text FROM public.bulletin_board',
               $$VALUES ('c654a8d2-72dc-4664-9699-000b19ec73b7')$$,
               'bulletin board notices can be read by authenticated member users'
       );
-- Then I cannot insert a new notice on the bulletin board
select throws_ok(
               $$ insert into public.bulletin_board (id, is_published, source_id, origin_source, body_message, publication_date,
                                   original_raw_data_message) values ('c654a8d2-72dc-4664-9699-000b19ec73b7', TRUE , '6310BAD0EF7CCA751B6D66D9B056AB74',
        'whatsapp', '*¡Atención a todas las personas socias de GMadrid Sports!* 📣','2023-05-03 16:51:22.235239 +00:00',
        '{"t":1709887624,"id":{"id":"6310BAD0EF7CCA751B6D66D9B056AB74","fromMe":false,"remote":"34638782987-1599067857@g.us","_serialized":"false_34638782987-1599067857@g.us_6310BAD0EF7CCA751B6D66D9B056AB74_34640818667@c.us","participant":{"user":"34640818667","server":"c.us","_serialized":"34640818667@c.us"}},"to":{"user":"34675334144","server":"c.us","_serialized":"34675334144@c.us"},"ack":0,"body":"*¡Atención a todas las personas socias de GMadrid Sports!* 📣\n\nQueremos mejorar la comunicación interna del club con el fin de ofrecer una experiencia aún más cercana y en la que estes al día de lo que acontece. 🚀\n\nQueda activo el canal de WhatsApp de GMadrid Sports INFO, este sustituirá al que hay actualmente en Telegram (_al finalizar el mes desaparecerá_).\n\n¡No te quedes fuera! Únete al nuevo grupo aquí https://whatsapp.com/channel/0029VaObvmKJuyAAyqI4Ve1g\n\n¡Te esperamos para vivir cada momento al máximo juntes! 🏆📲","from":{"user":"34638782987-1599067857","server":"g.us","_serialized":"34638782987-1599067857@g.us"},"rcat":null,"star":false,"type":"chat","invis":true,"links":[{"link":"https://whatsapp.com/channel/0029VaObvmKJuyAAyqI4Ve1g","isSuspicious":false}],"rowId":999999474,"title":"GMadrid Sports INFO","author":{"user":"34640818667","server":"c.us","_serialized":"34640818667@c.us"},"viewed":false,"subtype":"url","isAvatar":false,"mediaKey":"O6/+r+PaoO00aZWnGsTXbqOp9sxSZB2Klq0w0b01zEM=","broadcast":false,"thumbnail":"","bizBotType":null,"description":"Invitación al canal de WhatsApp","hasReaction":false,"isForwarded":true,"kicNotified":false,"matchedText":"https://whatsapp.com/channel/0029VaObvmKJuyAAyqI4Ve1g","parentMsgId":null,"pollOptions":[],"canonicalUrl":"https://whatsapp.com/channel/0029VaObvmKJuyAAyqI4Ve1g","botPluginType":null,"groupMentions":[],"inviteGrpType":"DEFAULT","invokedBotWid":null,"messageSecret":{"0":128,"1":93,"2":19,"3":241,"4":238,"5":137,"6":51,"7":93,"8":61,"9":130,"10":108,"11":5,"12":130,"13":241,"14":100,"15":222,"16":232,"17":14,"18":157,"19":209,"20":122,"21":72,"22":252,"23":154,"24":16,"25":149,"26":36,"27":90,"28":209,"29":19,"30":238,"31":216},"stickerSentTs":0,"botMsgBodyType":null,"isCarouselCard":false,"isFromTemplate":false,"isMdHistoryMsg":true,"thumbnailWidth":640,"forwardingScore":2,"pollInvalidated":false,"thumbnailHeight":640,"thumbnailSha256":"/t4sv7LW3e7+vbOyfaBr7nwrUREhIxEpuaza/NWhnQs=","latestEditMsgKey":null,"mentionedJidList":[],"mediaKeyTimestamp":1709886849,"botPluginSearchUrl":null,"botTargetSenderJid":null,"thumbnailEncSha256":"pVNrAgryrFeFRuQodA3Guj+1j4vQMXRya1zDPuyZaZ8=","botResponseTargetId":null,"thumbnailDirectPath":"/v/t62.36144-24/11837566_300324376132438_4633405433290806310_n.enc?ccb=11-4&oh=01_AdR3zPPIMwqMba5y_NScVlfLbo4LLfOOcHM0v3Sz3O3lgw&oe=66123CBA&_nc_sid=5e03e0","botPluginMaybeParent":false,"lastPlaybackProgress":0,"isVcardOverMmsDocument":false,"lastUpdateFromServerTs":0,"botPluginReferenceIndex":null,"botPluginSearchProvider":null,"isDynamicReplyButtonsMsg":false,"requiresDirectConnection":false,"bizContentPlaceholderType":null,"hostedBizEncStateMismatch":false,"productHeaderImageRejected":false,"latestEditSenderTimestampMs":null,"botReelPluginThumbnailCdnUrl":null,"senderOrRecipientAccountTypeHosted":false,"placeholderCreatedWhenAccountIsHosted":false}') $$,
               'new row violates row-level security policy for table "bulletin_board"'
       );
-- Then I cannot update a notice on the bulletin board
SELECT is_empty(
               $$ update public.bulletin_board set body_message = 'test update' returning 'this should not be returned' $$,
               'bulletin_board cannot be updated by authenticated_member_user'
       );
select tests.clear_authentication();

-- end of the transaction
select *
from finish();

ROLLBACK;
