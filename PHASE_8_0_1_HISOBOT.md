# PHASE 8.0–8.1 hisoboti

## Qisqa natija

`Toshkent Sarguzashti 0.8.0` mavjud Godot loyihasi ustida davom ettirildi. Loyiha qayta yaratilgani yo‘q, Godot va GDScript arxitekturasi saqlandi. Eski `210 × 210` hudud sharq tomonga kengayib, umumiy mantiqiy o‘lcham `278 × 208` bo‘ldi. Uchta yangi chunk, beshta yangi landmark, uzluksiz yo‘llar, yangi navigation yo‘nalishlari, svetoforlar, piyodalar va trafik integratsiya qilindi. `0.8.1` hotfix barcha boshqariladigan transportlarni `140 km/soat` bilan chekladi va haydovchi siluetlarini salon ichiga tushirdi.

Mualliflik huquqi bilan himoyalangan GTA assetlari, Chevrolet logotiplari yoki tayyor Toshkent binolari ko‘chirilmadi. Yangi hududdagi obyektlar Godot ichida original procedural geometriya bilan qurildi.

## Checkpoint

- Boshlang‘ich commit: `69c01e6`
- Mahalliy checkpoint tag: `checkpoint-phase8-start-0.7.0-20261026`
- Checkpoint PHASE 8 kodi yozilishidan oldin yaratildi.
- Fayllar o‘chirilmadi.

## Texnik audit

| Qism | Aniqlangan holat |
|---|---|
| Dvigatel | Godot `4.7.2 stable` |
| Til | GDScript |
| Renderer | OpenGL 3.3 Compatibility |
| O‘yin turi | Haqiqiy 3D, third-person open-world prototip |
| Asosiy scene | `main.tscn` va `scripts/main.gd` |
| Ma’lumotlar | 7 ta JSON missiya va `schema_version: 4` save |
| Dunyo qurilishi | Procedural meshlar, chunk guruhlari, MultiMesh va masofaviy visibility |
| Platforma | Windows x86_64 portable build |

## 65 ta imkoniyat auditi

`O‘tdi` — kod va avtomatik test bilan tasdiqlandi. `Ko‘rildi` — real OpenGL tasvirida ko‘rildi. `Qisman` — asosiy tizim mavjud, ammo professional darajadagi barcha varianti yo‘q. `Qo‘lda sinov kerak` — avtomatik tekshiruv bor, lekin to‘liq inson gameplay sinovi bajarilmagan.

