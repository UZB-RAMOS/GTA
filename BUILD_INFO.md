# Build ma’lumoti

- Mahsulot: `Toshkent Sarguzashti`
- Versiya: `0.7.0 PHASE 3–7 — NPC/traffic, gameplay, interyerlar va Windows build`
- Platforma: `Windows x86_64`
- Engine: `Godot 4.7.2 stable`
- Renderer: `OpenGL 3.3 Compatibility`
- Asosiy o‘lcham: `1280 × 720`
- Mobil build: `yo‘q, foydalanuvchi talabiga ko‘ra`
- Build vaqti: `2026-10-26 15:23:25` (Asia/Tashkent)
- `.exe` hajmi: `114 034 032 bayt`
- SHA-256: `988AE31D8F3C00C89E99CE6BB7C279F2881EF3B673DB6A93BAFE22B817BFA861`
- Eksport template: rasmiy `Godot 4.7.2 stable Windows x86_64 release`
- Manba self-test: `exit 0`
- Eksport qilingan build self-test: `exit 0`
- Kirish menyusi: `by JMJ gems` yozuvi real OpenGL screenshot’da tekshirildi
- Tungi shahar: 40 ta ko‘cha yoritgichi va 17 ta avtomobil farasi real OpenGL’da tekshirildi
- Avtomobil preview’i: `screenshots/preview_vehicle.png`
- Metall tayoq: o‘ng kaftdagi 3D model `screenshots/preview.png` orqali tekshirildi
- `0.7.0` LOW preset real AMD OpenGL benchmark: `48.5 FPS`, `536 draw call`, `819 obyekt`, `57 882 primitive`, `5.44 ms physics`, `63.46 ms process`
- Yangi tizimlar: 6 yo‘nalishli navigation graph, 7 NPC roli va FSM, 10 transport profili, 3 interyer, 6 do‘kon, 7 missiya, FPS limiti, localization va save v4 fallback
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

Windows sandbox standart `Temp` katalogiga yozishni rad etganda Godot `project.binary` faylini buzilgan holda eksport qilishi mumkin. `0.7.0` build yozish huquqi bor alohida `TEMP/TMP` katalogi bilan eksport qilindi va standalone self-test orqali tasdiqlandi.

Godot loyiha self-test natijasi:

```text
SELF_TEST_OK: dunyo=210x210 chunk=9+streaming landmark=13 interyer=3 navigatsiya=6_marshrut tun=doimiy ob_havo=5+nam_asfalt audio=shahar+qadam+motor+yomgir+UI chiroq=40 fara=17 transport=10_tur+270kmh+buzilmas+yumshoq_sekinlash+yerga_xavfsiz_chiqish trafik=16+egallanadi parvoz=yoq piyoda=44+7_rol+FSM+suhbat+zarba_uchishi svetofor=100 dokon=6 zarar=muvozanatli salon_joni=100foiz pul_drop=OK inventar=qurol_qolda urish=3_bosqich optimizatsiya=LOD+kesh kamera=silliq+avto_old+collision missiya=7+fail+retry xarita=mini+toliq sozlama=grafika+ekran+FPS intro=JMJ localization=3_til save_v4=OK
```
