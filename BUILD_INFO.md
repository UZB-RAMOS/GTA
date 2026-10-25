# Build ma’lumoti

- Mahsulot: `Toshkent Sarguzashti`
- Versiya: `0.6.0 PHASE 2 — Toshkent hududlari, ob-havo, missiyalar va to‘liq xarita`
- Platforma: `Windows x86_64`
- Engine: `Godot 4.7.2 stable`
- Renderer: `OpenGL 3.3 Compatibility`
- Asosiy o‘lcham: `1280 × 720`
- Mobil build: `yo‘q, foydalanuvchi talabiga ko‘ra`
- Build vaqti: `2026-10-26 02:02:34` (Asia/Tashkent)
- `.exe` hajmi: `113 986 416 bayt`
- SHA-256: `CCB0FCD90D3EE1E42920BF28BB698E2B9AA984B33A6DDF8AECACD2AFF4CBE333`
- Eksport template: rasmiy `Godot 4.7.2 stable Windows x86_64 release`
- Manba self-test: `exit 0`
- Eksport qilingan build self-test: `exit 0`
- Kirish menyusi: `by JMJ gems` yozuvi real OpenGL screenshot’da tekshirildi
- Tungi shahar: 40 ta ko‘cha yoritgichi va 17 ta avtomobil farasi real OpenGL’da tekshirildi
- Avtomobil preview’i: `screenshots/preview_vehicle.png`
- Metall tayoq: o‘ng kaftdagi 3D model `screenshots/preview.png` orqali tekshirildi
- `0.6.0` standalone real AMD OpenGL benchmark: `25.9 FPS`, `582 draw call`, `830 obyekt`, `57 544 primitive`, `9.64 ms physics`, `25.54 ms process`
- Yangi tizimlar: 9 chunk streaming, 8 landmark, 5 ob-havo rejimi, wet-road, uchta missiya, to‘liq xarita, grafik/ekran sozlamalari va procedural audio
- Original rasm assetlari: `assets/textures/asphalt_wet_original.png` va `assets/textures/toshkent_facade_night_original.png`
- Qotish tuzatishi: `MultiMesh`, LOD, keshlangan trafik sezgisi, davriy svetofor/HUD/minimap yangilanishi va yaqin yoritish
- Boshqariladigan JMJ avtomobili: `270 km/soat`, tezlanish `16.5 m/s²`, tormoz `28.0 m/s²`, kuzov `BUZILMAS`
- Erkin yurish: gaz qo‘yib yuborilganda avtomobil `1.35 m/s²` qarshilik bilan asta-sekin sekinlashadi; `S` yoki `Space` tez tormozlaydi
- Piyoda zarbasi: musht, tayoq va elektroshoker kuchiga qarab NPC orqaga hamda yuqoriga uchadi; bozor ichida paydo bo‘lish nuqtalari tashqariga ko‘chirildi
- Trafik: 16 ta mashinaning istalganini `E` bilan egallash mumkin; vertikal parvozga qarshi yo‘l sathi barqarorlashtirilgan
- Yo‘l: favvora, daraxt, chiroq, bekat va skameykalar asfalt markazidan trotuar/mahalla ichiga ko‘chirilgan
- Salon: transport ichida to‘qnashuv o‘yinchi jonini kamaytirmaydi
- Player: qiyalik va notekis sath uchun `floor snap`, past shift ostida xavfsiz turish tekshiruvi
- Kamera: silliq yaw/pitch, transport collision va boshqarilayotgan avtomobil uchun istisno
- Transportdan tushish: yer, qiyalik va to‘liq kapsula bo‘shlig‘i tekshiriladi

FPS kafolat emas: qurilma, drayver, grafik preset va sahnadagi kamera holatiga qarab o‘zgaradi. LOW preset integratsiyalashgan grafikaga mo‘ljallangan.

Windows sandbox standart `Temp` katalogiga yozishni rad etganda Godot `project.binary` faylini buzilgan holda eksport qilishi mumkin. `0.6.0` build yozish huquqi bor alohida `TEMP/TMP` katalogi bilan eksport qilindi va standalone self-test orqali tasdiqlandi.

Godot loyiha self-test natijasi:

```text
SELF_TEST_OK: dunyo=210x210 chunk=9+streaming landmark=8 tun=doimiy ob_havo=5+nam_asfalt audio=shahar+qadam+motor+yomgir+UI chiroq=40 fara=17 transport=270kmh+buzilmas+yumshoq_sekinlash+yerga_xavfsiz_chiqish trafik=16+egallanadi parvoz=yoq piyoda=44+suhbat+zarba_uchishi svetofor=100 dokon=3 zarar=muvozanatli salon_joni=100foiz pul_drop=OK inventar=qurol_qolda urish=3_bosqich optimizatsiya=LOD+kesh kamera=silliq+avto_old+collision missiya=3 xarita=mini+toliq sozlama=grafika+ekran intro=JMJ save_v3=OK
```