| № | Imkoniyat | Holat | Dalil |
|---:|---|---|---|
| 1 | Haqiqiy 3D ochiq dunyo | O‘tdi | `Node3D`, `CharacterBody3D`, kamera va 3D collision |
| 2 | Toshkentdan ilhomlangan original shahar | Ko‘rildi | OpenGL preview va procedural obyektlar |
| 3 | Eski 210 × 210 hudud | O‘tdi | Eski koordinatalar o‘zgarmadi |
| 4 | 9 ta eski chunk | O‘tdi | Streaming guruhida saqlandi |
| 5 | 13 ta eski landmark | O‘tdi | Self-test orqali |
| 6 | Doimiy tungi muhit | Ko‘rildi | Environment va preview |
| 7 | 5 ta ob-havo holati | O‘tdi | Weather system self-test |
| 8 | Nam asfalt | Ko‘rildi | Material va yomg‘ir preview’i |
| 9 | 3D personaj boshqaruvi | O‘tdi | Yurish, yugurish, sakrash va crouch kod yo‘li |
| 10 | Third-person kamera | O‘tdi | Yaw/pitch va SpringArm3D |
| 11 | Kamera collision | O‘tdi | SpringArm3D collision tekshiruvi |
| 12 | Jon tizimi | O‘tdi | HUD, zarar va save holati |
| 13 | Zirh tizimi | O‘tdi | Zarar hisoblash va save holati |
| 14 | Pul tizimi | O‘tdi | HUD, pickup, do‘kon va save |
| 15 | Inventar | O‘tdi | Ikki turdagi buyum va UI |
| 16 | Musht bilan jang | O‘tdi | Uch bosqichli zarba holati |
| 17 | Metall tayoq | Ko‘rildi | Kaftga ulangan 3D model |
| 18 | Elektroshoker | O‘tdi | Tanlash, model va zarar yo‘li |
| 19 | NPC zarbadan uloqtirilishi | O‘tdi | Kuchga mos impuls kodi |
| 20 | NPC pul tushirishi | O‘tdi | `money_pickup.gd` va self-test |
| 21 | 44 ta NPC | O‘tdi | Self-test sanog‘i |
| 22 | 7 ta NPC roli | O‘tdi | Rol profillari va self-test |
| 23 | NPC FSM | O‘tdi | Yurish, kutish, suhbat, qochish, zarba, halok |
| 24 | NPC suhbatlari | O‘tdi | `E` interaksiyasi va rolga mos o‘zbekcha matn |
| 25 | Turli NPC ko‘rinishlari | Ko‘rildi | Procedural tana, yuz va kiyim ranglari |
| 26 | 16 ta trafik avtomobili | O‘tdi | Self-test sanog‘i |
| 27 | 10 transport profili | O‘tdi | Alohida tezlik va boshqaruv parametrlari |
| 28 | Trafik avtomobilini egallash | O‘tdi | `E` orqali driver state almashadi |
| 29 | Transportga kirish | O‘tdi | Holat va kamera sinxronizatsiyasi |
| 30 | Transportdan xavfsiz chiqish | O‘tdi | Yer, qiyalik va kapsula tekshiruvi |
| 31 | 140 km/soat maksimal tezlik | O‘tdi | Vehicle va egallanadigan traffic konfiguratsiyasi |
| 32 | Gaz qo‘yilganda tabiiy sekinlashish | O‘tdi | `1.35 m/s²` qarshilik |
| 33 | Tez tormoz va qo‘l tormozi | O‘tdi | `S` va `Space` input yo‘li |
| 34 | Buzilmas boshqariladigan transport | O‘tdi | Damage bloklanadi |
| 35 | Salon ichida player health himoyasi | O‘tdi | Collision damage bloklanadi |
| 36 | Transport parvoziga qarshi barqarorlik | O‘tdi | Yo‘l balandligiga qaytarish |
| 37 | Avtomatik old tomonga qaytuvchi kamera | O‘tdi | Tezlikka mos heading alignment |
| 38 | 100 ta eski svetofor | O‘tdi | Eski obyektlar saqlandi |
| 39 | Svetoforda to‘xtaydigan trafik | O‘tdi | Cached sensing va holat tekshiruvi |
| 40 | 6 ta eski navigation marshruti | O‘tdi | Eski marshrutlar saqlandi |
| 41 | 6 ta do‘kon | O‘tdi | Turlari va interaksiya self-testda |
| 42 | Transport sotib olish | O‘tdi | Pul, ownership va save integratsiyasi |
| 43 | 3 ta interyer | O‘tdi | Bozor, servis, ofis |
| 44 | 7 ta JSON missiya | O‘tdi | Fayllar yuklanadi va validatsiya qilinadi |
| 45 | Missiya taymeri | O‘tdi | Progress state mavjud |
| 46 | Missiya muvaffaqiyatsizligi va retry | O‘tdi | Failure state va `R` |
| 47 | Missiya mukofotlari | O‘tdi | Data-driven reward |
| 48 | Barcha missiyalarni boshidan oxirigacha gameplay | Qo‘lda sinov kerak | Avtomatik state testi bor, to‘liq inson playthrough yo‘q |
| 49 | Mini-xarita | O‘tdi | Kengaygan koordinatalar bilan ishlaydi |
| 50 | To‘liq xarita | O‘tdi | Yangi hudud va yorliqlar qo‘shildi |
| 51 | LOW grafik rejimi | O‘tdi | Settings va render masofasi |
| 52 | MEDIUM grafik rejimi | O‘tdi | Settings va render masofasi |
| 53 | HIGH grafik rejimi | O‘tdi | Settings va render masofasi |
| 54 | 30/45/60/120 FPS limitlari | O‘tdi | Settings kodi va save |
| 55 | Resolution/fullscreen/VSync | O‘tdi | UI va save v4 |
| 56 | Ovoz sozlamalari | O‘tdi | UI va audio bus boshqaruvi |
| 57 | Shahar, qadam, motor, yomg‘ir va UI audio | O‘tdi | Procedural audio tizimi |
| 58 | O‘zbek localization | O‘tdi | Asosiy UI ishlaydi |
| 59 | Rus localization arxitekturasi | Qisman | Kalit tizimi bor, barcha matn tarjima qilinmagan |
| 60 | Ingliz localization arxitekturasi | Qisman | Kalit tizimi bor, barcha matn tarjima qilinmagan |
| 61 | Save/Load v4 | O‘tdi | Schema, yozish va qayta yuklash self-testda |
| 62 | Eski schema 1–3 migratsiyasi | O‘tdi | Migration kodi va sintetik eski save testi |
| 63 | Buzilgan save uchun backup recovery | O‘tdi | Tekshiruv va fallback kodi |
| 64 | `by JMJ gems` intro | Ko‘rildi | Real OpenGL menyu preview’i |
| 65 | Windows portable EXE | O‘tdi | 0.8.0 export va standalone self-test |

