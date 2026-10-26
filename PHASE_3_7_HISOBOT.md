# PHASE 3–7 hisoboti

## Natija

`Toshkent Sarguzashti 0.7.0` mavjud Godot 4.7.2 loyihasi ustida kengaytirildi. Oldingi yurish, jang, transport, kamera, tungi shahar, ob-havo, inventar va Windows build tizimlari saqlandi. O‘yin noldan yozilmadi; ish boshlanishidan oldin `checkpoint-phase3-start-0.6.0-20261026` Git checkpoint yaratildi.

## Yaratilgan va yaxshilangan tizimlar

- 6 ta yopiq, o‘ng tomonlama yo‘l yo‘nalishi va 100 dan ortiq waypoint tuguniga ega navigation graph;
- svetofor, oldingi transport va masofaviy LOD holatlari bilan 16 ta Traffic AI;
- sedan, hatchback, sportcar, SUV, taxi, bus, minivan, delivery van, fictional patrol va retro kabi 10 transport profili;
- yurish, kutish, suhbat, qochish, zarba va halok holatlariga ega NPC FSM;
- oddiy piyoda, sotuvchi, taksi haydovchisi, bekat odami, mahalla aholisi, ishchi va missiya personajidan iborat 7 NPC roli;
- eshigi ishlaydigan Chorsu ichki bozori, Sergeli servis garaji va Tashkent City ofisi;
- oziq-ovqat, kiyim, avtosalon, servis, aksessuar va umumiy anjom do‘konlari;
- transport sotib olish, servis, umumiy inventar va transport holatini save/load qilish;
- 7 ta JSON missiya: yetkazish, poyga, sayohat, taksi, buyum yetkazish, garaj va hudud ochish;
- vaqt chegarasi, failed state va `R` orqali retry;
- Mustaqillik maydoni, Minor, tungi sayilgoh, vokzal va metro landmarklari;
- 30/45/60/120 FPS chegarasi va LOW/MEDIUM/HIGH rejimida NPC, trafik hamda yorug‘lik yukini real kamaytirish;
- o‘zbek, rus va ingliz tillarini qabul qiladigan localization arxitekturasi;
- `schema_version: 4`, oldingi schema 1–3 bilan moslik, buzilgan asosiy save uchun zaxira fallback hamda resolution/fullscreen/VSync holatini saqlash;
- eshik va missiya uchun original procedural audio signallari;
- xarita chetidagi ko‘rinmas to‘siqlarga mos ko‘rinadigan qurilish chegaralari.

## O‘zgargan asosiy fayllar

- `scripts/main.gd` — integratsiya, iqtisodiyot, missiyalar, UI, save/load, grafik presetlar va QA;
- `scripts/navigation_graph.gd` — yo‘l grafigi;
- `scripts/interactive_interior.gd` — interyer va eshik;
- `scripts/localization.gd` — tarjima arxitekturasi;
- `scripts/pedestrian.gd` — NPC FSM va rollar;
- `scripts/traffic_car.gd` — Traffic AI holatlari, LOD va 10 profil;
- `scripts/vehicle.gd` — egalikdagi transport profillari va saqlash holati;
- `scripts/store.gd` — 6 do‘kon toifasi;
- `data/mission_04.json`–`data/mission_07.json` — yangi missiyalar;
- `README.md`, `BUILD_INFO.md`, `project.godot`, `export_presets.cfg` va `OYINNI_BOSHLASH.cmd`.

## QA natijalari

| Tekshiruv | Holat | Dalil |
|---|---|---|
| Godot manba self-test | Passed | `exit 0`, kengaytirilgan `SELF_TEST_OK` |
| Windows export | Passed | rasmiy Godot 4.7.2 release template |
| Windows standalone self-test | Passed | `exit 0` |
| Real AMD OpenGL preview | Passed | `screenshots/preview.png` yangilandi |
| LOW preset benchmark | Passed | 48.5 o‘rtacha FPS, 536 draw call, 819 obyekt |
| Qo‘lda barcha 7 missiyani boshidan oxirigacha o‘ynash | Not Tested | avtomatik bosqich va yakun testlari bajarildi, to‘liq inson playtest hali kerak |
| Windows 10 qurilmasi | Not Tested | build Windows 11 noutbukda yaratildi |

FPS kafolat emas. Natija AMD Radeon Graphics qurilmasida bir xil avtomatik sahna bilan o‘lchandi.

## Ishga tushirish

Portable paketni ochib, `Toshkent_Sarguzashti_0.7.0.exe` faylini ishga tushiring. Repository ichida `OYINNI_BOSHLASH.cmd` ham yangi buildni ochadi.

## Halol cheklovlar

Quyidagilar bajarildi deb ko‘rsatilmaydi: professional skeletonli `GLB/GLTF` insonlar, mocap AnimationTree, yozib olingan o‘zbekcha ovozlar, to‘liq geografik Toshkent, barcha binolarning interyeri, lift, benzin stansiyasi, installer va code signing. Hozirgi vizual modellar original procedural low-poly geometriya bo‘lib, loyiha o‘ynaladigan vertical-slice darajasida.

## Keyingi bosqich

Eng katta sifat sakrashi qonuniy litsenziyaga ega rigged inson va transport modellarini import qilish, AnimationTree blending, hududlar bo‘yicha qo‘lda environment art hamda 7 missiyaning to‘liq inson playtestidan keladi.
