# TOSHKENT SARGUZASHTI — PHASE 0 VA PHASE 1 HISOBOTI

## Qisqa natija

Loyiha noldan yaratilmagan va grafik dvigatel almashtirilmagan. Mavjud Godot loyihasi tekshirildi, `0.4.4` holati `checkpoint-phase0-0.4.4-20261025` Git tegi bilan saqlandi va PHASE 1 tuzatishlari mavjud tizimlarga integratsiya qilindi. Yangi versiya: `0.5.0`.

## 1. Dasturlash tili

- Asosiy til: `GDScript`.
- Ma’lumot fayli: `JSON` (`data/mission_01.json`).
- Ishga tushirish yordamchisi: Windows Batch (`OYINNI_BOSHLASH.cmd`).
- `C#`, C++, JavaScript, `package.json`, `index.html` yoki `src/` papkasi mavjud emas.

## 2. Framework

- Framework va o‘yin muhiti: `Godot 4.7.2 stable`.
- Asosiy sahna: `main.tscn`.
- Asosiy boshqaruvchi: `scripts/main.gd`.
- Renderer: `OpenGL 3.3 Compatibility`.
- Maqsadli platforma: Windows 10/11 x86_64.

## 3. 3D dvigatel

Loyiha haqiqiy 3D. Asosiy sahna `Node3D`, o‘yinchi va avtomobillar `CharacterBody3D`, kamera `Camera3D` va `SpringArm3D`, obyektlar esa `MeshInstance3D`, `MultiMeshInstance3D`, `StaticBody3D` hamda 3D collision shakllaridan foydalanadi.

Hozirgi modellar tashqi professional `GLB/GLTF` assetlar emas. Ular Godot ichida `BoxMesh`, `SphereMesh`, `CapsuleMesh`, `CylinderMesh` va `TorusMesh` orqali procedural qurilgan. Shu sabab o‘yin 3D, ammo fotorealistik emas.

## 4. Fizika tizimi

- Player, asosiy avtomobil va trafik: `CharacterBody3D` asosidagi arcade fizika.
- To‘qnashuv qatlamlari: Dunyo, O‘yinchi, Transport va NPC.
- Tekshiruvlar: `move_and_slide`, ray query va shape query.
- Transport tezlanish, tormoz, orqaga yurish, rul, erkin sekinlashish va urilish zarariga ega.
- Trafik avtomobillari yo‘l sathiga majburiy barqarorlashtiriladi; bu havoda uchib ketishni cheklaydi.
- Haqiqiy `VehicleBody3D`, g‘ildirak raycasti, mustaqil suspension va shina ishqalanish modeli mavjud emas.

## 5. Mavjud o‘yin imkoniyatlari

| № | Imkoniyat | Holat | Dalil |
|---:|---|---|---|
| 1 | Toshkentdan ilhomlangan 3D ochiq dunyo | Passed | Procedural `Node3D` shahar va self-test |
| 2 | Doimiy tungi muhit | Passed | `tungi_muhit`, ko‘cha chiroqlari va avtomobil faralari |
| 3 | Katta xarita hududi | Passed | 210 × 210, 9 ta mantiqiy chunk |
| 4 | Ko‘rinmas chegaralar | Passed | 4 ta fizik chegara |
| 5 | Yurish, yugurish va o‘tirish | Passed | `player.gd` |
| 6 | Jang mexanikasi | Passed | Musht, tayoq va elektroshoker |
| 7 | Jon, pul va inventar | Passed | HUD, inventar va save/load |
| 8 | Do‘kon va xarid | Passed | 3 ta interaktiv do‘kon |
| 9 | Harakatlanuvchi odamlar | Passed | 44 ta piyoda NPC |
| 10 | Svetofor va ko‘cha obyektlari | Passed | 100 ta svetofor, 71 ta yo‘l cheti obyekti |
| 11 | Turli avtomobillar | Passed | 1 ta asosiy sedan va 16 ta rang/model varianti |
| 12 | NPC avtomobilini egallash | Passed | Trafik transportida `kirish/chiqish` API |
| 13 | Avtomobilga kirish va chiqish | Passed | `E`, eshik animatsiyasi va xavfsiz nuqta |
| 14 | Tez va buzilmaydigan asosiy avtomobil | Passed | 270 km/soat, `buzilmas=true` |
| 15 | Erkin sekinlashish | Passed | 1.35 m/s² coasting |
| 16 | Transport yo‘nalishiga mos kamera | Passed | Avtomatik oldinga qaytish |
| 17 | NPC urilish reaksiyasi | Passed | Orqaga va yuqoriga fizik zarba |
| 18 | Dunyo, NPC va transport collision | Passed | Collision layer/mask va self-test |
| 19 | Missiya mukofoti | Passed | 25 000 so‘m mukofotli 4 bosqich |
| 20 | `by JMJ gems` intro yozuvi | Passed | Asosiy menyu va self-test |
| 21 | Windows standalone | Passed | `0.5.0` EXE self-test exit 0 |
| 22 | Tizimlar o‘zaro ishlashi | Passed | Missiya, transport, inventar, HUD va save/load self-test |

## 6. PHASE 1 da tuzatilgan muammolar

