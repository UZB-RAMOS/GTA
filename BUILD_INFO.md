# Build ma’lumoti

- Mahsulot: `Toshkent Sarguzashti`
- Versiya: `0.8.1 — 140 km/soat limit va salon silueti hotfix`
- Platforma: `Windows x86_64`
- Engine: `Godot 4.7.2 stable`
- Renderer: `OpenGL 3.3 Compatibility`
- Asosiy o‘lcham: `1280 × 720`
- Mobil build: `yo‘q, foydalanuvchi talabiga ko‘ra`
- Build vaqti: `2026-10-26 16:44:38` (Asia/Tashkent)
- `.exe` hajmi: `114 051 272 bayt`
- SHA-256: `9014DC2696AC0374CCD6FFFA03F997A135C5D7ADF80F6512353858389B88A9E7`
- Eksport template: rasmiy `Godot 4.7.2 stable Windows x86_64 release`
- Manba self-test: `exit 0`
- Eksport qilingan build self-test: `exit 0`
- Kirish menyusi: `by JMJ gems` yozuvi real OpenGL screenshot’da tekshirildi
- Tungi shahar: 40 ta ko‘cha yoritgichi va 17 ta avtomobil farasi real OpenGL’da tekshirildi
- Avtomobil preview’i: `screenshots/preview_vehicle.png`
- Metall tayoq: o‘ng kaftdagi 3D model `screenshots/preview.png` orqali tekshirildi
- `0.8.0` real AMD OpenGL benchmark: markazda `50.9 FPS`, Sharqiy xiyobonda `52.6 FPS`; qayta olingan PHASE 8 oldi baseline `29.7 FPS`
- Yangi tizimlar: 3 yangi chunk, 5 yangi landmark, 9 yo‘nalishli navigation graph, 120 svetofor, MultiMesh bezaklar, bosqichli hudud qurilishi va render keshlari
- Original rasm assetlari: `assets/textures/asphalt_wet_original.png` va `assets/textures/toshkent_facade_night_original.png`
- Qotish tuzatishi: `MultiMesh`, LOD, keshlangan trafik sezgisi, davriy svetofor/HUD/minimap yangilanishi va yaqin yoritish
- Boshqariladigan JMJ va egallanadigan trafik avtomobillari: maksimal `140 km/soat`, tezlanish `16.5 m/s²`, tormoz `28.0 m/s²`, kuzov `BUZILMAS`
- Haydovchi silueti: asosiy va trafik avtomobillarida bosh kabina tomidan chiqmaydi; bu holat self-test bilan tekshiriladi
- Erkin yurish: gaz qo‘yib yuborilganda avtomobil `1.35 m/s²` qarshilik bilan asta-sekin sekinlashadi; `S` yoki `Space` tez tormozlaydi
- Piyoda zarbasi: musht, tayoq va elektroshoker kuchiga qarab NPC orqaga hamda yuqoriga uchadi; bozor ichida paydo bo‘lish nuqtalari tashqariga ko‘chirildi
- Trafik: 16 ta mashinaning istalganini `E` bilan egallash mumkin; vertikal parvozga qarshi yo‘l sathi barqarorlashtirilgan
- Yo‘l: favvora, daraxt, chiroq, bekat va skameykalar asfalt markazidan trotuar/mahalla ichiga ko‘chirilgan
- Salon: transport ichida to‘qnashuv o‘yinchi jonini kamaytirmaydi
- Player: qiyalik va notekis sath uchun `floor snap`, past shift ostida xavfsiz turish tekshiruvi
- Kamera: silliq yaw/pitch, transport collision va boshqarilayotgan avtomobil uchun istisno
- Transportdan tushish: yer, qiyalik va to‘liq kapsula bo‘shlig‘i tekshiriladi

FPS kafolat emas: qurilma, drayver, grafik preset va sahnadagi kamera holatiga qarab o‘zgaradi. LOW preset integratsiyalashgan grafikaga mo‘ljallangan.

Windows sandbox standart `Temp` katalogiga yozishni rad etganda Godot `project.binary` faylini buzilgan holda eksport qilishi mumkin. `0.8.1` build yozish huquqi bor alohida `TEMP/TMP` katalogi bilan eksport qilindi va standalone self-test orqali tasdiqlandi.

Godot loyiha self-test natijasi:

```text
SELF_TEST_OK: dunyo=278x208 chunk=12+streaming phase8_sharqiy=3_chunk+5_landmark landmark=18 interyer=3 navigatsiya=9_marshrut tun=doimiy ob_havo=5+nam_asfalt audio=shahar+qadam+motor+yomgir+UI chiroq=46 fara=17 transport=10_tur+140kmh+buzilmas+yumshoq_sekinlash+yerga_xavfsiz_chiqish+salon_silueti trafik=16+yangi_hudud+egallanadi+140kmh parvoz=yoq piyoda=44+sharqiy_hudud+7_rol+FSM+suhbat+zarba_uchishi svetofor=120 dokon=6 zarar=muvozanatli salon_joni=100foiz pul_drop=OK inventar=qurol_qolda urish=3_bosqich optimizatsiya=LOD+MultiMesh+kesh+bosqichli_qurilish kamera=silliq+avto_old+collision missiya=7+fail+retry xarita=mini+toliq+kengaygan sozlama=grafika+ekran+FPS intro=JMJ localization=3_til save_v4=eski_mos+yangi_hudud
```