## PHASE 8.1 — Sharqiy xiyobon

Yangi kengaytma eski xaritaning sharqiy chetiga uzluksiz ulanadi:

- 3 ta yangi `70 × 70` chunk;
- umumiy dunyo chegarasi: `x = -104..174`, `z = -104..104`;
- 5 ta yangi landmark va qo‘shimcha piyoda ko‘prigi;
- sharqiy vertikal prospekt hamda eski gorizontal yo‘llarning davomlari;
- 3 ta yangi navigation marshruti, jami 9 ta;
- 20 ta yangi svetofor, jami 120 ta;
- kamida 6 ta NPC yangi hududda spawn bo‘ladi;
- trafikning yangi hududga yetib boradigan marshrutlari;
- mini-xarita va to‘liq xaritada yangi chegaralar hamda yozuvlar;
- save v4 player pozitsiyasi yangi sharqiy koordinatalarni qabul qiladi;
- `MultiMeshInstance3D` orqali deraza, yo‘l chizig‘i, daraxt, ustun va skameykalar;
- hudud qurilishi SceneTree xavfsizligi uchun uch kadrga bo‘lindi.

Yangi original obyektlar:

1. Sharq mehmonxonasi.
2. Texnologiya minorasi.
3. Biznes markazi.
4. Sharq savdo uyi.
5. Transport markazi.
6. Sharqiy piyoda ko‘prigi.
7. Yangi Toshkent tungi xiyoboni.

## Performance o‘lchovi

Bir xil kompyuter, Godot 4.7.2, OpenGL Compatibility, avtomatik kamera sahnasi va bir xil ichki benchmark usuli ishlatildi. FPS drayver, fon jarayonlari va shader warm-up sabab har ishga tushishda biroz farq qilishi mumkin.

| Ko‘rsatkich | PHASE 8 oldi baseline | PHASE 8 markaz | Yangi sharqiy hudud |
|---|---:|---:|---:|
| O‘rtacha FPS | 29.7 | 50.9 | 52.6 |
| Draw call | 537 | 443 | 151 |
| Render obyekt | 820 | 738 | 344 |
| Primitive | 57 894 | 46 212 | 14 508 |
| Physics | 6.39 ms | 5.88 ms | 5.26 ms |
| Process | 86.88 ms | 24.13 ms | 21.09 ms |

Oldingi hisobotdagi `48–59 FPS` qiymati tarixiy natija edi. Qayta audit baseline’i `29.7 FPS` chiqqani sabab, regressiya taqqoslashida aynan shu yangi o‘lchov ishlatildi. Natijada kengaytirilgan build baseline’dan pastlamadi.

## Eng ustuvor uch texnik muammo va yechim

### 1. Katta monolit `main.gd`

Muammo: dunyoning katta qismi bir faylda va ishga tushishda sinxron qurilgan.

Yechim: yangi hudud `phase8_east_district.gd` moduliga ajratildi va uch kadrda bosqichma-bosqich yaratiladi. Keyingi bosqichlarda eski tumanlarni ham alohida modullarga bo‘lish kerak.

### 2. Ko‘p alohida render obyektlari

Muammo: takroriy bezaklar alohida mesh bo‘lib, draw call va SceneTree yukini oshiradi.

Yechim: yangi hudud derazalari, yo‘l chiziqlari, daraxtlari, ustunlari va skameykalari MultiMesh orqali instans qilindi. Professional GLB modellar kelganda ham instancing saqlanishi kerak.

### 3. Har yangilanishda group qidiruvlari

Muammo: chunk, shahar chiroqlari va fara node’larini takroriy `get_nodes_in_group` bilan qidirish frame time’ni oshiradi.

Yechim: ro‘yxatlar keshlangan, yangi hudud tayyor bo‘lganda boshqariladigan tarzda yangilanadi.

## Save v4 mosligi

