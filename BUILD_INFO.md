# Build ma’lumoti

- Mahsulot: `Toshkent Sarguzashti`
- Versiya: `0.5.0 PHASE 1 — silliq kamera va xavfsiz harakat`
- Platforma: `Windows x86_64`
- Engine: `Godot 4.7.2 stable`
- Renderer: `OpenGL 3.3 Compatibility`
- Asosiy o‘lcham: `1280 × 720`
- Mobil build: `yo‘q, foydalanuvchi talabiga ko‘ra`
- Build vaqti: `2026-10-25 13:41:57` (Asia/Tashkent)
- `.exe` hajmi: `109 245 648 bayt`
- SHA-256: `F2C34E7A27B0D045478D03547A8EB42667871DD1FA6840FDD31BE0EBCAF60AAE`
- Manba self-test: `exit 0`
- Eksport qilingan build self-test: `exit 0`
- Kirish menyusi: `by JMJ gems` yozuvi real OpenGL screenshot’da tekshirildi
- Tungi shahar: 40 ta ko‘cha yoritgichi va 17 ta avtomobil farasi real OpenGL’da tekshirildi
- Avtomobil preview’i: `screenshots/preview_vehicle.png`
- Metall tayoq: o‘ng kaftdagi 3D model `screenshots/preview.png` orqali tekshirildi
- Bir xil yashirin OpenGL benchmark sharoitida: eski `0.4.4 = 15.1 FPS`, yangi `0.5.0 = 15.6 FPS`; regressiya kuzatilmadi
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

Yashirin/fokusdan tashqari oynadagi FPS odatiy o‘yin oynasidagi maksimal natija emas. Ushbu raqamlar faqat PHASE 1 regressiyasini bir xil sharoitda tekshirish uchun berilgan.

Windows sandbox standart `Temp` katalogiga yozishni rad etganda Godot `project.binary` faylini buzilgan holda eksport qilishi mumkin. `0.5.0` build yozish huquqi bor alohida `TEMP/TMP` katalogi bilan qayta eksport qilindi va standalone self-test orqali tasdiqlandi.

Godot loyiha self-test natijasi:

```text
SELF_TEST_OK: dunyo=210x210 chunk=9 yol=toza tun=doimiy chiroq=40 fara=17 transport=270kmh+buzilmas+yumshoq_sekinlash+yerga_xavfsiz_chiqish trafik=16+egallanadi parvoz=yoq piyoda=44+zarba_uchishi+past_shift_himoyasi svetofor=100 dokon=3 zarar=muvozanatli salon_joni=100foiz pul_drop=OK inventar=qurol_qolda urish=3_bosqich avto_tiklash=OK optimizatsiya=LOD+kesh kamera=silliq+avto_old+collision mission=4 save_v2=OK
```
