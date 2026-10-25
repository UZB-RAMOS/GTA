# TOSHKENT SARGUZASHTI — PHASE 2 HISOBOTI

## Qisqa natija

Mavjud Godot loyihasi va barcha ishlaydigan PHASE 0–1 mexanikalari saqlandi. `0.5.0` holati `checkpoint-phase2-start-0.5.0-20261025` Git tegi bilan belgilandi. Loyiha `0.6.0` versiyaga ko‘tarildi va PHASE 2 bilan birga keyingi bosqichlarning o‘ynaladigan asoslari ham integratsiya qilindi.

Manba belgilari:

- `kuzatildi` — real Godot/OpenGL ishga tushirish yoki screenshot orqali tekshirildi;
- `self-test` — avtomatik regressiya testi `exit 0` bilan tasdiqladi;
- `kod` — mavjud GDScript yoki JSON ichida bevosita mavjud;
- `aniqlanmadi` — hali tayyor emas va bajarilgan deb ko‘rsatilmaydi.

## 1. Nimalar yaratildi?

1. `world_streamer.gd`: o‘yinchi masofasiga qarab 9 ta shahar chunkini faollashtirish (`kod`, `self-test`).
2. Sakkizta original landmark: Markaz mehmonxonasi, Tashkent City egizak minoralari, Yunusobod aloqa minorasi, Sergeli garajlari va Chilonzor massivi (`kuzatildi`, `self-test`).
3. Besh tungi ob-havo rejimi: tiniq, yengil yomg‘ir, kuchli yomg‘ir, tuman va bulutli (`kuzatildi`, `self-test`).
4. Yomg‘irda roughness va metallic qiymati o‘zgaradigan nam asfalt (`kuzatildi`, `self-test`).
5. `M` bilan ochiladigan to‘liq xarita: player, missiya, do‘kon va hudud markerlari, sichqon g‘ildiragi bilan zoom (`kuzatildi`, `self-test`).
6. LOW/MEDIUM/HIGH grafik presetlari, resolution, fullscreen, VSync va ob-havo tanlash (`kod`, `self-test`).
7. Fade-in/fade-out va o‘tkazib yuboriladigan `TOSHKENT SARGUZASHTI — by JMJ gems` intro (`kod`, `self-test`).
8. Uchta ketma-ket JSON missiya: mahallaga yetkazish, tungi poyga va Toshkent bilan tanishuv (`kod`, `self-test`).
9. NPC bilan `E` orqali qisqa original o‘zbekcha suhbat (`kod`, `self-test`).
10. Procedural audio: shahar muhiti, yomg‘ir, qadam, tezlikka mos motor va UI signali (`kod`, `self-test`).
11. `schema_version: 3` save/load: missiya indeksi, tugallangan missiyalar, ochilgan hududlar, ob-havo va grafik sozlamalari (`self-test`).
12. Original asfalt va tungi fasad teksturalari (`imagegen`, `kuzatildi`).

## 2. Nimalar yaxshilandi?

- Generic binolar bo‘sh chunk tugunlaridan real chunk konteynerlariga o‘tkazildi.
- Tungi fasadlar teksturali bo‘ldi; yo‘llar asfalt teksturasi va to‘g‘ri takrorlanuvchi UV oldi.
- Missiya tizimi bitta topshiriqdan uchta ketma-ket topshiriqqa kengaydi.
- Minimap saqlanib, undan tashqari alohida katta xarita qo‘shildi.
- Save v1/v2 fayllarini yuklash mosligi saqlandi; yangi save v3 yoziladi.
- Grafik preset world streaming radiusi, 3D render masshtabi, yoritish masofasi va yom‘ir miqdorini birgalikda boshqaradi.

## 3. O‘zgargan muhim fayllar

- `scripts/main.gd`
- `scripts/player.gd`
- `scripts/pedestrian.gd`
- `scripts/world_streamer.gd`
- `scripts/weather_system.gd`
- `scripts/full_map.gd`
- `scripts/audio_system.gd`
- `data/mission_02.json`
- `data/mission_03.json`
- `assets/textures/asphalt_wet_original.png`
- `assets/textures/toshkent_facade_night_original.png`
- `project.godot`
- `export_presets.cfg`
- `OYINNI_BOSHLASH.cmd`
- `README.md`
- `BUILD_INFO.md`

