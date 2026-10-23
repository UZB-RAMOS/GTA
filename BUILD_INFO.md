# Build ma’lumoti

- Mahsulot: `Toshkent Sarguzashti`
- Versiya: `0.4.4 Zarba uchishi va yumshoq sekinlashish`
- Platforma: `Windows x86_64`
- Engine: `Godot 4.7.2 stable`
- Renderer: `OpenGL 3.3 Compatibility`
- Asosiy o‘lcham: `1280 × 720`
- Mobil build: `yo‘q, foydalanuvchi talabiga ko‘ra`
- Build vaqti: `2026-10-23 17:19:00` (Asia/Tashkent)
- `.exe` hajmi: `109 242 304 bayt` (`104.18 MiB`)
- SHA-256: `BDCE79DFA307D9A63F1A8A627118DEA93F083C85FE567CA7A3F4389A3750456D`
- Eksport qilingan build self-test: `BUILD_EXIT_CODE=0`
- ZIP ichidan ochilgan build self-test: `ZIP_BUILD_EXIT_CODE=0`, `.exe` hash mosligi `True`
- Kirish menyusi: `by JMJ gems` yozuvi real OpenGL screenshot’da tekshirildi
- Tungi shahar: 40 ta ko‘cha yoritgichi va 17 ta avtomobil farasi real OpenGL’da tekshirildi
- Avtomobil preview’i: `screenshots/preview_vehicle.png`
- Metall tayoq: o‘ng kaftdagi 3D model `screenshots/preview.png` orqali tekshirildi
- Ishlash testi: bir xil AMD Radeon Graphics qurilmasida `7.8 FPS → 29.7 FPS`; `4 677 → 537 draw call`
- Qotish tuzatishi: `MultiMesh`, LOD, keshlangan trafik sezgisi, davriy svetofor/HUD/minimap yangilanishi va yaqin yoritish
- Boshqariladigan JMJ avtomobili: `270 km/soat`, tezlanish `16.5 m/s²`, tormoz `28.0 m/s²`, kuzov `BUZILMAS`
- Erkin yurish: gaz qo‘yib yuborilganda avtomobil `1.35 m/s²` qarshilik bilan asta-sekin sekinlashadi; `S` yoki `Space` tez tormozlaydi
- Piyoda zarbasi: musht, tayoq va elektroshoker kuchiga qarab NPC orqaga hamda yuqoriga uchadi; bozor ichida paydo bo‘lish nuqtalari tashqariga ko‘chirildi
- Trafik: 16 ta mashinaning istalganini `E` bilan egallash mumkin; vertikal parvozga qarshi yo‘l sathi barqarorlashtirilgan
- Yo‘l: favvora, daraxt, chiroq, bekat va skameykalar asfalt markazidan trotuar/mahalla ichiga ko‘chirilgan
- Salon: transport ichida to‘qnashuv o‘yinchi jonini kamaytirmaydi

Godot loyiha self-test natijasi:

```text
SELF_TEST_OK: dunyo=210x210 chunk=9 yol=toza tun=doimiy chiroq=40 fara=17 transport=270kmh+buzilmas+yumshoq_sekinlash trafik=16+egallanadi parvoz=yoq piyoda=44+zarba_uchishi svetofor=100 dokon=3 zarar=muvozanatli salon_joni=100foiz pul_drop=OK inventar=qurol_qolda urish=3_bosqich avto_tiklash=OK optimizatsiya=LOD+kesh kamera=avto_old mission=4 save_v2=OK
```