1. O‘tirgan personaj bosh ustida to‘siq bo‘lsa ham tik holatga o‘tishi mumkin edi. Endi to‘liq kapsula bilan bo‘sh joy tekshiriladi.
2. Player notekis sathga mos `floor snap`, qiyalik chegarasi va xavfsiz collision margin oldi.
3. Piyoda kamera yaw va pitch harakati keskin emas, interpolation orqali silliqlanadi.
4. `SpringArm3D` endi dunyo bilan birga transport collision qatlamini ham ko‘radi. O‘yinchi boshqarayotgan avtomobil kamera tekshiruvidan alohida chiqariladi.
5. Asosiy va trafik avtomobillarida takrorlangan chiqish kodi `vehicle_exit_helper.gd` moduliga ajratildi.
6. Transportdan chiqish nuqtasi faqat bo‘shliq bilan emas, ostidagi yer, yer qiyaligi va to‘liq personaj kapsulasi bilan tekshiriladi.
7. Godot eksportidagi sandbox `Temp` muammosi aniqlanib, build vaqtida yoziladigan `TEMP/TMP` katalogi orqali buzilmagan EXE yaratildi.

## 7. Aniqlangan muammolar va yetishmayotgan qismlar

- `scripts/main.gd` taxminan 63 KB; world, UI, mission, save va build testi hali bitta katta faylda jamlangan.
- Haqiqiy world streaming yo‘q; mavjud 9 chunk mantiqiy guruh va visibility optimizatsiyasidir.
- To‘liq Toshkent geografiyasi va barcha so‘ralgan tumanlar hali yaratilmagan.
- Tashqi professional personaj animatsiyasi, skeleton, `AnimationTree` va motion capture yo‘q.
- Ob-havo, yomg‘ir, nam asfalt va dinamik tuman tizimi hali yo‘q.
- Audio va 3D spatial audio assetlari yo‘q.
- Bir dona 4 bosqichli missiya mavjud; uchta tugallangan mustaqil missiya hali yo‘q.
- Full-screen map, ko‘p ikonali mini-xarita, to‘liq graphics/settings menyusi va localization resurslari hali yo‘q.
- Traffic AI waypoint sikliga asoslangan; umumiy navigation graph, lane change va murakkab chorraha qarorlari yo‘q.
- Interyerlar, liftlar, garajlar va metro kirishlari hali to‘liq interaktiv emas.
- Avtomobillarda haqiqiy suspension va shina modeli yo‘q; hozirgi boshqaruv barqaror arcade usulida.

## 8. GTA Vice City uslubiga o‘tish rejasi

### Keyingi PHASE 2 — shaharni kengaytirish

1. `main.gd` ichidagi World, UI, Mission va Save qismlarini alohida modullarga xavfsiz ajratish.
2. Birinchi sifatli hudud sifatida markaziy Toshkent vertical slice yaratish.
3. Yo‘l va binolar uchun qayta ishlatiladigan `Resource` katalogi yaratish.
4. Masofaga asoslangan chunk activation, LOD va occlusion sinovini kiritish.
5. Litsenziyasi aniq original yoki ruxsat etilgan `GLB/GLTF` asset pipeline yaratish.

### PHASE 3 va undan keyin

- Navigation graph asosidagi piyoda va traffic AI.
- `AnimationTree` asosidagi personaj state machine.
- Uchta tugallangan original missiya.
- Ob-havo va tungi grafik presetlari.
- Audio, to‘liq settings, localization va full-screen map.
- Save schema migratsiyasi va release QA.

## 9. Tavsiya etilgan texnologiyalar

- Godot 4.7.2 ni saqlash: mavjud kod, sahna, save va eksport tizimiga mos.
- `NavigationServer3D` va `NavigationAgent3D`: NPC hamda piyoda yo‘li uchun.
- `AnimationTree` va state machine: professional animatsiya blending uchun.
- `Resource` va data-driven JSON: transport, do‘kon va missiya konfiguratsiyasi uchun.
- `MultiMesh`, visibility range, occlusion culling va object pooling: ishlash tezligi uchun.
- `AudioStreamPlayer3D`: shahar va transport spatial audio uchun.
- Blender + original/litsenziyali `GLB/GLTF`: keyingi sifatli 3D assetlar uchun.

Three.js, Unity yoki boshqa dvigatelga o‘tish tavsiya etilmaydi. Bunday almashtirish mavjud GDScript, sahna, save va Windows build tizimini asossiz qayta yozishga olib keladi.

## 10. Test natijalari

| Test | Natija |
|---|---|
| `0.4.4` bazaviy standalone self-test | Passed |
| `0.5.0` manba self-test | Passed |
| `0.5.0` Windows export | Passed |
| `0.5.0` standalone self-test | Passed, exit 0 |
| ZIP ichidan ochilgan `0.5.0` build self-test | Passed, exit 0 |
| `git diff --check` | Passed |
| Eski build, bir xil yashirin OpenGL benchmark | 15.1 FPS |
| Yangi build, bir xil yashirin OpenGL benchmark | 15.6 FPS |

Yashirin va fokusdan tashqari oynadagi FPS oddiy o‘yin oynasidagi maksimal natija emas. Ushbu taqqoslash faqat PHASE 1 o‘zgarishlari regressiya keltirmaganini tekshirish uchun ishlatildi.

## 11. O‘zgargan fayllar

- `scripts/player.gd`
- `scripts/vehicle.gd`
- `scripts/traffic_car.gd`
- `scripts/vehicle_exit_helper.gd` — yangi umumiy modul
- `scripts/main.gd` — yangi regressiya testlari
- `project.godot`
- `export_presets.cfg`
- `README.md`
- `BUILD_INFO.md`
- `CHECKSUMS.txt`
- `PHASE_0_1_HISOBOT.md`

## 12. O‘yinni ishga tushirish

Tayyor paket ichida:

```text
Toshkent_Sarguzashti.exe
```

Manba loyihada:

```powershell
Godot_v4.7.2-stable_win64_console.exe --path .
```

Avtomatik test:

```powershell
Godot_v4.7.2-stable_win64_console.exe --headless --path . -- --self-test
```