## 4. Tuzatilgan xatolar

1. Chunk tugunlari mavjud bo‘lsa-da, real shahar geometriyasiga ulanmagan edi; generic binolar endi chunklar ichida.
2. Dastlabki asfalt teksturasi noto‘g‘ri UV o‘qida cho‘zildi; o‘lcham nisbatiga mos takrorlanish kiritildi.
3. Asosiy menyudagi `Sozlamalar` tugmasi faqat xabar ko‘rsatar edi; endi haqiqiy interaktiv panel ochadi.
4. Bitta missiya tugagach o‘yin maqsadsiz qolardi; endi keyingi missiya avtomatik boshlanadi.
5. Save tizimi ob-havo va missiya progressini yo‘qotar edi; save v3 bularni tiklaydi.

## 5. Test natijalari

| Test | Holat | Natija |
|---|---|---|
| Godot 4.7.2 parser va manba self-test | Passed | `exit 0` |
| Windows `0.6.0` export | Passed | EXE yaratildi |
| Standalone EXE self-test | Passed | `exit 0` |
| Real OpenGL oddiy sahna preview | Passed | `screenshots/preview.png` |
| To‘liq xarita preview | Passed | `screenshots/preview_map.png` |
| Kuchli yomg‘ir va nam asfalt preview | Passed | `screenshots/preview_weather.png` |
| AMD OpenGL standalone benchmark | Passed | o‘rtacha `25.9 FPS` |
| 60 FPS LOW maqsadi | Failed | ushbu noutbukdagi joriy sahna 60 FPS ga yetmadi |
| 3D audio eshitish sifati | Not Tested | avtomatik test node va stream mavjudligini tekshirdi, subyektiv eshitish testi bajarilmadi |
| Barcha uch missiyani qo‘lda boshidan oxirigacha o‘ynash | Not Tested | bosqich API’lari self-testdan o‘tdi, to‘liq qo‘lda sessiya bajarilmadi |

Benchmark (`kuzatildi`):

```text
FPS: 25.9
Draw call: 582
Obyekt: 830
Primitive: 57 544
Physics: 9.64 ms
Process: 25.54 ms
```

## 6. O‘yinni ishga tushirish

Tayyor build:

```text
builds/Toshkent_Sarguzashti_0.6.0.exe
```

Yoki repository ildizidagi:

```text
OYINNI_BOSHLASH.cmd
```

Manba:

```powershell
Godot_v4.7.2-stable_win64_console.exe --path .
```

## 7. Hali bajarilmagan ishlar

- Fotorealistik skeletonli personaj va avtomobil `GLB/GLTF` modellari: `aniqlanmadi`.
- Professional mocap animatsiya va `AnimationTree` blending: `aniqlanmadi`.
- 3–5 ta to‘liq yuriladigan bino interyeri, lift va metro: `aniqlanmadi`.
- Murakkab lane-change va umumiy navigation graph: `aniqlanmadi`; trafik hozir waypoint marshrutidan foydalanadi.
- Ovozli o‘zbekcha dialog yozuvlari: `aniqlanmadi`; hozir matnli suhbat va procedural audio bor.
- To‘liq geografik Toshkent, barcha tumanlar va real bino nusxalari: `aniqlanmadi`.
- Installer va code-signing: `aniqlanmadi`; portable EXE/ZIP mavjud.
- 60 FPS LOW maqsadi ushbu qurilmada bajarilmadi.

Bu bandlar ataylab “tayyor” deb belgilanmadi. Ular sifatli tashqi 3D assetlar, litsenziya dalili, qo‘shimcha level-design va qo‘lda QA talab qiladi.

## 8. Keyingi bosqich

Keyingi sifatli ish — procedural modellarga qo‘shimcha ravishda litsenziyasi aniq original `GLB/GLTF` character/vehicle pipeline kiritish, `AnimationTree` yaratish, birinchi uchta interyerni tayyorlash va profiling orqali 30–60 FPS oralig‘iga yaqinlashish.