- `schema_version: 4` o‘zgartirilmadi.
- Eski save koordinatalari o‘z joyida qoladi.
- Eski schema 1–3 migration yo‘li saqlandi.
- Yangi xarita holati mavjud `unlocked_districts` strukturasiga mos.
- Player pozitsiyasi sharqda `x = 173` gacha saqlanadi.
- Sintetik eski save, yangi sharqiy pozitsiya va backup fallback avtomatik self-testdan o‘tdi.

## Sinovlar

| Sinov | Natija | Chegara |
|---|---|---|
| GDScript/source self-test | O‘tdi, `exit 0` | Integratsiya va sanog‘larni tekshiradi |
| Real OpenGL markaz benchmark | O‘tdi, 50.9 FPS | Bitta avtomatik kamera yo‘li |
| Real OpenGL Sharqiy xiyobon benchmark | O‘tdi, 52.6 FPS | Yangi hudud kamera nuqtasi |
| Yangi hudud screenshot | O‘tdi | Vizual smoke test |
| Windows 0.8.0 export | O‘tdi | Portable x86_64 |
| Export qilingan EXE self-test | O‘tdi, `exit 0` | To‘liq gameplay o‘rnini bosmaydi |
| 7 missiyani inson bilan to‘liq o‘ynash | Bajarilmadi | Alohida qo‘lda QA kerak |
| Windows 10 alohida kompyuter | Bajarilmadi | Joriy qurilma sinovi Windows muhitida |

## O‘zgargan fayllar

- `scripts/phase8_east_district.gd` — yangi modular hudud.
- `scripts/main.gd` — hudud integratsiyasi, kengaygan chegaralar, test va render keshlar.
- `scripts/navigation_graph.gd` — 3 ta yangi marshrut.
- `scripts/world_streamer.gd` — chunk keshi va refresh.
- `scripts/minimap.gd` — to‘rtburchak, kengaygan xarita.
- `scripts/full_map.gd` — yangi chegaralar va hudud yorliqlari.
- `scripts/player.gd` — sharqiy save pozitsiyasi.
- `project.godot` — versiya `0.8.0`.
- `export_presets.cfg` — Windows 0.8.0 build nomi.
- `OYINNI_BOSHLASH.cmd` — yangi buildni birinchi tanlash.
- `README.md`, `BUILD_INFO.md`, `CHECKSUMS.txt` — foydalanuvchi va release hujjatlari.
- `screenshots/preview_phase8.png` — real OpenGL vizual tekshiruv.

## Keyingi ustuvor roadmap

| Bosqich | Ustuvor ish | Qabul mezoni |
|---|---|---|
| 8.2 | Litsenziyasi tasdiqlangan modular GLB binolar, avtomobillar va humanoidlar | LOD0/LOD1/LOD2, collision va manba litsenziyasi |
| 8.3 | Skeleton, AnimationTree va blend-space | Idle/walk/run/crouch/jump/enter/exit silliq o‘tishi |
| 8.4 | NavigationAgent3D, masofaviy AI tick, pooling va yo‘l kesib o‘tish | NPC tiqilmasligi va trafik bilan xavfsiz ishlashi |
| 8.5 | Har transportga mass/grip/suspension va speed-steering profili | 10 tur amalda farqli boshqarilishi |
| 8.6 | PBR materiallar, yengil reflection, fog va sifat presetlari | LOW performance saqlanishi |
| 8.7 | 3 ta yangi to‘liq missiya va cutscene framework | Start/fail/retry/reward/save bilan playthrough |
| 8.8 | Bekat, skameyka, garaj, mission board va original ovoz yozuvlari | Localization va spatial audio |
| 8.9 | Godot profiler asosida CPU/GPU/VRAM QA | LOW 60 FPS maqsadiga yaqinlashish |
| 8.10 | To‘liq regressiya, Windows 10/11 smoke test, imzolangan installer | Release checklist to‘liq o‘tishi |

## Hozirgi halol cheklovlar

Bu versiya sifatli vertical-slice, lekin AAA yoki fotorealistik yakuniy o‘yin emas. Professional skeletal `GLB` personajlar, mocap animatsiyalar, haqiqiy yozib olingan ovozlar, liftlar, 30–50 missiya, barcha Toshkent tumanlari va code-signing sertifikati hali yo‘q. Bu elementlarni tayyor deb ko‘rsatish noto‘g‘ri bo‘ladi; ular yuqoridagi roadmap’da navbat bilan rejalashtirilgan.
